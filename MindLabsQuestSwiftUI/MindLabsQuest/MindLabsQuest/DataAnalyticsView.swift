import SwiftUI

struct DataAnalyticsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: MetricType = .productivity
    @State private var showingExportView = false
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case allTime = "All Time"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .allTime: return 365
            }
        }
    }
    
    enum MetricType: String, CaseIterable {
        case productivity = "Productivity"
        case habits = "Habits"
        case achievements = "Achievements"
        case focus = "Focus Time"
        
        var icon: String {
            switch self {
            case .productivity: return "chart.line.uptrend.xyaxis"
            case .habits: return "repeat.circle"
            case .achievements: return "trophy"
            case .focus: return "timer"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Selector
                    TimeRangePicker(selectedRange: $selectedTimeRange)
                    
                    // Key Metrics Overview
                    KeyMetricsCard()
                    
                    // Metric Type Selector
                    MetricTypePicker(selectedMetric: $selectedMetric)
                    
                    // Dynamic Content Based on Selected Metric
                    switch selectedMetric {
                    case .productivity:
                        ProductivityAnalyticsSection(timeRange: selectedTimeRange)
                    case .habits:
                        HabitsAnalyticsSection(timeRange: selectedTimeRange)
                    case .achievements:
                        AchievementsAnalyticsSection()
                    case .focus:
                        FocusTimeAnalyticsSection(timeRange: selectedTimeRange)
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(
                trailing: Button(action: { showingExportView = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.mindLabsPurple)
                }
            )
            .sheet(isPresented: $showingExportView) {
                DataExportView()
                    .environmentObject(gameManager)
            }
        }
    }
}

// MARK: - Time Range Picker
struct TimeRangePicker: View {
    @Binding var selectedRange: DataAnalyticsView.TimeRange
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(DataAnalyticsView.TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedRange = range
                    }
                }) {
                    Text(range.rawValue)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(selectedRange == range ? .white : .mindLabsText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            selectedRange == range ?
                            LinearGradient.mindLabsPrimary :
                            LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .padding(5)
        .background(Color.mindLabsCard)
        .clipShape(Capsule())
    }
}

// MARK: - Metric Type Picker
struct MetricTypePicker: View {
    @Binding var selectedMetric: DataAnalyticsView.MetricType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(DataAnalyticsView.MetricType.allCases, id: \.self) { metric in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedMetric = metric
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: metric.icon)
                                .font(.title2)
                                .foregroundColor(selectedMetric == metric ? .mindLabsPurple : .mindLabsTextSecondary)
                            
                            Text(metric.rawValue)
                                .font(MindLabsTypography.caption())
                                .foregroundColor(selectedMetric == metric ? .mindLabsText : .mindLabsTextSecondary)
                        }
                        .frame(width: 90, height: 80)
                        .background(
                            selectedMetric == metric ?
                            Color.mindLabsPurple.opacity(0.1) :
                            Color.mindLabsCard
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMetric == metric ? Color.mindLabsPurple : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - Key Metrics Card
struct KeyMetricsCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 20) {
                Text("Overview")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 20) {
                    MetricItem(
                        title: "Streak",
                        value: "\(gameManager.character.streak)",
                        subtitle: "days",
                        color: .mindLabsError,
                        icon: "flame.fill"
                    )
                    
                    MetricItem(
                        title: "Level",
                        value: "\(gameManager.character.level)",
                        subtitle: "Lvl",
                        color: .mindLabsPurple,
                        icon: "star.fill"
                    )
                    
                    MetricItem(
                        title: "Quests",
                        value: "\(gameManager.character.totalQuestsCompleted)",
                        subtitle: "done",
                        color: .mindLabsSuccess,
                        icon: "checkmark.circle.fill"
                    )
                    
                    MetricItem(
                        title: "Focus",
                        value: "\(gameManager.character.totalFocusMinutes / 60)",
                        subtitle: "hrs",
                        color: .mindLabsBlue,
                        icon: "timer"
                    )
                }
            }
        }
    }
}

struct MetricItem: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(MindLabsTypography.title2())
                    .foregroundColor(.mindLabsText)
                Text(subtitle)
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            
            Text(title)
                .font(MindLabsTypography.caption2())
                .foregroundColor(.mindLabsTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Productivity Analytics Section
struct ProductivityAnalyticsSection: View {
    @EnvironmentObject var gameManager: GameManager
    let timeRange: DataAnalyticsView.TimeRange
    
    var questsPerDay: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -timeRange.days, to: endDate)!
        
        var dailyCounts: [(date: Date, count: Int)] = []
        
        for dayOffset in 0..<timeRange.days {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: endDate)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let count = gameManager.quests.filter { quest in
                if let completedAt = quest.completedAt {
                    return completedAt >= dayStart && completedAt < dayEnd
                }
                return false
            }.count
            
            dailyCounts.append((date: dayStart, count: count))
        }
        
        return dailyCounts.reversed()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Productivity Chart
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Quest Completion Trend")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    CustomLineChart(data: questsPerDay.map { Double($0.count) })
                        .frame(height: 200)
                        .padding(.top, 10)
                    
                    // X-axis labels
                    HStack {
                        ForEach(questsPerDay.indices, id: \.self) { index in
                            if index % (timeRange == .week ? 1 : 7) == 0 {
                                Text(formatDate(questsPerDay[index].date))
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            
            // Category Breakdown
            CategoryBreakdownCard(timeRange: timeRange)
            
            // Productivity Insights
            ProductivityInsightsCard(questsData: questsPerDay)
        }
    }
}

// MARK: - Category Breakdown Card
struct CategoryBreakdownCard: View {
    @EnvironmentObject var gameManager: GameManager
    let timeRange: DataAnalyticsView.TimeRange
    
    var categoryData: [(category: TaskCategory, count: Int, percentage: Double)] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -timeRange.days, to: endDate)!
        
        let relevantQuests = gameManager.quests.filter { quest in
            if let completedAt = quest.completedAt {
                return completedAt >= startDate && completedAt <= endDate
            }
            return false
        }
        
        let total = relevantQuests.count
        guard total > 0 else { return [] }
        
        var categoryCounts: [TaskCategory: Int] = [:]
        for quest in relevantQuests {
            categoryCounts[quest.category, default: 0] += 1
        }
        
        return categoryCounts.map { category, count in
            (category: category, count: count, percentage: Double(count) / Double(total))
        }.sorted { $0.count > $1.count }
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Category Focus")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                if categoryData.isEmpty {
                    Text("No completed quests in this time range")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    VStack(spacing: 12) {
                        ForEach(categoryData, id: \.category) { item in
                            HStack {
                                Text(item.category.icon)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.category.rawValue)
                                        .font(MindLabsTypography.subheadline())
                                        .foregroundColor(.mindLabsText)
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color.mindLabsBorder.opacity(0.2))
                                                .frame(height: 8)
                                                .cornerRadius(4)
                                            
                                            Rectangle()
                                                .fill(LinearGradient.mindLabsPrimary)
                                                .frame(width: geometry.size.width * item.percentage, height: 8)
                                                .cornerRadius(4)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                                
                                Text("\(item.count)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Productivity Insights Card
struct ProductivityInsightsCard: View {
    let questsData: [(date: Date, count: Int)]
    
    var insights: [String] {
        var insights: [String] = []
        
        let totalQuests = questsData.reduce(0) { $0 + $1.count }
        let avgPerDay = Double(totalQuests) / Double(max(questsData.count, 1))
        
        insights.append("Average: \(String(format: "%.1f", avgPerDay)) quests/day")
        
        // Find best day
        if let bestDay = questsData.max(by: { $0.count < $1.count }), bestDay.count > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            insights.append("Most productive: \(formatter.string(from: bestDay.date))")
        }
        
        // Recent trend
        if questsData.count >= 3 {
            let recentDays = questsData.suffix(3)
            let recentAvg = Double(recentDays.reduce(0) { $0 + $1.count }) / 3.0
            if recentAvg > avgPerDay {
                insights.append("Trending up! 📈")
            } else if recentAvg < avgPerDay * 0.5 {
                insights.append("Time to get back on track! 💪")
            }
        }
        
        return insights
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Insights")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                }
                
                ForEach(insights, id: \.self) { insight in
                    HStack {
                        Circle()
                            .fill(Color.mindLabsPurple)
                            .frame(width: 6, height: 6)
                        Text(insight)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Habits Analytics Section
struct HabitsAnalyticsSection: View {
    @EnvironmentObject var gameManager: GameManager
    let timeRange: DataAnalyticsView.TimeRange
    
    var routineCompletionData: [(routine: Routine, completionRate: Double)] {
        let calendar = Calendar.current
        let endDate = Date()
        _ = calendar.date(byAdding: .day, value: -timeRange.days, to: endDate)!
        
        return gameManager.routines.compactMap { routine in
            // Count days this routine was active
            var activeDays = 0
            var completedDays = 0
            
            for dayOffset in 0..<timeRange.days {
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: endDate)!
                let dayStart = calendar.startOfDay(for: date)
                
                if routine.createdDate <= dayStart {
                    activeDays += 1
                    
                    if let lastCompleted = routine.lastCompletedDate,
                       calendar.isDate(lastCompleted, inSameDayAs: date) {
                        completedDays += 1
                    }
                }
            }
            
            guard activeDays > 0 else { return nil }
            
            let completionRate = Double(completedDays) / Double(activeDays)
            return (routine: routine, completionRate: completionRate)
        }.sorted { $0.completionRate > $1.completionRate }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Routine Streaks
            RoutineStreaksCard()
            
            // Completion Rates
            if !routineCompletionData.isEmpty {
                MindLabsCard {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Routine Consistency")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        ForEach(routineCompletionData, id: \.routine.id) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(item.routine.icon)
                                    Text(item.routine.name)
                                        .font(MindLabsTypography.subheadline())
                                        .foregroundColor(.mindLabsText)
                                    Spacer()
                                    Text("\(Int(item.completionRate * 100))%")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsPurple)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.mindLabsBorder.opacity(0.2))
                                            .frame(height: 6)
                                            .cornerRadius(3)
                                        
                                        Rectangle()
                                            .fill(
                                                item.completionRate > 0.8 ? Color.mindLabsSuccess :
                                                item.completionRate > 0.5 ? Color.mindLabsWarning :
                                                Color.mindLabsError
                                            )
                                            .frame(width: geometry.size.width * item.completionRate, height: 6)
                                            .cornerRadius(3)
                                    }
                                }
                                .frame(height: 6)
                            }
                            
                            if item.routine.id != routineCompletionData.last?.routine.id {
                                Divider()
                            }
                        }
                    }
                }
            }
            
            // Habit Formation Tips
            HabitFormationTipsCard()
        }
    }
}

// MARK: - Routine Streaks Card
struct RoutineStreaksCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var activeStreaks: [(routine: Routine, streak: Int)] {
        gameManager.routines
            .filter { $0.completionStreak > 0 }
            .map { ($0, $0.completionStreak) }
            .sorted { $0.streak > $1.streak }
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Active Streaks")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                }
                
                if activeStreaks.isEmpty {
                    Text("No active routine streaks. Complete a routine to start!")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .padding(.vertical, 10)
                } else {
                    VStack(spacing: 10) {
                        ForEach(activeStreaks, id: \.routine.id) { item in
                            HStack {
                                Text(item.routine.icon)
                                    .font(.title3)
                                
                                VStack(alignment: .leading) {
                                    Text(item.routine.name)
                                        .font(MindLabsTypography.subheadline())
                                        .foregroundColor(.mindLabsText)
                                    Text("\(item.streak) day streak")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                                
                                Spacer()
                                
                                Text(String(repeating: "🔥", count: min(item.streak / 7 + 1, 5)))
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Habit Formation Tips Card
struct HabitFormationTipsCard: View {
    let tips = [
        "🎯 Focus on one routine at a time for best results",
        "⏰ Set consistent times for your routines",
        "📱 Use notifications to remind yourself",
        "🎉 Celebrate small wins to build momentum",
        "🔄 It takes 21-66 days to form a habit"
    ]
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Building Better Habits")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                ForEach(tips, id: \.self) { tip in
                    Text(tip)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .padding(.vertical, 2)
                }
            }
        }
    }
}

// MARK: - Achievements Analytics Section
struct AchievementsAnalyticsSection: View {
    @EnvironmentObject var gameManager: GameManager
    
    var achievementProgress: [(category: String, unlocked: Int, total: Int)] {
        let achievements = gameManager.achievementManager.achievements
        let categories = Set(achievements.map { $0.category })
        
        return categories.compactMap { category in
            let categoryAchievements = achievements.filter { $0.category == category }
            let unlocked = categoryAchievements.filter { $0.isUnlocked }.count
            return (category: category.rawValue, unlocked: unlocked, total: categoryAchievements.count)
        }.sorted { $0.category < $1.category }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Overall Progress
            AchievementOverallProgressCard()
            
            // Category Progress
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Achievement Categories")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    ForEach(achievementProgress, id: \.category) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(item.category)
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsText)
                                Spacer()
                                Text("\(item.unlocked)/\(item.total)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.mindLabsBorder.opacity(0.2))
                                        .frame(height: 8)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .fill(LinearGradient.mindLabsPrimary)
                                        .frame(
                                            width: geometry.size.width * (Double(item.unlocked) / Double(item.total)),
                                            height: 8
                                        )
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
            
            // Recent Achievements
            RecentAchievementsCard()
        }
    }
}

// MARK: - Achievement Overall Progress Card
struct AchievementOverallProgressCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 15) {
                Text("Achievement Progress")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.mindLabsBorder.opacity(0.2), lineWidth: 20)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: gameManager.achievementManager.progressPercentage)
                        .stroke(
                            LinearGradient.mindLabsPrimary,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(gameManager.achievementManager.progressPercentage * 100))%")
                            .font(MindLabsTypography.title())
                            .foregroundColor(.mindLabsText)
                        Text("\(gameManager.achievementManager.unlockedCount)/\(gameManager.achievementManager.totalCount)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Next achievements to unlock
                if let nextAchievement = gameManager.achievementManager.achievements
                    .filter({ !$0.isUnlocked })
                    .sorted(by: { $0.requiredValue < $1.requiredValue })
                    .first {
                    
                    HStack {
                        Text("Next:")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        Text(nextAchievement.icon)
                        Text(nextAchievement.title)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsText)
                        Spacer()
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}

// MARK: - Recent Achievements Card
struct RecentAchievementsCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var recentAchievements: [Achievement] {
        gameManager.achievementManager.achievements
            .filter { $0.isUnlocked }
            .sorted { (a, b) in
                (a.unlockedDate ?? Date.distantPast) > (b.unlockedDate ?? Date.distantPast)
            }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Recent Unlocks")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                if recentAchievements.isEmpty {
                    Text("No achievements unlocked yet. Keep questing!")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .padding(.vertical, 10)
                } else {
                    VStack(spacing: 12) {
                        ForEach(recentAchievements) { achievement in
                            HStack {
                                Text(achievement.icon)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(achievement.title)
                                        .font(MindLabsTypography.subheadline())
                                        .foregroundColor(.mindLabsText)
                                    if let date = achievement.unlockedDate {
                                        Text(date, style: .relative)
                                            .font(MindLabsTypography.caption2())
                                            .foregroundColor(.mindLabsTextSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.mindLabsSuccess)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Focus Time Analytics Section
struct FocusTimeAnalyticsSection: View {
    @EnvironmentObject var gameManager: GameManager
    let timeRange: DataAnalyticsView.TimeRange
    
    var focusData: [(date: Date, minutes: Int)] {
        let calendar = Calendar.current
        let endDate = Date()
        
        var dailyFocus: [(date: Date, minutes: Int)] = []
        
        for dayOffset in 0..<timeRange.days {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: endDate)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let minutesForDay = gameManager.quests.reduce(0) { total, quest in
                let sessionsInDay = quest.timeSpentSessions.filter { session in
                    session.endTime >= dayStart && session.endTime < dayEnd
                }
                return total + sessionsInDay.reduce(0) { $0 + $1.duration }
            }
            
            dailyFocus.append((date: dayStart, minutes: minutesForDay))
        }
        
        return dailyFocus.reversed()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Focus Time Chart
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Daily Focus Time")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    CustomBarChart(data: focusData.map { Double($0.minutes) })
                        .frame(height: 200)
                        .padding(.top, 10)
                    
                    // X-axis labels
                    HStack {
                        ForEach(focusData.indices, id: \.self) { index in
                            if index % (timeRange == .week ? 1 : 7) == 0 {
                                Text(formatDate(focusData[index].date))
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            
            // Focus Statistics
            FocusStatisticsCard(focusData: focusData)
            
            // Time of Day Analysis
            TimeOfDayAnalysisCard()
        }
    }
}

// MARK: - Focus Statistics Card
struct FocusStatisticsCard: View {
    let focusData: [(date: Date, minutes: Int)]
    
    var statistics: (total: Int, average: Int, bestDay: (date: Date, minutes: Int)?) {
        let total = focusData.reduce(0) { $0 + $1.minutes }
        let average = focusData.isEmpty ? 0 : total / focusData.count
        let bestDay = focusData.max { $0.minutes < $1.minutes }
        return (total, average, bestDay)
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Focus Statistics")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                HStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Total")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        Text("\(statistics.total / 60)h \(statistics.total % 60)m")
                            .font(MindLabsTypography.title2())
                            .foregroundColor(.mindLabsBlue)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Daily Average")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        Text("\(statistics.average) min")
                            .font(MindLabsTypography.title2())
                            .foregroundColor(.mindLabsPurple)
                    }
                }
                
                if let bestDay = statistics.bestDay {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("Best day: \(bestDay.minutes) minutes")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding(.top, 5)
                }
            }
        }
    }
}

// MARK: - Time of Day Analysis Card
struct TimeOfDayAnalysisCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var timeOfDayData: [(period: String, percentage: Double)] {
        var morningMinutes = 0
        var afternoonMinutes = 0
        var eveningMinutes = 0
        
        let calendar = Calendar.current
        
        for quest in gameManager.quests {
            for session in quest.timeSpentSessions {
                let hour = calendar.component(.hour, from: session.startTime)
                
                if hour < 12 {
                    morningMinutes += session.duration
                } else if hour < 17 {
                    afternoonMinutes += session.duration
                } else {
                    eveningMinutes += session.duration
                }
            }
        }
        
        let total = morningMinutes + afternoonMinutes + eveningMinutes
        guard total > 0 else { return [] }
        
        return [
            ("Morning", Double(morningMinutes) / Double(total)),
            ("Afternoon", Double(afternoonMinutes) / Double(total)),
            ("Evening", Double(eveningMinutes) / Double(total))
        ]
    }
    
    var body: some View {
        if !timeOfDayData.isEmpty {
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Text("When You Focus Best")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    ForEach(timeOfDayData, id: \.period) { item in
                        HStack {
                            Text(item.period)
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)
                                .frame(width: 80, alignment: .leading)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.mindLabsBorder.opacity(0.2))
                                        .frame(height: 20)
                                        .cornerRadius(10)
                                    
                                    Rectangle()
                                        .fill(
                                            item.period == "Morning" ? Color.orange :
                                            item.period == "Afternoon" ? Color.blue :
                                            Color.purple
                                        )
                                        .frame(width: geometry.size.width * item.percentage, height: 20)
                                        .cornerRadius(10)
                                }
                            }
                            .frame(height: 20)
                            
                            Text("\(Int(item.percentage * 100))%")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                                .frame(width: 45, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Helper Functions
private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter.string(from: date)
}

// MARK: - Custom Charts for iOS 15 compatibility
struct CustomLineChart: View {
    let data: [Double]
    
    var maxValue: Double {
        data.max() ?? 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Rectangle()
                            .fill(Color.mindLabsBorder.opacity(0.2))
                            .frame(height: 1)
                        if i < 4 {
                            Spacer()
                        }
                    }
                }
                
                // Line chart
                if !data.isEmpty {
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let stepY = geometry.size.height / maxValue
                        
                        path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(data[0]) * stepY))
                        
                        for index in 1..<data.count {
                            let x = CGFloat(index) * stepX
                            let y = geometry.size.height - CGFloat(data[index]) * stepY
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(LinearGradient.mindLabsPrimary, lineWidth: 3)
                    
                    // Area under line
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let stepY = geometry.size.height / maxValue
                        
                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(data[0]) * stepY))
                        
                        for index in 1..<data.count {
                            let x = CGFloat(index) * stepX
                            let y = geometry.size.height - CGFloat(data[index]) * stepY
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(LinearGradient.mindLabsPrimary.opacity(0.2))
                    
                    // Points
                    ForEach(data.indices, id: \.self) { index in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let stepY = geometry.size.height / maxValue
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - CGFloat(data[index]) * stepY
                        
                        Circle()
                            .fill(Color.mindLabsPurple)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
}

struct CustomBarChart: View {
    let data: [Double]
    
    var maxValue: Double {
        data.max() ?? 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Rectangle()
                            .fill(Color.mindLabsBorder.opacity(0.2))
                            .frame(height: 1)
                        if i < 4 {
                            Spacer()
                        }
                    }
                }
                
                // Bars
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(data.indices, id: \.self) { index in
                        Rectangle()
                            .fill(LinearGradient.mindLabsPrimary)
                            .frame(height: geometry.size.height * CGFloat(data[index]) / CGFloat(maxValue))
                            .cornerRadius(5)
                    }
                }
            }
        }
    }
}

struct DataAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        DataAnalyticsView()
            .environmentObject(GameManager())
    }
}