import SwiftUI

struct QuestsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showNewQuestSheet = false
    @State private var showPredeterminedQuestSheet = false
    @State private var filterCategory: TaskCategory?
    @State private var showCompletedQuests = false
    
    var filteredQuests: [Quest] {
        gameManager.quests
            .filter { quest in
                if !showCompletedQuests && quest.isCompleted {
                    return false
                }
                if let filterCategory = filterCategory {
                    return quest.category == filterCategory
                }
                return true
            }
            .sorted { !$0.isCompleted && $1.isCompleted }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        QuestFilterChip(
                            title: "All",
                            isSelected: filterCategory == nil,
                            action: { filterCategory = nil }
                        )
                        
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            QuestFilterChip(
                                title: "\(category.icon) \(category.rawValue)",
                                isSelected: filterCategory == category,
                                action: { filterCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Toggle for completed quests
                Toggle("Show Completed", isOn: $showCompletedQuests)
                    .padding(.horizontal)
                    .tint(.mindLabsPurple)
                
                // Quests List
                if filteredQuests.isEmpty && !showCompletedQuests {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("🎯")
                            .font(.system(size: 80))
                        Text("No active quests")
                            .font(MindLabsTypography.title2())
                            .foregroundColor(.mindLabsText)
                        Text("Create your first adventure!")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsTextSecondary)
                        HStack(spacing: 15) {
                            Button("Create Custom Quest") {
                                showNewQuestSheet = true
                            }
                            .buttonStyle(MindLabsPrimaryButtonStyle())
                            .frame(width: 180)
                            
                            Button("Choose Preset") {
                                showPredeterminedQuestSheet = true
                            }
                            .buttonStyle(MindLabsSecondaryButtonStyle())
                            .frame(width: 180)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(filteredQuests) { quest in
                                QuestCard(quest: quest)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Adventures")
            .mindLabsBackground()
            .navigationBarItems(trailing:
                HStack(spacing: 15) {
                    Button(action: {
                        showPredeterminedQuestSheet = true
                    }) {
                        Image(systemName: "list.bullet.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                    }
                    
                    Button(action: {
                        showNewQuestSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                    }
                }
            )
        }
        .sheet(isPresented: $showNewQuestSheet) {
            NewQuestView()
        }
        .sheet(isPresented: $showPredeterminedQuestSheet) {
            PredeterminedQuestSelectionView()
        }
    }
}

struct QuestFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MindLabsTypography.caption())
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient.mindLabsPrimary
                        } else {
                            Color.mindLabsBorder.opacity(0.2)
                        }
                    }
                )
                .foregroundColor(isSelected ? .white : .mindLabsText)
                .cornerRadius(20)
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.spring(response: 0.3), value: isSelected)
        }
    }
}

struct QuestCard: View {
    let quest: Quest
    @EnvironmentObject var gameManager: GameManager
    @State private var showTimer = false
    @State private var showBreakdown = false
    @State private var expandSubtasks = false
    
    var difficultyColor: Color {
        switch quest.difficulty {
        case .easy: return .mindLabsSuccess
        case .medium: return .mindLabsWarning
        case .hard: return .mindLabsError
        }
    }
    
    var body: some View {
        MindLabsCard(padding: 15) {
            HStack {
                // Category Icon
                Text(quest.category.icon)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            colors: [quest.category.color.opacity(0.3), quest.category.color.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(quest.title)
                        .font(MindLabsTypography.headline())
                        .foregroundColor(quest.isCompleted ? .mindLabsTextSecondary : .mindLabsText)
                        .strikethrough(quest.isCompleted)
                    
                    HStack {
                        Label("\(quest.xpReward) XP", systemImage: "star.fill")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsBlue)
                        
                        Label("\(quest.goldReward) Gold", systemImage: "bitcoinsign.circle.fill")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.yellow)
                        
                        Text(quest.difficulty.rawValue)
                            .font(MindLabsTypography.caption2())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(difficultyColor.opacity(0.2))
                            .foregroundColor(difficultyColor)
                            .cornerRadius(5)
                    }
                    
                    // Subtask Progress
                    if quest.hasSubtasks {
                        HStack {
                            ProgressView(value: quest.subtaskProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .mindLabsPurple))
                                .frame(height: 4)
                            
                            Text("\(quest.completedSubtaskCount)/\(quest.subtasks.count)")
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    expandSubtasks.toggle()
                                }
                            }) {
                                Image(systemName: expandSubtasks ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                    
                    if !quest.isCompleted {
                        HStack {
                            Label("\(quest.estimatedTime) min", systemImage: "clock")
                                .font(MindLabsTypography.footnote())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Spacer()
                            
                            HStack(spacing: 10) {
                                Button(action: {
                                    gameManager.completeQuest(quest)
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.mindLabsSuccess)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    showTimer = true
                                }) {
                                    Image(systemName: "timer")
                                        .foregroundColor(.mindLabsPurple)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if !quest.hasSubtasks {
                                    Button(action: {
                                        showBreakdown = true
                                    }) {
                                        Image(systemName: "list.bullet.indent")
                                            .foregroundColor(.mindLabsWarning)
                                            .font(.title2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    } else if let completedAt = quest.completedAt,
                              Date().timeIntervalSince(completedAt) < 3600 { // Within 1 hour
                        HStack {
                            Label("Completed", systemImage: "checkmark.circle.fill")
                                .font(MindLabsTypography.footnote())
                                .foregroundColor(.mindLabsSuccess)
                            
                            Spacer()
                            
                            Button(action: {
                                gameManager.reactivateQuest(quest)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                    Text("Undo")
                                }
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsWarning)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            
            // Expanded Subtasks
            if expandSubtasks && quest.hasSubtasks {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 5)
                    
                    ForEach(quest.subtasks) { subtask in
                        HStack {
                            Button(action: {
                                gameManager.toggleSubtask(subtask.id, in: quest.id)
                            }) {
                                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(subtask.isCompleted ? .mindLabsSuccess : .mindLabsTextSecondary)
                                    .font(.caption)
                            }
                            
                            Text(subtask.title)
                                .font(MindLabsTypography.caption())
                                .foregroundColor(subtask.isCompleted ? .mindLabsTextSecondary : .mindLabsText)
                                .strikethrough(subtask.isCompleted)
                            
                            Spacer()
                            
                            Text("\(subtask.estimatedTime) min")
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
        .opacity(quest.isCompleted ? 0.7 : 1.0)
        .sheet(isPresented: $showTimer) {
            PomodoroTimerView(quest: quest)
        }
        .sheet(isPresented: $showBreakdown) {
            TaskBreakdownView(quest: quest)
        }
    }
}

struct PredeterminedQuestSelectionView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTemplateId: String? = nil
    @State private var selectedCategory: TaskCategory? = nil
    @State private var searchText = ""
    
    var filteredTemplates: [DailyQuestTemplate] {
        let templates = DailyQuestTemplate.allTemplates
        
        return templates.filter { template in
            let matchesCategory = selectedCategory == nil || template.category == selectedCategory
            let matchesSearch = searchText.isEmpty || 
                template.epicTitle.localizedCaseInsensitiveContains(searchText) ||
                template.normalTitle.localizedCaseInsensitiveContains(searchText)
            
            return matchesCategory && matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.mindLabsTextSecondary)
                    TextField("Search quests...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color.mindLabsBorder.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        QuestFilterChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            QuestFilterChip(
                                title: "\(category.icon) \(category.rawValue)",
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Quest Templates List
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(filteredTemplates, id: \.id) { template in
                            PredeterminedQuestCard(
                                template: template,
                                isSelected: selectedTemplateId == template.id,
                                onTap: {
                                    selectedTemplateId = template.id
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Choose Adventure")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple),
                
                trailing: Button("Add Quest") {
                    if let templateId = selectedTemplateId,
                       let template = DailyQuestTemplate.allTemplates.first(where: { $0.id == templateId }) {
                        let quest = Quest(
                            title: template.epicTitle,
                            description: template.normalTitle,
                            category: template.category,
                            difficulty: template.difficulty,
                            estimatedTime: template.estimatedTime,
                            isDaily: false,
                            questTemplate: template
                        )
                        gameManager.addQuest(quest)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(.mindLabsPurple)
                .disabled(selectedTemplateId == nil)
            )
            .mindLabsBackground()
        }
    }
}

struct PredeterminedQuestCard: View {
    let template: DailyQuestTemplate
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            MindLabsCard {
                HStack {
                    Text(template.icon)
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                colors: [template.category.color.opacity(0.3), template.category.color.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(template.epicTitle)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                            .lineLimit(1)
                        
                        Text(template.normalTitle)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        HStack {
                            Label("\(template.baseXP) XP", systemImage: "star.fill")
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsBlue)
                            
                            Label("\(template.estimatedTime) min", systemImage: "clock")
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Text(template.difficulty.rawValue)
                                .font(MindLabsTypography.caption2())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(template.difficulty.color.opacity(0.2))
                                .foregroundColor(template.difficulty.color)
                                .cornerRadius(5)
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                            .font(.title2)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.mindLabsPurple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuestsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestsView()
            .environmentObject(GameManager())
    }
}