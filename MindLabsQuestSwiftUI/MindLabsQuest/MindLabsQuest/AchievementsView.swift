import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    
    var achievementManager: AchievementManager {
        gameManager.achievementManager
    }
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementManager.achievements.filter { $0.category == category }
        }
        return achievementManager.achievements
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Overview
                AchievementProgressCard()
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        AchievementFilterChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                            AchievementFilterChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Achievements List
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .mindLabsBackground()
        }
    }
}

struct AchievementProgressCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var achievementManager: AchievementManager {
        gameManager.achievementManager
    }
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Achievement Progress")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Text("\(achievementManager.unlockedCount) of \(achievementManager.totalCount) unlocked")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.mindLabsBorder.opacity(0.3), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: achievementManager.progressPercentage)
                            .stroke(LinearGradient.mindLabsPrimary, lineWidth: 8)
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(achievementManager.progressPercentage * 100))%")
                            .font(MindLabsTypography.caption())
                            .bold()
                            .foregroundColor(.mindLabsPurple)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        MindLabsCard {
            HStack {
                // Icon
                Text(achievement.icon)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(
                                achievement.isUnlocked 
                                    ? achievement.category.color.opacity(0.3)
                                    : Color.gray.opacity(0.2)
                            )
                    )
                    .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(achievement.title)
                        .font(MindLabsTypography.headline())
                        .foregroundColor(achievement.isUnlocked ? .mindLabsText : .mindLabsTextSecondary)
                    
                    Text(achievement.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    if achievement.isUnlocked {
                        if let date = achievement.unlockedDate {
                            Text("Unlocked \(date, style: .date)")
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsPurple)
                        }
                    } else {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.mindLabsBorder.opacity(0.3))
                                    .frame(height: 4)
                                
                                Rectangle()
                                    .fill(achievement.category.color)
                                    .frame(width: geometry.size.width * min(1.0, Double(achievement.progress) / Double(achievement.requiredValue)), height: 4)
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(achievement.progress)/\(achievement.requiredValue)")
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                Spacer()
                
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.mindLabsSuccess)
                        .font(.title2)
                }
            }
        }
        .opacity(achievement.isUnlocked ? 1.0 : 0.8)
    }
}

struct AchievementFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MindLabsTypography.caption())
                .foregroundColor(isSelected ? .white : .mindLabsTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.mindLabsPurple : Color.mindLabsPurple.opacity(0.1)
                )
                .cornerRadius(20)
        }
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
            .environmentObject(GameManager())
    }
}