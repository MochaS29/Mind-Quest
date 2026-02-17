import SwiftUI
import Charts

struct TimeAnalyticsView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Stats Card
                    OverallTimeStatsCard()
                    
                    // Category Breakdown
                    CategoryTimeBreakdownCard()
                    
                    // Recent Sessions
                    RecentTimeSessionsCard()
                    
                    // Accuracy Tips
                    TimeEstimationTipsCard()
                }
                .padding()
            }
            .navigationTitle("Time Analytics")
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
}

struct OverallTimeStatsCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var overallAccuracy: String {
        let accuracy = gameManager.timeEstimateHistory.overallAccuracy
        if accuracy == 0 {
            return "No data"
        }
        return "\(Int(accuracy * 100))%"
    }
    
    var totalTimeTracked: String {
        let totalMinutes = gameManager.timeEstimateHistory.categoryAverages.values
            .reduce(0) { $0 + $1.totalActual }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 20) {
                Text("Time Tracking Overview")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                HStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text(overallAccuracy)
                            .font(MindLabsTypography.title())
                            .foregroundColor(.mindLabsPurple)
                        Text("Estimation Accuracy")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Divider()
                        .frame(height: 50)
                    
                    VStack(spacing: 8) {
                        Text(totalTimeTracked)
                            .font(MindLabsTypography.title())
                            .foregroundColor(.mindLabsBlue)
                        Text("Total Tracked")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Divider()
                        .frame(height: 50)
                    
                    VStack(spacing: 8) {
                        Text("\(gameManager.timeEstimateHistory.totalTasksTracked)")
                            .font(MindLabsTypography.title())
                            .foregroundColor(.mindLabsSuccess)
                        Text("Tasks Tracked")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                if gameManager.timeEstimateHistory.totalTasksTracked > 0 {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.mindLabsPurple)
                            .font(.caption)
                        Text(getAccuracyMessage())
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.mindLabsPurple.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func getAccuracyMessage() -> String {
        let accuracy = gameManager.timeEstimateHistory.overallAccuracy
        if accuracy > 1.2 {
            return "You tend to underestimate task duration. Try adding buffer time!"
        } else if accuracy < 0.8 {
            return "You often overestimate task duration. You're faster than you think!"
        } else {
            return "Great job! Your time estimates are quite accurate."
        }
    }
}

struct CategoryTimeBreakdownCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var categoryData: [(category: String, accuracy: Double, time: Int)] {
        gameManager.timeEstimateHistory.categoryAverages.compactMap { key, value in
            guard value.taskCount > 0 else { return nil }
            return (category: key, accuracy: value.averageAccuracy, time: value.totalActual)
        }.sorted { $0.time > $1.time }
    }
    
    var body: some View {
        if !categoryData.isEmpty {
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Time by Category")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    ForEach(categoryData, id: \.category) { item in
                        HStack {
                            // Category icon
                            if let category = TaskCategory(rawValue: item.category) {
                                Text(category.icon)
                                    .font(.title2)
                                    .frame(width: 40)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.category)
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsText)
                                
                                HStack {
                                    Text("\(item.time) min")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                    
                                    Text("•")
                                        .foregroundColor(.mindLabsTextSecondary)
                                    
                                    Text("\(Int(item.accuracy * 100))% accurate")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(accuracyColor(item.accuracy))
                                }
                            }
                            
                            Spacer()
                            
                            // Accuracy indicator
                            Image(systemName: accuracyIcon(item.accuracy))
                                .foregroundColor(accuracyColor(item.accuracy))
                        }
                        
                        if item.category != categoryData.last?.category {
                            Divider()
                        }
                    }
                }
            }
        }
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy > 1.2 {
            return .mindLabsError
        } else if accuracy < 0.8 {
            return .mindLabsWarning
        } else {
            return .mindLabsSuccess
        }
    }
    
    private func accuracyIcon(_ accuracy: Double) -> String {
        if accuracy > 1.2 {
            return "exclamationmark.triangle"
        } else if accuracy < 0.8 {
            return "hare"
        } else {
            return "checkmark.circle"
        }
    }
}

struct RecentTimeSessionsCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var recentSessions: [(quest: Quest, session: TimeSession)] {
        var sessions: [(quest: Quest, session: TimeSession)] = []
        
        for quest in gameManager.quests.filter({ !$0.timeSpentSessions.isEmpty }) {
            for session in quest.timeSpentSessions {
                sessions.append((quest: quest, session: session))
            }
        }
        
        return sessions
            .sorted { $0.session.endTime > $1.session.endTime }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        if !recentSessions.isEmpty {
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Focus Sessions")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    ForEach(recentSessions.indices, id: \.self) { index in
                        let item = recentSessions[index]
                        HStack {
                            Text(item.quest.category.icon)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.quest.title)
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsText)
                                    .lineLimit(1)
                                
                                Text(item.session.endTime, style: .relative)
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            
                            Spacer()
                            
                            Text("\(item.session.duration) min")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsPurple)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.mindLabsPurple.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        if index < recentSessions.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

struct TimeEstimationTipsCard: View {
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Time Estimation Tips")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    TimeEstimateTipRow(icon: "⏰", tip: "Break large tasks into smaller steps")
                    TimeEstimateTipRow(icon: "📊", tip: "Track at least 3 tasks per category for accurate suggestions")
                    TimeEstimateTipRow(icon: "🎯", tip: "Include buffer time for unexpected challenges")
                    TimeEstimateTipRow(icon: "📝", tip: "Review your estimates after completing tasks")
                    TimeEstimateTipRow(icon: "🔄", tip: "AI suggestions improve as you track more tasks")
                }
            }
        }
    }
}

struct TimeEstimateTipRow: View {
    let icon: String
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon)
                .font(.caption)
            Text(tip)
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
            Spacer()
        }
    }
}

struct TimeAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        TimeAnalyticsView()
            .environmentObject(GameManager())
    }
}