import SwiftUI
import AuthenticationServices

struct GoogleCalendarSyncView: View {
    @StateObject private var googleManager = GoogleCalendarManager.shared
    @StateObject private var calendarManager = CalendarManager.shared
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedGoogleCalendarId: String?
    @State private var autoConvertToQuests = false
    @State private var syncPastDays = 7
    @State private var syncFutureDays = 30
    @State private var showingSyncConfirmation = false
    @State private var syncProgress: Double = 0
    @State private var syncedEventCount = 0
    
    var body: some View {
        NavigationView {
            if googleManager.isAuthenticated {
                // Authenticated View
                Form {
                    Section("Google Account") {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                                .foregroundColor(.mindLabsPurple)
                            
                            VStack(alignment: .leading) {
                                Text("Connected")
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsSuccess)
                                Text("Sync your Google Calendar events")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            
                            Spacer()
                            
                            Button("Sign Out") {
                                googleManager.signOut()
                            }
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsError)
                        }
                    }
                    .listRowBackground(Color.mindLabsCard)
                    
                    Section("Select Calendar") {
                        if googleManager.calendars.isEmpty {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Loading calendars...")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            .padding(.vertical, 8)
                        } else {
                            ForEach(googleManager.calendars) { calendar in
                                HStack {
                                    Circle()
                                        .fill(Color.fromGoogleHex(calendar.backgroundColor ?? "#4285F4"))
                                        .frame(width: 16, height: 16)
                                    
                                    VStack(alignment: .leading) {
                                        Text(calendar.summary)
                                            .font(MindLabsTypography.body())
                                            .foregroundColor(.mindLabsText)
                                        if calendar.primary == true {
                                            Text("Primary")
                                                .font(MindLabsTypography.caption2())
                                                .foregroundColor(.mindLabsPurple)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedGoogleCalendarId == calendar.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.mindLabsPurple)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedGoogleCalendarId = calendar.id
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.mindLabsCard)
                    
                    Section("Sync Options") {
                        Toggle("Auto-convert to Quests", isOn: $autoConvertToQuests)
                            .tint(.mindLabsPurple)
                        
                        HStack {
                            Text("Sync Past Days")
                            Spacer()
                            Picker("", selection: $syncPastDays) {
                                Text("7 days").tag(7)
                                Text("14 days").tag(14)
                                Text("30 days").tag(30)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(.mindLabsPurple)
                        }
                        
                        HStack {
                            Text("Sync Future Days")
                            Spacer()
                            Picker("", selection: $syncFutureDays) {
                                Text("7 days").tag(7)
                                Text("14 days").tag(14)
                                Text("30 days").tag(30)
                                Text("60 days").tag(60)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(.mindLabsPurple)
                        }
                    }
                    .listRowBackground(Color.mindLabsCard)
                    
                    Section {
                        Button(action: {
                            showingSyncConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Sync Now")
                                Spacer()
                                if googleManager.isSyncing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                }
                            }
                            .foregroundColor(selectedGoogleCalendarId != nil ? .mindLabsPurple : .mindLabsTextSecondary)
                        }
                        .disabled(selectedGoogleCalendarId == nil || googleManager.isSyncing)
                    }
                    .listRowBackground(Color.mindLabsCard)
                }
                .background(Color.mindLabsBackground)
                
                if googleManager.isSyncing {
                    // Sync Progress View
                    VStack(spacing: 20) {
                        ProgressView(value: syncProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .mindLabsPurple))
                            .padding(.horizontal)
                        
                        Text("Syncing \(syncedEventCount) events...")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding()
                    .background(Color.mindLabsCard)
                    .cornerRadius(15)
                    .padding()
                }
            } else {
                // Sign In View
                GoogleSignInView()
            }
        }
        .navigationTitle("Google Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .mindLabsBackground()
        .navigationBarItems(
            trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.mindLabsPurple)
        )
        .alert("Sync Google Calendar?", isPresented: $showingSyncConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sync") {
                performSync()
            }
        } message: {
            Text("This will import events from your selected Google Calendar. Events can be converted to quests for XP and rewards.")
        }
        .alert("Sync Error", isPresented: .constant(googleManager.authError != nil)) {
            Button("OK") {
                googleManager.authError = nil
            }
        } message: {
            Text(googleManager.authError ?? "An error occurred")
        }
    }
    
    private func performSync() {
        guard let calendarId = selectedGoogleCalendarId else { return }
        
        syncProgress = 0
        syncedEventCount = 0
        
        let startDate = Calendar.current.date(byAdding: .day, value: -syncPastDays, to: Date()) ?? Date()
        let endDate = Calendar.current.date(byAdding: .day, value: syncFutureDays, to: Date()) ?? Date()
        
        googleManager.syncGoogleCalendarEvents(
            calendarId: calendarId,
            startDate: startDate,
            endDate: endDate
        ) { events in
            syncedEventCount = events.count
            
            if autoConvertToQuests {
                // Convert events to quests
                for (index, event) in events.enumerated() {
                    let quest = calendarManager.createQuestFromEvent(event)
                    gameManager.addQuest(quest)
                    
                    // Update progress
                    syncProgress = Double(index + 1) / Double(events.count)
                }
            }
            
            // Save events to local storage
            if let existingData = UserDefaults.standard.data(forKey: "calendarEvents"),
               var existingEvents = try? JSONDecoder().decode([CalendarEvent].self, from: existingData) {
                // Merge with existing events
                for event in events {
                    if !existingEvents.contains(where: { $0.calendarIdentifier == event.calendarIdentifier }) {
                        existingEvents.append(event)
                    }
                }
                
                if let encoded = try? JSONEncoder().encode(existingEvents) {
                    UserDefaults.standard.set(encoded, forKey: "calendarEvents")
                }
            } else {
                if let encoded = try? JSONEncoder().encode(events) {
                    UserDefaults.standard.set(encoded, forKey: "calendarEvents")
                }
            }
            
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct GoogleSignInView: View {
    @StateObject private var googleManager = GoogleCalendarManager.shared
    @State private var authContext = AuthenticationContext()
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "calendar")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .overlay(
                    Text("G")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.blue)
                        .offset(x: 25, y: -25)
                )
            
            VStack(spacing: 15) {
                Text("Connect Google Calendar")
                    .font(MindLabsTypography.title())
                    .foregroundColor(.mindLabsText)
                
                Text("Sync your Google Calendar events to manage academic deadlines and convert them into quests.")
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                GoogleBenefit(
                    icon: "🌐",
                    title: "Cross-Platform Sync",
                    description: "Access your events from any device"
                )
                
                GoogleBenefit(
                    icon: "🔄",
                    title: "Automatic Updates",
                    description: "Changes sync in real-time"
                )
                
                GoogleBenefit(
                    icon: "🎯",
                    title: "Smart Conversion",
                    description: "Events become gamified quests"
                )
            }
            .padding()
            .background(Color.mindLabsCard)
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                googleManager.authenticate(presentationContext: authContext)
            }) {
                HStack {
                    Image(systemName: "globe")
                    Text("Sign in with Google")
                }
                .font(MindLabsTypography.headline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
            }
            .padding(.horizontal)
            
            Text("Your data is secure and only used for calendar sync")
                .font(MindLabsTypography.caption2())
                .foregroundColor(.mindLabsTextSecondary)
                .padding(.bottom)
        }
    }
}

struct GoogleBenefit: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MindLabsTypography.subheadline())
                    .foregroundColor(.mindLabsText)
                
                Text(description)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Authentication Context
class AuthenticationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Color Extension for Google Calendar
extension Color {
    static func fromGoogleHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GoogleCalendarSyncView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleCalendarSyncView()
            .environmentObject(GameManager())
    }
}