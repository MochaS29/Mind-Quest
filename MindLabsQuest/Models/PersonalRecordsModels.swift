import Foundation
import SwiftUI

// MARK: - Personal Records
struct PersonalRecords: Codable {
    // Battle
    var totalBattlesWon: Int = 0
    var totalBattlesLost: Int = 0
    var totalDamageDealt: Int = 0
    var highestSingleHit: Int = 0
    var longestBattleWinStreak: Int = 0
    var currentBattleWinStreak: Int = 0
    var fastestBattleWin: TimeInterval? // seconds

    // Arena
    var arenaWins: Int = 0
    var arenaLosses: Int = 0
    var highestArenaRating: Int = 200

    // Economy
    var mostGoldInOneBattle: Int = 0
    var totalGoldEarned: Int = 0
    var totalGoldSpent: Int = 0
    var itemsPurchased: Int = 0
    var itemsSold: Int = 0
    var barterTradesCompleted: Int = 0

    // Quest
    var totalQuestsCompleted: Int = 0
    var longestQuestStreak: Int = 0

    // Dungeon
    var totalDungeonClears: Int = 0
    var highestFloor: Int = 0
    var fastestDungeonClear: TimeInterval? // seconds

    // General
    var highestLevel: Int = 1
    var totalPlayDays: Int = 0
    var firstPlayDate: Date = Date()
    var totalEnergySpent: Int = 0
}

// MARK: - Badge Category
enum BadgeCategory: String, CaseIterable, Codable {
    case battle = "Battle"
    case arena = "Arena"
    case economy = "Economy"
    case exploration = "Exploration"
    case dedication = "Dedication"

    var icon: String {
        switch self {
        case .battle: return "burst.fill"
        case .arena: return "person.2.fill"
        case .economy: return "dollarsign.circle.fill"
        case .exploration: return "map.fill"
        case .dedication: return "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .battle: return .red
        case .arena: return .orange
        case .economy: return .yellow
        case .exploration: return .green
        case .dedication: return .purple
        }
    }
}

// MARK: - Record Badge
struct RecordBadge: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var category: BadgeCategory
    var isUnlocked: Bool = false
    var dateUnlocked: Date?
}

// MARK: - Badge Database
struct BadgeDatabase {
    static let allBadges: [RecordBadge] = [
        // Battle (8)
        RecordBadge(id: "first_blood", title: "First Blood", description: "Win your first battle", icon: "drop.fill", category: .battle),
        RecordBadge(id: "seasoned_warrior", title: "Seasoned Warrior", description: "Win 10 battles", icon: "shield.fill", category: .battle),
        RecordBadge(id: "battle_hardened", title: "Battle Hardened", description: "Win 50 battles", icon: "shield.lefthalf.filled", category: .battle),
        RecordBadge(id: "war_hero", title: "War Hero", description: "Win 100 battles", icon: "star.circle.fill", category: .battle),
        RecordBadge(id: "on_a_roll", title: "On a Roll", description: "Win 5 battles in a row", icon: "flame.fill", category: .battle),
        RecordBadge(id: "unstoppable", title: "Unstoppable", description: "Win 10 battles in a row", icon: "bolt.circle.fill", category: .battle),
        RecordBadge(id: "heavy_hitter", title: "Heavy Hitter", description: "Deal 100+ damage in a single hit", icon: "burst.fill", category: .battle),
        RecordBadge(id: "damage_dealer", title: "Damage Dealer", description: "Deal 1,000 total damage", icon: "flame.circle.fill", category: .battle),

        // Arena (6)
        RecordBadge(id: "arena_debut", title: "Arena Debut", description: "Complete your first arena match", icon: "person.2.fill", category: .arena),
        RecordBadge(id: "silver_rank", title: "Silver Challenger", description: "Reach Silver rank", icon: "shield.lefthalf.filled", category: .arena),
        RecordBadge(id: "gold_rank", title: "Gold Contender", description: "Reach Gold rank", icon: "medal.fill", category: .arena),
        RecordBadge(id: "diamond_rank", title: "Diamond Elite", description: "Reach Diamond rank", icon: "diamond.fill", category: .arena),
        RecordBadge(id: "champion_rank", title: "Arena Champion", description: "Reach Champion rank", icon: "crown.fill", category: .arena),
        RecordBadge(id: "arena_dominator", title: "Arena Dominator", description: "Win 5 arena matches in a row", icon: "trophy.fill", category: .arena),

        // Economy (4)
        RecordBadge(id: "wealthy", title: "Wealthy", description: "Earn 1,000 total gold", icon: "dollarsign.circle.fill", category: .economy),
        RecordBadge(id: "rich", title: "Rich", description: "Earn 10,000 total gold", icon: "banknote.fill", category: .economy),
        RecordBadge(id: "big_spender", title: "Big Spender", description: "Purchase 20 items", icon: "cart.fill", category: .economy),
        RecordBadge(id: "merchants_friend", title: "Merchant's Friend", description: "Complete 5 barter trades", icon: "arrow.triangle.2.circlepath", category: .economy),

        // Exploration (3)
        RecordBadge(id: "dungeon_crawler", title: "Dungeon Crawler", description: "Clear your first dungeon", icon: "building.columns.fill", category: .exploration),
        RecordBadge(id: "dungeon_master", title: "Dungeon Master", description: "Clear 10 dungeons", icon: "building.columns.circle.fill", category: .exploration),
        RecordBadge(id: "quest_legend", title: "Quest Legend", description: "Complete 50 quests", icon: "scroll.fill", category: .exploration),

        // Dedication (4)
        RecordBadge(id: "rising_star", title: "Rising Star", description: "Reach level 10", icon: "star.fill", category: .dedication),
        RecordBadge(id: "veteran", title: "Veteran", description: "Reach level 20", icon: "star.circle.fill", category: .dedication),
        RecordBadge(id: "one_week_in", title: "One Week In", description: "Play for 7 days", icon: "calendar", category: .dedication),
        RecordBadge(id: "monthly_dedication", title: "Monthly Dedication", description: "Play for 30 days", icon: "calendar.badge.clock", category: .dedication),
    ]
}
