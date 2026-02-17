import Foundation

// MARK: - Arena Shop Entry
struct ArenaShopEntry: Identifiable {
    var id: String { item.templateId }
    var item: Item
    var tokenPrice: Int
    var rankRequired: ArenaRank
    var levelRequired: Int
}

// MARK: - Arena Item Database
struct ArenaItemDatabase {
    static let victorsMedal = Item(
        templateId: "arena_victors_medal",
        name: "Victor's Medal",
        icon: "🏅",
        type: .accessory,
        rarity: .rare,
        levelRequirement: 5,
        buyPrice: 0,
        sellPrice: 60,
        itemDescription: "A medal awarded to victorious arena combatants.",
        statModifiers: [.strength: 2, .dexterity: 2, .constitution: 2],
        slot: .accessory
    )

    static let arenaElixir = Item(
        templateId: "arena_elixir",
        name: "Arena Elixir",
        icon: "🧃",
        type: .consumable,
        rarity: .rare,
        levelRequirement: 1,
        buyPrice: 0,
        sellPrice: 25,
        itemDescription: "A powerful elixir that fully restores health.",
        healAmount: 999
    )

    static let gladiatorsBlade = Item(
        templateId: "arena_gladiators_blade",
        name: "Gladiator's Blade",
        icon: "⚔️",
        type: .weapon,
        rarity: .rare,
        levelRequirement: 8,
        buyPrice: 0,
        sellPrice: 100,
        itemDescription: "A blade forged in the arena's furnace.",
        statModifiers: [.strength: 5, .dexterity: 3],
        slot: .weapon
    )

    static let gladiatorsPlate = Item(
        templateId: "arena_gladiators_plate",
        name: "Gladiator's Plate",
        icon: "🛡️",
        type: .armor,
        rarity: .rare,
        levelRequirement: 8,
        buyPrice: 0,
        sellPrice: 90,
        itemDescription: "Heavy plate armor from the gladiatorial pits.",
        statModifiers: [.constitution: 5, .strength: 2],
        slot: .armor
    )

    static let championsLance = Item(
        templateId: "arena_champions_lance",
        name: "Champion's Lance",
        icon: "🔱",
        type: .weapon,
        rarity: .epic,
        levelRequirement: 12,
        buyPrice: 0,
        sellPrice: 200,
        itemDescription: "A lance carried only by arena champions.",
        statModifiers: [.strength: 8, .constitution: 2, .dexterity: 2],
        slot: .weapon
    )

    static let arcaneDuelistStaff = Item(
        templateId: "arena_arcane_duelist_staff",
        name: "Arcane Duelist Staff",
        icon: "🪄",
        type: .weapon,
        rarity: .epic,
        levelRequirement: 12,
        buyPrice: 0,
        sellPrice: 200,
        itemDescription: "A staff attuned to magical arena combat.",
        statModifiers: [.intelligence: 7, .wisdom: 4],
        slot: .weapon
    )

    static let diamondGuardArmor = Item(
        templateId: "arena_diamond_guard_armor",
        name: "Diamond Guard Armor",
        icon: "💠",
        type: .armor,
        rarity: .epic,
        levelRequirement: 15,
        buyPrice: 0,
        sellPrice: 250,
        itemDescription: "Armor reinforced with crystallized arena dust.",
        statModifiers: [.constitution: 8, .strength: 3, .wisdom: 2],
        slot: .armor
    )

    static let championsCrown = Item(
        templateId: "arena_champions_crown",
        name: "Champion's Crown",
        icon: "👑",
        type: .accessory,
        rarity: .legendary,
        levelRequirement: 18,
        buyPrice: 0,
        sellPrice: 400,
        itemDescription: "The ultimate symbol of arena mastery.",
        statModifiers: [.strength: 5, .dexterity: 5, .constitution: 5, .intelligence: 3, .wisdom: 3, .charisma: 3],
        slot: .accessory
    )

    // MARK: - Shop Entries
    static let shopEntries: [ArenaShopEntry] = [
        ArenaShopEntry(item: victorsMedal, tokenPrice: 120, rankRequired: .bronze, levelRequired: 5),
        ArenaShopEntry(item: arenaElixir, tokenPrice: 50, rankRequired: .bronze, levelRequired: 1),
        ArenaShopEntry(item: gladiatorsBlade, tokenPrice: 200, rankRequired: .silver, levelRequired: 8),
        ArenaShopEntry(item: gladiatorsPlate, tokenPrice: 180, rankRequired: .silver, levelRequired: 8),
        ArenaShopEntry(item: championsLance, tokenPrice: 400, rankRequired: .gold, levelRequired: 12),
        ArenaShopEntry(item: arcaneDuelistStaff, tokenPrice: 400, rankRequired: .gold, levelRequired: 12),
        ArenaShopEntry(item: diamondGuardArmor, tokenPrice: 500, rankRequired: .diamond, levelRequired: 15),
        ArenaShopEntry(item: championsCrown, tokenPrice: 800, rankRequired: .champion, levelRequired: 18),
    ]
}
