import Foundation
import SwiftUI

// MARK: - Seasonal Event
struct SeasonalEvent: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var icon: String
    var themeColorHex: String
    var startMonth: Int // 1-12
    var endMonth: Int // 1-12
    var challenges: [SeasonalChallenge]
    var exclusiveEnemies: [BattleEncounter]
    var exclusiveItems: [Item]

    var isActive: Bool {
        let month = Calendar.current.component(.month, from: Date())
        if startMonth <= endMonth {
            return month >= startMonth && month <= endMonth
        } else {
            return month >= startMonth || month <= endMonth
        }
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        var endComponents = DateComponents()
        endComponents.year = endMonth < calendar.component(.month, from: now) ? year + 1 : year
        endComponents.month = endMonth + 1
        endComponents.day = 1
        if let endDate = calendar.date(from: endComponents) {
            return max(0, calendar.dateComponents([.day], from: now, to: endDate).day ?? 0)
        }
        return 0
    }

    var themeColor: Color {
        Color(hex: themeColorHex)
    }
}

// MARK: - Seasonal Challenge Type
enum SeasonalChallengeType: String, Codable {
    case winBattles = "Win Battles"
    case completeQuests = "Complete Quests"
    case defeatEnemy = "Defeat Enemy"
    case craftItems = "Craft Items"
    case earnGold = "Earn Gold"
    case winArenaMatches = "Win Arena Matches"
    case clearDungeons = "Clear Dungeons"
    case reachWinStreak = "Reach Win Streak"
}

// MARK: - Seasonal Challenge
struct SeasonalChallenge: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var type: SeasonalChallengeType
    var target: Int
    var progress: Int = 0
    var isClaimed: Bool = false

    var isCompleted: Bool {
        progress >= target
    }

    var rewards: SeasonalRewardSet
}

// MARK: - Seasonal Reward Set
struct SeasonalRewardSet: Codable {
    var xp: Int = 0
    var gold: Int = 0
    var items: [Item] = []
    var cosmeticId: String? = nil
}

// MARK: - Seasonal Progress
struct SeasonalProgress: Codable {
    var participatedEventIds: Set<String> = []
    var completedChallengeIds: Set<String> = []
    var claimedRewardIds: Set<String> = []
}

