import SwiftUI

struct ADHDToolsHub: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingFocusMode = false
    @State private var showingTaskSwitching = false
    @State private var showingBodyDoubling = false
    @State private var showingSensoryBreaks = false
    @State private var showingTimeBlindnessSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    ADHDToolsHeaderCard()
                    
                    // Quick Stats
                    QuickStatsCard(gameManager: gameManager)
                    
                    // Main Tools Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        // Focus Mode
                        ToolCard(
                            title: "Focus Mode",
                            subtitle: "Minimize distractions",
                            icon: "eye.trianglebadge.exclamationmark",
                            color: .purple,
                            badge: focusModeBadge,
                            action: { showingFocusMode = true }
                        )
                        
                        // Task Switching
                        ToolCard(
                            title: "Task Switching",
                            subtitle: "Smooth transitions",
                            icon: "arrow.triangle.2.circlepath",
                            color: .blue,
                            action: { showingTaskSwitching = true }
                        )
                        
                        // Body Doubling
                        ToolCard(
                            title: "Body Doubling",
                            subtitle: "Virtual co-working",
                            icon: "person.2.fill",
                            color: .green,
                            action: { showingBodyDoubling = true }
                        )
                        
                        // Sensory Breaks
                        ToolCard(
                            title: "Sensory Breaks",
                            subtitle: "Recharge activities",
                            icon: "leaf.fill",
                            color: .orange,
                            action: { showingSensoryBreaks = true }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Time Management Section
                    TimeManagementSection(
                        showingTimeBlindnessSettings: $showingTimeBlindnessSettings
                    )
                    
                    // Active Tools Status
                    if hasActiveTools {
                        ActiveToolsCard()
                    }
                    
                    // Tips of the Day
                    ADHDTipsCard()
                }
                .padding(.vertical)
            }
            .navigationTitle("ADHD Tools")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
            .sheet(isPresented: $showingFocusMode) {
                FocusModeView()
            }
            .sheet(isPresented: $showingTaskSwitching) {
                TaskSwitchingView()
            }
            .sheet(isPresented: $showingBodyDoubling) {
                BodyDoublingView()
            }
            .sheet(isPresented: $showingSensoryBreaks) {
                SensoryBreaksView()
            }
            .sheet(isPresented: $showingTimeBlindnessSettings) {
                TimeBlindnessSettingsView()
            }
        }
    }
    
    var hasActiveTools: Bool {
        FocusManager.shared.isInFocusMode || 
        TaskSwitchingHelper().isTransitioning
    }
    
    var focusModeBadge: String? {
        FocusManager.shared.isInFocusMode ? "Active" : nil
    }
}

// MARK: - Supporting Views
struct ADHDToolsHeaderCard: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundColor(.mindLabsPurple)
            
            Text("ADHD Support Tools")
                .font(MindLabsTypography.title2())
                .foregroundColor(.mindLabsText)
            
            Text("Specialized features to help manage ADHD symptoms and boost productivity")
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
        .padding(.horizontal)
    }
}

struct QuickStatsCard: View {
    let gameManager: GameManager
    
    var todaysFocusMinutes: Int {
        // This would be calculated from today's sessions
        gameManager.character.totalFocusMinutes % 100
    }
    
    var body: some View {
        HStack(spacing: 20) {
            StatItem(
                value: "\(todaysFocusMinutes)",
                label: "Focus Minutes Today",
                icon: "timer",
                color: .purple
            )
            
            StatItem(
                value: "\(gameManager.character.streak)",
                label: "Current Streak",
                icon: "flame.fill",
                color: .orange
            )
            
            StatItem(
                value: "\(gameManager.completedQuestsToday)",
                label: "Tasks Today",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(MindLabsTypography.title())
                .foregroundColor(.mindLabsText)
            
            Text(label)
                .font(MindLabsTypography.caption2())
                .foregroundColor(.mindLabsTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ToolCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var badge: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(color)
                    
                    if let badge = badge {
                        Text(badge)
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.mindLabsSuccess)
                            .cornerRadius(10)
                            .offset(x: 20, y: -10)
                    }
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Text(subtitle)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.mindLabsCard)
            .cornerRadius(15)
            .shadow(color: color.opacity(0.2), radius: 5)
        }
    }
}

struct TimeManagementSection: View {
    @Binding var showingTimeBlindnessSettings: Bool
    @AppStorage("timeBlindnessAlertsEnabled") private var timeBlindnessAlertsEnabled = true
    @AppStorage("timeCheckInterval") private var timeCheckInterval = 30
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("Time Management", systemImage: "clock.fill")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
                
                Button("Settings") {
                    showingTimeBlindnessSettings = true
                }
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsPurple)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(.mindLabsPurple)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Time Blindness Alerts")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        Text(timeBlindnessAlertsEnabled ? 
                             "Every \(timeCheckInterval) minutes" : 
                             "Disabled")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $timeBlindnessAlertsEnabled)
                        .labelsHidden()
                        .tint(.mindLabsPurple)
                }
                
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.mindLabsPurple)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Visual Time Display")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        Text("Always visible in focus modes")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct ActiveToolsCard: View {
    @StateObject private var focusManager = FocusManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Active Tools", systemImage: "circle.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            if focusManager.isInFocusMode {
                ActiveToolRow(
                    icon: "eye.fill",
                    title: "Focus Mode",
                    status: focusManager.timeRemaining,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct ActiveToolRow: View {
    let icon: String
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
                .font(MindLabsTypography.subheadline())
                .foregroundColor(.mindLabsText)
            
            Spacer()
            
            Text(status)
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ADHDTipsCard: View {
    let tips = [
        ADHDTip(
            title: "Use Visual Timers",
            description: "Visual representation of time helps with time blindness",
            icon: "timer"
        ),
        ADHDTip(
            title: "Break Large Tasks",
            description: "Divide big projects into smaller, manageable chunks",
            icon: "square.grid.3x3"
        ),
        ADHDTip(
            title: "Body Movement",
            description: "Regular movement breaks improve focus and attention",
            icon: "figure.walk"
        ),
        ADHDTip(
            title: "External Accountability",
            description: "Body doubling and check-ins help maintain motivation",
            icon: "person.2"
        )
    ]
    
    @State private var currentTipIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("ADHD Tips", systemImage: "lightbulb.fill")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
                
                Button(action: nextTip) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                }
            }
            
            let tip = tips[currentTipIndex]
            HStack(alignment: .top, spacing: 15) {
                Image(systemName: tip.icon)
                    .font(.title2)
                    .foregroundColor(.mindLabsPurple)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(tip.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Text(tip.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    private func nextTip() {
        withAnimation {
            currentTipIndex = (currentTipIndex + 1) % tips.count
        }
    }
}

struct ADHDTip {
    let title: String
    let description: String
    let icon: String
}

// MARK: - Sensory Breaks View
struct SensoryBreaksView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let sensoryActivities = [
        SensoryActivity(
            title: "Deep Breathing",
            duration: 3,
            icon: "wind",
            instructions: "Take 4 slow breaths: In for 4, hold for 4, out for 4",
            category: .calming
        ),
        SensoryActivity(
            title: "Stretching",
            duration: 5,
            icon: "figure.walk",
            instructions: "Gentle neck rolls, shoulder shrugs, and arm stretches",
            category: .movement
        ),
        SensoryActivity(
            title: "Fidget Time",
            duration: 5,
            icon: "hands.sparkles",
            instructions: "Use a fidget toy or stress ball for tactile input",
            category: .tactile
        ),
        SensoryActivity(
            title: "Music Break",
            duration: 5,
            icon: "music.note",
            instructions: "Listen to calming or energizing music",
            category: .auditory
        ),
        SensoryActivity(
            title: "Mindful Walking",
            duration: 10,
            icon: "figure.walk.circle",
            instructions: "Take a short walk, focusing on each step",
            category: .movement
        ),
        SensoryActivity(
            title: "Progressive Relaxation",
            duration: 10,
            icon: "person.fill.checkmark",
            instructions: "Tense and relax muscle groups from toes to head",
            category: .calming
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Sensory Breaks")
                            .font(MindLabsTypography.title2())
                            .foregroundColor(.mindLabsText)
                        
                        Text("Quick activities to reset your sensory system")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding()
                    
                    // Activities Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(sensoryActivities) { activity in
                            SensoryActivityCard(activity: activity)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
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

struct SensoryActivity: Identifiable {
    let id = UUID()
    let title: String
    let duration: Int
    let icon: String
    let instructions: String
    let category: SensoryCategory
    
    enum SensoryCategory {
        case calming, movement, tactile, auditory
    }
}

struct SensoryActivityCard: View {
    let activity: SensoryActivity
    @State private var isActive = false
    
    var body: some View {
        Button(action: { isActive = true }) {
            VStack(spacing: 10) {
                Image(systemName: activity.icon)
                    .font(.system(size: 35))
                    .foregroundColor(.green)
                
                Text(activity.title)
                    .font(MindLabsTypography.subheadline())
                    .foregroundColor(.mindLabsText)
                    .multilineTextAlignment(.center)
                
                Text("\(activity.duration) min")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.mindLabsCard)
            .cornerRadius(15)
        }
        .sheet(isPresented: $isActive) {
            SensoryActivityView(activity: activity)
        }
    }
}

struct SensoryActivityView: View {
    let activity: SensoryActivity
    @Environment(\.presentationMode) var presentationMode
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    
    init(activity: SensoryActivity) {
        self.activity = activity
        self._timeRemaining = State(initialValue: activity.duration * 60)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Spacer()
                Button("Done") {
                    timer?.invalidate()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            }
            .padding()
            
            Spacer()
            
            // Activity Icon
            Image(systemName: activity.icon)
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            // Title
            Text(activity.title)
                .font(MindLabsTypography.title())
                .foregroundColor(.mindLabsText)
            
            // Timer
            Text(formatTime(timeRemaining))
                .font(.system(size: 60, weight: .thin, design: .monospaced))
                .foregroundColor(.mindLabsText)
            
            // Instructions
            Text(activity.instructions)
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Complete Button
            Button(action: {
                timer?.invalidate()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Complete Break")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
        .mindLabsBackground()
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Time Blindness Settings
struct TimeBlindnessSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("timeBlindnessAlertsEnabled") private var alertsEnabled = true
    @AppStorage("timeCheckInterval") private var checkInterval = 30
    @AppStorage("showFloatingTimer") private var showFloatingTimer = true
    @AppStorage("announceTimeRemaining") private var announceTimeRemaining = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time Awareness")) {
                    Toggle("Enable Time Blindness Alerts", isOn: $alertsEnabled)
                        .tint(.mindLabsPurple)
                    
                    if alertsEnabled {
                        HStack {
                            Text("Check-in Interval")
                            Spacer()
                            Picker("", selection: $checkInterval) {
                                Text("15 min").tag(15)
                                Text("30 min").tag(30)
                                Text("45 min").tag(45)
                                Text("60 min").tag(60)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(.mindLabsPurple)
                        }
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section(header: Text("Visual Aids")) {
                    Toggle("Show Floating Timer", isOn: $showFloatingTimer)
                        .tint(.mindLabsPurple)
                    
                    Toggle("Announce Time Remaining", isOn: $announceTimeRemaining)
                        .tint(.mindLabsPurple)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About Time Blindness")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        Text("Time blindness is a common ADHD symptom where individuals have difficulty perceiving the passage of time. These tools help provide external time cues and reminders.")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("Time Blindness Settings")
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

struct ADHDToolsHub_Previews: PreviewProvider {
    static var previews: some View {
        ADHDToolsHub()
            .environmentObject(GameManager())
    }
}