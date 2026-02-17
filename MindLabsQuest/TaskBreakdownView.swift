import SwiftUI

struct TaskBreakdownView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    let quest: Quest
    @State private var subtasks: [Subtask] = []
    @State private var newSubtaskTitle = ""
    @State private var showingSuggestions = true
    @State private var editingSubtaskId: UUID?
    @State private var editingText = ""
    
    var suggestedSteps: [String] {
        TaskBreakdownTemplate.getSuggestions(for: quest.category, title: quest.title)
    }
    
    var totalEstimatedTime: Int {
        subtasks.reduce(0) { $0 + $1.estimatedTime }
    }
    
    init(quest: Quest) {
        self.quest = quest
        self._subtasks = State(initialValue: quest.subtasks)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Quest Info Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(quest.category.icon)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(quest.title)
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
                        if showingSuggestions && subtasks.isEmpty {
                            SuggestionsCard(
                                suggestions: suggestedSteps,
                                onAccept: { acceptSuggestions() },
                                onDismiss: { showingSuggestions = false }
                            )
                        }
                        
                        // Subtasks List
                        if !subtasks.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Steps")
                                        .font(MindLabsTypography.headline())
                                        .foregroundColor(.mindLabsText)
                                    Spacer()
                                    Text("\(subtasks.count) steps • \(totalEstimatedTime) min total")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                                
                                ForEach(subtasks.indices, id: \.self) { index in
                                    SubtaskRow(
                                        subtask: $subtasks[index],
                                        isEditing: editingSubtaskId == subtasks[index].id,
                                        editingText: $editingText,
                                        onEdit: {
                                            startEditing(subtasks[index])
                                        },
                                        onSave: {
                                            saveEdit(index: index)
                                        },
                                        onDelete: {
                                            deleteSubtask(at: index)
                                        },
                                        onTimeChange: { minutes in
                                            subtasks[index].estimatedTime = minutes
                                        },
                                        onMoveUp: index > 0 ? {
                                            moveSubtask(from: index, to: index - 1)
                                        } : nil,
                                        onMoveDown: index < subtasks.count - 1 ? {
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
                        saveBreakdown()
                    }
                    .buttonStyle(MindLabsPrimaryButtonStyle())
                    .disabled(subtasks.isEmpty)
                }
                .padding()
                .background(Color.mindLabsCard)
            }
            .navigationTitle("Break Down Task")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
        }
    }
    
    private func acceptSuggestions() {
        subtasks = suggestedSteps.enumerated().map { index, step in
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
            order: subtasks.count
        )
        
        subtasks.append(newSubtask)
        newSubtaskTitle = ""
    }
    
    private func deleteSubtask(at index: Int) {
        subtasks.remove(at: index)
        // Reorder remaining subtasks
        for i in 0..<subtasks.count {
            subtasks[i].order = i
        }
    }
    
    private func moveSubtask(from: Int, to: Int) {
        let movingSubtask = subtasks[from]
        subtasks.remove(at: from)
        subtasks.insert(movingSubtask, at: to)
        
        // Update order
        for i in 0..<subtasks.count {
            subtasks[i].order = i
        }
    }
    
    private func startEditing(_ subtask: Subtask) {
        editingSubtaskId = subtask.id
        editingText = subtask.title
    }
    
    private func saveEdit(index: Int) {
        subtasks[index].title = editingText
        editingSubtaskId = nil
        editingText = ""
    }
    
    private func saveBreakdown() {
        gameManager.updateQuestSubtasks(quest.id, subtasks: subtasks)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Views
struct SuggestionsCard: View {
    let suggestions: [String]
    let onAccept: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Suggested Steps")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(suggestions.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                                .frame(width: 20)
                            Text(suggestions[index])
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)
                            Spacer()
                        }
                    }
                }
                
                Button("Use These Steps") {
                    onAccept()
                }
                .buttonStyle(MindLabsPrimaryButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct SubtaskRow: View {
    @Binding var subtask: Subtask
    let isEditing: Bool
    @Binding var editingText: String
    let onEdit: () -> Void
    let onSave: () -> Void
    let onDelete: () -> Void
    let onTimeChange: (Int) -> Void
    let onMoveUp: (() -> Void)?
    let onMoveDown: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                // Reorder buttons
                VStack(spacing: 5) {
                    if let moveUp = onMoveUp {
                        Button(action: moveUp) {
                            Image(systemName: "chevron.up")
                                .font(.caption)
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    } else {
                        Image(systemName: "chevron.up")
                            .font(.caption)
                            .foregroundColor(.clear)
                    }
                    
                    if let moveDown = onMoveDown {
                        Button(action: moveDown) {
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    } else {
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.clear)
                    }
                }
                .frame(width: 20)
                
                // Checkbox
                Button(action: {
                    subtask.toggleCompletion()
                }) {
                    Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(subtask.isCompleted ? .mindLabsSuccess : .mindLabsTextSecondary)
                        .font(.title3)
                }
                
                // Title
                if isEditing {
                    TextField("Step title", text: $editingText, onCommit: onSave)
                        .textFieldStyle(MindLabsTextFieldStyle())
                } else {
                    Text(subtask.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(subtask.isCompleted ? .mindLabsTextSecondary : .mindLabsText)
                        .strikethrough(subtask.isCompleted)
                        .onTapGesture {
                            onEdit()
                        }
                }
                
                Spacer()
                
                // Time estimate
                Menu {
                    ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { minutes in
                        Button("\(minutes) min") {
                            onTimeChange(minutes)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(subtask.estimatedTime) min")
                    }
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.mindLabsBorder.opacity(0.2))
                    .cornerRadius(5)
                }
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.mindLabsError)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.mindLabsBorder.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct AddSubtaskCard: View {
    @Binding var newSubtaskTitle: String
    let onAdd: () -> Void
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Add Step")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                HStack {
                    TextField("What needs to be done?", text: $newSubtaskTitle, onCommit: onAdd)
                        .textFieldStyle(MindLabsTextFieldStyle())
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                            .font(.title2)
                    }
                    .disabled(newSubtaskTitle.isEmpty)
                }
            }
        }
    }
}

struct TipsCard: View {
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                    Text("Tips for Breaking Down Tasks")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    TipRow(tip: "Keep steps small and specific")
                    TipRow(tip: "Each step should take 5-20 minutes")
                    TipRow(tip: "Order steps logically")
                    TipRow(tip: "Include breaks for long tasks")
                    TipRow(tip: "Add 'check' or 'review' steps")
                }
            }
        }
    }
}

struct TipRow: View {
    let tip: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundColor(.mindLabsTextSecondary)
            Text(tip)
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
            Spacer()
        }
    }
}