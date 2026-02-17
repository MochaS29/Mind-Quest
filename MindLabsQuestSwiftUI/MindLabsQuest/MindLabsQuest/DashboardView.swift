import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showNewQuestSheet = false
    @State private var showPredeterminedQuestSheet = false
    @State private var selectedCategory: TaskCategory? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Character Header
                    CharacterHeaderView()
                    
                    // Daily Progress
                    DailyProgressCard()
                    
                    // Weekly Progress
                    WeeklyProgressCard()
                    
                    // Analytics Quick Access
                    AnalyticsQuickAccessCard()
                    
                    // Active Routines
                    if !gameManager.routines.filter({ $0.isActive }).isEmpty {
                        ActiveRoutinesCard()
                    }
                    
                    // Quick Adventures
                    QuickAdventuresCard(showNewQuestSheet: $showNewQuestSheet, showPredeterminedQuestSheet: $showPredeterminedQuestSheet, selectedCategory: $selectedCategory)
                    
                    // Character Status
                    CharacterStatusCard()
                }
                .padding()
            }
            .navigationTitle("Mind Labs Quest")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(trailing:
                Button(action: {
                    showNewQuestSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                }
            )
        }
        .sheet(isPresented: $showNewQuestSheet) {
            NewQuestView()
        }
        .sheet(isPresented: $showPredeterminedQuestSheet) {
            QuickAdventureSelectionView(selectedCategory: selectedCategory)
        }
    }
}

struct CharacterHeaderView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 15) {
                HStack {
                    Text(gameManager.character.avatar)
                        .font(.system(size: 50))
                    
                    VStack(alignment: .leading) {
                        Text(gameManager.character.name)
                            .font(MindLabsTypography.title2())
                            .bold()
                            .foregroundColor(.mindLabsText)
                        
                        if let characterClass = gameManager.character.characterClass {
                            Text("Level \(gameManager.character.level) \(characterClass.rawValue)")
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        
                        if gameManager.character.streak > 0 {
                            HStack(spacing: 4) {
                                Text("🔥")
                                    .font(.system(size: 16))
                                Text("\(gameManager.character.streak) day streak")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("\(gameManager.character.gold)")
                                .bold()
                                .foregroundColor(.mindLabsText)
                        }
                        
                        Text("\(gameManager.character.xp)/\(gameManager.character.xpToNext) XP")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                // Health Bar
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(gameManager.character.health)/\(gameManager.character.maxHealth)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsText)
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.mindLabsBorder.opacity(0.5))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(LinearGradient(colors: [Color.mindLabsError.opacity(0.8), Color.mindLabsError], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geometry.size.width * CGFloat(gameManager.character.health) / CGFloat(gameManager.character.maxHealth), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
                
                // XP Bar
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.blue)
                        Text("Level \(gameManager.character.level)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsText)
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.mindLabsBorder.opacity(0.5))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(LinearGradient.mindLabsPrimary)
                                .frame(width: geometry.size.width * CGFloat(gameManager.character.xp) / CGFloat(gameManager.character.xpToNext), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
    }
}

struct DailyProgressCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var progress: Double {
        guard gameManager.todayQuests.count > 0 else { return 0 }
        return Double(gameManager.completedTodayCount) / Double(gameManager.todayQuests.count)
    }
    
    var questsWithSubtasks: Int {
        gameManager.todayQuests.filter { $0.hasSubtasks }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Today's Adventures")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.white)
                Spacer()
                Text("\(gameManager.completedTodayCount)/\(gameManager.todayQuests.count) completed")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.white.opacity(0.8))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 12)
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(LinearGradient.mindLabsAccent)
                        .frame(width: geometry.size.width * progress, height: 12)
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text(gameManager.completedTodayCount == gameManager.todayQuests.count && gameManager.todayQuests.count > 0 
                     ? "🎉 All adventures completed! Epic!" 
                     : "\(gameManager.todayQuests.count - gameManager.completedTodayCount) adventures remaining")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.white.opacity(0.8))
                
                if questsWithSubtasks > 0 {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet.indent")
                            .font(.caption2)
                        Text("\(questsWithSubtasks)")
                            .font(MindLabsTypography.caption2())
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(LinearGradient.mindLabsPrimary)
        .foregroundColor(.white)
        .cornerRadius(15)
        .mindLabsCardShadow()
    }
}

struct QuickAdventuresCard: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showNewQuestSheet: Bool
    @Binding var showPredeterminedQuestSheet: Bool
    @Binding var selectedCategory: TaskCategory?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Quick Adventures")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: {
                            selectedCategory = nil
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
                }
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            showPredeterminedQuestSheet = true
                        }) {
                            VStack(spacing: 8) {
                                Text(category.icon)
                                    .font(.system(size: 30))
                                Text(category.rawValue)
                                    .font(MindLabsTypography.caption())
                                    .bold()
                                Text("+\(category.primaryStat.rawValue.prefix(3).uppercased())")
                                    .font(MindLabsTypography.caption2())
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [category.color.opacity(0.8), category.color], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .mindLabsButtonShadow()
                        }
                    }
                }
            }
        }
    }
}

struct CharacterStatusCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Character Status")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                HStack {
                    Text(gameManager.character.avatar)
                        .font(.system(size: 60))
                    
                    VStack(alignment: .leading) {
                        Text(gameManager.character.name)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        if let characterClass = gameManager.character.characterClass {
                            Text("Level \(gameManager.character.level) \(characterClass.rawValue)")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        
                        Text("Next Level: \(gameManager.character.xpToNext - gameManager.character.xp) XP")
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsPurple)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct WeeklyProgressCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var weekData: [(date: Date, completed: Int, total: Int)] {
        var data: [(date: Date, completed: Int, total: Int)] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let dailyQuests = gameManager.quests.filter { quest in
                quest.isDaily && calendar.isDate(quest.createdDate, inSameDayAs: date)
            }
            
            let completed = dailyQuests.filter { $0.isCompleted }.count
            let total = dailyQuests.count
            
            data.append((date: date, completed: completed, total: total))
        }
        
        return data.reversed()
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("7-Day Progress")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                HStack(spacing: 8) {
                    ForEach(weekData, id: \.date) { dayData in
                        VStack(spacing: 5) {
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .bottom) {
                                    Rectangle()
                                        .fill(Color.mindLabsBorder.opacity(0.3))
                                        .cornerRadius(4)
                                    
                                    if dayData.total > 0 {
                                        Rectangle()
                                            .fill(LinearGradient.mindLabsPrimary)
                                            .frame(height: geometry.size.height * CGFloat(dayData.completed) / CGFloat(dayData.total))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                            .frame(height: 60)
                            
                            // Day label
                            Text(dayLabel(for: dayData.date))
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            // Count
                            Text("\(dayData.completed)/\(dayData.total)")
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsPurple)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                HStack {
                    Circle()
                        .fill(LinearGradient.mindLabsPrimary)
                        .frame(width: 10, height: 10)
                    Text("Completed")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.mindLabsBorder.opacity(0.3))
                        .frame(width: 10, height: 10)
                    Text("Total")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
        }
    }
    
    private func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        }
    }
}

struct QuickAdventureSelectionView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    let selectedCategory: TaskCategory?
    
    var filteredTemplates: [DailyQuestTemplate] {
        let templates = DailyQuestTemplate.allTemplates
        
        if let category = selectedCategory {
            return templates.filter { $0.category == category }
        }
        return templates
    }
    
    var suggestedTemplates: [DailyQuestTemplate] {
        // Show up to 6 templates that fit the current time of day
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: DailyQuestTemplate.TimeOfDay
        
        if hour < 12 {
            timeOfDay = .morning
        } else if hour < 17 {
            timeOfDay = .afternoon
        } else {
            timeOfDay = .evening
        }
        
        return filteredTemplates
            .filter { $0.timeOfDay == timeOfDay || $0.timeOfDay == .anytime }
            .shuffled()
            .prefix(6)
            .map { $0 }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Choose Your Adventure")
                    .font(MindLabsTypography.title2())
                    .foregroundColor(.mindLabsText)
                    .padding(.top)
                
                if let category = selectedCategory {
                    Text("\(category.icon) \(category.rawValue) Quests")
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsTextSecondary)
                        .padding(.bottom)
                }
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(suggestedTemplates, id: \.id) { template in
                            QuickQuestCard(template: template) {
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
                        
                        Button("Create Custom Quest") {
                            presentationMode.wrappedValue.dismiss()
                            // This will trigger the new quest sheet
                        }
                        .buttonStyle(MindLabsSecondaryButtonStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    }
                    .padding()
                }
            }
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

struct QuickQuestCard: View {
    let template: DailyQuestTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            MindLabsCard {
                HStack {
                    Text(template.icon)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(template.normalTitle)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        HStack {
                            Label("\(template.baseXP) XP", systemImage: "star.fill")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsBlue)
                            
                            Label("\(template.estimatedTime) min", systemImage: "clock")
                                .font(MindLabsTypography.caption())
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
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                        .font(.title2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActiveRoutinesCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var activeRoutines: [Routine] {
        gameManager.routines.filter { $0.isActive }.prefix(2).map { $0 }
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Daily Routines")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    Spacer()
                    NavigationLink(destination: RoutinesView()) {
                        HStack(spacing: 4) {
                            Text("View All")
                                .font(MindLabsTypography.caption())
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.mindLabsPurple)
                    }
                }
                
                ForEach(activeRoutines.indices, id: \.self) { index in
                    let routine = activeRoutines[index]
                    HStack {
                        Text(routine.icon)
                            .font(.system(size: 30))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(routine.name)
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)
                            
                            HStack {
                                // Progress bar mini
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.mindLabsBorder.opacity(0.3))
                                            .frame(height: 4)
                                            .cornerRadius(2)
                                        
                                        Rectangle()
                                            .fill(
                                                routine.isCompletedToday
                                                    ? LinearGradient(colors: [Color.mindLabsSuccess], startPoint: .leading, endPoint: .trailing)
                                                    : LinearGradient.mindLabsPrimary
                                            )
                                            .frame(width: geometry.size.width * routine.progressToday, height: 4)
                                            .cornerRadius(2)
                                    }
                                }
                                .frame(width: 80, height: 4)
                                
                                Text("\(routine.completedStepsToday)/\(routine.steps.count)")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        if routine.isCompletedToday {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.mindLabsSuccess)
                        } else if routine.completionStreak > 0 {
                            HStack(spacing: 2) {
                                Text("🔥")
                                    .font(.caption)
                                Text("\(routine.completionStreak)")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    if index < activeRoutines.count - 1 {
                        Divider()
                    }
                }
                
                if gameManager.routines.filter({ $0.isActive }).count > 2 {
                    Text("+\(gameManager.routines.filter({ $0.isActive }).count - 2) more routines")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct AnalyticsQuickAccessCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        MindLabsCard {
            Button(action: {
                gameManager.currentView = .analytics
            }) {
                HStack(spacing: 15) {
                    // Analytics Icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient.mindLabsPrimary.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundColor(.mindLabsPurple)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("View Analytics")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        HStack(spacing: 15) {
                            HStack(spacing: 4) {
                                Text("🔥")
                                    .font(.caption)
                                Text("\(gameManager.character.streak) day streak")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.orange)
                            }
                            
                            Text("•")
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.mindLabsSuccess)
                                Text("\(gameManager.character.totalQuestsCompleted) quests")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.mindLabsTextSecondary)
                }
                .padding(.vertical, 5)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(GameManager())
    }
}