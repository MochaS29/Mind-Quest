import SwiftUI

struct TaskSwitchingView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var switchingHelper = TaskSwitchingHelper()
    
    @State private var currentTask: Quest?
    @State private var nextTask: Quest?
    @State private var transitionMinutes = 5
    @State private var showTransitionGuide = false
    @State private var isInTransition = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    TaskSwitchingHeaderCard()
                    
                    if !isInTransition {
                        // Current Task
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Current Task", systemImage: "checkmark.circle.fill")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            if let current = currentTask {
                                CurrentTaskCard(quest: current)
                            } else {
                                TaskSelectionCard(
                                    title: "Select Current Task",
                                    quests: gameManager.activeQuests,
                                    selectedQuest: $currentTask
                                )
                            }
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        
                        // Next Task
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Next Task", systemImage: "arrow.right.circle.fill")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            if let next = nextTask {
                                NextTaskCard(quest: next)
                            } else {
                                TaskSelectionCard(
                                    title: "Select Next Task",
                                    quests: gameManager.activeQuests.filter { $0.id != currentTask?.id },
                                    selectedQuest: $nextTask
                                )
                            }
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                        
                        // Transition Settings
                        if currentTask != nil && nextTask != nil {
                            TransitionSettingsCard(
                                transitionMinutes: $transitionMinutes,
                                showTransitionGuide: $showTransitionGuide
                            )
                            
                            // Start Transition Button
                            Button(action: startTransition) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Start Task Transition")
                                }
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient.mindLabsPrimary)
                                .cornerRadius(15)
                            }
                        }
                    } else {
                        // Active Transition View
                        ActiveTransitionView(
                            switchingHelper: switchingHelper,
                            currentTask: currentTask!,
                            nextTask: nextTask!,
                            onComplete: completeTransition
                        )
                    }
                    
                    // Tips Section
                    if !isInTransition {
                        TaskSwitchingTipsCard()
                    }
                }
                .padding()
            }
            .navigationTitle("Task Switching")
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
    
    private func startTransition() {
        guard let current = currentTask, let next = nextTask else { return }
        
        isInTransition = true
        switchingHelper.startTransition(
            from: current,
            to: next,
            duration: transitionMinutes,
            showGuide: showTransitionGuide
        )
    }
    
    private func completeTransition() {
        isInTransition = false
        currentTask = nextTask
        nextTask = nil
        
        // Award XP for successful transition
        gameManager.character.xp += 5
    }
}

// MARK: - Supporting Views
struct TaskSwitchingHeaderCard: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.mindLabsPurple)
            
            Text("Task Switching Helper")
                .font(MindLabsTypography.title2())
                .foregroundColor(.mindLabsText)
            
            Text("Smooth transitions between tasks to maintain focus and momentum")
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

struct CurrentTaskCard: View {
    let quest: Quest
    
    var body: some View {
        HStack {
            Text(quest.category.icon)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(quest.title)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                HStack {
                    Label("\(quest.estimatedTime) min", systemImage: "clock")
                    Text("•")
                    Text(quest.difficulty.rawValue)
                        .foregroundColor(quest.difficulty.color)
                }
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.mindLabsSuccess.opacity(0.1))
        .cornerRadius(10)
    }
}

struct NextTaskCard: View {
    let quest: Quest
    
    var body: some View {
        HStack {
            Text(quest.category.icon)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(quest.title)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                HStack {
                    Label("\(quest.estimatedTime) min", systemImage: "clock")
                    Text("•")
                    Text(quest.difficulty.rawValue)
                        .foregroundColor(quest.difficulty.color)
                }
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

struct TaskSelectionCard: View {
    let title: String
    let quests: [Quest]
    @Binding var selectedQuest: Quest?
    @State private var showingPicker = false
    
    var body: some View {
        Button(action: { showingPicker = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.mindLabsPurple)
                
                Text(title)
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .padding()
            .background(Color.mindLabsPurple.opacity(0.1))
            .cornerRadius(10)
        }
        .sheet(isPresented: $showingPicker) {
            QuestPickerView(quests: quests, selectedQuest: $selectedQuest)
        }
    }
}

struct TransitionSettingsCard: View {
    @Binding var transitionMinutes: Int
    @Binding var showTransitionGuide: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Transition Settings", systemImage: "gearshape.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            HStack {
                Text("Transition Time")
                Spacer()
                Picker("", selection: $transitionMinutes) {
                    Text("3 min").tag(3)
                    Text("5 min").tag(5)
                    Text("10 min").tag(10)
                    Text("15 min").tag(15)
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.mindLabsPurple)
            }
            
            Toggle(isOn: $showTransitionGuide) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transition Guide")
                    Text("Step-by-step guidance")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            .tint(.mindLabsPurple)
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
    }
}

struct ActiveTransitionView: View {
    @ObservedObject var switchingHelper: TaskSwitchingHelper
    let currentTask: Quest
    let nextTask: Quest
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.mindLabsPurple.opacity(0.2), lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: switchingHelper.progress)
                    .stroke(
                        LinearGradient.mindLabsPrimary,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: switchingHelper.progress)
                
                VStack {
                    Text(switchingHelper.timeRemaining)
                        .font(.system(size: 35, weight: .thin, design: .monospaced))
                        .foregroundColor(.mindLabsText)
                    
                    Text("Transition")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            // Current Step
            if let currentStep = switchingHelper.currentStep {
                StepCard(step: currentStep)
            }
            
            // Task Transition Visual
            HStack(spacing: 20) {
                VStack {
                    Text(currentTask.category.icon)
                        .font(.system(size: 40))
                    Text("From")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.mindLabsPurple)
                
                VStack {
                    Text(nextTask.category.icon)
                        .font(.system(size: 40))
                    Text("To")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            .padding()
            .background(Color.mindLabsCard)
            .cornerRadius(15)
            
            // Skip Button
            Button(action: {
                switchingHelper.completeTransition()
                onComplete()
            }) {
                Text("Skip Remaining Steps")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
            }
        }
    }
}

struct StepCard: View {
    let step: TransitionStep
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: step.icon)
                .font(.system(size: 40))
                .foregroundColor(.mindLabsPurple)
            
            Text(step.title)
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            Text(step.description)
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsTextSecondary)
                .multilineTextAlignment(.center)
            
            if let action = step.action {
                Text(action)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsPurple)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.mindLabsPurple.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.mindLabsCard)
        .cornerRadius(15)
    }
}

struct TaskSwitchingTipsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Task Switching Tips", systemImage: "lightbulb.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            VStack(alignment: .leading, spacing: 10) {
                TaskSwitchingTipRow(tip: "Take a brief physical break between tasks")
                TaskSwitchingTipRow(tip: "Clear your workspace before starting new task")
                TaskSwitchingTipRow(tip: "Review the new task's requirements")
                TaskSwitchingTipRow(tip: "Set a clear intention for the next task")
                TaskSwitchingTipRow(tip: "Use transition time to reset mentally")
            }
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
    }
}

struct TaskSwitchingTipRow: View {
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.mindLabsSuccess)
            
            Text(tip)
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsText)
        }
    }
}

struct QuestPickerView: View {
    let quests: [Quest]
    @Binding var selectedQuest: Quest?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(quests) { quest in
                Button(action: {
                    selectedQuest = quest
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(quest.category.icon)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(quest.title)
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)
                            
                            HStack {
                                Label("\(quest.estimatedTime)m", systemImage: "clock")
                                Text("•")
                                Text(quest.difficulty.rawValue)
                                    .foregroundColor(quest.difficulty.color)
                            }
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Select Quest")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
        }
    }
}

// MARK: - Task Switching Helper
class TaskSwitchingHelper: ObservableObject {
    @Published var isTransitioning = false
    @Published var progress: Double = 0
    @Published var timeRemaining = "00:00"
    @Published var currentStep: TransitionStep?
    
    private var timer: Timer?
    private var steps: [TransitionStep] = []
    private var currentStepIndex = 0
    private var stepDuration: TimeInterval = 0
    private var stepStartTime: Date?
    
    func startTransition(from: Quest, to: Quest, duration: Int, showGuide: Bool) {
        isTransitioning = true
        
        // Generate transition steps
        if showGuide {
            steps = generateTransitionSteps(from: from, to: to, duration: duration)
        } else {
            steps = [
                TransitionStep(
                    title: "Transition Time",
                    description: "Take a moment to shift your focus",
                    icon: "arrow.triangle.2.circlepath",
                    duration: TimeInterval(duration * 60)
                )
            ]
        }
        
        currentStepIndex = 0
        startNextStep()
    }
    
    func completeTransition() {
        timer?.invalidate()
        isTransitioning = false
        progress = 1.0
    }
    
    private func generateTransitionSteps(from: Quest, to: Quest, duration: Int) -> [TransitionStep] {
        let stepCount = min(duration, 5)
        let stepDuration = TimeInterval((duration * 60) / stepCount)
        
        var steps: [TransitionStep] = []
        
        // Step 1: Wrap up current task
        steps.append(TransitionStep(
            title: "Wrap Up Current Task",
            description: "Save your progress and make notes",
            icon: "square.and.arrow.down",
            action: "Save and close \(from.title)",
            duration: stepDuration
        ))
        
        // Step 2: Physical reset
        if stepCount >= 2 {
            steps.append(TransitionStep(
                title: "Physical Reset",
                description: "Stand up, stretch, or take a brief walk",
                icon: "figure.walk",
                action: "Take 5 deep breaths",
                duration: stepDuration
            ))
        }
        
        // Step 3: Mental transition
        if stepCount >= 3 {
            steps.append(TransitionStep(
                title: "Mental Transition",
                description: "Clear your mind of the previous task",
                icon: "brain",
                action: "Close your eyes for 30 seconds",
                duration: stepDuration
            ))
        }
        
        // Step 4: Prepare workspace
        if stepCount >= 4 {
            steps.append(TransitionStep(
                title: "Prepare Workspace",
                description: "Set up materials for the next task",
                icon: "square.grid.3x3",
                action: "Organize for \(to.title)",
                duration: stepDuration
            ))
        }
        
        // Step 5: Set intention
        if stepCount >= 5 {
            steps.append(TransitionStep(
                title: "Set Intention",
                description: "Review goals for the next task",
                icon: "target",
                action: "Focus on \(to.title)",
                duration: stepDuration
            ))
        }
        
        return steps
    }
    
    private func startNextStep() {
        guard currentStepIndex < steps.count else {
            completeTransition()
            return
        }
        
        currentStep = steps[currentStepIndex]
        stepDuration = steps[currentStepIndex].duration
        stepStartTime = Date()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateProgress()
        }
    }
    
    private func updateProgress() {
        guard let startTime = stepStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let stepProgress = min(elapsed / stepDuration, 1.0)
        
        // Calculate overall progress
        let completedSteps = Double(currentStepIndex)
        let currentStepProgress = stepProgress / Double(steps.count)
        progress = (completedSteps / Double(steps.count)) + currentStepProgress
        
        // Update time remaining for current step
        let remainingSeconds = max(0, Int(stepDuration - elapsed))
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timeRemaining = String(format: "%02d:%02d", minutes, seconds)
        
        // Move to next step if current is complete
        if stepProgress >= 1.0 {
            currentStepIndex += 1
            startNextStep()
        }
    }
}

struct TransitionStep {
    let title: String
    let description: String
    let icon: String
    let action: String?
    let duration: TimeInterval
    
    init(title: String, description: String, icon: String, action: String? = nil, duration: TimeInterval) {
        self.title = title
        self.description = description
        self.icon = icon
        self.action = action
        self.duration = duration
    }
}

struct TaskSwitchingView_Previews: PreviewProvider {
    static var previews: some View {
        TaskSwitchingView()
            .environmentObject(GameManager())
    }
}