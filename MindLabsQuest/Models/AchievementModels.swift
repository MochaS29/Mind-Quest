import Foundation
import SwiftUI

// MARK: - Achievement Tier
enum AchievementTier: String, Codable, CaseIterable {
    case bronze, silver, gold, platinum

    var icon: String {
        switch self {
        case .bronze: return "circle.fill"
        case .silver: return "diamond.fill"
        case .gold: return "star.fill"
        case .platinum: return "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.3, blue: 0.9)
        }
    }
}

// MARK: - Achievement Reward
struct AchievementReward: Codable {
    var gold: Int = 0
    var xp: Int = 0
    var cosmeticId: String? = nil

    static func forTier(_ tier: AchievementTier) -> AchievementReward {
        switch tier {
        case .bronze: return AchievementReward(gold: 10, xp: 0)
        case .silver: return AchievementReward(gold: 25, xp: 25)
        case .gold: return AchievementReward(gold: 50, xp: 50)
        case .platinum: return AchievementReward(gold: 100, xp: 100)
        }
    }
}

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
    var tier: AchievementTier = .bronze
    var reward: AchievementReward? = nil

    enum AchievementCategory: String, CaseIterable, Codable {
        case quests = "Quests"
        case streak = "Streaks"
        case level = "Levels"
        case focus = "Focus"
        case collection = "Collection"
        case battle = "Battle"
        case arena = "Arena"
        case crafting = "Crafting"
        case dungeon = "Dungeon"
        case prestige = "Prestige"
        case economy = "Economy"
        case dedication = "Dedication"
        case seasonal = "Seasonal"

        var color: Color {
            switch self {
            case .quests: return .blue
            case .streak: return .orange
            case .level: return .purple
            case .focus: return .green
            case .collection: return .yellow
            case .battle: return .red
            case .arena: return Color(red: 0.5, green: 0.8, blue: 1.0)
            case .crafting: return Color(red: 0.6, green: 0.4, blue: 0.2)
            case .dungeon: return Color(red: 0.4, green: 0.2, blue: 0.4)
            case .prestige: return Color(red: 1.0, green: 0.6, blue: 0.0)
            case .economy: return Color(red: 1.0, green: 0.84, blue: 0.0)
            case .dedication: return .mint
            case .seasonal: return .pink
            }
        }
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        // MARK: - Quest Achievements (existing)
        Achievement(key: "first_quest", title: "First Steps", description: "Complete your first quest", icon: "🎯", requiredValue: 1, category: .quests, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "quest_10", title: "Adventurer", description: "Complete 10 quests", icon: "⚔️", requiredValue: 10, category: .quests, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "quest_50", title: "Quest Master", description: "Complete 50 quests", icon: "🗡️", requiredValue: 50, category: .quests, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "quest_100", title: "Legendary Hero", description: "Complete 100 quests", icon: "🏆", requiredValue: 100, category: .quests, tier: .gold, reward: .forTier(.gold)),

        // MARK: - Streak Achievements (existing)
        Achievement(key: "streak_3", title: "Warming Up", description: "Maintain a 3-day streak", icon: "🔥", requiredValue: 3, category: .streak, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "streak_7", title: "Week Warrior", description: "Maintain a 7-day streak", icon: "🔥🔥", requiredValue: 7, category: .streak, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "streak_30", title: "Unstoppable", description: "Maintain a 30-day streak", icon: "🔥🔥🔥", requiredValue: 30, category: .streak, tier: .gold, reward: .forTier(.gold)),

        // MARK: - Level Achievements (existing)
        Achievement(key: "level_5", title: "Rising Star", description: "Reach level 5", icon: "⭐", requiredValue: 5, category: .level, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "level_10", title: "Seasoned Adventurer", description: "Reach level 10", icon: "🌟", requiredValue: 10, category: .level, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "level_25", title: "Epic Hero", description: "Reach level 25", icon: "💫", requiredValue: 25, category: .level, tier: .gold, reward: .forTier(.gold)),

        // MARK: - Focus Achievements (existing)
        Achievement(key: "focus_60", title: "Deep Focus", description: "Complete a 60-minute focus session", icon: "🧘", requiredValue: 60, category: .focus, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "focus_total_300", title: "Focus Master", description: "Focus for 300 minutes total", icon: "🎯", requiredValue: 300, category: .focus, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "focus_total_1000", title: "Zen Master", description: "Focus for 1000 minutes total", icon: "🧘‍♂️", requiredValue: 1000, category: .focus, tier: .gold, reward: .forTier(.gold)),

        // MARK: - Collection Achievements (existing)
        Achievement(key: "all_classes", title: "Jack of All Trades", description: "Try all character classes", icon: "🎭", requiredValue: 6, category: .collection, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "all_categories", title: "Well Rounded", description: "Complete quests in all categories", icon: "🌈", requiredValue: 6, category: .collection, tier: .silver, reward: .forTier(.silver)),

        // MARK: - Additional Quest Achievements (existing)
        Achievement(key: "early_bird", title: "Early Bird", description: "Complete a quest before 8 AM", icon: "🌅", requiredValue: 1, category: .quests, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "night_owl", title: "Night Owl", description: "Complete a quest after 10 PM", icon: "🦉", requiredValue: 1, category: .quests, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "perfect_week", title: "Perfect Week", description: "Complete all daily quests for 7 days", icon: "✨", requiredValue: 7, category: .quests, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "speed_demon", title: "Speed Demon", description: "Complete 5 quests in one day", icon: "⚡", requiredValue: 5, category: .quests, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "gold_hoarder", title: "Gold Hoarder", description: "Accumulate 1000 gold", icon: "💰", requiredValue: 1000, category: .collection, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "pomodoro_master", title: "Pomodoro Master", description: "Complete 25 Pomodoro sessions", icon: "🍅", requiredValue: 25, category: .focus, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "routine_champion", title: "Routine Champion", description: "Complete all routines for 7 days straight", icon: "🏅", requiredValue: 7, category: .streak, tier: .silver, reward: .forTier(.silver)),

        // MARK: - Battle Achievements (NEW - 8)
        Achievement(key: "battle_first", title: "First Blood", description: "Win your first battle", icon: "⚔️", requiredValue: 1, category: .battle, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "battle_25", title: "Warrior", description: "Win 25 battles", icon: "🗡️", requiredValue: 25, category: .battle, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "battle_100", title: "Battle Master", description: "Win 100 battles", icon: "⚔️", requiredValue: 100, category: .battle, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "battle_500", title: "Untouchable", description: "Win 500 battles", icon: "🏆", requiredValue: 500, category: .battle, tier: .platinum, reward: .forTier(.platinum)),
        Achievement(key: "battle_hit_100", title: "Heavy Hitter", description: "Deal 100 damage in a single hit", icon: "💥", requiredValue: 100, category: .battle, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "battle_dmg_5000", title: "Damage Dealer", description: "Deal 5000 total damage", icon: "🔥", requiredValue: 5000, category: .battle, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "battle_items_10", title: "Battle Healer", description: "Use 10 items in battle", icon: "🧪", requiredValue: 10, category: .battle, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "battle_comeback", title: "Comeback King", description: "Win a battle with less than 10% HP", icon: "👑", requiredValue: 1, category: .battle, tier: .gold, reward: .forTier(.gold)),

        // MARK: - Arena Achievements (NEW - 6)
        Achievement(key: "arena_debut", title: "Arena Debut", description: "Complete your first arena match", icon: "🏟️", requiredValue: 1, category: .arena, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "arena_silver", title: "Silver Challenger", description: "Reach Silver arena rank", icon: "🥈", requiredValue: 500, category: .arena, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "arena_gold", title: "Gold Champion", description: "Reach Gold arena rank", icon: "🥇", requiredValue: 1000, category: .arena, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "arena_diamond", title: "Diamond Elite", description: "Reach Diamond arena rank", icon: "💎", requiredValue: 1500, category: .arena, tier: .platinum, reward: .forTier(.platinum)),
        Achievement(key: "arena_champion", title: "Arena Legend", description: "Reach Champion arena rank", icon: "👑", requiredValue: 2000, category: .arena, tier: .platinum, reward: AchievementReward(gold: 100, xp: 100, cosmeticId: "title_champion")),
        Achievement(key: "arena_streak_10", title: "Win Streak", description: "Reach a 10-arena win streak", icon: "🔥", requiredValue: 10, category: .arena, tier: .gold, reward: .forTier(.gold)),

        // MARK: - Crafting Achievements (NEW - 5)
        Achievement(key: "craft_1", title: "Apprentice Crafter", description: "Craft your first item", icon: "🔨", requiredValue: 1, category: .crafting, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "craft_10", title: "Journeyman", description: "Craft 10 items", icon: "⚒️", requiredValue: 10, category: .crafting, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "craft_25", title: "Master Crafter", description: "Craft 25 items", icon: "🏗️", requiredValue: 25, category: .crafting, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "craft_materials_50", title: "Material Hoarder", description: "Own 50 materials", icon: "🪨", requiredValue: 50, category: .crafting, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "craft_recipes_10", title: "Recipe Collector", description: "Discover 10 recipes", icon: "📜", requiredValue: 10, category: .crafting, tier: .silver, reward: .forTier(.silver)),

        // MARK: - Dungeon Achievements (NEW - 5)
        Achievement(key: "dungeon_1", title: "Dungeon Delver", description: "Clear your first dungeon", icon: "🏰", requiredValue: 1, category: .dungeon, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "dungeon_5", title: "Dungeon Explorer", description: "Clear 5 dungeons", icon: "🗺️", requiredValue: 5, category: .dungeon, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "dungeon_15", title: "Dungeon Conqueror", description: "Clear 15 dungeons", icon: "🏰", requiredValue: 15, category: .dungeon, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "dungeon_speed", title: "Speed Runner", description: "Clear a dungeon in under 10 battles", icon: "⚡", requiredValue: 1, category: .dungeon, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "dungeon_floor_10", title: "Floor Master", description: "Reach floor 10 in a dungeon", icon: "🏗️", requiredValue: 10, category: .dungeon, tier: .gold, reward: .forTier(.gold)),

        // MARK: - Prestige Achievements (NEW - 4)
        Achievement(key: "prestige_1", title: "First Prestige", description: "Prestige for the first time", icon: "⭐", requiredValue: 1, category: .prestige, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "prestige_2", title: "Double Prestige", description: "Reach prestige level 2", icon: "⭐⭐", requiredValue: 2, category: .prestige, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "prestige_3", title: "Triple Prestige", description: "Reach prestige level 3", icon: "⭐⭐⭐", requiredValue: 3, category: .prestige, tier: .platinum, reward: .forTier(.platinum)),
        Achievement(key: "prestige_5", title: "Prestige Master", description: "Reach prestige level 5", icon: "🌟", requiredValue: 5, category: .prestige, tier: .platinum, reward: AchievementReward(gold: 100, xp: 100, cosmeticId: "title_the_immortal")),

        // MARK: - Economy Achievements (NEW - 5)
        Achievement(key: "gold_5000", title: "Wealthy", description: "Accumulate 5000 gold", icon: "💰", requiredValue: 5000, category: .economy, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "gold_10000", title: "Rich", description: "Accumulate 10000 gold", icon: "💎", requiredValue: 10000, category: .economy, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "shop_25", title: "Shopaholic", description: "Buy 25 items from shops", icon: "🛒", requiredValue: 25, category: .economy, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "barter_5", title: "Merchant's Friend", description: "Complete 5 barter trades", icon: "🤝", requiredValue: 5, category: .economy, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "arena_tokens_500", title: "Arena Spender", description: "Spend 500 arena tokens", icon: "🎫", requiredValue: 500, category: .economy, tier: .silver, reward: .forTier(.silver)),

        // MARK: - Dedication Achievements (NEW - 5)
        Achievement(key: "days_7", title: "Week Warrior", description: "Play for 7 days", icon: "📅", requiredValue: 7, category: .dedication, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "days_30", title: "Monthly Hero", description: "Play for 30 days", icon: "📆", requiredValue: 30, category: .dedication, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "days_90", title: "Quarterly Champion", description: "Play for 90 days", icon: "🗓️", requiredValue: 90, category: .dedication, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "days_180", title: "Half Year Hero", description: "Play for 180 days", icon: "📊", requiredValue: 180, category: .dedication, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "days_365", title: "Annual Legend", description: "Play for 365 days", icon: "🏆", requiredValue: 365, category: .dedication, tier: .platinum, reward: .forTier(.platinum)),

        // MARK: - Collection Achievements (NEW - 5)
        Achievement(key: "rare_items_5", title: "Rare Collector", description: "Own 5 rare items", icon: "💎", requiredValue: 5, category: .collection, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "epic_items_3", title: "Epic Collector", description: "Own 3 epic items", icon: "👑", requiredValue: 3, category: .collection, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "legendary_item", title: "Legendary Finder", description: "Own a legendary item", icon: "🌟", requiredValue: 1, category: .collection, tier: .platinum, reward: .forTier(.platinum)),
        Achievement(key: "full_equip", title: "Full Wardrobe", description: "Equip all 3 equipment slots", icon: "🛡️", requiredValue: 3, category: .collection, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "cosmetics_10", title: "Cosmetic Collector", description: "Unlock 10 cosmetics", icon: "🎨", requiredValue: 10, category: .collection, tier: .silver, reward: .forTier(.silver)),

        // MARK: - Seasonal Achievements (NEW - 5)
        Achievement(key: "seasonal_participate", title: "Event Participant", description: "Complete 1 seasonal challenge", icon: "🎪", requiredValue: 1, category: .seasonal, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "seasonal_champion", title: "Event Champion", description: "Complete all challenges in 1 event", icon: "🏆", requiredValue: 1, category: .seasonal, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "seasonal_veteran", title: "Season Veteran", description: "Participate in 3 events", icon: "🎖️", requiredValue: 3, category: .seasonal, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "seasonal_collector", title: "Seasonal Collector", description: "Earn 3 seasonal items", icon: "🎁", requiredValue: 3, category: .seasonal, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "seasonal_holiday", title: "Holiday Hero", description: "Complete a holiday event", icon: "🎉", requiredValue: 1, category: .seasonal, tier: .gold, reward: .forTier(.gold)),

        // MARK: - Focus Achievements (NEW - 5)
        Achievement(key: "focus_5_sessions", title: "Focus Apprentice", description: "Complete 5 focus sessions", icon: "🎯", requiredValue: 5, category: .focus, tier: .bronze, reward: .forTier(.bronze)),
        Achievement(key: "focus_25_sessions", title: "Focus Journeyman", description: "Complete 25 focus sessions", icon: "🎯", requiredValue: 25, category: .focus, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "focus_120_min", title: "Marathon Focus", description: "Complete a 120-minute session", icon: "🧘", requiredValue: 120, category: .focus, tier: .gold, reward: .forTier(.gold)),
        Achievement(key: "focus_streak_7", title: "Focus Streak", description: "Focus 7 days in a row", icon: "🔥", requiredValue: 7, category: .focus, tier: .silver, reward: .forTier(.silver)),
        Achievement(key: "focus_total_5000", title: "Total Dedication", description: "Focus for 5000 minutes total", icon: "🧘‍♂️", requiredValue: 5000, category: .focus, tier: .platinum, reward: .forTier(.platinum))
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
