import SwiftUI
import EventKit

struct CalendarSyncView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var calendarManager = CalendarManager.shared
    @EnvironmentObject var gameManager: GameManager
    
    @State private var showingSyncConfirmation = false
    @State private var syncProgress: Double = 0
    @State private var isSyncing = false
    @State private var syncedEvents: [CalendarEvent] = []
    @State private var selectedSyncOption: SyncOption = .ios
    @State private var showingGoogleSync = false
    
    enum SyncOption: String, CaseIterable {
        case ios = "iOS Calendar"
        case google = "Google Calendar"
        
        var icon: String {
            switch self {
            case .ios: return "applelogo"
            case .google: return "globe"
            }
        }
        
        var color: Color {
            switch self {
            case .ios: return .black
            case .google: return .blue
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sync Option Selector
                Picker("Sync Option", selection: $selectedSyncOption) {
                    ForEach(SyncOption.allCases, id: \.self) { option in
                        Label {
                            Text(option.rawValue)
                        } icon: {
                            Image(systemName: option.icon)
                        }
                        .tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.mindLabsCard)
                
                if selectedSyncOption == .google {
                    // Google Calendar Sync
                    GoogleCalendarSyncContent()
                } else if calendarManager.authorizationStatus == .notDetermined {
                    // Permission Request View
                    PermissionRequestView()
                } else if calendarManager.authorizationStatus == .denied {
                    // Permission Denied View
                    PermissionDeniedView()
                } else {
                    // iOS Calendar Sync Settings View
                    Form {
                        Section {
                            Toggle("Enable Calendar Sync", isOn: $calendarManager.syncSettings.isEnabled)
                                .tint(.mindLabsPurple)
                                .onChange(of: calendarManager.syncSettings.isEnabled) { _ in
                                    calendarManager.saveSyncSettings()
                                }
                            
                            if calendarManager.syncSettings.isEnabled {
                                Text("Automatically sync events from your iOS Calendar")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        .listRowBackground(Color.mindLabsCard)
                        
                        if calendarManager.syncSettings.isEnabled {
                            Section("Select Calendar") {
                                ForEach(calendarManager.calendars, id: \.calendarIdentifier) { calendar in
                                    HStack {
                                        Circle()
                                            .fill(Color(cgColor: calendar.cgColor))
                                            .frame(width: 16, height: 16)
                                        
                                        Text(calendar.title)
                                            .font(MindLabsTypography.body())
                                            .foregroundColor(.mindLabsText)
                                        
                                        Spacer()
                                        
                                        if calendarManager.syncSettings.selectedCalendarIdentifier == calendar.calendarIdentifier {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.mindLabsPurple)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        calendarManager.syncSettings.selectedCalendarIdentifier = calendar.calendarIdentifier
                                        calendarManager.saveSyncSettings()
                                    }
                                }
                            }
                            .listRowBackground(Color.mindLabsCard)
                            
                            Section("Sync Options") {
                                Toggle("Auto-convert to Quests", isOn: $calendarManager.syncSettings.autoConvertToQuests)
                                    .tint(.mindLabsPurple)
                                
                                HStack {
                                    Text("Sync Past Days")
                                    Spacer()
                                    Picker("", selection: $calendarManager.syncSettings.syncPastDays) {
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
                                    Picker("", selection: $calendarManager.syncSettings.syncFutureDays) {
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
                            .onChange(of: calendarManager.syncSettings.autoConvertToQuests) { _ in
                                calendarManager.saveSyncSettings()
                            }
                            .onChange(of: calendarManager.syncSettings.syncPastDays) { _ in
                                calendarManager.saveSyncSettings()
                            }
                            .onChange(of: calendarManager.syncSettings.syncFutureDays) { _ in
                                calendarManager.saveSyncSettings()
                            }
                            
                            Section {
                                Button(action: {
                                    showingSyncConfirmation = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Sync Now")
                                        Spacer()
                                        if isSyncing {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                                .scaleEffect(0.8)
                                        }
                                    }
                                    .foregroundColor(calendarManager.syncSettings.selectedCalendarIdentifier != nil ? .mindLabsPurple : .mindLabsTextSecondary)
                                }
                                .disabled(calendarManager.syncSettings.selectedCalendarIdentifier == nil || isSyncing)
                            }
                            .listRowBackground(Color.mindLabsCard)
                        }
                    }
                    .background(Color.mindLabsBackground)
                    
                    if isSyncing {
                        // Sync Progress View
                        VStack(spacing: 20) {
                            ProgressView(value: syncProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .mindLabsPurple))
                                .padding(.horizontal)
                            
                            Text("Syncing events...")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        .padding()
                    }
                }
            }
            .navigationTitle("Calendar Sync")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
            .alert("Sync Calendar Events?", isPresented: $showingSyncConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sync") {
                    performSync()
                }
            } message: {
                Text("This will import events from your selected calendar. Events can be converted to quests for XP and rewards.")
            }
        }
    }
    
    private func performSync() {
        isSyncing = true
        syncProgress = 0
        
        calendarManager.syncEventsFromCalendar { events in
            DispatchQueue.main.async {
                syncedEvents = events
                
                if calendarManager.syncSettings.autoConvertToQuests {
                    // Auto-convert events to quests
                    for (index, event) in events.enumerated() {
                        let quest = calendarManager.createQuestFromEvent(event)
                        gameManager.addQuest(quest)
                        
                        // Update progress
                        syncProgress = Double(index + 1) / Double(events.count)
                    }
                }
                
                // Save synced events to local storage
                if let existingData = UserDefaults.standard.data(forKey: "calendarEvents"),
                   var existingEvents = try? JSONDecoder().decode([CalendarEvent].self, from: existingData) {
                    // Merge with existing events, avoiding duplicates
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
                
                isSyncing = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct PermissionRequestView: View {
    @StateObject private var calendarManager = CalendarManager.shared
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.mindLabsPurple)
            
            VStack(spacing: 15) {
                Text("Calendar Access")
                    .font(MindLabsTypography.title())
                    .foregroundColor(.mindLabsText)
                
                Text("Mind Labs Quest can sync with your iOS Calendar to help you manage academic events and deadlines.")
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                PermissionBenefit(
                    icon: "calendar.badge.checkmark",
                    title: "Import Events",
                    description: "Automatically import classes, exams, and assignments"
                )
                
                PermissionBenefit(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Convert to Quests",
                    description: "Transform calendar events into gamified quests"
                )
                
                PermissionBenefit(
                    icon: "bell.badge",
                    title: "Smart Reminders",
                    description: "Get notified with ADHD-friendly reminders"
                )
            }
            .padding()
            .background(Color.mindLabsCard)
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                calendarManager.requestCalendarAccess { _ in }
            }) {
                Text("Enable Calendar Access")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient.mindLabsPrimary)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Skip for now
            }) {
                Text("Maybe Later")
                    .font(MindLabsTypography.subheadline())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .padding(.bottom)
        }
    }
}

struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.mindLabsError)
            
            VStack(spacing: 15) {
                Text("Calendar Access Denied")
                    .font(MindLabsTypography.title())
                    .foregroundColor(.mindLabsText)
                
                Text("To sync calendar events, please enable access in Settings.")
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient.mindLabsPrimary)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

struct PermissionBenefit: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.mindLabsPurple)
                .frame(width: 30)
            
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

// MARK: - Google Calendar Sync Content
struct GoogleCalendarSyncContent: View {
    @StateObject private var googleManager = GoogleCalendarManager.shared
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        if googleManager.isAuthenticated {
            GoogleCalendarSyncView()
                .environmentObject(gameManager)
        } else {
            GoogleSignInPromptView()
        }
    }
}

struct GoogleSignInPromptView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Connect Google Calendar")
                .font(MindLabsTypography.title2())
                .foregroundColor(.mindLabsText)
            
            Text("Sign in to sync your Google Calendar events")
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            NavigationLink(destination: GoogleCalendarSyncView()) {
                HStack {
                    Image(systemName: "globe")
                    Text("Connect Google Calendar")
                }
                .font(MindLabsTypography.headline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct CalendarSyncView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSyncView()
            .environmentObject(GameManager())
    }
}