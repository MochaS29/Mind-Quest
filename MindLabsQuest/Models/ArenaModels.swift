import Foundation
import SwiftUI

// MARK: - Arena Rank
enum ArenaRank: String, CaseIterable, Codable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case diamond = "Diamond"
    case champion = "Champion"

    var icon: String {
        switch self {
        case .bronze: return "shield.fill"
        case .silver: return "shield.lefthalf.filled"
        case .gold: return "medal.fill"
        case .diamond: return "diamond.fill"
        case .champion: return "crown.fill"
        }
    }

    var emoji: String {
        switch self {
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🥇"
        case .diamond: return "💎"
        case .champion: return "👑"
        }
    }

    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .diamond: return Color(red: 0.5, green: 0.8, blue: 1.0)
        case .champion: return Color(red: 1.0, green: 0.3, blue: 0.3)
        }
    }

    var ratingRange: ClosedRange<Int> {
        switch self {
        case .bronze: return 0...499
        case .silver: return 500...999
        case .gold: return 1000...1499
        case .diamond: return 1500...1999
        case .champion: return 2000...9999
        }
    }

    static func rank(for rating: Int) -> ArenaRank {
        switch rating {
        case 0..<500: return .bronze
        case 500..<1000: return .silver
        case 1000..<1500: return .gold
        case 1500..<2000: return .diamond
        default: return .champion
        }
    }
}

// MARK: - Arena Opponent
struct ArenaOpponent: Codable {
    var name: String
    var characterClass: CharacterClass
    var level: Int
    var avatar: String
    var rating: Int
    var rank: ArenaRank
    var equipment: EquipmentLoadout
    var stats: [StatType: Int]

    var attackPower: Int {
        let str = stats[.strength] ?? 10
        let dex = stats[.dexterity] ?? 10
        let equipBonus = equipment.totalStatModifiers()[.strength] ?? 0
        return 10 + (str - 10) + (dex - 10) / 2 + equipBonus
    }

    var defensePower: Int {
        let con = stats[.constitution] ?? 10
        let equipBonus = equipment.totalStatModifiers()[.constitution] ?? 0
        return 5 + (con - 10) / 2 + equipBonus
    }

    var maxHP: Int {
        return 100 + (level - 1) * 10
    }

    var effectiveStats: [StatType: Int] {
        var result = stats
        let mods = equipment.totalStatModifiers()
        for (stat, value) in mods {
            result[stat, default: 10] += value
        }
        return result
    }

    func toBattleEncounter() -> BattleEncounter {
        let abilities = ArenaOpponent.abilitiesForClass(characterClass, level: level)
        let xpReward = max(10, level * 5)
        let goldReward = max(5, level * 3)

        return BattleEncounter(
            enemyName: name,
            enemyAvatar: avatar,
            enemyDescription: "Arena opponent — \(rank.rawValue) rank \(characterClass.rawValue)",
            enemyLevel: level,
            enemyHP: maxHP,
            enemyMaxHP: maxHP,
            enemyAttack: attackPower,
            enemyDefense: defensePower,
            abilities: abilities,
            rewards: BattleRewards(xp: xpReward, gold: goldReward),
            lootTable: nil,
            preBattleText: "\(name) challenges you!",
            victoryText: "You defeated \(name) in the arena!"
        )
    }

    static func abilitiesForClass(_ characterClass: CharacterClass, level: Int) -> [EnemyAbility] {
        let scaledDmg = 8 + level * 2
        switch characterClass {
        case .warrior:
            return [
                EnemyAbility(name: "Power Strike", damage: scaledDmg + 5, description: "A mighty overhead swing", chance: 0.4),
                EnemyAbility(name: "Shield Wall", damage: 0, description: "Raises defenses", chance: 0.2,
                             statusEffect: StatusEffect(type: .shield, duration: 2, value: scaledDmg / 2))
            ]
        case .ranger:
            return [
                EnemyAbility(name: "Aimed Shot", damage: scaledDmg + 8, description: "A precise arrow", chance: 0.35),
                EnemyAbility(name: "Quick Shot", damage: scaledDmg, description: "A rapid volley", chance: 0.3)
            ]
        case .pirate:
            return [
                EnemyAbility(name: "Cutlass Fury", damage: scaledDmg + 4, description: "Wild slashing attack", chance: 0.35),
                EnemyAbility(name: "Bleeding Strike", damage: scaledDmg, description: "A cut that bleeds", chance: 0.25,
                             statusEffect: StatusEffect(type: .bleed, duration: 3, value: scaledDmg / 3))
            ]
        case .iceMage:
            return [
                EnemyAbility(name: "Frost Bolt", damage: scaledDmg + 6, description: "A bolt of ice", chance: 0.35),
                EnemyAbility(name: "Frozen Touch", damage: scaledDmg / 2, description: "Chilling stun", chance: 0.2,
                             statusEffect: StatusEffect(type: .stun, duration: 1, value: 0))
            ]
        case .necromancer:
            return [
                EnemyAbility(name: "Shadow Drain", damage: scaledDmg + 3, description: "Drains life force", chance: 0.35),
                EnemyAbility(name: "Curse", damage: scaledDmg / 2, description: "A weakening curse", chance: 0.25,
                             statusEffect: StatusEffect(type: .weaken, duration: 2, value: scaledDmg / 3))
            ]
        case .warriorKing:
            return [
                EnemyAbility(name: "Royal Command", damage: scaledDmg + 6, description: "A commanding strike", chance: 0.35),
                EnemyAbility(name: "Inspire", damage: 0, description: "Bolsters own strength", chance: 0.2,
                             statusEffect: StatusEffect(type: .strengthen, duration: 2, value: scaledDmg / 3))
            ]
        case .dragon:
            return [
                EnemyAbility(name: "Fire Breath", damage: scaledDmg + 7, description: "Scorching flames", chance: 0.35,
                             statusEffect: StatusEffect(type: .burn, duration: 2, value: scaledDmg / 4)),
                EnemyAbility(name: "Tail Swipe", damage: scaledDmg + 3, description: "A powerful tail swing", chance: 0.3)
            ]
        case .angel:
            return [
                EnemyAbility(name: "Divine Smite", damage: scaledDmg + 6, description: "Holy energy strike", chance: 0.35),
                EnemyAbility(name: "Healing Light", damage: 0, description: "Regenerates health", chance: 0.2,
                             statusEffect: StatusEffect(type: .regenerate, duration: 3, value: scaledDmg / 3))
            ]
        }
    }
}

// MARK: - Arena Stats
struct ArenaStats: Codable {
    var rating: Int = 200
    var arenaTokens: Int = 0
    var totalWins: Int = 0
    var totalLosses: Int = 0
    var currentWinStreak: Int = 0
    var highestWinStreak: Int = 0
    var highestRating: Int = 200
    var matchHistory: [ArenaMatchResult] = []

    var rank: ArenaRank {
        ArenaRank.rank(for: rating)
    }

    mutating func addMatchResult(_ result: ArenaMatchResult) {
        matchHistory.insert(result, at: 0)
        if matchHistory.count > 50 {
            matchHistory = Array(matchHistory.prefix(50))
        }
    }
}

// MARK: - Arena Match Result
struct ArenaMatchResult: Identifiable, Codable {
    var id: UUID = UUID()
    var opponentName: String
    var opponentClass: CharacterClass
    var opponentLevel: Int
    var opponentRank: ArenaRank
    var victory: Bool
    var ratingChange: Int
    var tokensEarned: Int
    var date: Date = Date()
}

// MARK: - Arena Name Bank
struct ArenaNameBank {
    static let prefixes = [
        "Shadow", "Storm", "Iron", "Frost", "Flame",
        "Dark", "Crystal", "Thunder", "Silent", "Crimson",
        "Night", "Star", "Wind", "Stone", "Blood",
        "Moon", "Sun", "Void", "Ember", "Steel"
    ]

    static let suffixes = [
        "blade", "hunter", "walker", "striker", "weaver",
        "bane", "fang", "heart", "shield", "sworn",
        "fire", "storm", "claw", "forge", "spirit",
        "wing", "eye", "hand", "soul", "keeper"
    ]

    static func randomName() -> String {
        let prefix = prefixes.randomElement()!
        let suffix = suffixes.randomElement()!
        return "\(prefix)\(suffix)"
    }
}
