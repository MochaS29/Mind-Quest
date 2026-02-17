import Foundation

// MARK: - Skill Tree Database
// 8 classes x 3 branches x 3 tiers = 72 skills total
// Each branch has a tier 1 (1 SP), tier 2 (2 SP, requires tier 1), tier 3 (3 SP, requires tier 2)

struct SkillTreeDatabase {

    /// Returns the 9-skill tree for a given character class (3 branches x 3 tiers).
    static func skillTree(for characterClass: CharacterClass) -> [Skill] {
        switch characterClass {
        case .ranger:      return rangerSkills
        case .warrior:     return warriorSkills
        case .warriorKing: return warriorKingSkills
        case .pirate:      return pirateSkills
        case .iceMage:     return iceMageSkills
        case .necromancer: return necromancerSkills
        case .dragon:      return dragonSkills
        case .angel:       return angelSkills
        }
    }

    /// Returns every skill across all classes (72 total).
    static var allSkills: [Skill] {
        CharacterClass.allCases.flatMap { skillTree(for: $0) }
    }

    // MARK: - Ranger Skills

    static let rangerSkills: [Skill] = [
        // Offense Branch
        Skill(
            id: "ranger_off_1",
            name: "Keen Eye",
            icon: "eye.fill",
            description: "Years of tracking prey have sharpened your aim. Increases critical hit chance by 5%.",
            branch: .offense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.critChance(percent: 5)],
            characterClass: .ranger
        ),
        Skill(
            id: "ranger_off_2",
            name: "Piercing Shot",
            icon: "arrow.right.circle.fill",
            description: "Your arrows find weak points in any armor. Increases damage by 10%.",
            branch: .offense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "ranger_off_1",
            effects: [.damageMultiplier(percent: 10)],
            characterClass: .ranger
        ),
        Skill(
            id: "ranger_off_3",
            name: "Hunter's Mark",
            icon: "scope",
            description: "Mark your prey and drain their vitality with every strike. Gain 8% lifesteal on all attacks.",
            branch: .offense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "ranger_off_2",
            effects: [.lifesteal(percent: 8), .critChance(percent: 5)],
            characterClass: .ranger
        ),
        // Defense Branch
        Skill(
            id: "ranger_def_1",
            name: "Quick Reflexes",
            icon: "hare.fill",
            description: "Swift footwork lets you sidestep incoming blows. Gain 5% dodge chance.",
            branch: .defense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.dodgeChance(percent: 5)],
            characterClass: .ranger
        ),
        Skill(
            id: "ranger_def_2",
            name: "Natural Armor",
            icon: "leaf.fill",
            description: "Hardened leather and forest knowledge grant you resilience. Gain 20 max health.",
            branch: .defense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "ranger_def_1",
            effects: [.maxHealthBonus(value: 20), .dodgeChance(percent: 3)],
            characterClass: .ranger
        ),
        Skill(
            id: "ranger_def_3",
            name: "Poison Immunity",
            icon: "cross.vial.fill",
            description: "Exposure to the wilds has made you resistant to toxins. Gain 50% poison resistance and 10% defense.",
            branch: .defense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "ranger_def_2",
            effects: [.statusResistance(type: .poison, percent: 50), .defenseMultiplier(percent: 10)],
            characterClass: .ranger
        ),
        // Utility Branch
        Skill(
            id: "ranger_util_1",
            name: "Scavenger",
            icon: "bag.fill",
            description: "You know where to find hidden treasures in the wild. Gain 10% bonus gold.",
            branch: .utility,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.goldMultiplier(percent: 10)],
            characterClass: .ranger
        ),
        Skill(
            id: "ranger_util_2",
            name: "Trailblazer",
            icon: "map.fill",
            description: "Efficient pathfinding conserves your strength. Gain 10 bonus energy and 5% bonus XP.",
            branch: .utility,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "ranger_util_1",
            effects: [.energyBonus(value: 10), .xpMultiplier(percent: 5)],
            characterClass: .ranger
        ),
        Skill(
            id: "ranger_util_3",
            name: "Survivalist",
            icon: "tent.fill",
            description: "Master of wilderness survival. Reduce special cooldowns by 1 turn and gain 10% bonus XP.",
            branch: .utility,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "ranger_util_2",
            effects: [.specialCooldownReduction(turns: 1), .xpMultiplier(percent: 10)],
            characterClass: .ranger
        ),
    ]

    // MARK: - Warrior Skills

    static let warriorSkills: [Skill] = [
        // Offense Branch
        Skill(
            id: "warrior_off_1",
            name: "Battle Fury",
            icon: "flame.fill",
            description: "Channel your rage into devastating strikes. Increases critical hit chance by 4%.",
            branch: .offense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.critChance(percent: 4), .statBoost(stat: .strength, value: 1)],
            characterClass: .warrior
        ),
        Skill(
            id: "warrior_off_2",
            name: "Rending Blow",
            icon: "bolt.slash.fill",
            description: "Your attacks tear through defenses. Increases damage by 12%.",
            branch: .offense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "warrior_off_1",
            effects: [.damageMultiplier(percent: 12)],
            characterClass: .warrior
        ),
        Skill(
            id: "warrior_off_3",
            name: "Berserker Rage",
            icon: "burst.fill",
            description: "Embrace the fury within. Gain 6% lifesteal and 15% damage increase.",
            branch: .offense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "warrior_off_2",
            effects: [.lifesteal(percent: 6), .damageMultiplier(percent: 15)],
            characterClass: .warrior
        ),
        // Defense Branch
        Skill(
            id: "warrior_def_1",
            name: "Iron Skin",
            icon: "shield.fill",
            description: "Your body has been hardened by countless battles. Gain 25 max health.",
            branch: .defense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.maxHealthBonus(value: 25)],
            characterClass: .warrior
        ),
        Skill(
            id: "warrior_def_2",
            name: "Shield Wall",
            icon: "shield.lefthalf.filled",
            description: "An impenetrable wall of steel. Gain 8% defense and 4% dodge chance.",
            branch: .defense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "warrior_def_1",
            effects: [.defenseMultiplier(percent: 8), .dodgeChance(percent: 4)],
            characterClass: .warrior
        ),
        Skill(
            id: "warrior_def_3",
            name: "Unbreakable",
            icon: "shield.checkered",
            description: "No force can shatter your resolve. Gain 40 max health and 50% stun resistance.",
            branch: .defense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "warrior_def_2",
            effects: [.maxHealthBonus(value: 40), .statusResistance(type: .stun, percent: 50)],
            characterClass: .warrior
        ),
        // Utility Branch
        Skill(
            id: "warrior_util_1",
            name: "War Spoils",
            icon: "dollarsign.circle.fill",
            description: "Claim the wealth of the defeated. Gain 8% bonus gold.",
            branch: .utility,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.goldMultiplier(percent: 8)],
            characterClass: .warrior
        ),
        Skill(
            id: "warrior_util_2",
            name: "Battle Hardened",
            icon: "figure.strengthtraining.traditional",
            description: "Every fight is a lesson. Gain 8% bonus XP and 5 bonus energy.",
            branch: .utility,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "warrior_util_1",
            effects: [.xpMultiplier(percent: 8), .energyBonus(value: 5)],
            characterClass: .warrior
        ),
        Skill(
            id: "warrior_util_3",
            name: "Warlord's Command",
            icon: "crown.fill",
            description: "Lead from the front. Reduce special cooldowns by 1 turn and gain 10% bonus gold.",
            branch: .utility,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "warrior_util_2",
            effects: [.specialCooldownReduction(turns: 1), .goldMultiplier(percent: 10)],
            characterClass: .warrior
        ),
    ]

    // MARK: - Warrior King Skills

    static let warriorKingSkills: [Skill] = [
        // Offense Branch
        Skill(
            id: "warriorKing_off_1",
            name: "Royal Strike",
            icon: "crown.fill",
            description: "Strike with the authority of a king. Increases critical hit chance by 5%.",
            branch: .offense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.critChance(percent: 5)],
            characterClass: .warriorKing
        ),
        Skill(
            id: "warriorKing_off_2",
            name: "Sovereign's Wrath",
            icon: "bolt.fill",
            description: "Unleash the fury of the throne. Increases damage by 12% and strength by 2.",
            branch: .offense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "warriorKing_off_1",
            effects: [.damageMultiplier(percent: 12), .statBoost(stat: .strength, value: 2)],
            characterClass: .warriorKing
        ),
        Skill(
            id: "warriorKing_off_3",
            name: "Conqueror's Blade",
            icon: "seal.fill",
            description: "A blade that has felled empires. Gain 10% lifesteal and 8% crit chance.",
            branch: .offense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "warriorKing_off_2",
            effects: [.lifesteal(percent: 10), .critChance(percent: 8)],
            characterClass: .warriorKing
        ),
        // Defense Branch
        Skill(
            id: "warriorKing_def_1",
            name: "Regal Fortitude",
            icon: "shield.fill",
            description: "A king does not flinch. Gain 20 max health and 3% dodge chance.",
            branch: .defense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.maxHealthBonus(value: 20), .dodgeChance(percent: 3)],
            characterClass: .warriorKing
        ),
        Skill(
            id: "warriorKing_def_2",
            name: "Crown's Aegis",
            icon: "shield.lefthalf.filled",
            description: "The crown protects its wearer. Gain 10% defense and 50% weaken resistance.",
            branch: .defense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "warriorKing_def_1",
            effects: [.defenseMultiplier(percent: 10), .statusResistance(type: .weaken, percent: 50)],
            characterClass: .warriorKing
        ),
        Skill(
            id: "warriorKing_def_3",
            name: "Immortal Sovereign",
            icon: "checkmark.shield.fill",
            description: "Legends say the Warrior King cannot fall. Gain 50 max health and 10% counterattack chance.",
            branch: .defense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "warriorKing_def_2",
            effects: [.maxHealthBonus(value: 50), .counterattack(percent: 10)],
            characterClass: .warriorKing
        ),
        // Utility Branch
        Skill(
            id: "warriorKing_util_1",
            name: "Royal Treasury",
            icon: "building.columns.fill",
            description: "The kingdom's wealth flows to its ruler. Gain 12% bonus gold.",
            branch: .utility,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.goldMultiplier(percent: 12)],
            characterClass: .warriorKing
        ),
        Skill(
            id: "warriorKing_util_2",
            name: "Inspiring Presence",
            icon: "person.3.fill",
            description: "Your presence inspires greatness. Gain 10% bonus XP and +2 charisma.",
            branch: .utility,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "warriorKing_util_1",
            effects: [.xpMultiplier(percent: 10), .statBoost(stat: .charisma, value: 2)],
            characterClass: .warriorKing
        ),
        Skill(
            id: "warriorKing_util_3",
            name: "Decree of Power",
            icon: "scroll.fill",
            description: "Issue a royal decree that empowers all abilities. Reduce cooldowns by 1 turn and gain 15 bonus energy.",
            branch: .utility,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "warriorKing_util_2",
            effects: [.specialCooldownReduction(turns: 1), .energyBonus(value: 15)],
            characterClass: .warriorKing
        ),
    ]

    // MARK: - Pirate Skills

    static let pirateSkills: [Skill] = [
        // Offense Branch
        Skill(
            id: "pirate_off_1",
            name: "Dirty Fighting",
            icon: "hand.raised.slash.fill",
            description: "Fight without honor, win without question. Increases critical hit chance by 6%.",
            branch: .offense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.critChance(percent: 6)],
            characterClass: .pirate
        ),
        Skill(
            id: "pirate_off_2",
            name: "Cutlass Mastery",
            icon: "scissors",
            description: "Your blade dances like the tide. Increases damage by 10% and crit chance by 3%.",
            branch: .offense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "pirate_off_1",
            effects: [.damageMultiplier(percent: 10), .critChance(percent: 3)],
            characterClass: .pirate
        ),
        Skill(
            id: "pirate_off_3",
            name: "Dead Man's Strike",
            icon: "bolt.heart.fill",
            description: "A finishing blow that steals the life from your foes. Gain 10% lifesteal and 10% damage.",
            branch: .offense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "pirate_off_2",
            effects: [.lifesteal(percent: 10), .damageMultiplier(percent: 10)],
            characterClass: .pirate
        ),
        // Defense Branch
        Skill(
            id: "pirate_def_1",
            name: "Sea Legs",
            icon: "figure.walk",
            description: "Years at sea have given you uncanny balance. Gain 6% dodge chance.",
            branch: .defense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.dodgeChance(percent: 6)],
            characterClass: .pirate
        ),
        Skill(
            id: "pirate_def_2",
            name: "Rum-Soaked Hide",
            icon: "mug.fill",
            description: "Rum numbs the pain and hardens the spirit. Gain 15 max health and 50% burn resistance.",
            branch: .defense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "pirate_def_1",
            effects: [.maxHealthBonus(value: 15), .statusResistance(type: .burn, percent: 50)],
            characterClass: .pirate
        ),
        Skill(
            id: "pirate_def_3",
            name: "Captain's Resolve",
            icon: "anchor.circle.fill",
            description: "A captain goes down with the ship, but not today. Gain 8% dodge, 12% defense, and 20 max health.",
            branch: .defense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "pirate_def_2",
            effects: [.dodgeChance(percent: 8), .defenseMultiplier(percent: 12), .maxHealthBonus(value: 20)],
            characterClass: .pirate
        ),
        // Utility Branch
        Skill(
            id: "pirate_util_1",
            name: "Plunder",
            icon: "bag.fill.badge.plus",
            description: "Take everything that is not nailed down. Gain 15% bonus gold.",
            branch: .utility,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.goldMultiplier(percent: 15)],
            characterClass: .pirate
        ),
        Skill(
            id: "pirate_util_2",
            name: "Treasure Map",
            icon: "map.fill",
            description: "X marks the spot for experience and riches. Gain 8% bonus XP and 8% bonus gold.",
            branch: .utility,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "pirate_util_1",
            effects: [.xpMultiplier(percent: 8), .goldMultiplier(percent: 8)],
            characterClass: .pirate
        ),
        Skill(
            id: "pirate_util_3",
            name: "Privateer's Fortune",
            icon: "star.circle.fill",
            description: "Fortune favors the bold. Reduce cooldowns by 1 turn and gain 15 bonus energy.",
            branch: .utility,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "pirate_util_2",
            effects: [.specialCooldownReduction(turns: 1), .energyBonus(value: 15)],
            characterClass: .pirate
        ),
    ]

    // MARK: - Ice Mage Skills

    static let iceMageSkills: [Skill] = [
        // Offense Branch
        Skill(
            id: "iceMage_off_1",
            name: "Frost Bite",
            icon: "snowflake",
            description: "Your touch carries the chill of winter. Increases critical hit chance by 4% and intelligence by 1.",
            branch: .offense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.critChance(percent: 4), .statBoost(stat: .intelligence, value: 1)],
            characterClass: .iceMage
        ),
        Skill(
            id: "iceMage_off_2",
            name: "Frost Nova",
            icon: "sparkles",
            description: "Unleash a burst of freezing energy. Increases damage by 14%.",
            branch: .offense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "iceMage_off_1",
            effects: [.damageMultiplier(percent: 14)],
            characterClass: .iceMage
        ),
        Skill(
            id: "iceMage_off_3",
            name: "Absolute Zero",
            icon: "thermometer.snowflake",
            description: "Reduce all matter to stillness. Gain 10% crit chance and 5% lifesteal from frozen shards.",
            branch: .offense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "iceMage_off_2",
            effects: [.critChance(percent: 10), .lifesteal(percent: 5)],
            characterClass: .iceMage
        ),
        // Defense Branch
        Skill(
            id: "iceMage_def_1",
            name: "Glacial Shield",
            icon: "shield.fill",
            description: "A barrier of solid ice absorbs incoming damage. Gain 15 max health and 5% defense.",
            branch: .defense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.maxHealthBonus(value: 15), .defenseMultiplier(percent: 5)],
            characterClass: .iceMage
        ),
        Skill(
            id: "iceMage_def_2",
            name: "Frozen Armor",
            icon: "circle.hexagongrid.fill",
            description: "Encase yourself in enchanted ice. Gain 5% dodge chance and 50% stun resistance.",
            branch: .defense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "iceMage_def_1",
            effects: [.dodgeChance(percent: 5), .statusResistance(type: .stun, percent: 50)],
            characterClass: .iceMage
        ),
        Skill(
            id: "iceMage_def_3",
            name: "Permafrost",
            icon: "snowflake.circle.fill",
            description: "Your icy aura punishes attackers. Gain 30 max health and 12% counterattack chance.",
            branch: .defense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "iceMage_def_2",
            effects: [.maxHealthBonus(value: 30), .counterattack(percent: 12)],
            characterClass: .iceMage
        ),
        // Utility Branch
        Skill(
            id: "iceMage_util_1",
            name: "Crystal Harvest",
            icon: "diamond.fill",
            description: "Extract magical crystals from defeated foes. Gain 10% bonus gold.",
            branch: .utility,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.goldMultiplier(percent: 10)],
            characterClass: .iceMage
        ),
        Skill(
            id: "iceMage_util_2",
            name: "Arcane Study",
            icon: "book.fill",
            description: "Deep study of frost magic accelerates learning. Gain 12% bonus XP.",
            branch: .utility,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "iceMage_util_1",
            effects: [.xpMultiplier(percent: 12)],
            characterClass: .iceMage
        ),
        Skill(
            id: "iceMage_util_3",
            name: "Time Freeze",
            icon: "clock.arrow.circlepath",
            description: "Briefly slow time itself. Reduce cooldowns by 2 turns and gain 10 bonus energy.",
            branch: .utility,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "iceMage_util_2",
            effects: [.specialCooldownReduction(turns: 2), .energyBonus(value: 10)],
            characterClass: .iceMage
        ),
    ]

    // MARK: - Necromancer Skills

    static let necromancerSkills: [Skill] = [
        // Offense Branch
        Skill(
            id: "necromancer_off_1",
            name: "Soul Siphon",
            icon: "wand.and.stars",
            description: "Drain fragments of life from the living. Increases critical hit chance by 3% and gain 3% lifesteal.",
            branch: .offense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.critChance(percent: 3), .lifesteal(percent: 3)],
            characterClass: .necromancer
        ),
        Skill(
            id: "necromancer_off_2",
            name: "Death's Embrace",
            icon: "hand.raised.fill",
            description: "Channel the power of death itself. Increases damage by 12% and lifesteal by 4%.",
            branch: .offense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "necromancer_off_1",
            effects: [.damageMultiplier(percent: 12), .lifesteal(percent: 4)],
            characterClass: .necromancer
        ),
        Skill(
            id: "necromancer_off_3",
            name: "Reaper's Harvest",
            icon: "moon.stars.fill",
            description: "Become one with death. Every strike reaps life force. Gain 15% damage and 8% lifesteal.",
            branch: .offense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "necromancer_off_2",
            effects: [.damageMultiplier(percent: 15), .lifesteal(percent: 8)],
            characterClass: .necromancer
        ),
        // Defense Branch
        Skill(
            id: "necromancer_def_1",
            name: "Bone Armor",
            icon: "xmark.shield.fill",
            description: "Surround yourself with animated bones for protection. Gain 20 max health.",
            branch: .defense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.maxHealthBonus(value: 20)],
            characterClass: .necromancer
        ),
        Skill(
            id: "necromancer_def_2",
            name: "Spectral Ward",
            icon: "aqi.medium",
            description: "Ghostly guardians deflect attacks. Gain 6% dodge chance and 50% poison resistance.",
            branch: .defense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "necromancer_def_1",
            effects: [.dodgeChance(percent: 6), .statusResistance(type: .poison, percent: 50)],
            characterClass: .necromancer
        ),
        Skill(
            id: "necromancer_def_3",
            name: "Undying Will",
            icon: "infinity.circle.fill",
            description: "Death itself cannot claim you easily. Gain 35 max health, 10% defense, and 50% bleed resistance.",
            branch: .defense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "necromancer_def_2",
            effects: [.maxHealthBonus(value: 35), .defenseMultiplier(percent: 10), .statusResistance(type: .bleed, percent: 50)],
            characterClass: .necromancer
        ),
        // Utility Branch
        Skill(
            id: "necromancer_util_1",
            name: "Grave Robber",
            icon: "dollarsign.circle.fill",
            description: "The dead have no use for gold. Gain 12% bonus gold.",
            branch: .utility,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.goldMultiplier(percent: 12)],
            characterClass: .necromancer
        ),
        Skill(
            id: "necromancer_util_2",
            name: "Dark Knowledge",
            icon: "book.closed.fill",
            description: "Forbidden tomes reveal hidden wisdom. Gain 10% bonus XP and +2 intelligence.",
            branch: .utility,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "necromancer_util_1",
            effects: [.xpMultiplier(percent: 10), .statBoost(stat: .intelligence, value: 2)],
            characterClass: .necromancer
        ),
        Skill(
            id: "necromancer_util_3",
            name: "Temporal Rift",
            icon: "hourglass",
            description: "Tear a hole in time to hasten your dark magic. Reduce cooldowns by 1 turn and gain 15 bonus energy.",
            branch: .utility,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "necromancer_util_2",
            effects: [.specialCooldownReduction(turns: 1), .energyBonus(value: 15)],
            characterClass: .necromancer
        ),
    ]

    // MARK: - Dragon Skills

    static let dragonSkills: [Skill] = [
        // Offense Branch
        Skill(
            id: "dragon_off_1",
            name: "Dragon's Fury",
            icon: "flame.fill",
            description: "The fire within burns hot. Increases critical hit chance by 5% and strength by 1.",
            branch: .offense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.critChance(percent: 5), .statBoost(stat: .strength, value: 1)],
            characterClass: .dragon
        ),
        Skill(
            id: "dragon_off_2",
            name: "Inferno Breath",
            icon: "flame.circle.fill",
            description: "Exhale a torrent of destruction. Increases damage by 15%.",
            branch: .offense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "dragon_off_1",
            effects: [.damageMultiplier(percent: 15)],
            characterClass: .dragon
        ),
        Skill(
            id: "dragon_off_3",
            name: "Cataclysm",
            icon: "tornado",
            description: "Unleash devastation incarnate. Gain 8% crit chance, 10% damage, and 5% lifesteal.",
            branch: .offense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "dragon_off_2",
            effects: [.critChance(percent: 8), .damageMultiplier(percent: 10), .lifesteal(percent: 5)],
            characterClass: .dragon
        ),
        // Defense Branch
        Skill(
            id: "dragon_def_1",
            name: "Scale Plating",
            icon: "checkerboard.shield",
            description: "Ancient dragon scales harden your hide. Gain 30 max health.",
            branch: .defense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.maxHealthBonus(value: 30)],
            characterClass: .dragon
        ),
        Skill(
            id: "dragon_def_2",
            name: "Flame Ward",
            icon: "flame.shield.fill",
            description: "Fire cannot harm a dragon. Gain 10% defense and 75% burn resistance.",
            branch: .defense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "dragon_def_1",
            effects: [.defenseMultiplier(percent: 10), .statusResistance(type: .burn, percent: 75)],
            characterClass: .dragon
        ),
        Skill(
            id: "dragon_def_3",
            name: "Ancient Wyrm",
            icon: "shield.lefthalf.filled.badge.checkmark",
            description: "Channel the resilience of the eldest dragons. Gain 50 max health and 15% counterattack chance.",
            branch: .defense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "dragon_def_2",
            effects: [.maxHealthBonus(value: 50), .counterattack(percent: 15)],
            characterClass: .dragon
        ),
        // Utility Branch
        Skill(
            id: "dragon_util_1",
            name: "Hoard Instinct",
            icon: "sparkle",
            description: "An insatiable desire to collect treasure. Gain 12% bonus gold.",
            branch: .utility,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.goldMultiplier(percent: 12)],
            characterClass: .dragon
        ),
        Skill(
            id: "dragon_util_2",
            name: "Elder Wisdom",
            icon: "brain.head.profile.fill",
            description: "Centuries of existence grant unparalleled insight. Gain 10% bonus XP and +2 wisdom.",
            branch: .utility,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "dragon_util_1",
            effects: [.xpMultiplier(percent: 10), .statBoost(stat: .wisdom, value: 2)],
            characterClass: .dragon
        ),
        Skill(
            id: "dragon_util_3",
            name: "Primordial Force",
            icon: "bolt.circle.fill",
            description: "Tap into the primal energies of creation. Reduce cooldowns by 1 turn and gain 20 bonus energy.",
            branch: .utility,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "dragon_util_2",
            effects: [.specialCooldownReduction(turns: 1), .energyBonus(value: 20)],
            characterClass: .dragon
        ),
    ]

    // MARK: - Angel Skills

    static let angelSkills: [Skill] = [
        // Offense Branch
        Skill(
            id: "angel_off_1",
            name: "Holy Smite",
            icon: "bolt.fill",
            description: "Channel divine wrath into your strikes. Increases critical hit chance by 4% and wisdom by 1.",
            branch: .offense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.critChance(percent: 4), .statBoost(stat: .wisdom, value: 1)],
            characterClass: .angel
        ),
        Skill(
            id: "angel_off_2",
            name: "Radiant Blade",
            icon: "sun.max.fill",
            description: "Your weapon blazes with celestial light. Increases damage by 12% and crit chance by 3%.",
            branch: .offense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "angel_off_1",
            effects: [.damageMultiplier(percent: 12), .critChance(percent: 3)],
            characterClass: .angel
        ),
        Skill(
            id: "angel_off_3",
            name: "Divine Judgment",
            icon: "sun.max.trianglebadge.exclamationmark.fill",
            description: "Pass judgment upon the wicked. Gain 10% lifesteal and 12% damage as divine retribution.",
            branch: .offense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "angel_off_2",
            effects: [.lifesteal(percent: 10), .damageMultiplier(percent: 12)],
            characterClass: .angel
        ),
        // Defense Branch
        Skill(
            id: "angel_def_1",
            name: "Blessed Aura",
            icon: "sparkle",
            description: "A holy aura surrounds and protects you. Gain 20 max health and 3% dodge chance.",
            branch: .defense,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.maxHealthBonus(value: 20), .dodgeChance(percent: 3)],
            characterClass: .angel
        ),
        Skill(
            id: "angel_def_2",
            name: "Wings of Grace",
            icon: "wind",
            description: "Ethereal wings grant divine evasion. Gain 7% dodge chance and 50% burn resistance.",
            branch: .defense,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "angel_def_1",
            effects: [.dodgeChance(percent: 7), .statusResistance(type: .burn, percent: 50)],
            characterClass: .angel
        ),
        Skill(
            id: "angel_def_3",
            name: "Seraphim's Guard",
            icon: "checkmark.shield.fill",
            description: "The highest order of angels watches over you. Gain 40 max health, 12% defense, and 50% bleed resistance.",
            branch: .defense,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "angel_def_2",
            effects: [.maxHealthBonus(value: 40), .defenseMultiplier(percent: 12), .statusResistance(type: .bleed, percent: 50)],
            characterClass: .angel
        ),
        // Utility Branch
        Skill(
            id: "angel_util_1",
            name: "Divine Blessing",
            icon: "hands.sparkles.fill",
            description: "The heavens shower you with blessings. Gain 8% bonus gold and 5% bonus XP.",
            branch: .utility,
            tier: 1,
            skillPointCost: 1,
            prerequisiteSkillId: nil,
            effects: [.goldMultiplier(percent: 8), .xpMultiplier(percent: 5)],
            characterClass: .angel
        ),
        Skill(
            id: "angel_util_2",
            name: "Celestial Insight",
            icon: "eye.trianglebadge.exclamationmark.fill",
            description: "See the world through divine eyes. Gain 10% bonus XP and +2 wisdom.",
            branch: .utility,
            tier: 2,
            skillPointCost: 2,
            prerequisiteSkillId: "angel_util_1",
            effects: [.xpMultiplier(percent: 10), .statBoost(stat: .wisdom, value: 2)],
            characterClass: .angel
        ),
        Skill(
            id: "angel_util_3",
            name: "Ascension",
            icon: "arrow.up.circle.fill",
            description: "Transcend mortal limits. Reduce cooldowns by 2 turns and gain 10 bonus energy.",
            branch: .utility,
            tier: 3,
            skillPointCost: 3,
            prerequisiteSkillId: "angel_util_2",
            effects: [.specialCooldownReduction(turns: 2), .energyBonus(value: 10)],
            characterClass: .angel
        ),
    ]
}
