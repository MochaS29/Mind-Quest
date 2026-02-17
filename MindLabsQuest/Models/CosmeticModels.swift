import Foundation
import SwiftUI

// MARK: - Cosmetic Type
enum CosmeticType: String, CaseIterable, Codable {
    case title = "Title"
    case border = "Border"
    case battleEffect = "Battle Effect"

    var icon: String {
        switch self {
        case .title: return "tag.fill"
        case .border: return "square.dashed"
        case .battleEffect: return "sparkles"
        }
    }
}

// MARK: - Cosmetic Unlock Requirement
enum CosmeticUnlockRequirement: Codable, Equatable {
    case level(Int)
    case achievement(String)
    case prestigeLevel(Int)
    case arenaRank(ArenaRank)
    case questsCompleted(Int)
    case dungeonClears(Int)
    case battleWins(Int)
    case gold(Int)
    case seasonal(String)
    case characterClass(CharacterClass)
    case classAndLevel(CharacterClass, Int)

    var description: String {
        switch self {
        case .level(let lvl): return "Reach level \(lvl)"
        case .achievement(let id): return "Unlock achievement: \(id)"
        case .prestigeLevel(let lvl): return "Prestige level \(lvl)"
        case .arenaRank(let rank): return "Reach \(rank.rawValue) arena rank"
        case .questsCompleted(let count): return "Complete \(count) quests"
        case .dungeonClears(let count): return "Clear \(count) dungeons"
        case .battleWins(let count): return "Win \(count) battles"
        case .gold(let amount): return "Accumulate \(amount) gold"
        case .seasonal(let eventId): return "Participate in seasonal event: \(eventId)"
        case .characterClass(let cc): return "Play as \(cc.rawValue)"
        case .classAndLevel(let cc, let lvl): return "\(cc.rawValue) class at level \(lvl)"
        }
    }
}

// MARK: - Cosmetic Item
struct CosmeticItem: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var description: String
    var type: CosmeticType
    var icon: String
    var rarity: ItemRarity
    var unlockRequirement: CosmeticUnlockRequirement

    // Type-specific data
    var displayText: String? // For titles (e.g., "the Brave")
    var borderColorHex: String? // For borders
    var borderWidth: CGFloat? // For borders
    var glowEffect: Bool? // For borders
    var enterEmoji: String? // For battle effects
    var victoryEmoji: String? // For battle effects
    var defeatEmoji: String? // For battle effects

    static func == (lhs: CosmeticItem, rhs: CosmeticItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Cosmetic Loadout
struct CosmeticLoadout: Codable, Equatable {
    var equippedTitle: String? = nil
    var equippedBorder: String? = nil
    var equippedBattleEffect: String? = nil
}
