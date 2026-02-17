import Foundation
import SwiftUI

// MARK: - Battle Encounter
struct BattleEncounter: Identifiable, Codable {
    var id: UUID = UUID()
    var enemyName: String
    var enemyAvatar: String
    var enemyDescription: String
    var enemyLevel: Int
    var enemyHP: Int
    var enemyMaxHP: Int
    var enemyAttack: Int
    var enemyDefense: Int
    var isBoss: Bool = false
    var abilities: [EnemyAbility]
    var rewards: BattleRewards
    var lootTable: LootTable?
    var backgroundImage: String?
    var preBattleText: String?
    var victoryText: String?
}

// MARK: - Enemy Ability
struct EnemyAbility: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var damage: Int
    var description: String
    var chance: Double = 0.3
    var statusEffect: StatusEffect?
}

// MARK: - Battle Rewards
struct BattleRewards: Codable {
    var xp: Int
    var gold: Int
    var itemDrops: [(Item, Int)]?

    enum CodingKeys: String, CodingKey {
        case xp, gold
    }

    init(xp: Int, gold: Int, itemDrops: [(Item, Int)]? = nil) {
        self.xp = xp
        self.gold = gold
        self.itemDrops = itemDrops
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        xp = try container.decode(Int.self, forKey: .xp)
        gold = try container.decode(Int.self, forKey: .gold)
        itemDrops = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(xp, forKey: .xp)
        try container.encode(gold, forKey: .gold)
    }
}

// MARK: - Status Effect
struct StatusEffect: Identifiable, Codable {
    var id: UUID = UUID()
    var type: StatusEffectType
    var duration: Int // turns remaining
    var value: Int // damage per tick, heal per tick, stat modifier amount, etc.
    var sourceDescription: String = ""

    var isExpired: Bool { duration <= 0 }

    mutating func tick() {
        duration -= 1
    }
}

enum StatusEffectType: String, CaseIterable, Codable {
    case poison = "Poison"
    case burn = "Burn"
    case stun = "Stun"
    case bleed = "Bleed"
    case shield = "Shield"
    case strengthen = "Strengthen"
    case weaken = "Weaken"
    case regenerate = "Regenerate"

    var icon: String {
        switch self {
        case .poison: return "☠️"
        case .burn: return "🔥"
        case .stun: return "⚡"
        case .bleed: return "🩸"
        case .shield: return "🛡️"
        case .strengthen: return "💪"
        case .weaken: return "📉"
        case .regenerate: return "💚"
        }
    }

    var color: Color {
        switch self {
        case .poison: return .green
        case .burn: return .orange
        case .stun: return .yellow
        case .bleed: return .red
        case .shield: return .blue
        case .strengthen: return .purple
        case .weaken: return .gray
        case .regenerate: return .mint
        }
    }

    var isDebuff: Bool {
        switch self {
        case .poison, .burn, .stun, .bleed, .weaken: return true
        case .shield, .strengthen, .regenerate: return false
        }
    }
}

// MARK: - Elemental Type
enum ElementalType: String, CaseIterable, Codable {
    case fire = "Fire"
    case ice = "Ice"
    case shadow = "Shadow"
    case lightning = "Lightning"
    case nature = "Nature"
    case holy = "Holy"
    case physical = "Physical"

    var icon: String {
        switch self {
        case .fire: return "🔥"
        case .ice: return "❄️"
        case .shadow: return "🌑"
        case .lightning: return "⚡"
        case .nature: return "🌿"
        case .holy: return "✨"
        case .physical: return "⚔️"
        }
    }
}

// MARK: - Enemy Template
struct EnemyTemplate: Identifiable, Codable {
    var id: String
    var name: String
    var avatar: String
    var description: String
    var tier: Int // 1-5
    var levelRange: ClosedRange<Int>
    var baseHP: Int
    var baseAttack: Int
    var baseDefense: Int
    var isBoss: Bool = false
    var element: ElementalType = .physical
    var abilities: [EnemyAbility]
    var lootTable: LootTable

    func encounter(atLevel level: Int) -> BattleEncounter {
        let scaleFactor = 1.0 + Double(level - levelRange.lowerBound) * 0.1
        let scaledHP = Int(Double(baseHP) * scaleFactor)
        let scaledAttack = Int(Double(baseAttack) * scaleFactor)
        let scaledDefense = Int(Double(baseDefense) * scaleFactor)

        let lootResult = lootTable.roll()
        let baseRewards = BattleRewards(
            xp: lootTable.guaranteedXP + level * 10,
            gold: lootResult.gold,
            itemDrops: lootResult.items.isEmpty ? nil : lootResult.items
        )

        return BattleEncounter(
            enemyName: name,
            enemyAvatar: avatar,
            enemyDescription: description,
            enemyLevel: level,
            enemyHP: scaledHP,
            enemyMaxHP: scaledHP,
            enemyAttack: scaledAttack,
            enemyDefense: scaledDefense,
            isBoss: isBoss,
            abilities: abilities,
            rewards: baseRewards,
            lootTable: lootTable
        )
    }
}
