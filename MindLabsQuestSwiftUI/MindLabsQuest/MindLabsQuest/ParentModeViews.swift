import SwiftUI

// MARK: - Add/Edit Reward Views
struct AddRewardView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var requiredLevel = 5
    @State private var selectedRequirements: Set<RequirementType> = []
    @State private var streakDays = 3
    @State private var achievementCount = 5
    @State private var questCount = 25
    @State private var focusMinutes = 60
    
    enum RequirementType: String, CaseIterable {
        case streak = "Minimum Streak"
        case achievements = "Achievements Unlocked"
        case quests = "Quests Completed"
        case focus = "Focus Minutes"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Reward Details") {
                    TextField("Reward Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section("Level Requirement") {
                    Stepper("Level \(requiredLevel)", value: $requiredLevel, in: 1...50)
                }
                
                Section("Additional Requirements") {
                    ForEach(RequirementType.allCases, id: \.self) { requirement in
                        HStack {
                            Button(action: {
                                if selectedRequirements.contains(requirement) {
                                    selectedRequirements.remove(requirement)
                                } else {
                                    selectedRequirements.insert(requirement)
                                }
                            }) {
                                HStack {
                                    Image(systemName: selectedRequirements.contains(requirement) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(.mindLabsPurple)
                                    Text(requirement.rawValue)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            if selectedRequirements.contains(requirement) {
                                switch requirement {
                                case .streak:
                                    Stepper("\(streakDays) days", value: $streakDays, in: 1...30)
                                case .achievements:
                                    Stepper("\(achievementCount)", value: $achievementCount, in: 1...20)
                                case .quests:
                                    Stepper("\(questCount)", value: $questCount, in: 5...100, step: 5)
                                case .focus:
                                    Stepper("\(focusMinutes) min", value: $focusMinutes, in: 15...300, step: 15)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Reward")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveReward()
                }
                .disabled(title.isEmpty || description.isEmpty)
            )
        }
    }
    
    private func saveReward() {
        var requirements: [ParentReward.RewardRequirement] = []
        
        if selectedRequirements.contains(.streak) {
            requirements.append(.minimumStreak(days: streakDays))
        }
        if selectedRequirements.contains(.achievements) {
            requirements.append(.achievementCount(count: achievementCount))
        }
        if selectedRequirements.contains(.quests) {
            requirements.append(.questsCompleted(count: questCount))
        }
        if selectedRequirements.contains(.focus) {
            requirements.append(.focusMinutes(minutes: focusMinutes))
        }
        
        let reward = ParentReward(
            title: title,
            description: description,
            requiredLevel: requiredLevel,
            additionalRequirements: requirements
        )
        
        gameManager.parentRewardManager.addReward(reward)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditRewardView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    let reward: ParentReward
    
    @State private var isActive: Bool
    @State private var showDeleteAlert = false
    
    init(reward: ParentReward) {
        self.reward = reward
        self._isActive = State(initialValue: reward.isActive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Reward Details") {
                    HStack {
                        Text("Title")
                        Spacer()
                        Text(reward.title)
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    HStack {
                        Text("Description")
                        Spacer()
                        Text(reward.description)
                            .foregroundColor(.mindLabsTextSecondary)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Required Level")
                        Spacer()
                        Text("\(reward.requiredLevel)")
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                if !reward.additionalRequirements.isEmpty {
                    Section("Additional Requirements") {
                        ForEach(reward.additionalRequirements.indices, id: \.self) { index in
                            Text(reward.additionalRequirements[index].description)
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                }
                
                Section("Status") {
                    Toggle("Active", isOn: $isActive)
                        .tint(.mindLabsPurple)
                }
                
                if reward.isClaimed {
                    Section("History") {
                        if let claimedDate = reward.claimedDate {
                            HStack {
                                Text("Claimed")
                                Spacer()
                                Text(claimedDate, style: .date)
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        
                        if let approvedDate = reward.approvedDate {
                            HStack {
                                Text("Approved")
                                Spacer()
                                Text(approvedDate, style: .date)
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        
                        Button("Reset Reward") {
                            gameManager.parentRewardManager.resetReward(reward)
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                Section {
                    Button("Delete Reward") {
                        showDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Reward")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    var updatedReward = reward
                    updatedReward.isActive = isActive
                    gameManager.parentRewardManager.updateReward(updatedReward)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert("Delete Reward?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    gameManager.parentRewardManager.deleteReward(reward)
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}

// MARK: - Parent Progress View
struct ParentProgressView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Character Overview
                MindLabsCard {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Character Progress")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(gameManager.character.name)
                                    .font(MindLabsTypography.title2())
                                    .foregroundColor(.mindLabsText)
                                Text("Level \(gameManager.character.level)")
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            
                            Spacer()
                            
                            Text(gameManager.character.avatar)
                                .font(.system(size: 60))
                        }
                        
                        // Stats
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            StatCard(title: "Quests", value: "\(gameManager.character.totalQuestsCompleted)", icon: "checkmark.circle.fill", color: .blue)
                            StatCard(title: "Streak", value: "\(gameManager.character.streak) days", icon: "flame.fill", color: .orange)
                            StatCard(title: "Focus Time", value: "\(gameManager.character.totalFocusMinutes) min", icon: "timer", color: .green)
                            StatCard(title: "Achievements", value: "\(gameManager.achievementManager.unlockedCount)", icon: "trophy.fill", color: .purple)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Recent Activity
                MindLabsCard {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Activity")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        ForEach(gameManager.quests.filter { $0.isCompleted }.prefix(5)) { quest in
                            HStack {
                                Text(quest.category.icon)
                                    .font(.title3)
                                
                                VStack(alignment: .leading) {
                                    Text(quest.title)
                                        .font(MindLabsTypography.subheadline())
                                        .foregroundColor(.mindLabsText)
                                    if let completedAt = quest.completedAt {
                                        Text(completedAt, style: .relative)
                                            .font(MindLabsTypography.caption())
                                            .foregroundColor(.mindLabsTextSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.mindLabsSuccess)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            Text(title)
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.mindLabsBorder.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Parent Settings View
struct ParentSettingsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showChangePIN = false
    @State private var showResetData = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MindLabsCard {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Security")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Button(action: {
                            showChangePIN = true
                        }) {
                            HStack {
                                Image(systemName: "lock.rotation")
                                Text("Change PIN")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            .foregroundColor(.mindLabsText)
                        }
                    }
                }
                .padding(.horizontal)
                
                MindLabsCard {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Notifications")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Toggle("Reward Claims", isOn: .constant(true))
                            .tint(.mindLabsPurple)
                        
                        Toggle("Level Milestones", isOn: .constant(true))
                            .tint(.mindLabsPurple)
                        
                        Toggle("Weekly Progress", isOn: .constant(true))
                            .tint(.mindLabsPurple)
                    }
                }
                .padding(.horizontal)
                
                MindLabsCard {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quest Guide")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        NavigationLink(destination: QuestTranslationGuideView()) {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("Quest Translation Guide")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            .foregroundColor(.mindLabsText)
                        }
                        
                        Text("See what epic quest names mean")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                .padding(.horizontal)
                
                MindLabsCard {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Data")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Button(action: {
                            gameManager.parentRewardManager.setupDefaultRewards()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset to Default Rewards")
                                Spacer()
                            }
                            .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showChangePIN) {
            ChangePINView()
        }
    }
}

struct ChangePINView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentPIN = ""
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Change PIN")
                    .font(MindLabsTypography.title2())
                    .foregroundColor(.mindLabsText)
                
                VStack(spacing: 20) {
                    SecureField("Current PIN", text: $currentPIN)
                        .textFieldStyle(MindLabsTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 200)
                    
                    SecureField("New PIN", text: $newPIN)
                        .textFieldStyle(MindLabsTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 200)
                    
                    SecureField("Confirm New PIN", text: $confirmPIN)
                        .textFieldStyle(MindLabsTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 200)
                    
                    if showError {
                        Text("Current PIN is incorrect")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsError)
                    }
                    
                    Button("Change PIN") {
                        if gameManager.parentRewardManager.verifyPIN(currentPIN) {
                            if newPIN == confirmPIN && newPIN.count == 4 {
                                gameManager.parentRewardManager.setPIN(newPIN)
                                presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            showError = true
                        }
                    }
                    .buttonStyle(MindLabsPrimaryButtonStyle())
                    .frame(width: 200)
                    .disabled(newPIN != confirmPIN || newPIN.count != 4)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
            .mindLabsBackground()
        }
    }
}

// MARK: - Quest Translation Guide View
struct QuestTranslationGuideView: View {
    @State private var searchText = ""
    @State private var selectedCategory: TaskCategory? = nil
    
    var filteredQuests: [DailyQuestTemplate] {
        let quests = DailyQuestTemplate.allTemplates
        
        if searchText.isEmpty && selectedCategory == nil {
            return quests
        }
        
        return quests.filter { quest in
            let matchesSearch = searchText.isEmpty || 
                quest.epicTitle.localizedCaseInsensitiveContains(searchText) ||
                quest.normalTitle.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || quest.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var groupedQuests: [(key: TaskCategory, value: [DailyQuestTemplate])] {
        Dictionary(grouping: filteredQuests, by: { $0.category })
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.mindLabsTextSecondary)
                    TextField("Search quests...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(12)
                .background(Color.mindLabsBorder.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryFilterChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            CategoryFilterChip(
                                title: "\(category.icon) \(category.rawValue)",
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Quest list grouped by category
                ForEach(groupedQuests, id: \.key) { category, quests in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(category.icon) \(category.rawValue)")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                            .padding(.horizontal)
                        
                        ForEach(quests, id: \.id) { quest in
                            QuestTranslationCard(quest: quest)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Quest Translation Guide")
        .navigationBarTitleDisplayMode(.inline)
        .mindLabsBackground()
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MindLabsTypography.caption())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.mindLabsPurple : Color.mindLabsBorder.opacity(0.1))
                .foregroundColor(isSelected ? .white : .mindLabsText)
                .cornerRadius(15)
        }
    }
}

struct QuestTranslationCard: View {
    let quest: DailyQuestTemplate
    @State private var isExpanded = false
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(quest.icon)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quest.epicTitle)
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsPurple)
                            .fontWeight(.semibold)
                        
                        Text("→ \(quest.normalTitle)")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsText)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.mindLabsTextSecondary)
                            .font(.caption)
                    }
                }
                
                if isExpanded {
                    Divider()
                        .background(Color.mindLabsBorder)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 15) {
                            Label("\(quest.estimatedTime) min", systemImage: "clock")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Label(quest.difficulty.rawValue, systemImage: "star.fill")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(quest.difficulty.color)
                        }
                        
                        HStack(spacing: 15) {
                            Label("\(quest.baseXP) XP", systemImage: "sparkles")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsPurple)
                            
                            Label("\(quest.baseGold) Gold", systemImage: "bitcoinsign.circle")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsWarning)
                        }
                        
                        if quest.timeOfDay != .anytime {
                            Label("Best done: \(quest.timeOfDay.rawValue)", systemImage: "calendar")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}