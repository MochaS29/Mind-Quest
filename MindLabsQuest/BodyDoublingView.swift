import SwiftUI
import AVFoundation

struct BodyDoublingView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var bodyDoublingManager = BodyDoublingManager()
    
    @State private var selectedCompanion: VirtualCompanion = .alex
    @State private var selectedActivity: ActivityType = .studying
    @State private var sessionDuration = 30
    @State private var enableAmbientSounds = true
    @State private var enableCheckIns = true
    @State private var checkInInterval = 15
    @State private var isSessionActive = false
    
    enum VirtualCompanion: String, CaseIterable {
        case alex = "Alex"
        case sam = "Sam"
        case jordan = "Jordan"
        case casey = "Casey"
        
        var avatar: String {
            switch self {
            case .alex: return "🧑‍💻"
            case .sam: return "👩‍🎨"
            case .jordan: return "🧑‍🔬"
            case .casey: return "👨‍📚"
            }
        }
        
        var description: String {
            switch self {
            case .alex: return "Software developer working on a project"
            case .sam: return "Artist creating digital illustrations"
            case .jordan: return "Researcher analyzing data"
            case .casey: return "Student preparing for exams"
            }
        }
        
        var workStyle: String {
            switch self {
            case .alex: return "Focused coding sessions with regular breaks"
            case .sam: return "Creative flow with ambient music"
            case .jordan: return "Methodical work with note-taking"
            case .casey: return "Intensive study with flashcards"
            }
        }
    }
    
    enum ActivityType: String, CaseIterable {
        case studying = "Studying"
        case working = "Working"
        case reading = "Reading"
        case writing = "Writing"
        case creating = "Creating"
        
        var icon: String {
            switch self {
            case .studying: return "book.fill"
            case .working: return "laptopcomputer"
            case .reading: return "book"
            case .writing: return "pencil"
            case .creating: return "paintbrush.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    BodyDoublingHeaderCard()
                    
                    if !isSessionActive {
                        // Companion Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Choose Your Study Buddy", systemImage: "person.2.fill")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            ForEach(VirtualCompanion.allCases, id: \.self) { companion in
                                CompanionCard(
                                    companion: companion,
                                    isSelected: selectedCompanion == companion,
                                    action: { selectedCompanion = companion }
                                )
                            }
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        
                        // Activity Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Label("What are you working on?", systemImage: "list.bullet")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(ActivityType.allCases, id: \.self) { activity in
                                        ActivityButton(
                                            activity: activity,
                                            isSelected: selectedActivity == activity,
                                            action: { selectedActivity = activity }
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        
                        // Session Settings
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Session Settings", systemImage: "gearshape.fill")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            // Duration
                            HStack {
                                Text("Duration")
                                Spacer()
                                Picker("", selection: $sessionDuration) {
                                    Text("15 min").tag(15)
                                    Text("30 min").tag(30)
                                    Text("45 min").tag(45)
                                    Text("60 min").tag(60)
                                    Text("90 min").tag(90)
                                }
                                .pickerStyle(MenuPickerStyle())
                                .tint(.mindLabsPurple)
                            }
                            
                            // Ambient Sounds
                            Toggle(isOn: $enableAmbientSounds) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Ambient Sounds")
                                    Text("Background noise from your buddy")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                            }
                            .tint(.mindLabsPurple)
                            
                            // Check-ins
                            Toggle(isOn: $enableCheckIns) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Virtual Check-ins")
                                    Text("Periodic encouragement messages")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                            }
                            .tint(.mindLabsPurple)
                            
                            if enableCheckIns {
                                HStack {
                                    Text("Check-in every")
                                    Picker("", selection: $checkInInterval) {
                                        Text("10 min").tag(10)
                                        Text("15 min").tag(15)
                                        Text("20 min").tag(20)
                                        Text("30 min").tag(30)
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .tint(.mindLabsPurple)
                                }
                                .padding(.leading, 32)
                            }
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        
                        // Start Button
                        Button(action: startSession) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("Start Body Doubling Session")
                            }
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient.mindLabsPrimary)
                            .cornerRadius(15)
                        }
                    } else {
                        // Active Session View
                        ActiveBodyDoublingView(
                            manager: bodyDoublingManager,
                            companion: selectedCompanion,
                            activity: selectedActivity,
                            onEnd: endSession
                        )
                    }
                    
                    // Benefits Info
                    if !isSessionActive {
                        BodyDoublingBenefitsCard()
                    }
                }
                .padding()
            }
            .navigationTitle("Body Doubling")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
        }
    }
    
    private func startSession() {
        isSessionActive = true
        bodyDoublingManager.startSession(
            companion: selectedCompanion,
            activity: selectedActivity,
            duration: sessionDuration,
            enableAmbientSounds: enableAmbientSounds,
            enableCheckIns: enableCheckIns,
            checkInInterval: checkInInterval
        )
        
        // Track in game manager
        gameManager.addFocusMinutes(0) // Will be updated when session ends
    }
    
    private func endSession() {
        isSessionActive = false
        let focusMinutes = bodyDoublingManager.sessionMinutes
        gameManager.addFocusMinutes(focusMinutes)
        
        // Award bonus XP for body doubling
        gameManager.character.xp += focusMinutes
        
        bodyDoublingManager.endSession()
    }
}

// MARK: - Supporting Views
struct BodyDoublingHeaderCard: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: -10) {
                Text("🧑‍💻")
                    .font(.system(size: 50))
                Text("👩‍🎨")
                    .font(.system(size: 50))
            }
            
            Text("Virtual Body Doubling")
                .font(MindLabsTypography.title2())
                .foregroundColor(.mindLabsText)
            
            Text("Work alongside a virtual companion to stay focused and motivated")
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.mindLabsCard],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
    }
}

struct CompanionCard: View {
    let companion: BodyDoublingView.VirtualCompanion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(companion.avatar)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(companion.rawValue)
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Text(companion.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Text(companion.workStyle)
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsPurple)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Color.mindLabsPurple.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
    }
}

struct ActivityButton: View {
    let activity: BodyDoublingView.ActivityType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: activity.icon)
                    .font(.title2)
                Text(activity.rawValue)
                    .font(MindLabsTypography.caption())
            }
            .foregroundColor(isSelected ? .white : .mindLabsText)
            .frame(width: 90, height: 90)
            .background(isSelected ? Color.mindLabsPurple : Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct ActiveBodyDoublingView: View {
    @ObservedObject var manager: BodyDoublingManager
    let companion: BodyDoublingView.VirtualCompanion
    let activity: BodyDoublingView.ActivityType
    let onEnd: () -> Void
    
    @State private var showEndConfirmation = false
    @State private var companionMessage = ""
    @State private var showMessage = false
    
    var body: some View {
        VStack(spacing: 25) {
            // Companion Status
            VStack(spacing: 15) {
                Text(companion.avatar)
                    .font(.system(size: 80))
                
                Text("\(companion.rawValue) is \(activity.rawValue.lowercased()) with you")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                // Status indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text(manager.companionStatus)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            .padding()
            .background(Color.mindLabsCard)
            .cornerRadius(15)
            
            // Session Timer
            VStack(spacing: 10) {
                Text(manager.timeElapsed)
                    .font(.system(size: 48, weight: .thin, design: .monospaced))
                    .foregroundColor(.mindLabsText)
                
                Text("of \(manager.totalDuration) minutes")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
                
                ProgressView(value: manager.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .mindLabsPurple))
                    .frame(height: 8)
            }
            
            // Companion Message
            if showMessage {
                CompanionMessageBubble(message: companionMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Session Stats
            HStack(spacing: 40) {
                VStack {
                    Text("\(manager.sessionMinutes)")
                        .font(MindLabsTypography.title())
                        .foregroundColor(.mindLabsPurple)
                    Text("Minutes")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                VStack {
                    Text("\(manager.checkInsReceived)")
                        .font(MindLabsTypography.title())
                        .foregroundColor(.mindLabsSuccess)
                    Text("Check-ins")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            .padding()
            .background(Color.mindLabsCard)
            .cornerRadius(15)
            
            Spacer()
            
            // End Session Button
            Button(action: { showEndConfirmation = true }) {
                HStack {
                    Image(systemName: "stop.circle.fill")
                    Text("End Session")
                }
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsError)
                .padding()
                .background(Color.mindLabsError.opacity(0.1))
                .cornerRadius(15)
            }
        }
        .onReceive(manager.$latestCheckIn) { checkIn in
            if let message = checkIn {
                companionMessage = message
                withAnimation {
                    showMessage = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        showMessage = false
                    }
                }
            }
        }
        .alert("End Session?", isPresented: $showEndConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("End Session", role: .destructive) {
                onEnd()
            }
        } message: {
            Text("You've been working for \(manager.sessionMinutes) minutes with \(companion.rawValue)")
        }
    }
}

struct CompanionMessageBubble: View {
    let message: String
    
    var body: some View {
        HStack {
            Text(message)
                .font(MindLabsTypography.body())
                .foregroundColor(.white)
                .padding()
                .background(Color.mindLabsPurple)
                .cornerRadius(20)
                .shadow(radius: 5)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct BodyDoublingBenefitsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Benefits of Body Doubling", systemImage: "info.circle.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(
                    icon: "brain",
                    title: "Increased Focus",
                    description: "Presence of others helps maintain attention"
                )
                
                BenefitRow(
                    icon: "person.2",
                    title: "Social Accountability",
                    description: "Feel motivated by working alongside someone"
                )
                
                BenefitRow(
                    icon: "clock",
                    title: "Better Time Management",
                    description: "Structured sessions improve productivity"
                )
                
                BenefitRow(
                    icon: "sparkles",
                    title: "Reduced Procrastination",
                    description: "Start tasks more easily with a companion"
                )
            }
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
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
        }
    }
}

// MARK: - Body Doubling Manager
class BodyDoublingManager: ObservableObject {
    @Published var isSessionActive = false
    @Published var timeElapsed = "00:00"
    @Published var sessionMinutes = 0
    @Published var progress: Double = 0
    @Published var companionStatus = "Getting ready..."
    @Published var checkInsReceived = 0
    @Published var latestCheckIn: String?
    
    var totalDuration = 30
    private var timer: Timer?
    private var checkInTimer: Timer?
    private var startTime: Date?
    private var companion: BodyDoublingView.VirtualCompanion = .alex
    
    private let statusMessages = [
        "Working diligently",
        "Taking notes",
        "Deep in focus",
        "Making progress",
        "Staying on task",
        "In the zone"
    ]
    
    private let checkInMessages = [
        "Keep up the great work! 💪",
        "You're doing amazing! 🌟",
        "Stay focused, you've got this! 🎯",
        "Making excellent progress! 📈",
        "Your dedication is inspiring! ✨",
        "Almost there, keep going! 🚀"
    ]
    
    func startSession(
        companion: BodyDoublingView.VirtualCompanion,
        activity: BodyDoublingView.ActivityType,
        duration: Int,
        enableAmbientSounds: Bool,
        enableCheckIns: Bool,
        checkInInterval: Int
    ) {
        self.companion = companion
        self.totalDuration = duration
        self.startTime = Date()
        self.isSessionActive = true
        
        // Start main timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateTimer()
        }
        
        // Start check-in timer if enabled
        if enableCheckIns {
            checkInTimer = Timer.scheduledTimer(
                withTimeInterval: TimeInterval(checkInInterval * 60),
                repeats: true
            ) { _ in
                self.sendCheckIn()
            }
        }
        
        // Update companion status
        updateCompanionStatus()
    }
    
    func endSession() {
        timer?.invalidate()
        checkInTimer?.invalidate()
        isSessionActive = false
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        sessionMinutes = Int(elapsed / 60)
        
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        timeElapsed = String(format: "%02d:%02d", minutes, seconds)
        
        progress = min(elapsed / (Double(totalDuration) * 60), 1.0)
        
        // Update companion status periodically
        if Int(elapsed) % 120 == 0 {
            updateCompanionStatus()
        }
        
        // End session if time is up
        if progress >= 1.0 {
            endSession()
        }
    }
    
    private func updateCompanionStatus() {
        companionStatus = statusMessages.randomElement() ?? "Working"
    }
    
    private func sendCheckIn() {
        checkInsReceived += 1
        latestCheckIn = checkInMessages.randomElement()
        
        // Send notification if app is in background
        let content = UNMutableNotificationContent()
        content.title = "\(companion.rawValue) says:"
        content.body = latestCheckIn ?? "Keep going!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("gentle_notification.caf"))
        if content.sound == nil {
            content.sound = .default
        }
        
        let request = UNNotificationRequest(
            identifier: "body_doubling_checkin_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct BodyDoublingView_Previews: PreviewProvider {
    static var previews: some View {
        BodyDoublingView()
            .environmentObject(GameManager())
    }
}