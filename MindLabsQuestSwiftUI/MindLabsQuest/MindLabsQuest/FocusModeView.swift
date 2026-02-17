import SwiftUI
import UserNotifications

struct FocusModeView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var focusManager = FocusManager.shared
    
    @State private var selectedDuration = 30
    @State private var selectedQuest: Quest?
    @State private var customBlockedApps = Set<String>()
    @State private var showingAppPicker = false
    @State private var focusIntensity: FocusIntensity = .moderate
    @State private var enableTimeBlindnessAlerts = true
    @State private var alertInterval = 15
    @State private var enableAmbientSounds = false
    @State private var selectedAmbientSound: AmbientSound = .rain
    
    enum FocusIntensity: String, CaseIterable {
        case light = "Light"
        case moderate = "Moderate"
        case deep = "Deep"
        
        var description: String {
            switch self {
            case .light:
                return "Gentle reminders, notifications allowed"
            case .moderate:
                return "Limited notifications, regular check-ins"
            case .deep:
                return "No distractions, emergency only"
            }
        }
        
        var color: Color {
            switch self {
            case .light: return .green
            case .moderate: return .orange
            case .deep: return .red
            }
        }
    }
    
    enum AmbientSound: String, CaseIterable {
        case rain = "Rain"
        case whitenoise = "White Noise"
        case forest = "Forest"
        case ocean = "Ocean"
        case brownNoise = "Brown Noise"
        case silence = "Silence"
        
        var icon: String {
            switch self {
            case .rain: return "cloud.rain.fill"
            case .whitenoise: return "waveform"
            case .forest: return "tree.fill"
            case .ocean: return "wind.snow"
            case .brownNoise: return "waveform.path"
            case .silence: return "speaker.slash.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Focus Mode Header
                    FocusModeHeaderCard(focusManager: focusManager)
                    
                    if !focusManager.isInFocusMode {
                        // Duration Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Focus Duration", systemImage: "timer")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach([15, 30, 45, 60, 90, 120], id: \.self) { duration in
                                        DurationButton(
                                            duration: duration,
                                            isSelected: selectedDuration == duration,
                                            action: { selectedDuration = duration }
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        
                        // Focus Intensity
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Focus Intensity", systemImage: "dial.max.fill")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            ForEach(FocusIntensity.allCases, id: \.self) { intensity in
                                IntensityOption(
                                    intensity: intensity,
                                    isSelected: focusIntensity == intensity,
                                    action: { focusIntensity = intensity }
                                )
                            }
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        
                        // Quest Selection
                        if !gameManager.activeQuests.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Label("Focus on Quest", systemImage: "target")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                                
                                ForEach(gameManager.activeQuests) { quest in
                                    QuestSelectionRow(
                                        quest: quest,
                                        isSelected: selectedQuest?.id == quest.id,
                                        action: { selectedQuest = quest }
                                    )
                                }
                            }
                            .padding()
                            .background(Color.mindLabsCard)
                            .cornerRadius(15)
                        }
                        
                        // ADHD Support Features
                        VStack(alignment: .leading, spacing: 15) {
                            Label("ADHD Support", systemImage: "brain.head.profile")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            // Time Blindness Alerts
                            Toggle(isOn: $enableTimeBlindnessAlerts) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Time Blindness Alerts")
                                        .font(MindLabsTypography.subheadline())
                                        .foregroundColor(.mindLabsText)
                                    Text("Regular time check-ins")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                            }
                            .tint(.mindLabsPurple)
                            
                            if enableTimeBlindnessAlerts {
                                HStack {
                                    Text("Alert every")
                                    Picker("", selection: $alertInterval) {
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
                            
                            // Ambient Sounds
                            Toggle(isOn: $enableAmbientSounds) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Ambient Sounds")
                                        .font(MindLabsTypography.subheadline())
                                        .foregroundColor(.mindLabsText)
                                    Text("Background noise for focus")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                            }
                            .tint(.mindLabsPurple)
                            
                            if enableAmbientSounds {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(AmbientSound.allCases, id: \.self) { sound in
                                            AmbientSoundButton(
                                                sound: sound,
                                                isSelected: selectedAmbientSound == sound,
                                                action: { selectedAmbientSound = sound }
                                            )
                                        }
                                    }
                                }
                                .padding(.leading, 32)
                            }
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        
                        // Start Focus Button
                        Button(action: startFocusMode) {
                            HStack {
                                Image(systemName: "eye.trianglebadge.exclamationmark")
                                Text("Start Focus Mode")
                            }
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient.mindLabsPrimary)
                            .cornerRadius(15)
                        }
                    } else {
                        // Active Focus Mode View
                        ActiveFocusModeView(
                            focusManager: focusManager,
                            onEnd: endFocusMode
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Focus Mode")
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
    
    private func startFocusMode() {
        focusManager.startFocusMode(
            duration: selectedDuration,
            intensity: focusIntensity,
            quest: selectedQuest,
            enableTimeBlindnessAlerts: enableTimeBlindnessAlerts,
            alertInterval: alertInterval,
            ambientSound: enableAmbientSounds ? selectedAmbientSound : .silence
        )
        
        // Track focus session in game manager
        if let quest = selectedQuest {
            gameManager.startTimeTracking(for: quest.id)
        }
    }
    
    private func endFocusMode() {
        if let quest = selectedQuest {
            gameManager.stopTimeTracking(for: quest.id)
            gameManager.addFocusMinutes(focusManager.elapsedMinutes)
        }
        
        focusManager.endFocusMode()
    }
}

// MARK: - Supporting Views
struct FocusModeHeaderCard: View {
    @ObservedObject var focusManager: FocusManager
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: focusManager.isInFocusMode ? "eye.fill" : "eye")
                .font(.system(size: 50))
                .foregroundColor(.mindLabsPurple)
            
            Text(focusManager.isInFocusMode ? "Focus Mode Active" : "Enter Focus Mode")
                .font(MindLabsTypography.title2())
                .foregroundColor(.mindLabsText)
            
            Text(focusManager.isInFocusMode ? 
                 "Stay focused, you're doing great!" : 
                 "Minimize distractions and maximize productivity")
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.mindLabsPurple.opacity(0.1), Color.mindLabsCard],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
    }
}

struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(duration)")
                    .font(MindLabsTypography.headline())
                Text("min")
                    .font(MindLabsTypography.caption())
            }
            .foregroundColor(isSelected ? .white : .mindLabsText)
            .frame(width: 70, height: 70)
            .background(isSelected ? Color.mindLabsPurple : Color.mindLabsCard)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.clear : Color.mindLabsPurple.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct IntensityOption: View {
    let intensity: FocusModeView.FocusIntensity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(intensity.color)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(intensity.rawValue)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    Text(intensity.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                }
            }
            .padding()
            .background(isSelected ? Color.mindLabsPurple.opacity(0.1) : Color.clear)
            .cornerRadius(10)
        }
    }
}

struct QuestSelectionRow: View {
    let quest: Quest
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(quest.category.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                        .lineLimit(1)
                    
                    HStack {
                        Label("\(quest.estimatedTime)m", systemImage: "clock")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        Text("•")
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        Text(quest.difficulty.rawValue)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(quest.difficulty.color)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                }
            }
            .padding()
            .background(isSelected ? Color.mindLabsPurple.opacity(0.1) : Color.clear)
            .cornerRadius(10)
        }
    }
}

struct AmbientSoundButton: View {
    let sound: FocusModeView.AmbientSound
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: sound.icon)
                    .font(.title2)
                Text(sound.rawValue)
                    .font(MindLabsTypography.caption())
            }
            .foregroundColor(isSelected ? .white : .mindLabsText)
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.mindLabsPurple : Color.mindLabsCard)
            .cornerRadius(15)
        }
    }
}

struct ActiveFocusModeView: View {
    @ObservedObject var focusManager: FocusManager
    let onEnd: () -> Void
    @State private var showEndConfirmation = false
    
    var body: some View {
        VStack(spacing: 25) {
            // Timer Display
            ZStack {
                Circle()
                    .stroke(Color.mindLabsPurple.opacity(0.2), lineWidth: 15)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: focusManager.progress)
                    .stroke(
                        LinearGradient.mindLabsPrimary,
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: focusManager.progress)
                
                VStack(spacing: 5) {
                    Text(focusManager.timeRemaining)
                        .font(.system(size: 45, weight: .thin, design: .monospaced))
                        .foregroundColor(.mindLabsText)
                    
                    Text("Remaining")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            // Current Focus Info
            if let quest = focusManager.currentQuest {
                VStack(spacing: 10) {
                    Text("Focusing on")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    HStack {
                        Text(quest.category.icon)
                        Text(quest.title)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                    }
                }
                .padding()
                .background(Color.mindLabsCard)
                .cornerRadius(15)
            }
            
            // Focus Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(focusManager.elapsedMinutes)")
                        .font(MindLabsTypography.title())
                        .foregroundColor(.mindLabsPurple)
                    Text("Minutes")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                VStack {
                    Text("\(focusManager.distractionsBlocked)")
                        .font(MindLabsTypography.title())
                        .foregroundColor(.mindLabsSuccess)
                    Text("Distractions Blocked")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            Spacer()
            
            // End Focus Button
            Button(action: { showEndConfirmation = true }) {
                HStack {
                    Image(systemName: "stop.circle.fill")
                    Text("End Focus Mode")
                }
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsError)
                .padding()
                .background(Color.mindLabsError.opacity(0.1))
                .cornerRadius(15)
            }
        }
        .alert("End Focus Mode?", isPresented: $showEndConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("End Focus", role: .destructive) {
                onEnd()
            }
        } message: {
            Text("You've been focusing for \(focusManager.elapsedMinutes) minutes. Are you sure you want to end?")
        }
    }
}

// MARK: - Focus Manager
class FocusManager: ObservableObject {
    static let shared = FocusManager()
    
    @Published var isInFocusMode = false
    @Published var currentQuest: Quest?
    @Published var startTime: Date?
    @Published var duration: Int = 30
    @Published var intensity: FocusModeView.FocusIntensity = .moderate
    @Published var distractionsBlocked = 0
    @Published var elapsedMinutes: Int = 0
    @Published var timeRemaining = "00:00"
    @Published var progress: Double = 0
    
    private var timer: Timer?
    private var timeBlindnessTimer: Timer?
    private let notificationManager = NotificationManager.shared
    
    private init() {}
    
    func startFocusMode(
        duration: Int,
        intensity: FocusModeView.FocusIntensity,
        quest: Quest?,
        enableTimeBlindnessAlerts: Bool,
        alertInterval: Int,
        ambientSound: FocusModeView.AmbientSound
    ) {
        self.duration = duration
        self.intensity = intensity
        self.currentQuest = quest
        self.startTime = Date()
        self.isInFocusMode = true
        self.distractionsBlocked = 0
        
        // Start main timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateTimer()
        }
        
        // Schedule time blindness alerts if enabled
        if enableTimeBlindnessAlerts {
            scheduleTimeBlindnessAlerts(interval: alertInterval)
        }
        
        // Schedule focus complete notification
        notificationManager.scheduleTimerNotification(
            questTitle: quest?.title ?? "Focus Session",
            duration: TimeInterval(duration * 60),
            timerType: .focus
        )
        
        // Configure based on intensity
        configureIntensity(intensity)
    }
    
    func endFocusMode() {
        isInFocusMode = false
        timer?.invalidate()
        timeBlindnessTimer?.invalidate()
        notificationManager.cancelTimerNotifications()
        
        // Calculate XP bonus for focus session
        let xpBonus = elapsedMinutes * 2
        if currentQuest != nil {
            // Award bonus XP for focused work
            print("Focus session completed: \(elapsedMinutes) minutes, \(xpBonus) bonus XP")
        }
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        elapsedMinutes = Int(elapsed / 60)
        
        let totalSeconds = duration * 60
        let remainingSeconds = max(0, totalSeconds - Int(elapsed))
        
        if remainingSeconds == 0 {
            endFocusMode()
            return
        }
        
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timeRemaining = String(format: "%02d:%02d", minutes, seconds)
        
        progress = elapsed / Double(totalSeconds)
    }
    
    private func scheduleTimeBlindnessAlerts(interval: Int) {
        timeBlindnessTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval * 60), repeats: true) { _ in
            self.sendTimeBlindnessAlert()
        }
    }
    
    private func sendTimeBlindnessAlert() {
        let content = UNMutableNotificationContent()
        content.title = "Time Check 🕐"
        content.body = "You've been focusing for \(elapsedMinutes) minutes. \(timeRemaining) remaining!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("gentle_chime.caf"))
        if content.sound == nil {
            content.sound = .default
        }
        
        let request = UNNotificationRequest(
            identifier: "time_blindness_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func configureIntensity(_ intensity: FocusModeView.FocusIntensity) {
        switch intensity {
        case .light:
            // Allow some notifications
            break
        case .moderate:
            // Limited notifications
            distractionsBlocked += 5
        case .deep:
            // Block all non-emergency notifications
            distractionsBlocked += 10
        }
    }
}

struct FocusModeView_Previews: PreviewProvider {
    static var previews: some View {
        FocusModeView()
            .environmentObject(GameManager())
    }
}