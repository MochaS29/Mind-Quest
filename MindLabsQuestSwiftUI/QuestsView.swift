import SwiftUI

struct QuestsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showNewQuestSheet = false
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
                        FilterChip(
                            title: "All",
                            isSelected: filterCategory == nil,
                            action: { filterCategory = nil }
                        )
                        
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            FilterChip(
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
                
                // Quests List
                if filteredQuests.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "scroll")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No adventures yet!")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Button("Create Your First Quest") {
                            showNewQuestSheet = true
                        }
                        .foregroundColor(.purple)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewQuestSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .sheet(isPresented: $showNewQuestSheet) {
            NewQuestView()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct QuestCard: View {
    @EnvironmentObject var gameManager: GameManager
    let quest: Quest
    @State private var showingTimer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(quest.category.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.headline)
                        .strikethrough(quest.isCompleted)
                    
                    if !quest.description.isEmpty {
                        Text(quest.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if quest.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            HStack {
                // Difficulty Badge
                Text(quest.difficulty.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(quest.difficulty.color.opacity(0.2))
                    .foregroundColor(quest.difficulty.color)
                    .cornerRadius(12)
                
                // Time
                Label("\(quest.estimatedTime)m", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Rewards
                HStack(spacing: 10) {
                    Label("\(quest.xpReward)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Label("\(quest.goldReward)", systemImage: "bitcoinsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            if !quest.isCompleted {
                HStack(spacing: 10) {
                    Button(action: {
                        showingTimer = true
                    }) {
                        Label("Start Timer", systemImage: "timer")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        gameManager.completeQuest(quest)
                    }) {
                        Label("Complete", systemImage: "checkmark")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingTimer) {
            TimerView(quest: quest)
        }
    }
}

struct QuestsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestsView()
            .environmentObject(GameManager())
    }
}