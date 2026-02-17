import Foundation
import SwiftUI

// MARK: - Character Classes
enum CharacterClass: String, CaseIterable, Codable {
    case ranger = "Ranger"
    case warrior = "Warrior"
    case warriorKing = "Warrior King"
    case pirate = "Pirate"
    case iceMage = "Ice Mage"
    case necromancer = "Necromancer"
    case dragon = "Dragon"
    case angel = "Angel"

    var icon: String {
        switch self {
        case .ranger: return "🏹"
        case .warrior: return "⚔️"
        case .warriorKing: return "👑"
        case .pirate: return "🏴‍☠️"
        case .iceMage: return "❄️"
        case .necromancer: return "💀"
        case .dragon: return "🐉"
        case .angel: return "😇"
        }
    }

    var avatarImages: [String] {
        switch self {
        case .ranger: return ["mindquest_ranger_female_01", "mindquest_ranger_male_01", "mindquest_ranger_03", "mindquest_ranger_04"]
        case .warrior: return ["mindquest_warrior_01", "mindquest_warrior_02", "mindquest_warrior_03", "mindquest_warrior_04"]
        case .warriorKing: return ["mindquest_warrior_king_01", "mindquest_warrior_king_02"]
        case .pirate: return ["mindquest_pirate_01", "mindquest_pirate_02", "mindquest_pirate_03"]
        case .iceMage: return ["mindquest_ice_mage_01", "mindquest_ice_mage_02", "mindquest_ice_mage_03"]
        case .necromancer: return ["mindquest_necromancer_female_01", "mindquest_necromancer_female_02"]
        case .dragon: return ["mindquest_dragon_01", "mindquest_dragon_02", "mindquest_dragon_mage_01"]
        case .angel: return ["mindquest_angel_warrior_01", "mindquest_angel_warrior_02", "mindquest_angel_warrior_03"]
        }
    }

    var description: String {
        switch self {
        case .ranger: return "Master archer and nature's guardian"
        case .warrior: return "Champion of strength and courage"
        case .warriorKing: return "Royal leader with unmatched combat prowess"
        case .pirate: return "Swashbuckling adventurer of the high seas"
        case .iceMage: return "Wielder of frost and ice magic"
        case .necromancer: return "Master of dark arts and ancient magic"
        case .dragon: return "Legendary creature of immense power"
        case .angel: return "Divine warrior with celestial powers"
        }
    }

    var primaryStat: StatType {
        switch self {
        case .ranger: return .dexterity
        case .warrior, .warriorKing: return .strength
        case .pirate: return .charisma
        case .iceMage, .necromancer: return .intelligence
        case .dragon: return .constitution
        case .angel: return .wisdom
        }
    }

    var statBonuses: [StatType: Int] {
        switch self {
        case .ranger: return [.dexterity: 3, .wisdom: 2, .strength: 1]
        case .warrior: return [.strength: 3, .constitution: 2, .dexterity: 1]
        case .warriorKing: return [.strength: 3, .charisma: 2, .constitution: 1]
        case .pirate: return [.charisma: 3, .dexterity: 2, .strength: 1]
        case .iceMage: return [.intelligence: 3, .wisdom: 2, .constitution: 1]
        case .necromancer: return [.intelligence: 3, .constitution: 2, .wisdom: 1]
        case .dragon: return [.constitution: 3, .strength: 2, .wisdom: 1]
        case .angel: return [.wisdom: 3, .charisma: 2, .dexterity: 1]
        }
    }
}

// MARK: - Background
enum Background: String, CaseIterable, Codable {
    case student = "Student"
    case athlete = "Athlete"
    case artist = "Artist"
    case leader = "Leader"
    case explorer = "Explorer"

    var description: String {
        switch self {
        case .student: return "Academic life is your main quest"
        case .athlete: return "Physical excellence drives you"
        case .artist: return "Creativity flows through everything you do"
        case .leader: return "You inspire and guide others"
        case .explorer: return "Adventure and discovery call to you"
        }
    }

    var bonuses: [StatType: Int] {
        switch self {
        case .student: return [.intelligence: 1, .wisdom: 1]
        case .athlete: return [.strength: 1, .constitution: 1]
        case .artist: return [.dexterity: 1, .charisma: 1]
        case .leader: return [.charisma: 1, .wisdom: 1]
        case .explorer: return [.dexterity: 1, .constitution: 1]
        }
    }
}

// MARK: - Stats
enum StatType: String, CaseIterable, Codable {
    case strength = "Strength"
    case dexterity = "Dexterity"
    case constitution = "Constitution"
    case intelligence = "Intelligence"
    case wisdom = "Wisdom"
    case charisma = "Charisma"

    var icon: String {
        switch self {
        case .strength: return "💪"
        case .dexterity: return "🤸"
        case .constitution: return "❤️"
        case .intelligence: return "🧠"
        case .wisdom: return "🧘"
        case .charisma: return "✨"
        }
    }

    var color: Color {
        switch self {
        case .strength: return .red
        case .dexterity: return .orange
        case .constitution: return .green
        case .intelligence: return .blue
        case .wisdom: return .purple
        case .charisma: return .pink
        }
    }
}

// MARK: - Character Traits
enum CharacterTrait: String, CaseIterable, Codable {
    case disciplined = "Disciplined"
    case creative = "Creative"
    case social = "Social"
    case analytical = "Analytical"
    case resilient = "Resilient"
    case adventurous = "Adventurous"
    case focused = "Focused"
    case empathetic = "Empathetic"

    var description: String {
        switch self {
        case .disciplined: return "Gain +10% XP from completed daily quests"
        case .creative: return "+15% XP from creative tasks"
        case .social: return "+15% XP from social tasks"
        case .analytical: return "+15% XP from academic tasks"
        case .resilient: return "+5 max health per level"
        case .adventurous: return "+10% gold from all quests"
        case .focused: return "-20% estimated time for all tasks"
        case .empathetic: return "+1 to all social quest rewards"
        }
    }

    var icon: String {
        switch self {
        case .disciplined: return "⚔️"
        case .creative: return "🎨"
        case .social: return "💬"
        case .analytical: return "🔬"
        case .resilient: return "🛡️"
        case .adventurous: return "🗺️"
        case .focused: return "🎯"
        case .empathetic: return "❤️"
        }
    }
}

// MARK: - Character Motivation
enum CharacterMotivation: String, CaseIterable, Codable {
    case achievement = "Achievement Hunter"
    case knowledge = "Knowledge Seeker"
    case social = "Social Butterfly"
    case health = "Wellness Warrior"
    case creative = "Creative Soul"
    case balanced = "Balanced Life"

    var description: String {
        switch self {
        case .achievement: return "Live for completing challenges"
        case .knowledge: return "Driven by learning and discovery"
        case .social: return "Motivated by helping others"
        case .health: return "Focused on physical and mental wellness"
        case .creative: return "Inspired by artistic expression"
        case .balanced: return "Seek harmony in all things"
        }
    }

    var questBonus: TaskCategory? {
        switch self {
        case .achievement: return nil
        case .knowledge: return .academic
        case .social: return .social
        case .health: return .health
        case .creative: return .creative
        case .balanced: return nil
        }
    }
}

// MARK: - Character Model
struct Character: Codable {
    var name: String = ""
    var characterClass: CharacterClass?
    var background: Background?
    var traits: [CharacterTrait] = []
    var motivation: CharacterMotivation?
    var level: Int = 1
    var xp: Int = 0
    var xpToNext: Int = 100
    var stats: [StatType: Int] = [
        .strength: 10,
        .dexterity: 10,
        .constitution: 10,
        .intelligence: 10,
        .wisdom: 10,
        .charisma: 10
    ]
    var health: Int = 100
    var maxHealth: Int = 100
    var gold: Int = 100
    var energy: Int = 5
    var maxEnergy: Int = 5
    var lastEnergyRegenTime: Date = Date()
    var streak: Int = 0
    var avatar: String = "🧙‍♂️"
    var preferredDifficulty: Difficulty = .medium
    var dailyQuestIds: Set<String> = []

    // Achievement tracking
    var totalQuestsCompleted: Int = 0
    var totalFocusMinutes: Int = 0
    var uniqueClassesPlayed: Set<String> = []
    var questCategoriesCompleted: Set<String> = []

    // MARK: - Skill System
    var skillProgress: SkillProgress = SkillProgress()

    // MARK: - Inventory & Equipment
    var inventory: [InventoryEntry] = []
    var equipment: EquipmentLoadout = EquipmentLoadout()
    var inventoryCapacity: Int = 50

    var modifier: (StatType) -> Int {
        return { stat in
            (self.stats[stat, default: 10] - 10) / 2
        }
    }

    // MARK: - Skill Bonuses
    var skillBonuses: SkillBonusSummary {
        guard let charClass = characterClass else { return SkillBonusSummary() }
        let allSkills = SkillTreeDatabase.skillTree(for: charClass)
        var summary = SkillBonusSummary()
        for skill in allSkills where skillProgress.unlockedSkillIds.contains(skill.id) {
            for effect in skill.effects {
                summary.apply(effect)
            }
        }
        return summary
    }

    // MARK: - Effective Stats (base + equipment + skills)
    var effectiveStats: [StatType: Int] {
        var result = stats
        let equipmentMods = equipment.totalStatModifiers()
        for (stat, bonus) in equipmentMods {
            result[stat, default: 10] += bonus
        }
        let skillBoosts = skillBonuses.statBoosts
        for (stat, bonus) in skillBoosts {
            result[stat, default: 10] += bonus
        }
        return result
    }

    var attackPower: Int {
        let str = effectiveStats[.strength] ?? 10
        let dex = effectiveStats[.dexterity] ?? 10
        return 10 + (str - 10) + (dex - 10) / 2
    }

    var defensePower: Int {
        let con = effectiveStats[.constitution] ?? 10
        return 5 + (con - 10) / 2
    }

    mutating func applyTraitBonuses() {
        for trait in traits {
            switch trait {
            case .resilient:
                maxHealth += 5 * level
                health = maxHealth
            default:
                break
            }
        }
    }

    // MARK: - Inventory Helpers
    var inventoryCount: Int {
        inventory.reduce(0) { $0 + $1.quantity }
    }

    var isInventoryFull: Bool {
        inventoryCount >= inventoryCapacity
    }

    mutating func addItem(_ item: Item, quantity: Int = 1) -> Bool {
        guard inventoryCount + quantity <= inventoryCapacity else { return false }

        if let index = inventory.firstIndex(where: { $0.item.id == item.id }) {
            inventory[index].quantity += quantity
        } else {
            inventory.append(InventoryEntry(item: item, quantity: quantity))
        }
        return true
    }

    mutating func removeItem(_ itemId: UUID, quantity: Int = 1) -> Bool {
        guard let index = inventory.firstIndex(where: { $0.item.id == itemId }) else { return false }

        if inventory[index].quantity <= quantity {
            inventory.remove(at: index)
        } else {
            inventory[index].quantity -= quantity
        }
        return true
    }

    mutating func equip(_ item: Item) -> Item? {
        guard let slot = item.slot else { return nil }

        // Check class restriction
        if let restrictions = item.classRestrictions, !restrictions.isEmpty {
            guard let charClass = characterClass, restrictions.contains(charClass) else { return nil }
        }

        // Check level requirement
        guard level >= item.levelRequirement else { return nil }

        // Unequip current item in that slot
        let previousItem = equipment.item(in: slot)

        // Remove from inventory
        guard removeItem(item.id) else { return nil }

        // Equip new item
        equipment.setItem(item, in: slot)

        // Add previous item back to inventory
        if let prev = previousItem {
            _ = addItem(prev)
        }

        return previousItem
    }

    mutating func unequip(slot: EquipmentSlot) -> Bool {
        guard let item = equipment.item(in: slot) else { return false }
        guard !isInventoryFull else { return false }

        equipment.clearSlot(slot)
        _ = addItem(item)
        return true
    }
}
