import Foundation

// MARK: - Skill Branch
enum SkillBranch: String, CaseIterable, Codable {
    case offense
    case defense
    case utility

    var displayName: String {
        switch self {
        case .offense: return "Offense"
        case .defense: return "Defense"
        case .utility: return "Utility"
        }
    }

    var icon: String {
        switch self {
        case .offense: return "flame.fill"
        case .defense: return "shield.fill"
        case .utility: return "gearshape.fill"
        }
    }

    var color: String {
        switch self {
        case .offense: return "red"
        case .defense: return "blue"
        case .utility: return "green"
        }
    }
}

// MARK: - Skill Effect
enum SkillEffect: Codable, Equatable {
    case statBoost(stat: StatType, value: Int)
    case critChance(percent: Int)
    case dodgeChance(percent: Int)
    case damageMultiplier(percent: Int)
    case defenseMultiplier(percent: Int)
    case maxHealthBonus(value: Int)
    case energyBonus(value: Int)
    case goldMultiplier(percent: Int)
    case xpMultiplier(percent: Int)
    case statusResistance(type: StatusEffectType, percent: Int)
    case specialCooldownReduction(turns: Int)
    case lifesteal(percent: Int)
    case counterattack(percent: Int)
}

// MARK: - Skill
struct Skill: Identifiable, Codable, Equatable {
    var id: String              // e.g. "ranger_off_1"
    var name: String
    var icon: String
    var description: String
    var branch: SkillBranch
    var tier: Int               // 1-3
    var skillPointCost: Int     // tier 1=1, tier 2=2, tier 3=3
    var prerequisiteSkillId: String?
    var effects: [SkillEffect]
    var characterClass: CharacterClass
}

// MARK: - Skill Progress (persisted on Character)
struct SkillProgress: Codable {
    var unlockedSkillIds: Set<String> = []
    var skillPoints: Int = 0
    var totalSkillPointsEarned: Int = 0
}

// MARK: - Skill Bonus Summary (computed from unlocked skills)
struct SkillBonusSummary {
    var statBoosts: [StatType: Int] = [:]
    var critChance: Int = 0
    var dodgeChance: Int = 0
    var damageMultiplier: Int = 0       // percent bonus
    var defenseMultiplier: Int = 0      // percent bonus
    var maxHealthBonus: Int = 0
    var energyBonus: Int = 0
    var goldMultiplier: Int = 0         // percent bonus
    var xpMultiplier: Int = 0           // percent bonus
    var specialCooldownReduction: Int = 0
    var lifestealPercent: Int = 0
    var counterattackPercent: Int = 0
    var statusResistances: [StatusEffectType: Int] = [:]

    mutating func apply(_ effect: SkillEffect) {
        switch effect {
        case .statBoost(let stat, let value):
            statBoosts[stat, default: 0] += value
        case .critChance(let percent):
            critChance += percent
        case .dodgeChance(let percent):
            dodgeChance += percent
        case .damageMultiplier(let percent):
            damageMultiplier += percent
        case .defenseMultiplier(let percent):
            defenseMultiplier += percent
        case .maxHealthBonus(let value):
            maxHealthBonus += value
        case .energyBonus(let value):
            energyBonus += value
        case .goldMultiplier(let percent):
            goldMultiplier += percent
        case .xpMultiplier(let percent):
            xpMultiplier += percent
        case .statusResistance(let type, let percent):
            statusResistances[type, default: 0] += percent
        case .specialCooldownReduction(let turns):
            specialCooldownReduction += turns
        case .lifesteal(let percent):
            lifestealPercent += percent
        case .counterattack(let percent):
            counterattackPercent += percent
        }
    }
}
