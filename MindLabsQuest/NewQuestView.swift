import SwiftUI

struct NewQuestView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var questTitle = ""
    @State private var questDescription = ""
    @State private var selectedCategory: TaskCategory = .academic
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var estimatedTime = 25
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var showBreakdown = false
    @State private var subtasks: [Subtask] = []
    
    var timeEstimateSuggestion: TimeEstimateSuggestion? {
        guard !questTitle.isEmpty else { return nil }
        return gameManager.getTimeEstimateSuggestion(for: selectedCategory, originalEstimate: estimatedTime)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Adventure Details") {
                    TextField("Adventure Title", text: $questTitle)
                        .textFieldStyle(MindLabsTextFieldStyle())
                    
                    TextField("Description (optional)", text: $questDescription)
                        .textFieldStyle(MindLabsTextFieldStyle())
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Label {
                                Text(category.rawValue)
                            } icon: {
                                Text(category.icon)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(.mindLabsPurple)
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                        Text("Primary Stat Bonus: +\(selectedCategory.primaryStat.rawValue)")
                            .font(MindLabsTypography.caption())
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(LinearGradient.mindLabsPrimary.opacity(0.1))
                    .cornerRadius(8)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Difficulty & Time") {
                    // Difficulty Selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Difficulty")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        HStack(spacing: 10) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                DifficultyButton(
                                    difficulty: difficulty,
                                    isSelected: selectedDifficulty == difficulty,
                                    action: { selectedDifficulty = difficulty }
                                )
                            }
                        }
                    }
                    
                    // Time Estimate with AI Suggestion
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Estimated Time: \(estimatedTime) minutes")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Spacer()
                            
                            if let suggestion = timeEstimateSuggestion {
                                Button(action: {
                                    estimatedTime = suggestion.suggestedTime
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: suggestion.confidence.icon)
                                            .font(.caption)
                                        Text("AI: \(suggestion.suggestedTime) min")
                                            .font(MindLabsTypography.caption2())
                                    }
                                    .foregroundColor(suggestion.confidence.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(suggestion.confidence.color.opacity(0.2))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        Slider(value: Binding(
                            get: { Double(estimatedTime) },
                            set: { estimatedTime = Int($0) }
                        ), in: 5...120, step: 5)
                        .tint(.mindLabsPurple)
                        
                        if let suggestion = timeEstimateSuggestion {
                            Text(suggestion.reason)
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.mindLabsBorder.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Due Date (Optional)") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                        .tint(.mindLabsPurple)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .tint(.mindLabsPurple)
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                // Task Breakdown Section
                Section("Task Breakdown") {
                    if subtasks.isEmpty {
                        Button(action: {
                            showBreakdown = true
                        }) {
                            HStack {
                                Image(systemName: "list.bullet.indent")
                                    .foregroundColor(.mindLabsWarning)
                                Text("Break down into steps")
                                    .foregroundColor(.mindLabsText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.mindLabsTextSecondary)
                                    .font(.caption)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("\(subtasks.count) steps")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                                Spacer()
                                Button("Edit") {
                                    showBreakdown = true
                                }
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsPurple)
                            }
                            
                            ForEach(subtasks.prefix(3)) { subtask in
                                HStack {
                                    Image(systemName: "circle")
                                        .font(.caption)
                                        .foregroundColor(.mindLabsTextSecondary)
                                    Text(subtask.title)
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsText)
                                        .lineLimit(1)
                                    Spacer()
                                }
                            }
                            
                            if subtasks.count > 3 {
                                Text("+ \(subtasks.count - 3) more steps")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                // Quest Summary
                Section("Quest Summary") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("XP Reward:")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            Spacer()
                            Text("\(calculateXP()) XP")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsBlue)
                        }
                        
                        HStack {
                            Text("Gold Reward:")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            Spacer()
                            Text("\(calculateGold()) Gold")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .listRowBackground(Color.mindLabsCard)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("New Adventure")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.mindLabsPurple),
            
            trailing: Button("Create") {
                createQuest()
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(questTitle.isEmpty)
            .foregroundColor(questTitle.isEmpty ? .mindLabsTextLight : .mindLabsPurple)
        )
        .sheet(isPresented: $showBreakdown) {
            TaskBreakdownForCreationView(
                questTitle: questTitle,
                questCategory: selectedCategory,
                subtasks: $subtasks
            )
        }
    }
    
    func calculateXP() -> Int {
        let baseXP = 50
        let difficultyMultiplier: Double = {
            switch selectedDifficulty {
            case .easy: return 0.8
            case .medium: return 1.0
            case .hard: return 1.5
            }
        }()
        let timeBonus = Double(estimatedTime) * 0.5
        
        return Int(Double(baseXP) * difficultyMultiplier + timeBonus)
    }
    
    func calculateGold() -> Int {
        let baseGold = 10
        let difficultyMultiplier: Double = {
            switch selectedDifficulty {
            case .easy: return 0.5
            case .medium: return 1.0
            case .hard: return 2.0
            }
        }()
        
        return Int(Double(baseGold) * difficultyMultiplier)
    }
    
    func createQuest() {
        var quest = Quest(
            title: questTitle,
            category: selectedCategory,
            difficulty: selectedDifficulty,
            estimatedTime: estimatedTime,
            dueDate: hasDueDate ? dueDate : nil
        )
        quest.subtasks = subtasks
        gameManager.addQuest(quest)
    }
}

struct DifficultyButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var difficultyColor: Color {
        switch difficulty {
        case .easy: return .mindLabsSuccess
        case .medium: return .mindLabsWarning
        case .hard: return .mindLabsError
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: difficulty == .easy ? "star" : difficulty == .medium ? "star.leadinghalf.filled" : "star.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? difficultyColor : .mindLabsTextLight)
                
                Text(difficulty.rawValue)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(isSelected ? difficultyColor : .mindLabsTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? difficultyColor.opacity(0.2) : Color.mindLabsBorder.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? difficultyColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskBreakdownForCreationView: View {
    let questTitle: String
    let questCategory: TaskCategory
    @Binding var subtasks: [Subtask]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var localSubtasks: [Subtask] = []
    @State private var newSubtaskTitle = ""
    @State private var showingSuggestions = true
    @State private var editingSubtaskId: UUID?
    @State private var editingText = ""
    
    var suggestedSteps: [String] {
        TaskBreakdownTemplate.getSuggestions(for: questCategory, title: questTitle)
    }
    
    var totalEstimatedTime: Int {
        localSubtasks.reduce(0) { $0 + $1.estimatedTime }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Quest Info Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(questCategory.icon)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(questTitle.isEmpty ? "New Quest" : questTitle)
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            Text("Breaking down into manageable steps")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.mindLabsCard)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Suggestions
                        if showingSuggestions && localSubtasks.isEmpty {
                            SuggestionsCard(
                                suggestions: suggestedSteps,
                                onAccept: { acceptSuggestions() },
                                onDismiss: { showingSuggestions = false }
                            )
                        }
                        
                        // Subtasks List
                        if !localSubtasks.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Steps")
                                        .font(MindLabsTypography.headline())
                                        .foregroundColor(.mindLabsText)
                                    Spacer()
                                    Text("\(localSubtasks.count) steps • \(totalEstimatedTime) min total")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                                
                                ForEach(localSubtasks.indices, id: \.self) { index in
                                    SubtaskRow(
                                        subtask: $localSubtasks[index],
                                        isEditing: editingSubtaskId == localSubtasks[index].id,
                                        editingText: $editingText,
                                        onEdit: {
                                            startEditing(localSubtasks[index])
                                        },
                                        onSave: {
                                            saveEdit(index: index)
                                        },
                                        onDelete: {
                                            deleteSubtask(at: index)
                                        },
                                        onTimeChange: { minutes in
                                            localSubtasks[index].estimatedTime = minutes
                                        },
                                        onMoveUp: index > 0 ? {
                                            moveSubtask(from: index, to: index - 1)
                                        } : nil,
                                        onMoveDown: index < localSubtasks.count - 1 ? {
                                            moveSubtask(from: index, to: index + 1)
                                        } : nil
                                    )
                                }
                            }
                            .padding()
                            .background(Color.mindLabsCard)
                            .cornerRadius(15)
                        }
                        
                        // Add Subtask
                        AddSubtaskCard(
                            newSubtaskTitle: $newSubtaskTitle,
                            onAdd: addSubtask
                        )
                        
                        // Tips
                        TipsCard()
                    }
                    .padding()
                }
                
                // Bottom Action Bar
                HStack(spacing: 15) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(MindLabsSecondaryButtonStyle())
                    
                    Button("Save Steps") {
                        subtasks = localSubtasks
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(MindLabsPrimaryButtonStyle())
                }
                .padding()
                .background(Color.mindLabsCard)
            }
            .navigationTitle("Break Down Task")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
        }
        .onAppear {
            localSubtasks = subtasks
        }
    }
    
    private func acceptSuggestions() {
        localSubtasks = suggestedSteps.enumerated().map { index, step in
            Subtask(
                title: step,
                estimatedTime: 10,
                order: index
            )
        }
    }
    
    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        
        let newSubtask = Subtask(
            title: newSubtaskTitle,
            estimatedTime: 10,
            order: localSubtasks.count
        )
        
        localSubtasks.append(newSubtask)
        newSubtaskTitle = ""
    }
    
    private func deleteSubtask(at index: Int) {
        localSubtasks.remove(at: index)
        // Reorder remaining subtasks
        for i in 0..<localSubtasks.count {
            localSubtasks[i].order = i
        }
    }
    
    private func moveSubtask(from: Int, to: Int) {
        let movingSubtask = localSubtasks[from]
        localSubtasks.remove(at: from)
        localSubtasks.insert(movingSubtask, at: to)
        
        // Update order
        for i in 0..<localSubtasks.count {
            localSubtasks[i].order = i
        }
    }
    
    private func startEditing(_ subtask: Subtask) {
        editingSubtaskId = subtask.id
        editingText = subtask.title
    }
    
    private func saveEdit(index: Int) {
        localSubtasks[index].title = editingText
        editingSubtaskId = nil
        editingText = ""
    }
}

struct NewQuestView_Previews: PreviewProvider {
    static var previews: some View {
        NewQuestView()
            .environmentObject(GameManager())
    }
}