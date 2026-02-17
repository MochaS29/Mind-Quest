import Foundation

struct EnemyDatabase {

    // MARK: - Tier 1 — Forest Fringe (Lv 1-4)

    static let whiskeredRat = EnemyTemplate(
        id: "enemy_whiskered_rat",
        name: "Whiskered Rat",
        avatar: "🐀",
        description: "A scraggly rat with unusually sharp teeth.",
        tier: 1,
        levelRange: 1...4,
        baseHP: 30,
        baseAttack: 8,
        baseDefense: 2,
        abilities: [
            EnemyAbility(name: "Gnaw", damage: 10, description: "Bites with sharp teeth.", chance: 0.3)
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.ironOre, dropChance: 0.3)
            ],
            guaranteedGold: 5,
            guaranteedXP: 10,
            bonusGoldRange: 2...8
        )
    )

    static let shadowWisp = EnemyTemplate(
        id: "enemy_shadow_wisp",
        name: "Shadow Wisp",
        avatar: "👻",
        description: "A flickering wisp of dark energy.",
        tier: 1,
        levelRange: 1...4,
        baseHP: 25,
        baseAttack: 10,
        baseDefense: 1,
        element: .shadow,
        abilities: [
            EnemyAbility(name: "Shadow Bolt", damage: 12, description: "Fires a bolt of dark energy.", chance: 0.3)
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.shadowEssence, dropChance: 0.2)
            ],
            guaranteedGold: 6,
            guaranteedXP: 12,
            bonusGoldRange: 3...10
        )
    )

    static let mossGoblin = EnemyTemplate(
        id: "enemy_moss_goblin",
        name: "Moss Goblin",
        avatar: "👺",
        description: "A small goblin covered in forest moss.",
        tier: 1,
        levelRange: 1...4,
        baseHP: 35,
        baseAttack: 9,
        baseDefense: 3,
        element: .nature,
        abilities: [
            EnemyAbility(name: "Club Smash", damage: 11, description: "Swings a crude wooden club.", chance: 0.25)
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.ironOre, dropChance: 0.25),
                LootTableEntry(item: ItemDatabase.healthPotion, dropChance: 0.15)
            ],
            guaranteedGold: 8,
            guaranteedXP: 12,
            bonusGoldRange: 3...10
        )
    )

    static let caveSpider = EnemyTemplate(
        id: "enemy_cave_spider",
        name: "Cave Spider",
        avatar: "🕷️",
        description: "A venomous spider lurking in dark caves.",
        tier: 1,
        levelRange: 1...4,
        baseHP: 28,
        baseAttack: 9,
        baseDefense: 2,
        element: .nature,
        abilities: [
            EnemyAbility(name: "Venomous Bite", damage: 8, description: "Injects poison with its fangs.", chance: 0.35,
                         statusEffect: StatusEffect(type: .poison, duration: 3, value: 3, sourceDescription: "Cave Spider venom"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.antidote, dropChance: 0.3),
                LootTableEntry(item: ItemDatabase.enchantedThread, dropChance: 0.2)
            ],
            guaranteedGold: 7,
            guaranteedXP: 14,
            bonusGoldRange: 2...8
        )
    )

    static let emeraldSlime = EnemyTemplate(
        id: "enemy_emerald_slime",
        name: "Emerald Slime",
        avatar: "🟢",
        description: "A gooey green slime that weakens on contact.",
        tier: 1,
        levelRange: 1...4,
        baseHP: 40,
        baseAttack: 7,
        baseDefense: 4,
        element: .nature,
        abilities: [
            EnemyAbility(name: "Slimy Embrace", damage: 6, description: "Engulfs and weakens its target.", chance: 0.3,
                         statusEffect: StatusEffect(type: .weaken, duration: 2, value: 3, sourceDescription: "Slime residue"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.crystalShard, dropChance: 0.2)
            ],
            guaranteedGold: 6,
            guaranteedXP: 12,
            bonusGoldRange: 3...9
        )
    )

    static let barkSentinel = EnemyTemplate(
        id: "enemy_bark_sentinel",
        name: "Bark Sentinel",
        avatar: "🌳",
        description: "An animated tree trunk standing guard.",
        tier: 1,
        levelRange: 1...4,
        baseHP: 45,
        baseAttack: 8,
        baseDefense: 5,
        element: .nature,
        abilities: [
            EnemyAbility(name: "Branch Slam", damage: 12, description: "Swings a heavy branch.", chance: 0.25)
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.ironOre, dropChance: 0.3),
                LootTableEntry(item: ItemDatabase.enchantedThread, dropChance: 0.15)
            ],
            guaranteedGold: 9,
            guaranteedXP: 15,
            bonusGoldRange: 4...12
        )
    )

    // MARK: - Tier 2 — Shadow Depths (Lv 5-8)

    static let shadowStalker = EnemyTemplate(
        id: "enemy_shadow_stalker",
        name: "Shadow Stalker",
        avatar: "🦇",
        description: "A dark creature that strikes from the shadows.",
        tier: 2,
        levelRange: 5...8,
        baseHP: 60,
        baseAttack: 14,
        baseDefense: 5,
        element: .shadow,
        abilities: [
            EnemyAbility(name: "Rending Claws", damage: 16, description: "Tears at flesh, causing bleeding.", chance: 0.3,
                         statusEffect: StatusEffect(type: .bleed, duration: 3, value: 4, sourceDescription: "Shadow Stalker claws"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.shadowEssence, dropChance: 0.35),
                LootTableEntry(item: ItemDatabase.healthPotion, dropChance: 0.2)
            ],
            guaranteedGold: 15,
            guaranteedXP: 25,
            bonusGoldRange: 5...15
        )
    )

    static let frostImp = EnemyTemplate(
        id: "enemy_frost_imp",
        name: "Frost Imp",
        avatar: "🧊",
        description: "A mischievous imp crackling with frost magic.",
        tier: 2,
        levelRange: 5...8,
        baseHP: 50,
        baseAttack: 16,
        baseDefense: 4,
        element: .ice,
        abilities: [
            EnemyAbility(name: "Frost Snap", damage: 18, description: "A burst of freezing energy that stuns.", chance: 0.25,
                         statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Frost magic"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.crystalShard, dropChance: 0.3),
                LootTableEntry(item: ItemDatabase.statPotion, dropChance: 0.15)
            ],
            guaranteedGold: 14,
            guaranteedXP: 24,
            bonusGoldRange: 6...14
        )
    )

    static let emberHound = EnemyTemplate(
        id: "enemy_ember_hound",
        name: "Ember Hound",
        avatar: "🐕‍🦺",
        description: "A fiery beast that scorches everything it touches.",
        tier: 2,
        levelRange: 5...8,
        baseHP: 55,
        baseAttack: 15,
        baseDefense: 5,
        element: .fire,
        abilities: [
            EnemyAbility(name: "Flame Breath", damage: 14, description: "Breathes fire that burns over time.", chance: 0.3,
                         statusEffect: StatusEffect(type: .burn, duration: 3, value: 4, sourceDescription: "Ember Hound flames"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.battleScroll, dropChance: 0.2),
                LootTableEntry(item: ItemDatabase.healthPotion, dropChance: 0.25)
            ],
            guaranteedGold: 16,
            guaranteedXP: 26,
            bonusGoldRange: 5...15
        )
    )

    static let corruptedKnight = EnemyTemplate(
        id: "enemy_corrupted_knight",
        name: "Corrupted Knight",
        avatar: "🗡️",
        description: "A fallen knight consumed by dark energy.",
        tier: 2,
        levelRange: 5...8,
        baseHP: 70,
        baseAttack: 13,
        baseDefense: 8,
        abilities: [
            EnemyAbility(name: "Shield Bash", damage: 15, description: "Strikes with a corrupted shield.", chance: 0.25,
                         statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Shield impact"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.ironOre, dropChance: 0.4, minQuantity: 1, maxQuantity: 2),
                LootTableEntry(item: ItemDatabase.chainmail, dropChance: 0.1)
            ],
            guaranteedGold: 18,
            guaranteedXP: 28,
            bonusGoldRange: 8...18
        )
    )

    static let crystalGolem = EnemyTemplate(
        id: "enemy_crystal_golem",
        name: "Crystal Golem",
        avatar: "💎",
        description: "A massive golem made of living crystal.",
        tier: 2,
        levelRange: 5...8,
        baseHP: 80,
        baseAttack: 12,
        baseDefense: 10,
        abilities: [
            EnemyAbility(name: "Crystal Slam", damage: 18, description: "Crashes down with crystalline fists.", chance: 0.2)
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.crystalShard, dropChance: 0.5, minQuantity: 1, maxQuantity: 3),
                LootTableEntry(item: ItemDatabase.clarityAmulet, dropChance: 0.08)
            ],
            guaranteedGold: 20,
            guaranteedXP: 30,
            bonusGoldRange: 10...20
        )
    )

    static let vineWeaver = EnemyTemplate(
        id: "enemy_vine_weaver",
        name: "Vine Weaver",
        avatar: "🌿",
        description: "A tangled mass of sentient vines that regenerates.",
        tier: 2,
        levelRange: 5...8,
        baseHP: 65,
        baseAttack: 11,
        baseDefense: 6,
        element: .nature,
        abilities: [
            EnemyAbility(name: "Thorn Lash", damage: 13, description: "Whips with thorny vines.", chance: 0.3),
            EnemyAbility(name: "Regrowth", damage: 0, description: "Regenerates health over time.", chance: 0.2,
                         statusEffect: StatusEffect(type: .regenerate, duration: 3, value: 5, sourceDescription: "Natural regrowth"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.enchantedThread, dropChance: 0.35),
                LootTableEntry(item: ItemDatabase.antidote, dropChance: 0.2)
            ],
            guaranteedGold: 14,
            guaranteedXP: 24,
            bonusGoldRange: 5...12
        )
    )

    // MARK: - Tier 3 — Infernal Crossing (Lv 9-12)

    static let flameWraith = EnemyTemplate(
        id: "enemy_flame_wraith",
        name: "Flame Wraith",
        avatar: "🔥",
        description: "A spectral entity wreathed in eternal flame.",
        tier: 3,
        levelRange: 9...12,
        baseHP: 90,
        baseAttack: 20,
        baseDefense: 8,
        element: .fire,
        abilities: [
            EnemyAbility(name: "Infernal Wave", damage: 22, description: "Unleashes a wave of hellfire.", chance: 0.3,
                         statusEffect: StatusEffect(type: .burn, duration: 3, value: 6, sourceDescription: "Hellfire"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.battleScroll, dropChance: 0.3),
                LootTableEntry(item: ItemDatabase.greaterHealthPotion, dropChance: 0.2)
            ],
            guaranteedGold: 25,
            guaranteedXP: 40,
            bonusGoldRange: 10...25
        )
    )

    static let iceRevenant = EnemyTemplate(
        id: "enemy_ice_revenant",
        name: "Ice Revenant",
        avatar: "❄️",
        description: "An undead warrior frozen in eternal ice.",
        tier: 3,
        levelRange: 9...12,
        baseHP: 100,
        baseAttack: 18,
        baseDefense: 10,
        element: .ice,
        abilities: [
            EnemyAbility(name: "Glacial Strike", damage: 20, description: "A freezing blow that stuns and weakens.", chance: 0.25,
                         statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Glacial cold")),
            EnemyAbility(name: "Frost Aura", damage: 10, description: "Chilling aura that saps strength.", chance: 0.2,
                         statusEffect: StatusEffect(type: .weaken, duration: 2, value: 4, sourceDescription: "Frost aura"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.crystalShard, dropChance: 0.35, minQuantity: 1, maxQuantity: 2),
                LootTableEntry(item: ItemDatabase.frostStaff, dropChance: 0.05)
            ],
            guaranteedGold: 28,
            guaranteedXP: 45,
            bonusGoldRange: 12...28
        )
    )

    static let thunderDrake = EnemyTemplate(
        id: "enemy_thunder_drake",
        name: "Thunder Drake",
        avatar: "⚡",
        description: "A young drake crackling with lightning.",
        tier: 3,
        levelRange: 9...12,
        baseHP: 95,
        baseAttack: 22,
        baseDefense: 9,
        element: .lightning,
        abilities: [
            EnemyAbility(name: "Lightning Bolt", damage: 25, description: "Hurls a bolt of lightning.", chance: 0.3,
                         statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Electric shock"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.dragonScale, dropChance: 0.2),
                LootTableEntry(item: ItemDatabase.statPotion, dropChance: 0.25)
            ],
            guaranteedGold: 30,
            guaranteedXP: 48,
            bonusGoldRange: 15...30
        )
    )

    static let plagueBearer = EnemyTemplate(
        id: "enemy_plague_bearer",
        name: "Plague Bearer",
        avatar: "☠️",
        description: "A diseased horror that spreads toxic miasma.",
        tier: 3,
        levelRange: 9...12,
        baseHP: 85,
        baseAttack: 17,
        baseDefense: 7,
        element: .nature,
        abilities: [
            EnemyAbility(name: "Plague Cloud", damage: 14, description: "Exhales a cloud of toxic gas.", chance: 0.35,
                         statusEffect: StatusEffect(type: .poison, duration: 4, value: 5, sourceDescription: "Plague toxins")),
            EnemyAbility(name: "Enfeeble", damage: 10, description: "Drains vitality from the target.", chance: 0.2,
                         statusEffect: StatusEffect(type: .weaken, duration: 3, value: 4, sourceDescription: "Life drain"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.antidote, dropChance: 0.4, minQuantity: 1, maxQuantity: 2),
                LootTableEntry(item: ItemDatabase.greaterHealthPotion, dropChance: 0.2)
            ],
            guaranteedGold: 24,
            guaranteedXP: 42,
            bonusGoldRange: 10...22
        )
    )

    static let boneConstruct = EnemyTemplate(
        id: "enemy_bone_construct",
        name: "Bone Construct",
        avatar: "💀",
        description: "An animated skeleton held together by dark magic.",
        tier: 3,
        levelRange: 9...12,
        baseHP: 110,
        baseAttack: 16,
        baseDefense: 12,
        element: .shadow,
        abilities: [
            EnemyAbility(name: "Bone Crush", damage: 20, description: "Crushes with skeletal strength.", chance: 0.25),
            EnemyAbility(name: "Dark Mend", damage: 0, description: "Repairs itself with dark energy.", chance: 0.15,
                         statusEffect: StatusEffect(type: .regenerate, duration: 2, value: 8, sourceDescription: "Dark mending"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.shadowEssence, dropChance: 0.4, minQuantity: 1, maxQuantity: 2),
                LootTableEntry(item: ItemDatabase.shadowBlade, dropChance: 0.05)
            ],
            guaranteedGold: 26,
            guaranteedXP: 44,
            bonusGoldRange: 12...26
        )
    )

    static let stormHarpy = EnemyTemplate(
        id: "enemy_storm_harpy",
        name: "Storm Harpy",
        avatar: "🦅",
        description: "A winged terror that commands the winds.",
        tier: 3,
        levelRange: 9...12,
        baseHP: 80,
        baseAttack: 21,
        baseDefense: 6,
        element: .lightning,
        abilities: [
            EnemyAbility(name: "Gale Force", damage: 18, description: "A cutting blast of wind.", chance: 0.3,
                         statusEffect: StatusEffect(type: .weaken, duration: 2, value: 3, sourceDescription: "Gale winds"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.enchantedThread, dropChance: 0.35),
                LootTableEntry(item: ItemDatabase.dexterityBoots, dropChance: 0.06)
            ],
            guaranteedGold: 27,
            guaranteedXP: 43,
            bonusGoldRange: 12...25
        )
    )

    // MARK: - Tier 4 — Abyssal Sanctum (Lv 13-16)

    static let shadowLord = EnemyTemplate(
        id: "enemy_shadow_lord",
        name: "Shadow Lord",
        avatar: "🌑",
        description: "A commander of shadow forces, cruel and powerful.",
        tier: 4,
        levelRange: 13...16,
        baseHP: 140,
        baseAttack: 26,
        baseDefense: 14,
        element: .shadow,
        abilities: [
            EnemyAbility(name: "Shadow Rend", damage: 28, description: "Tears through defenses with dark blades.", chance: 0.3,
                         statusEffect: StatusEffect(type: .bleed, duration: 3, value: 6, sourceDescription: "Shadow blades")),
            EnemyAbility(name: "Dark Command", damage: 20, description: "A stunning bolt of dark authority.", chance: 0.2,
                         statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Dark command"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.shadowEssence, dropChance: 0.5, minQuantity: 2, maxQuantity: 4),
                LootTableEntry(item: ItemDatabase.shadowBlade, dropChance: 0.1)
            ],
            guaranteedGold: 40,
            guaranteedXP: 65,
            bonusGoldRange: 20...40
        )
    )

    static let infernoTitan = EnemyTemplate(
        id: "enemy_inferno_titan",
        name: "Inferno Titan",
        avatar: "🌋",
        description: "A giant wreathed in volcanic flame.",
        tier: 4,
        levelRange: 13...16,
        baseHP: 160,
        baseAttack: 24,
        baseDefense: 16,
        element: .fire,
        abilities: [
            EnemyAbility(name: "Magma Slam", damage: 30, description: "Crashes down with molten fists.", chance: 0.3,
                         statusEffect: StatusEffect(type: .burn, duration: 4, value: 7, sourceDescription: "Magma burns"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.dragonScale, dropChance: 0.35, minQuantity: 1, maxQuantity: 2),
                LootTableEntry(item: ItemDatabase.greaterHealthPotion, dropChance: 0.3)
            ],
            guaranteedGold: 45,
            guaranteedXP: 70,
            bonusGoldRange: 20...45
        )
    )

    static let frostWyrm = EnemyTemplate(
        id: "enemy_frost_wyrm",
        name: "Frost Wyrm",
        avatar: "🐍",
        description: "An ancient serpent of ice and frost.",
        tier: 4,
        levelRange: 13...16,
        baseHP: 150,
        baseAttack: 25,
        baseDefense: 13,
        element: .ice,
        abilities: [
            EnemyAbility(name: "Blizzard Coil", damage: 26, description: "Wraps in a blizzard that freezes solid.", chance: 0.3,
                         statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Blizzard freeze"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.crystalShard, dropChance: 0.45, minQuantity: 2, maxQuantity: 4),
                LootTableEntry(item: ItemDatabase.frostStaff, dropChance: 0.08)
            ],
            guaranteedGold: 42,
            guaranteedXP: 68,
            bonusGoldRange: 20...42
        )
    )

    static let lichAcolyte = EnemyTemplate(
        id: "enemy_lich_acolyte",
        name: "Lich Acolyte",
        avatar: "🧙‍♂️",
        description: "A dark mage on the path to undeath.",
        tier: 4,
        levelRange: 13...16,
        baseHP: 130,
        baseAttack: 28,
        baseDefense: 10,
        element: .shadow,
        abilities: [
            EnemyAbility(name: "Necrotic Bolt", damage: 24, description: "Fires a bolt of decay.", chance: 0.3,
                         statusEffect: StatusEffect(type: .poison, duration: 4, value: 6, sourceDescription: "Necrotic energy")),
            EnemyAbility(name: "Life Siphon", damage: 0, description: "Drains life to heal itself.", chance: 0.2,
                         statusEffect: StatusEffect(type: .regenerate, duration: 3, value: 8, sourceDescription: "Life siphon"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.shadowEssence, dropChance: 0.5, minQuantity: 2, maxQuantity: 3),
                LootTableEntry(item: ItemDatabase.mageRobes, dropChance: 0.06)
            ],
            guaranteedGold: 38,
            guaranteedXP: 62,
            bonusGoldRange: 18...38
        )
    )

    static let celestialGuardian = EnemyTemplate(
        id: "enemy_celestial_guardian",
        name: "Celestial Guardian",
        avatar: "✨",
        description: "A divine sentinel that tests the worthy.",
        tier: 4,
        levelRange: 13...16,
        baseHP: 170,
        baseAttack: 22,
        baseDefense: 18,
        element: .holy,
        abilities: [
            EnemyAbility(name: "Holy Smite", damage: 24, description: "Strikes with divine judgment.", chance: 0.25),
            EnemyAbility(name: "Divine Aegis", damage: 0, description: "Strengthens itself with holy power.", chance: 0.2,
                         statusEffect: StatusEffect(type: .strengthen, duration: 3, value: 5, sourceDescription: "Divine blessing"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.crystalShard, dropChance: 0.4, minQuantity: 2, maxQuantity: 3),
                LootTableEntry(item: ItemDatabase.wisdomPendant, dropChance: 0.1)
            ],
            guaranteedGold: 48,
            guaranteedXP: 72,
            bonusGoldRange: 22...48
        )
    )

    // MARK: - Tier 5 — Bosses (Lv 15+)

    static let theMindflayer = EnemyTemplate(
        id: "boss_mindflayer",
        name: "The Mindflayer",
        avatar: "🧠",
        description: "An eldritch horror that feasts on thoughts and willpower.",
        tier: 5,
        levelRange: 15...20,
        baseHP: 250,
        baseAttack: 30,
        baseDefense: 15,
        isBoss: true,
        element: .shadow,
        abilities: [
            EnemyAbility(name: "Psychic Blast", damage: 32, description: "A devastating mental assault.", chance: 0.3,
                         statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Psychic shock")),
            EnemyAbility(name: "Mind Drain", damage: 20, description: "Drains mental fortitude.", chance: 0.25,
                         statusEffect: StatusEffect(type: .weaken, duration: 3, value: 5, sourceDescription: "Mind drain"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.shadowEssence, dropChance: 1.0, minQuantity: 3, maxQuantity: 5),
                LootTableEntry(item: ItemDatabase.dragonSlayer, dropChance: 0.15)
            ],
            guaranteedGold: 100,
            guaranteedXP: 150,
            bonusGoldRange: 50...100
        )
    )

    static let ignarothDragonKing = EnemyTemplate(
        id: "boss_ignaroth",
        name: "Ignaroth, Dragon King",
        avatar: "🐉",
        description: "The ancient dragon king whose flames forged mountains.",
        tier: 5,
        levelRange: 15...20,
        baseHP: 300,
        baseAttack: 32,
        baseDefense: 18,
        isBoss: true,
        element: .fire,
        abilities: [
            EnemyAbility(name: "Dragon's Inferno", damage: 35, description: "Breathes an inferno of ancient flame.", chance: 0.35,
                         statusEffect: StatusEffect(type: .burn, duration: 4, value: 8, sourceDescription: "Dragon's Inferno"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.dragonScale, dropChance: 1.0, minQuantity: 3, maxQuantity: 5),
                LootTableEntry(item: ItemDatabase.dragonSlayer, dropChance: 0.2)
            ],
            guaranteedGold: 120,
            guaranteedXP: 180,
            bonusGoldRange: 60...120
        )
    )

    static let glaciaraFrostQueen = EnemyTemplate(
        id: "boss_glaciara",
        name: "Glaciara, Frost Queen",
        avatar: "👑",
        description: "The immortal queen of the frozen wastes.",
        tier: 5,
        levelRange: 15...20,
        baseHP: 270,
        baseAttack: 28,
        baseDefense: 20,
        isBoss: true,
        element: .ice,
        abilities: [
            EnemyAbility(name: "Absolute Zero", damage: 30, description: "Flash-freezes everything in range.", chance: 0.3,
                         statusEffect: StatusEffect(type: .stun, duration: 2, value: 0, sourceDescription: "Absolute zero")),
            EnemyAbility(name: "Frost Crown", damage: 18, description: "Channels weakening frost.", chance: 0.2,
                         statusEffect: StatusEffect(type: .weaken, duration: 3, value: 5, sourceDescription: "Frost Crown"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.crystalShard, dropChance: 1.0, minQuantity: 4, maxQuantity: 6),
                LootTableEntry(item: ItemDatabase.frostStaff, dropChance: 0.2)
            ],
            guaranteedGold: 110,
            guaranteedXP: 170,
            bonusGoldRange: 55...110
        )
    )

    static let nyxShadowEmperor = EnemyTemplate(
        id: "boss_nyx",
        name: "Nyx, Shadow Emperor",
        avatar: "🌑",
        description: "The emperor of shadows whose darkness consumes all light.",
        tier: 5,
        levelRange: 15...20,
        baseHP: 280,
        baseAttack: 34,
        baseDefense: 16,
        isBoss: true,
        element: .shadow,
        abilities: [
            EnemyAbility(name: "Void Slash", damage: 30, description: "A slash that bleeds through dimensions.", chance: 0.3,
                         statusEffect: StatusEffect(type: .bleed, duration: 4, value: 7, sourceDescription: "Dimensional rift")),
            EnemyAbility(name: "Poison Eclipse", damage: 22, description: "Eclipses the field in toxic shadow.", chance: 0.25,
                         statusEffect: StatusEffect(type: .poison, duration: 4, value: 6, sourceDescription: "Toxic eclipse"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.shadowEssence, dropChance: 1.0, minQuantity: 4, maxQuantity: 6),
                LootTableEntry(item: ItemDatabase.shadowBlade, dropChance: 0.2)
            ],
            guaranteedGold: 115,
            guaranteedXP: 175,
            bonusGoldRange: 55...115
        )
    )

    static let solaraGuardianOfLight = EnemyTemplate(
        id: "boss_solara",
        name: "Solara, Guardian of Light",
        avatar: "☀️",
        description: "The radiant guardian whose light purifies and destroys.",
        tier: 5,
        levelRange: 15...20,
        baseHP: 290,
        baseAttack: 30,
        baseDefense: 20,
        isBoss: true,
        element: .holy,
        abilities: [
            EnemyAbility(name: "Solar Flare", damage: 28, description: "A blinding burst of holy fire.", chance: 0.3,
                         statusEffect: StatusEffect(type: .burn, duration: 3, value: 7, sourceDescription: "Solar fire")),
            EnemyAbility(name: "Radiant Might", damage: 0, description: "Empowers itself with divine strength.", chance: 0.2,
                         statusEffect: StatusEffect(type: .strengthen, duration: 3, value: 6, sourceDescription: "Radiant power"))
        ],
        lootTable: LootTable(
            entries: [
                LootTableEntry(item: ItemDatabase.crystalShard, dropChance: 1.0, minQuantity: 3, maxQuantity: 5),
                LootTableEntry(item: ItemDatabase.dragonSlayer, dropChance: 0.18)
            ],
            guaranteedGold: 125,
            guaranteedXP: 185,
            bonusGoldRange: 60...125
        )
    )

    // MARK: - Collections

    static let tier1: [EnemyTemplate] = [whiskeredRat, shadowWisp, mossGoblin, caveSpider, emeraldSlime, barkSentinel]
    static let tier2: [EnemyTemplate] = [shadowStalker, frostImp, emberHound, corruptedKnight, crystalGolem, vineWeaver]
    static let tier3: [EnemyTemplate] = [flameWraith, iceRevenant, thunderDrake, plagueBearer, boneConstruct, stormHarpy]
    static let tier4: [EnemyTemplate] = [shadowLord, infernoTitan, frostWyrm, lichAcolyte, celestialGuardian]
    static let tier5: [EnemyTemplate] = [theMindflayer, ignarothDragonKing, glaciaraFrostQueen, nyxShadowEmperor, solaraGuardianOfLight]

    static let allEnemies: [EnemyTemplate] = tier1 + tier2 + tier3 + tier4 + tier5

    // MARK: - Query Methods

    static func enemies(forTier tier: Int) -> [EnemyTemplate] {
        switch tier {
        case 1: return tier1
        case 2: return tier2
        case 3: return tier3
        case 4: return tier4
        case 5: return tier5
        default: return []
        }
    }

    static func enemies(forLevel level: Int) -> [EnemyTemplate] {
        allEnemies.filter { !$0.isBoss && $0.levelRange.contains(level) }
    }

    static func randomEnemy(forLevel level: Int) -> EnemyTemplate? {
        enemies(forLevel: level).randomElement()
    }

    static func bosses() -> [EnemyTemplate] {
        tier5
    }

    static func tierForLevel(_ level: Int) -> Int {
        switch level {
        case 1...4: return 1
        case 5...8: return 2
        case 9...12: return 3
        case 13...16: return 4
        default: return level >= 15 ? 5 : 1
        }
    }
}
