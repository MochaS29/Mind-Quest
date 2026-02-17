import Foundation
import SwiftUI

// MARK: - Item Type
enum ItemType: String, CaseIterable, Codable {
    case weapon = "Weapon"
    case armor = "Armor"
    case accessory = "Accessory"
    case consumable = "Consumable"
    case material = "Material"
    case questItem = "Quest Item"

    var icon: String {
        switch self {
        case .weapon: return "⚔️"
        case .armor: return "🛡️"
        case .accessory: return "💍"
        case .consumable: return "🧪"
        case .material: return "🪨"
        case .questItem: return "🔑"
        }
    }
}

// MARK: - Item Rarity
enum ItemRarity: String, CaseIterable, Codable, Comparable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"

    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }

    var sortOrder: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }

    static func < (lhs: ItemRarity, rhs: ItemRarity) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    var sellMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.5
        case .rare: return 2.5
        case .epic: return 4.0
        case .legendary: return 8.0
        }
    }
}

// MARK: - Equipment Slot
enum EquipmentSlot: String, CaseIterable, Codable {
    case weapon = "Weapon"
    case armor = "Armor"
    case accessory = "Accessory"

    var icon: String {
        switch self {
        case .weapon: return "⚔️"
        case .armor: return "🛡️"
        case .accessory: return "💍"
        }
    }
}

// MARK: - Item
struct Item: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var templateId: String
    var name: String
    var icon: String
    var type: ItemType
    var rarity: ItemRarity
    var levelRequirement: Int = 1
    var buyPrice: Int
    var sellPrice: Int
    var itemDescription: String
    var statModifiers: [StatType: Int] = [:]
    var slot: EquipmentSlot?
    var classRestrictions: [CharacterClass]?

    // Consumable properties
    var healAmount: Int?
    var statusEffectCure: String?
    var tempStatBoost: [StatType: Int]?
    var tempBoostDuration: Int?
    var battleDamage: Int?

    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Inventory Entry
struct InventoryEntry: Identifiable, Codable {
    var id: UUID { item.id }
    var item: Item
    var quantity: Int
}

// MARK: - Equipment Loadout
struct EquipmentLoadout: Codable {
    var weapon: Item?
    var armor: Item?
    var accessory: Item?

    func totalStatModifiers() -> [StatType: Int] {
        var result: [StatType: Int] = [:]

        for equippedItem in [weapon, armor, accessory].compactMap({ $0 }) {
            for (stat, value) in equippedItem.statModifiers {
                result[stat, default: 0] += value
            }
        }

        return result
    }

    func item(in slot: EquipmentSlot) -> Item? {
        switch slot {
        case .weapon: return weapon
        case .armor: return armor
        case .accessory: return accessory
        }
    }

    mutating func setItem(_ item: Item, in slot: EquipmentSlot) {
        switch slot {
        case .weapon: weapon = item
        case .armor: armor = item
        case .accessory: accessory = item
        }
    }

    mutating func clearSlot(_ slot: EquipmentSlot) {
        switch slot {
        case .weapon: weapon = nil
        case .armor: armor = nil
        case .accessory: accessory = nil
        }
    }

    var allEquipped: [Item] {
        [weapon, armor, accessory].compactMap { $0 }
    }
}

// MARK: - Loot Table
struct LootTableEntry: Codable {
    var item: Item
    var dropChance: Double // 0.0 to 1.0
    var minQuantity: Int = 1
    var maxQuantity: Int = 1
}

struct LootTable: Codable {
    var entries: [LootTableEntry]
    var guaranteedGold: Int = 0
    var guaranteedXP: Int = 0
    var bonusGoldRange: ClosedRange<Int>?

    func roll() -> (items: [(Item, Int)], gold: Int) {
        var droppedItems: [(Item, Int)] = []
        var totalGold = guaranteedGold

        if let bonusRange = bonusGoldRange {
            totalGold += Int.random(in: bonusRange)
        }

        for entry in entries {
            if Double.random(in: 0...1) <= entry.dropChance {
                let quantity = Int.random(in: entry.minQuantity...entry.maxQuantity)
                droppedItems.append((entry.item, quantity))
            }
        }

        return (droppedItems, totalGold)
    }
}

// MARK: - Item Database
struct ItemDatabase {

    // MARK: - Starter Weapons (1 per class)
    static let rangerBow = Item(
        templateId: "starter_ranger_bow",
        name: "Recruit's Longbow",
        icon: "🏹",
        type: .weapon,
        rarity: .common,
        buyPrice: 0,
        sellPrice: 5,
        itemDescription: "A simple but reliable bow for a new Ranger.",
        statModifiers: [.dexterity: 2, .strength: 1],
        slot: .weapon,
        classRestrictions: [.ranger]
    )

    static let warriorSword = Item(
        templateId: "starter_warrior_sword",
        name: "Iron Broadsword",
        icon: "⚔️",
        type: .weapon,
        rarity: .common,
        buyPrice: 0,
        sellPrice: 5,
        itemDescription: "A sturdy blade for a new Warrior.",
        statModifiers: [.strength: 3],
        slot: .weapon,
        classRestrictions: [.warrior]
    )

    static let warriorKingScepter = Item(
        templateId: "starter_king_scepter",
        name: "Royal Training Scepter",
        icon: "👑",
        type: .weapon,
        rarity: .common,
        buyPrice: 0,
        sellPrice: 5,
        itemDescription: "A practice scepter befitting a young king.",
        statModifiers: [.strength: 2, .charisma: 1],
        slot: .weapon,
        classRestrictions: [.warriorKing]
    )

    static let pirateCutlass = Item(
        templateId: "starter_pirate_cutlass",
        name: "Rusty Cutlass",
        icon: "🗡️",
        type: .weapon,
        rarity: .common,
        buyPrice: 0,
        sellPrice: 5,
        itemDescription: "A well-used cutlass from the docks.",
        statModifiers: [.dexterity: 2, .charisma: 1],
        slot: .weapon,
        classRestrictions: [.pirate]
    )

    static let iceMageStaff = Item(
        templateId: "starter_ice_staff",
        name: "Frost Apprentice Staff",
        icon: "❄️",
        type: .weapon,
        rarity: .common,
        buyPrice: 0,
        sellPrice: 5,
        itemDescription: "A staff that channels basic frost magic.",
        statModifiers: [.intelligence: 3],
        slot: .weapon,
        classRestrictions: [.iceMage]
    )

    static let necromancerWand = Item(
        templateId: "starter_necro_wand",
        name: "Dark Initiate Wand",
        icon: "💀",
        type: .weapon,
        rarity: .common,
        buyPrice: 0,
        sellPrice: 5,
        itemDescription: "A wand infused with shadowy energy.",
        statModifiers: [.intelligence: 2, .constitution: 1],
        slot: .weapon,
        classRestrictions: [.necromancer]
    )

    static let dragonClaw = Item(
        templateId: "starter_dragon_claw",
        name: "Hatchling's Claw",
        icon: "🐉",
        type: .weapon,
        rarity: .common,
        buyPrice: 0,
        sellPrice: 5,
        itemDescription: "Razor-sharp claws of a young dragon.",
        statModifiers: [.constitution: 2, .strength: 1],
        slot: .weapon,
        classRestrictions: [.dragon]
    )

    static let angelBlade = Item(
        templateId: "starter_angel_blade",
        name: "Celestial Training Blade",
        icon: "😇",
        type: .weapon,
        rarity: .common,
        buyPrice: 0,
        sellPrice: 5,
        itemDescription: "A blade blessed with faint divine light.",
        statModifiers: [.wisdom: 2, .charisma: 1],
        slot: .weapon,
        classRestrictions: [.angel]
    )

    // MARK: - Basic Armor
    static let basicArmor = Item(
        templateId: "basic_leather_armor",
        name: "Leather Armor",
        icon: "🛡️",
        type: .armor,
        rarity: .common,
        buyPrice: 25,
        sellPrice: 12,
        itemDescription: "Simple leather armor. Better than nothing.",
        statModifiers: [.constitution: 2],
        slot: .armor
    )

    // MARK: - Tiered Weapons
    static let steelSword = Item(
        templateId: "steel_sword",
        name: "Steel Longsword",
        icon: "⚔️",
        type: .weapon,
        rarity: .uncommon,
        levelRequirement: 5,
        buyPrice: 100,
        sellPrice: 50,
        itemDescription: "A well-forged steel blade.",
        statModifiers: [.strength: 4, .dexterity: 1],
        slot: .weapon
    )

    static let enchantedBow = Item(
        templateId: "enchanted_bow",
        name: "Enchanted Longbow",
        icon: "🏹",
        type: .weapon,
        rarity: .uncommon,
        levelRequirement: 5,
        buyPrice: 100,
        sellPrice: 50,
        itemDescription: "A bow imbued with minor enchantments.",
        statModifiers: [.dexterity: 4, .wisdom: 1],
        slot: .weapon
    )

    static let frostStaff = Item(
        templateId: "frost_staff",
        name: "Frostbite Staff",
        icon: "❄️",
        type: .weapon,
        rarity: .rare,
        levelRequirement: 10,
        buyPrice: 250,
        sellPrice: 125,
        itemDescription: "Channels powerful frost magic.",
        statModifiers: [.intelligence: 6, .wisdom: 2],
        slot: .weapon
    )

    static let shadowBlade = Item(
        templateId: "shadow_blade",
        name: "Shadow Blade",
        icon: "🗡️",
        type: .weapon,
        rarity: .rare,
        levelRequirement: 10,
        buyPrice: 250,
        sellPrice: 125,
        itemDescription: "A blade forged in darkness, strikes from shadows.",
        statModifiers: [.strength: 5, .dexterity: 3],
        slot: .weapon
    )

    static let dragonSlayer = Item(
        templateId: "dragon_slayer",
        name: "Dragonslayer Greatsword",
        icon: "⚔️",
        type: .weapon,
        rarity: .epic,
        levelRequirement: 15,
        buyPrice: 500,
        sellPrice: 250,
        itemDescription: "Legendary sword said to have felled a dragon.",
        statModifiers: [.strength: 8, .constitution: 3, .dexterity: 2],
        slot: .weapon
    )

    // MARK: - Tiered Armor
    static let chainmail = Item(
        templateId: "chainmail_armor",
        name: "Chainmail Armor",
        icon: "🛡️",
        type: .armor,
        rarity: .uncommon,
        levelRequirement: 5,
        buyPrice: 120,
        sellPrice: 60,
        itemDescription: "Interlocking metal rings provide solid protection.",
        statModifiers: [.constitution: 3, .strength: 1],
        slot: .armor
    )

    static let plateArmor = Item(
        templateId: "plate_armor",
        name: "Plate Armor",
        icon: "🛡️",
        type: .armor,
        rarity: .rare,
        levelRequirement: 10,
        buyPrice: 300,
        sellPrice: 150,
        itemDescription: "Heavy plate armor for maximum defense.",
        statModifiers: [.constitution: 5, .strength: 2],
        slot: .armor
    )

    static let mageRobes = Item(
        templateId: "mage_robes",
        name: "Arcane Robes",
        icon: "🧙",
        type: .armor,
        rarity: .rare,
        levelRequirement: 10,
        buyPrice: 280,
        sellPrice: 140,
        itemDescription: "Robes woven with magical threads.",
        statModifiers: [.intelligence: 4, .wisdom: 3],
        slot: .armor
    )

    // MARK: - Accessories
    static let clarityAmulet = Item(
        templateId: "clarity_amulet",
        name: "Clarity Amulet",
        icon: "💎",
        type: .accessory,
        rarity: .common,
        buyPrice: 50,
        sellPrice: 25,
        itemDescription: "Sharpens the mind and clears distracting thoughts.",
        statModifiers: [.intelligence: 1, .wisdom: 1],
        slot: .accessory
    )

    static let strengthRing = Item(
        templateId: "strength_ring",
        name: "Ring of Might",
        icon: "💍",
        type: .accessory,
        rarity: .uncommon,
        levelRequirement: 5,
        buyPrice: 80,
        sellPrice: 40,
        itemDescription: "A ring that enhances physical power.",
        statModifiers: [.strength: 3],
        slot: .accessory
    )

    static let wisdomPendant = Item(
        templateId: "wisdom_pendant",
        name: "Pendant of Insight",
        icon: "📿",
        type: .accessory,
        rarity: .uncommon,
        levelRequirement: 5,
        buyPrice: 80,
        sellPrice: 40,
        itemDescription: "Grants heightened perception and wisdom.",
        statModifiers: [.wisdom: 3],
        slot: .accessory
    )

    static let dexterityBoots = Item(
        templateId: "dexterity_boots",
        name: "Swiftfoot Boots",
        icon: "👢",
        type: .accessory,
        rarity: .rare,
        levelRequirement: 8,
        buyPrice: 150,
        sellPrice: 75,
        itemDescription: "Enchanted boots that increase agility.",
        statModifiers: [.dexterity: 4, .strength: 1],
        slot: .accessory
    )

    // MARK: - Consumables
    static let healthPotion = Item(
        templateId: "health_potion",
        name: "Health Potion",
        icon: "❤️‍🩹",
        type: .consumable,
        rarity: .common,
        buyPrice: 20,
        sellPrice: 10,
        itemDescription: "Restores 30 HP.",
        healAmount: 30
    )

    static let greaterHealthPotion = Item(
        templateId: "greater_health_potion",
        name: "Greater Health Potion",
        icon: "❤️",
        type: .consumable,
        rarity: .uncommon,
        levelRequirement: 5,
        buyPrice: 50,
        sellPrice: 25,
        itemDescription: "Restores 75 HP.",
        healAmount: 75
    )

    static let antidote = Item(
        templateId: "antidote",
        name: "Antidote",
        icon: "🧪",
        type: .consumable,
        rarity: .common,
        buyPrice: 15,
        sellPrice: 7,
        itemDescription: "Cures poison and bleed effects.",
        statusEffectCure: "poison,bleed"
    )

    static let battleScroll = Item(
        templateId: "battle_scroll",
        name: "Scroll of Flames",
        icon: "📜",
        type: .consumable,
        rarity: .uncommon,
        buyPrice: 40,
        sellPrice: 20,
        itemDescription: "Deals 40 fire damage to an enemy.",
        battleDamage: 40
    )

    static let statPotion = Item(
        templateId: "stat_potion",
        name: "Elixir of Power",
        icon: "💪",
        type: .consumable,
        rarity: .uncommon,
        levelRequirement: 3,
        buyPrice: 35,
        sellPrice: 17,
        itemDescription: "Temporarily boosts STR by 5 for 3 turns.",
        tempStatBoost: [.strength: 5],
        tempBoostDuration: 3
    )

    // MARK: - Crafting Materials
    static let ironOre = Item(
        templateId: "iron_ore",
        name: "Iron Ore",
        icon: "🪨",
        type: .material,
        rarity: .common,
        buyPrice: 10,
        sellPrice: 5,
        itemDescription: "Raw iron ore for smithing."
    )

    static let shadowEssence = Item(
        templateId: "shadow_essence",
        name: "Shadow Essence",
        icon: "🌑",
        type: .material,
        rarity: .uncommon,
        buyPrice: 25,
        sellPrice: 12,
        itemDescription: "Dark energy extracted from shadow creatures."
    )

    static let crystalShard = Item(
        templateId: "crystal_shard",
        name: "Crystal Shard",
        icon: "💎",
        type: .material,
        rarity: .uncommon,
        buyPrice: 20,
        sellPrice: 10,
        itemDescription: "A glowing crystal fragment with magical properties."
    )

    static let dragonScale = Item(
        templateId: "dragon_scale",
        name: "Dragon Scale",
        icon: "🐲",
        type: .material,
        rarity: .rare,
        buyPrice: 50,
        sellPrice: 25,
        itemDescription: "A tough scale shed by a dragon."
    )

    static let enchantedThread = Item(
        templateId: "enchanted_thread",
        name: "Enchanted Thread",
        icon: "🧵",
        type: .material,
        rarity: .uncommon,
        buyPrice: 15,
        sellPrice: 7,
        itemDescription: "Magically woven thread for crafting."
    )

    // MARK: - Class Starter Weapon Lookup
    static func starterWeapon(for characterClass: CharacterClass) -> Item {
        switch characterClass {
        case .ranger: return rangerBow
        case .warrior: return warriorSword
        case .warriorKing: return warriorKingScepter
        case .pirate: return pirateCutlass
        case .iceMage: return iceMageStaff
        case .necromancer: return necromancerWand
        case .dragon: return dragonClaw
        case .angel: return angelBlade
        }
    }

    // MARK: - All Shop Items
    static let allShopItems: [Item] = [
        // Weapons
        steelSword, enchantedBow, frostStaff, shadowBlade, dragonSlayer,
        // Armor
        basicArmor, chainmail, plateArmor, mageRobes,
        // Accessories
        clarityAmulet, strengthRing, wisdomPendant, dexterityBoots,
        // Consumables
        healthPotion, greaterHealthPotion, antidote, battleScroll, statPotion,
        // Materials
        ironOre, shadowEssence, crystalShard, dragonScale, enchantedThread
    ]

    // MARK: - Items by Level Range
    static func items(forLevel level: Int) -> [Item] {
        allShopItems.filter { $0.levelRequirement <= level }
    }
}
