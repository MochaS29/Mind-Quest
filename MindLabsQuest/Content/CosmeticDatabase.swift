import Foundation
import SwiftUI

struct CosmeticDatabase {

    // MARK: - All Cosmetics
    static let allCosmetics: [CosmeticItem] = titles + borders + battleEffects

    // MARK: - Titles (8)
    static let titles: [CosmeticItem] = [
        CosmeticItem(
            id: "title_the_brave", name: "the Brave", description: "A title for courageous adventurers",
            type: .title, icon: "shield.fill", rarity: .common,
            unlockRequirement: .level(5), displayText: "the Brave"
        ),
        CosmeticItem(
            id: "title_quest_master", name: "Quest Master", description: "Awarded to prolific quest completers",
            type: .title, icon: "scroll.fill", rarity: .uncommon,
            unlockRequirement: .questsCompleted(50), displayText: "Quest Master"
        ),
        CosmeticItem(
            id: "title_dungeon_crawler", name: "Dungeon Crawler", description: "Earned by clearing dungeons",
            type: .title, icon: "building.columns.fill", rarity: .uncommon,
            unlockRequirement: .dungeonClears(5), displayText: "Dungeon Crawler"
        ),
        CosmeticItem(
            id: "title_arena_victor", name: "Arena Victor", description: "Claimed by arena combatants",
            type: .title, icon: "trophy.fill", rarity: .rare,
            unlockRequirement: .arenaRank(.silver), displayText: "Arena Victor"
        ),
        CosmeticItem(
            id: "title_the_legendary", name: "the Legendary", description: "For those who reach great heights",
            type: .title, icon: "star.fill", rarity: .rare,
            unlockRequirement: .level(25), displayText: "the Legendary"
        ),
        CosmeticItem(
            id: "title_champion", name: "Champion", description: "The ultimate arena title",
            type: .title, icon: "crown.fill", rarity: .epic,
            unlockRequirement: .arenaRank(.champion), displayText: "Champion"
        ),
        CosmeticItem(
            id: "title_prestige_star", name: "Prestige Star", description: "Earned through prestige",
            type: .title, icon: "star.circle.fill", rarity: .epic,
            unlockRequirement: .prestigeLevel(1), displayText: "Prestige Star"
        ),
        CosmeticItem(
            id: "title_the_immortal", name: "the Immortal", description: "For the most dedicated heroes",
            type: .title, icon: "infinity", rarity: .legendary,
            unlockRequirement: .prestigeLevel(3), displayText: "the Immortal"
        )
    ]

    // MARK: - Borders (6)
    static let borders: [CosmeticItem] = [
        CosmeticItem(
            id: "border_bronze", name: "Bronze Frame", description: "A simple bronze frame",
            type: .border, icon: "square", rarity: .common,
            unlockRequirement: .level(3), borderColorHex: "CD7F32", borderWidth: 2, glowEffect: false
        ),
        CosmeticItem(
            id: "border_silver", name: "Silver Frame", description: "A polished silver frame",
            type: .border, icon: "square", rarity: .uncommon,
            unlockRequirement: .level(10), borderColorHex: "C0C0C0", borderWidth: 3, glowEffect: false
        ),
        CosmeticItem(
            id: "border_gold", name: "Gold Frame", description: "A gleaming gold frame",
            type: .border, icon: "square", rarity: .rare,
            unlockRequirement: .level(20), borderColorHex: "FFD700", borderWidth: 3, glowEffect: false
        ),
        CosmeticItem(
            id: "border_arena_champion", name: "Arena Champion", description: "Earned in the arena",
            type: .border, icon: "square.fill", rarity: .epic,
            unlockRequirement: .arenaRank(.gold), borderColorHex: "FF4500", borderWidth: 4, glowEffect: true
        ),
        CosmeticItem(
            id: "border_dungeon_master", name: "Dungeon Master", description: "Earned by conquering dungeons",
            type: .border, icon: "square.fill", rarity: .epic,
            unlockRequirement: .dungeonClears(10), borderColorHex: "8B0000", borderWidth: 4, glowEffect: true
        ),
        CosmeticItem(
            id: "border_prestige_glow", name: "Prestige Glow", description: "A radiant prestige border",
            type: .border, icon: "square.fill", rarity: .legendary,
            unlockRequirement: .prestigeLevel(2), borderColorHex: "9B59B6", borderWidth: 5, glowEffect: true
        )
    ]

    // MARK: - Battle Effects (6)
    static let battleEffects: [CosmeticItem] = [
        CosmeticItem(
            id: "effect_basic_sparks", name: "Basic Sparks", description: "Simple battle sparks",
            type: .battleEffect, icon: "sparkle", rarity: .common,
            unlockRequirement: .level(1), enterEmoji: "✨", victoryEmoji: "🎉", defeatEmoji: "💫"
        ),
        CosmeticItem(
            id: "effect_frost_entry", name: "Frost Entry", description: "Enter battle in a flurry of ice",
            type: .battleEffect, icon: "snowflake", rarity: .uncommon,
            unlockRequirement: .characterClass(.iceMage), enterEmoji: "❄️", victoryEmoji: "🧊", defeatEmoji: "💧"
        ),
        CosmeticItem(
            id: "effect_fire_entry", name: "Fire Entry", description: "Blaze into battle",
            type: .battleEffect, icon: "flame.fill", rarity: .uncommon,
            unlockRequirement: .battleWins(10), enterEmoji: "🔥", victoryEmoji: "🌋", defeatEmoji: "💨"
        ),
        CosmeticItem(
            id: "effect_lightning_strike", name: "Lightning Strike", description: "Enter with a thunderous crash",
            type: .battleEffect, icon: "bolt.fill", rarity: .rare,
            unlockRequirement: .arenaRank(.silver), enterEmoji: "⚡", victoryEmoji: "🌩️", defeatEmoji: "☁️"
        ),
        CosmeticItem(
            id: "effect_shadow_entrance", name: "Shadow Entrance", description: "Emerge from the darkness",
            type: .battleEffect, icon: "moon.fill", rarity: .rare,
            unlockRequirement: .classAndLevel(.necromancer, 15), enterEmoji: "🌑", victoryEmoji: "💀", defeatEmoji: "👻"
        ),
        CosmeticItem(
            id: "effect_divine_light", name: "Divine Light", description: "A holy aura surrounds you",
            type: .battleEffect, icon: "sun.max.fill", rarity: .epic,
            unlockRequirement: .battleWins(100), enterEmoji: "✨", victoryEmoji: "👼", defeatEmoji: "🕊️"
        )
    ]

    static func cosmetic(for id: String) -> CosmeticItem? {
        allCosmetics.first(where: { $0.id == id })
    }

    static func cosmetics(of type: CosmeticType) -> [CosmeticItem] {
        allCosmetics.filter { $0.type == type }
    }
}
