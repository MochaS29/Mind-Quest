import Foundation
import SwiftUI

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    var id = UUID()
    let key: String
    let title: String
    let description: String
    let icon: String
    let requiredValue: Int
    let category: AchievementCategory
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var progress: Int = 0

    enum AchievementCategory: String, CaseIterable, Codable {
        case quests = "Quests"
        case streak = "Streaks"
        case level = "Levels"
        case focus = "Focus"
        case collection = "Collection"

        var color: Color {
            switch self {
            case .quests: return .blue
            case .streak: return .orange
            case .level: return .purple
            case .focus: return .green
            case .collection: return .yellow
            }
        }
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        // Quest Achievements
        Achievement(key: "first_quest", title: "First Steps", description: "Complete your first quest", icon: "🎯", requiredValue: 1, category: .quests),
        Achievement(key: "quest_10", title: "Adventurer", description: "Complete 10 quests", icon: "⚔️", requiredValue: 10, category: .quests),
        Achievement(key: "quest_50", title: "Quest Master", description: "Complete 50 quests", icon: "🗡️", requiredValue: 50, category: .quests),
        Achievement(key: "quest_100", title: "Legendary Hero", description: "Complete 100 quests", icon: "🏆", requiredValue: 100, category: .quests),

        // Streak Achievements
        Achievement(key: "streak_3", title: "Warming Up", description: "Maintain a 3-day streak", icon: "🔥", requiredValue: 3, category: .streak),
        Achievement(key: "streak_7", title: "Week Warrior", description: "Maintain a 7-day streak", icon: "🔥🔥", requiredValue: 7, category: .streak),
        Achievement(key: "streak_30", title: "Unstoppable", description: "Maintain a 30-day streak", icon: "🔥🔥🔥", requiredValue: 30, category: .streak),

        // Level Achievements
        Achievement(key: "level_5", title: "Rising Star", description: "Reach level 5", icon: "⭐", requiredValue: 5, category: .level),
        Achievement(key: "level_10", title: "Seasoned Adventurer", description: "Reach level 10", icon: "🌟", requiredValue: 10, category: .level),
        Achievement(key: "level_25", title: "Epic Hero", description: "Reach level 25", icon: "💫", requiredValue: 25, category: .level),

        // Focus Achievements
        Achievement(key: "focus_60", title: "Deep Focus", description: "Complete a 60-minute focus session", icon: "🧘", requiredValue: 60, category: .focus),
        Achievement(key: "focus_total_300", title: "Focus Master", description: "Focus for 300 minutes total", icon: "🎯", requiredValue: 300, category: .focus),
        Achievement(key: "focus_total_1000", title: "Zen Master", description: "Focus for 1000 minutes total", icon: "🧘‍♂️", requiredValue: 1000, category: .focus),

        // Collection Achievements
        Achievement(key: "all_classes", title: "Jack of All Trades", description: "Try all character classes", icon: "🎭", requiredValue: 6, category: .collection),
        Achievement(key: "all_categories", title: "Well Rounded", description: "Complete quests in all categories", icon: "🌈", requiredValue: 6, category: .collection),

        // Additional Achievements
        Achievement(key: "early_bird", title: "Early Bird", description: "Complete a quest before 8 AM", icon: "🌅", requiredValue: 1, category: .quests),
        Achievement(key: "night_owl", title: "Night Owl", description: "Complete a quest after 10 PM", icon: "🦉", requiredValue: 1, category: .quests),
        Achievement(key: "perfect_week", title: "Perfect Week", description: "Complete all daily quests for 7 days", icon: "✨", requiredValue: 7, category: .quests),
        Achievement(key: "speed_demon", title: "Speed Demon", description: "Complete 5 quests in one day", icon: "⚡", requiredValue: 5, category: .quests),
        Achievement(key: "gold_hoarder", title: "Gold Hoarder", description: "Accumulate 1000 gold", icon: "💰", requiredValue: 1000, category: .collection),
        Achievement(key: "pomodoro_master", title: "Pomodoro Master", description: "Complete 25 Pomodoro sessions", icon: "🍅", requiredValue: 25, category: .focus),
        Achievement(key: "routine_champion", title: "Routine Champion", description: "Complete all routines for 7 days straight", icon: "🏅", requiredValue: 7, category: .streak)
    ]
}

// MARK: - Parent Rewards System
struct ParentReward: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var requiredLevel: Int
    var additionalRequirements: [RewardRequirement] = []
    var isActive: Bool = true
    var isClaimed: Bool = false
    var isApproved: Bool = false
    var claimedDate: Date?
    var approvedDate: Date?
    var createdDate: Date = Date()

    enum RewardRequirement: Codable {
        case minimumStreak(days: Int)
        case achievementCount(count: Int)
        case questsCompleted(count: Int)
        case focusMinutes(minutes: Int)

        var description: String {
            switch self {
            case .minimumStreak(let days):
                return "\(days)-day streak"
            case .achievementCount(let count):
                return "\(count) achievements unlocked"
            case .questsCompleted(let count):
                return "\(count) quests completed"
            case .focusMinutes(let minutes):
                return "\(minutes) minutes focused"
            }
        }

        func isMet(character: Character, achievements: [Achievement]) -> Bool {
            switch self {
            case .minimumStreak(let days):
                return character.streak >= days
            case .achievementCount(let count):
                return achievements.filter { $0.isUnlocked }.count >= count
            case .questsCompleted(let count):
                return character.totalQuestsCompleted >= count
            case .focusMinutes(let minutes):
                return character.totalFocusMinutes >= minutes
            }
        }
    }
}

extension ParentReward {
    static let defaultRewards: [ParentReward] = [
        ParentReward(
            title: "Extra Hour Screen Time",
            description: "One extra hour of screen time this weekend",
            requiredLevel: 5,
            additionalRequirements: [.minimumStreak(days: 3)]
        ),
        ParentReward(
            title: "Choose Family Movie Night",
            description: "Pick the movie for family movie night",
            requiredLevel: 10,
            additionalRequirements: [.questsCompleted(count: 50)]
        ),
        ParentReward(
            title: "Late Bedtime Weekend",
            description: "Stay up 1 hour later on Friday or Saturday",
            requiredLevel: 15,
            additionalRequirements: [.achievementCount(count: 10)]
        ),
        ParentReward(
            title: "Friend Outing",
            description: "Special outing with friends",
            requiredLevel: 20,
            additionalRequirements: [.focusMinutes(minutes: 600)]
        )
    ]
}
