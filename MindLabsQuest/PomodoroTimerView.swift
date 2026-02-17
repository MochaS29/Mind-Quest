import SwiftUI
import UIKit

struct PomodoroTimerView: View {
    @EnvironmentObject var gameManager: GameManager
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    let quest: Quest?
    
    // Timer States
    @State private var timeRemaining: Int = 0
    @State private var totalTime: Int = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var selectedMode: TimerMode = .pomodoro
    @State private var currentPhase: TimerPhase = .focus
    @State private var sessionCount = 0
    @State private var completedPomodoros = 0
    
    // Settings
    @State private var focusDuration = 25
    @State private var shortBreakDuration = 5
    @State private var longBreakDuration = 15
    @State private var pomodorosUntilLongBreak = 4
    @State private var autoStartBreaks = true
    @State private var autoStartPomodoros = false
    
    // UI States
    @State private var showSettings = false
    @State private var showPhaseTransition = false
    @State private var transitionMessage = ""
    
    enum TimerMode: String, CaseIterable {
        case pomodoro = "Pomodoro"
        case custom = "Custom"
        case deepWork = "Deep Work"
        case quickFocus = "Quick Focus"
        
        var description: String {
            switch self {
            case .pomodoro:
                return "25 min focus, 5 min breaks"
            case .custom:
                return "Set your own intervals"
            case .deepWork:
                return "90 min sessions with longer breaks"
            case .quickFocus:
                return "15 min bursts for quick tasks"
            }
        }
        
        var defaultFocusDuration: Int {
            switch self {
            case .pomodoro: return 25
            case .custom: return 25
            case .deepWork: return 90
            case .quickFocus: return 15
            }
        }
        
        var defaultShortBreak: Int {
            switch self {
            case .pomodoro: return 5
            case .custom: return 5
            case .deepWork: return 20
            case .quickFocus: return 3
            }
        }
        
        var defaultLongBreak: Int {
            switch self {
            case .pomodoro: return 15
            case .custom: return 15
            case .deepWork: return 30
            case .quickFocus: return 10
            }
        }
    }
    
    enum TimerPhase {
        case focus
        case shortBreak
        case longBreak
        
        var color: Color {
            switch self {
            case .focus: return .mindLabsPurple
            case .shortBreak: return .mindLabsSuccess
            case .longBreak: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .focus: return "brain.head.profile"
            case .shortBreak: return "cup.and.saucer.fill"
            case .longBreak: return "figure.walk"
            }
        }
        
        var title: String {
            switch self {
            case .focus: return "Focus Time"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }
    }
    
    init(quest: Quest? = nil) {
        self.quest = quest
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient based on phase
                LinearGradient(
                    colors: [currentPhase.color.opacity(0.1), Color.mindLabsBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Mode Selector
                        if !isRunning {
                            VStack(spacing: 15) {
                                Picker("Timer Mode", selection: $selectedMode) {
                                    ForEach(TimerMode.allCases, id: \.self) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: selectedMode) { newMode in
                                    updateModeSettings(newMode)
                                }
                                
                                Text(selectedMode.description)
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Quest Info
                        if let quest = quest {
                            VStack(spacing: 10) {
                                Text(quest.category.icon)
                                    .font(.system(size: 40))
                                
                                Text(quest.title)
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color.mindLabsCard)
                            .cornerRadius(15)
                        }
                        
                        // Timer Display
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(currentPhase.color.opacity(0.2), lineWidth: 20)
                                .frame(width: 280, height: 280)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [currentPhase.color, currentPhase.color.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .frame(width: 280, height: 280)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.5), value: timeRemaining)
                            
                            VStack(spacing: 10) {
                                Image(systemName: currentPhase.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(currentPhase.color)
                                
                                Text(timeString)
                                    .font(.system(size: 65, weight: .thin, design: .monospaced))
                                    .foregroundColor(.mindLabsText)
                                
                                Text(currentPhase.title)
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsTextSecondary)
                                
                                if completedPomodoros > 0 {
                                    HStack(spacing: 4) {
                                        ForEach(0..<completedPomodoros, id: \.self) { _ in
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.mindLabsPurple)
                                        }
                                    }
                                    .padding(.top, 5)
                                }
                            }
                        }
                        
                        // Controls
                        HStack(spacing: 30) {
                            // Settings button
                            Button(action: { showSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            .disabled(isRunning)
                            
                            // Play/Pause button
                            Button(action: {
                                if isRunning {
                                    pauseTimer()
                                } else {
                                    startTimer()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(currentPhase.color)
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 35))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // Skip button
                            Button(action: skipPhase) {
                                Image(systemName: "forward.end.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        
                        // Quick Actions
                        if !isRunning && currentPhase == .focus {
                            HStack(spacing: 15) {
                                QuickTimeButton(minutes: 5, action: { setCustomTime(5) })
                                QuickTimeButton(minutes: 10, action: { setCustomTime(10) })
                                QuickTimeButton(minutes: 15, action: { setCustomTime(15) })
                                QuickTimeButton(minutes: 30, action: { setCustomTime(30) })
                            }
                        }
                        
                        // Session Stats
                        if sessionCount > 0 || completedPomodoros > 0 {
                            HStack(spacing: 40) {
                                StatView(title: "Sessions", value: "\(sessionCount)", icon: "timer")
                                StatView(title: "Pomodoros", value: "\(completedPomodoros)", icon: "checkmark.circle")
                                StatView(title: "Focus Time", value: "\(totalFocusMinutes)m", icon: "brain")
                            }
                            .padding()
                            .background(Color.mindLabsCard)
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                }
                
                // Phase Transition Overlay
                if showPhaseTransition {
                    PhaseTransitionView(
                        message: transitionMessage,
                        phase: currentPhase,
                        onDismiss: {
                            showPhaseTransition = false
                            if (currentPhase == .shortBreak || currentPhase == .longBreak) && autoStartBreaks {
                                startTimer()
                            } else if currentPhase == .focus && autoStartPomodoros {
                                startTimer()
                            }
                        }
                    )
                    .zIndex(100)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .navigationTitle("Pomodoro Timer")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: quest != nil ? Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple) : nil,
                trailing: Button(action: resetTimer) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.mindLabsPurple)
                }
            )
            .sheet(isPresented: $showSettings) {
                PomodoroSettingsView(
                    focusDuration: $focusDuration,
                    shortBreakDuration: $shortBreakDuration,
                    longBreakDuration: $longBreakDuration,
                    pomodorosUntilLongBreak: $pomodorosUntilLongBreak,
                    autoStartBreaks: $autoStartBreaks,
                    autoStartPomodoros: $autoStartPomodoros
                )
            }
        }
        .onAppear {
            setupTimer()
        }
        .onDisappear {
            timer?.invalidate()
            notificationManager.cancelTimerNotifications()
        }
    }
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var totalFocusMinutes: Int {
        return sessionCount * focusDuration
    }
    
    private func setupTimer() {
        updateModeSettings(selectedMode)
        resetTimer()
    }
    
    private func updateModeSettings(_ mode: TimerMode) {
        if !isRunning {
            focusDuration = mode.defaultFocusDuration
            shortBreakDuration = mode.defaultShortBreak
            longBreakDuration = mode.defaultLongBreak
            
            if currentPhase == .focus {
                timeRemaining = focusDuration * 60
                totalTime = focusDuration * 60
            }
        }
    }
    
    private func setCustomTime(_ minutes: Int) {
        focusDuration = minutes
        timeRemaining = minutes * 60
        totalTime = minutes * 60
        selectedMode = .custom
    }
    
    private func startTimer() {
        isRunning = true
        
        // Start time tracking for quest
        if let quest = quest, currentPhase == .focus {
            gameManager.startTimeTracking(for: quest.id)
        }
        
        // Schedule notification
        let timerType: NotificationManager.TimerType = {
            switch currentPhase {
            case .focus: return selectedMode == .pomodoro ? .pomodoro : .focus
            case .shortBreak: return .shortBreak
            case .longBreak: return .longBreak
            }
        }()
        
        notificationManager.scheduleTimerNotification(
            questTitle: quest?.title ?? "Focus Session",
            duration: TimeInterval(timeRemaining),
            timerType: timerType
        )
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                handlePhaseComplete()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Stop time tracking for quest
        if let quest = quest, currentPhase == .focus {
            gameManager.stopTimeTracking(for: quest.id)
        }
        
        notificationManager.cancelTimerNotifications()
    }
    
    private func resetTimer() {
        pauseTimer()
        currentPhase = .focus
        timeRemaining = focusDuration * 60
        totalTime = focusDuration * 60
        sessionCount = 0
        completedPomodoros = 0
    }
    
    private func skipPhase() {
        handlePhaseComplete()
    }
    
    private func handlePhaseComplete() {
        pauseTimer()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        switch currentPhase {
        case .focus:
            sessionCount += 1
            completedPomodoros += 1
            
            // Track focus minutes
            gameManager.addFocusMinutes(focusDuration)
            
            // Determine next phase
            if completedPomodoros % pomodorosUntilLongBreak == 0 {
                currentPhase = .longBreak
                timeRemaining = longBreakDuration * 60
                totalTime = longBreakDuration * 60
                transitionMessage = "Great work! Time for a long break."
            } else {
                currentPhase = .shortBreak
                timeRemaining = shortBreakDuration * 60
                totalTime = shortBreakDuration * 60
                transitionMessage = "Nice focus! Take a short break."
            }
            
        case .shortBreak, .longBreak:
            currentPhase = .focus
            timeRemaining = focusDuration * 60
            totalTime = focusDuration * 60
            transitionMessage = "Break's over! Ready to focus?"
        }
        
        showPhaseTransition = true
    }
}

// MARK: - Supporting Views
struct QuickTimeButton: View {
    let minutes: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(minutes)m")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsPurple)
                .frame(width: 60, height: 40)
                .background(Color.mindLabsCard)
                .cornerRadius(10)
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.mindLabsPurple)
            Text(value)
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            Text(title)
                .font(MindLabsTypography.caption2())
                .foregroundColor(.mindLabsTextSecondary)
        }
    }
}

struct PhaseTransitionView: View {
    let message: String
    let phase: PomodoroTimerView.TimerPhase
    let onDismiss: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: phase.icon)
                    .font(.system(size: 60))
                    .foregroundColor(phase.color)
                    .scaleEffect(showContent ? 1 : 0.5)
                
                Text(message)
                    .font(MindLabsTypography.title2())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                
                Button(action: onDismiss) {
                    Text("Continue")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(phase.color)
                        .cornerRadius(25)
                }
                .opacity(showContent ? 1 : 0)
            }
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring()) {
                showContent = true
            }
        }
    }
}

struct PomodoroSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var focusDuration: Int
    @Binding var shortBreakDuration: Int
    @Binding var longBreakDuration: Int
    @Binding var pomodorosUntilLongBreak: Int
    @Binding var autoStartBreaks: Bool
    @Binding var autoStartPomodoros: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer Durations")) {
                    Stepper("Focus: \(focusDuration) minutes", value: $focusDuration, in: 1...90, step: 5)
                    Stepper("Short Break: \(shortBreakDuration) minutes", value: $shortBreakDuration, in: 1...30, step: 1)
                    Stepper("Long Break: \(longBreakDuration) minutes", value: $longBreakDuration, in: 5...60, step: 5)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section(header: Text("Pomodoro Settings")) {
                    Stepper("Long break after \(pomodorosUntilLongBreak) pomodoros", value: $pomodorosUntilLongBreak, in: 2...8, step: 1)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section(header: Text("Automation")) {
                    Toggle("Auto-start breaks", isOn: $autoStartBreaks)
                        .tint(.mindLabsPurple)
                    Toggle("Auto-start focus sessions", isOn: $autoStartPomodoros)
                        .tint(.mindLabsPurple)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section {
                    Text("These settings help manage ADHD by providing structure and regular breaks to maintain focus.")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                .listRowBackground(Color.clear)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("Timer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
        }
        .mindLabsBackground()
    }
}

struct PomodoroTimerView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroTimerView(quest: Quest(
            title: "Study for Math Test",
            category: .academic,
            difficulty: .hard,
            estimatedTime: 25
        ))
        .environmentObject(GameManager())
    }
}