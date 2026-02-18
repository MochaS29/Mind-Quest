import Foundation

// MARK: - Combat Ability Database
// 8 classes x 6 abilities each = 48 combat abilities
// Pattern per class:
//   - 1 basic attack (tier 0, no cooldown)
//   - 1 defensive move (tier 0, 2-turn cooldown)
//   - 1 offense ability (tier 0, 3-turn cooldown) — always available
//   - 1 defense ability (tier 0, 3-turn cooldown) — always available
//   - 1 powerful offense (tier 2, 4-turn cooldown)
//   - 1 ultimate (tier 3, 5-turn cooldown)

struct CombatAbilityDatabase {

    static func abilities(for characterClass: CharacterClass) -> [CombatAbility] {
        switch characterClass {
        case .warrior:     return warriorAbilities
        case .ranger:      return rangerAbilities
        case .warriorKing: return warriorKingAbilities
        case .pirate:      return pirateAbilities
        case .iceMage:     return iceMageAbilities
        case .necromancer: return necromancerAbilities
        case .dragon:      return dragonAbilities
        case .angel:       return angelAbilities
        }
    }

    // MARK: - Warrior

    static let warriorAbilities: [CombatAbility] = [
        CombatAbility(
            id: "warrior_slash",
            name: "Slash",
            icon: "burst.fill",
            description: "A swift blade strike.",
            damageMultiplier: 1.0,
            effect: nil,
            cooldown: 0,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "warrior_guard",
            name: "Guard",
            icon: "shield.fill",
            description: "Brace for impact, reducing incoming damage by 50%.",
            damageMultiplier: 0,
            effect: .shield(damageReduction: 0.5),
            cooldown: 2,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "warrior_power_strike",
            name: "Power Strike",
            icon: "hammer.fill",
            description: "Channel raw strength into a devastating blow.",
            damageMultiplier: 1.8,
            effect: nil,
            cooldown: 3,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "warrior_shield_bash",
            name: "Shield Bash",
            icon: "shield.lefthalf.filled",
            description: "Slam your shield into the enemy, stunning them.",
            damageMultiplier: 1.2,
            effect: .stun(turns: 1),
            cooldown: 3,
            unlockTier: 0,
            branch: .defense,
            isDefensive: false
        ),
        CombatAbility(
            id: "warrior_whirlwind",
            name: "Whirlwind",
            icon: "tornado",
            description: "Spin with unstoppable force, striking everything around you.",
            damageMultiplier: 2.0,
            effect: nil,
            cooldown: 4,
            unlockTier: 2,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "warrior_berserker_rage",
            name: "Berserker Rage",
            icon: "flame.fill",
            description: "Enter a berserk frenzy, dealing massive damage and strengthening yourself.",
            damageMultiplier: 2.5,
            effect: .strengthen(value: 3, turns: 2),
            cooldown: 5,
            unlockTier: 3,
            branch: .offense,
            isDefensive: false
        ),
    ]

    // MARK: - Ranger

    static let rangerAbilities: [CombatAbility] = [
        CombatAbility(
            id: "ranger_quick_shot",
            name: "Quick Shot",
            icon: "arrow.right",
            description: "A rapid arrow fired with precision.",
            damageMultiplier: 1.0,
            effect: nil,
            cooldown: 0,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "ranger_evasion",
            name: "Evasion",
            icon: "figure.walk",
            description: "Dodge and weave, reducing incoming damage by 50%.",
            damageMultiplier: 0,
            effect: .shield(damageReduction: 0.5),
            cooldown: 2,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "ranger_poison_arrow",
            name: "Poison Arrow",
            icon: "leaf.arrow.circlepath",
            description: "A venomous arrow that poisons the target over time.",
            damageMultiplier: 1.2,
            effect: .poison(damage: 3, turns: 3),
            cooldown: 3,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "ranger_natures_grasp",
            name: "Nature's Grasp",
            icon: "leaf.fill",
            description: "Call upon nature to heal your wounds.",
            damageMultiplier: 0,
            effect: .regenerate(value: 5, turns: 3),
            cooldown: 3,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "ranger_piercing_volley",
            name: "Piercing Volley",
            icon: "scope",
            description: "Unleash a barrage of armor-piercing arrows.",
            damageMultiplier: 2.2,
            effect: nil,
            cooldown: 4,
            unlockTier: 2,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "ranger_rain_of_arrows",
            name: "Rain of Arrows",
            icon: "cloud.bolt.rain.fill",
            description: "Darken the sky with arrows, dealing massive damage and weakening the foe.",
            damageMultiplier: 2.5,
            effect: .weaken(value: 3, turns: 2),
            cooldown: 5,
            unlockTier: 3,
            branch: .offense,
            isDefensive: false
        ),
    ]

    // MARK: - Warrior King

    static let warriorKingAbilities: [CombatAbility] = [
        CombatAbility(
            id: "wk_royal_strike",
            name: "Royal Strike",
            icon: "crown.fill",
            description: "Strike with the authority of a king.",
            damageMultiplier: 1.0,
            effect: nil,
            cooldown: 0,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "wk_kings_guard",
            name: "King's Guard",
            icon: "shield.checkered",
            description: "Raise your royal shield, reducing damage by 50%.",
            damageMultiplier: 0,
            effect: .shield(damageReduction: 0.5),
            cooldown: 2,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "wk_commanding_blow",
            name: "Commanding Blow",
            icon: "bolt.fill",
            description: "A powerful strike that weakens the enemy's resolve.",
            damageMultiplier: 1.5,
            effect: .weaken(value: 2, turns: 2),
            cooldown: 3,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "wk_rallying_cry",
            name: "Rallying Cry",
            icon: "megaphone.fill",
            description: "Inspire yourself with a battle cry, boosting attack power.",
            damageMultiplier: 0,
            effect: .strengthen(value: 4, turns: 3),
            cooldown: 3,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "wk_sovereign_wrath",
            name: "Sovereign's Wrath",
            icon: "seal.fill",
            description: "Unleash the fury of the throne upon your enemies.",
            damageMultiplier: 2.2,
            effect: nil,
            cooldown: 4,
            unlockTier: 2,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "wk_conquerors_judgment",
            name: "Conqueror's Judgment",
            icon: "sparkles",
            description: "Pass royal judgment, dealing devastating damage and stunning the foe.",
            damageMultiplier: 2.8,
            effect: .stun(turns: 1),
            cooldown: 5,
            unlockTier: 3,
            branch: .offense,
            isDefensive: false
        ),
    ]

    // MARK: - Pirate

    static let pirateAbilities: [CombatAbility] = [
        CombatAbility(
            id: "pirate_cutlass_swing",
            name: "Cutlass Swing",
            icon: "scissors",
            description: "A swift slash with your trusty cutlass.",
            damageMultiplier: 1.0,
            effect: nil,
            cooldown: 0,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "pirate_brace",
            name: "Brace Yourself",
            icon: "anchor.circle.fill",
            description: "Anchor your stance and brace for the blow.",
            damageMultiplier: 0,
            effect: .shield(damageReduction: 0.5),
            cooldown: 2,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "pirate_dirty_trick",
            name: "Dirty Trick",
            icon: "hand.raised.slash.fill",
            description: "Throw sand in their eyes! Deals damage and stuns.",
            damageMultiplier: 1.0,
            effect: .stun(turns: 1),
            cooldown: 3,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "pirate_rum_swig",
            name: "Rum Swig",
            icon: "mug.fill",
            description: "Take a swig of rum to heal and strengthen yourself.",
            damageMultiplier: 0,
            effect: .heal(percent: 0.2),
            cooldown: 3,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "pirate_broadside",
            name: "Broadside",
            icon: "bolt.horizontal.fill",
            description: "Fire a devastating cannon blast at close range.",
            damageMultiplier: 2.0,
            effect: .burn(damage: 3, turns: 2),
            cooldown: 4,
            unlockTier: 2,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "pirate_dead_mans_hand",
            name: "Dead Man's Hand",
            icon: "bolt.heart.fill",
            description: "A cursed strike that drains the life from your foe.",
            damageMultiplier: 2.5,
            effect: .lifesteal(percent: 0.5),
            cooldown: 5,
            unlockTier: 3,
            branch: .offense,
            isDefensive: false
        ),
    ]

    // MARK: - Ice Mage

    static let iceMageAbilities: [CombatAbility] = [
        CombatAbility(
            id: "ice_frost_bolt",
            name: "Frost Bolt",
            icon: "snowflake",
            description: "Hurl a shard of magical ice.",
            damageMultiplier: 1.0,
            effect: nil,
            cooldown: 0,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "ice_barrier",
            name: "Ice Barrier",
            icon: "shield.fill",
            description: "Encase yourself in ice, reducing damage and reflecting some back.",
            damageMultiplier: 0,
            effect: .reflect(percent: 0.25),
            cooldown: 2,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "ice_blizzard",
            name: "Blizzard",
            icon: "cloud.snow.fill",
            description: "Summon a freezing storm that weakens the enemy.",
            damageMultiplier: 1.5,
            effect: .weaken(value: 2, turns: 2),
            cooldown: 3,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "ice_frost_nova",
            name: "Frost Nova",
            icon: "sparkles",
            description: "Explode with frost energy, freezing the enemy in place.",
            damageMultiplier: 1.0,
            effect: .stun(turns: 1),
            cooldown: 3,
            unlockTier: 0,
            branch: .defense,
            isDefensive: false
        ),
        CombatAbility(
            id: "ice_glacial_spike",
            name: "Glacial Spike",
            icon: "arrow.up.right.circle.fill",
            description: "Launch an enormous spike of ancient ice.",
            damageMultiplier: 2.2,
            effect: nil,
            cooldown: 4,
            unlockTier: 2,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "ice_absolute_zero",
            name: "Absolute Zero",
            icon: "thermometer.snowflake",
            description: "Reduce all matter to absolute stillness. Devastating damage and stun.",
            damageMultiplier: 3.0,
            effect: .stun(turns: 1),
            cooldown: 6,
            unlockTier: 3,
            branch: .offense,
            isDefensive: false
        ),
    ]

    // MARK: - Necromancer

    static let necromancerAbilities: [CombatAbility] = [
        CombatAbility(
            id: "necro_shadow_bolt",
            name: "Shadow Bolt",
            icon: "moon.fill",
            description: "Launch a bolt of dark energy.",
            damageMultiplier: 1.0,
            effect: nil,
            cooldown: 0,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "necro_bone_shield",
            name: "Bone Shield",
            icon: "xmark.shield.fill",
            description: "Surround yourself with orbiting bones that absorb damage.",
            damageMultiplier: 0,
            effect: .shield(damageReduction: 0.5),
            cooldown: 2,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "necro_drain_life",
            name: "Drain Life",
            icon: "wand.and.stars",
            description: "Siphon the life force from your enemy.",
            damageMultiplier: 1.3,
            effect: .lifesteal(percent: 0.4),
            cooldown: 3,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "necro_curse",
            name: "Curse of Agony",
            icon: "eye.slash.fill",
            description: "Place a devastating curse that bleeds the target.",
            damageMultiplier: 0.8,
            effect: .bleed(damage: 4, turns: 3),
            cooldown: 3,
            unlockTier: 0,
            branch: .defense,
            isDefensive: false
        ),
        CombatAbility(
            id: "necro_corpse_explosion",
            name: "Corpse Explosion",
            icon: "burst.fill",
            description: "Detonate dark energy in a devastating blast.",
            damageMultiplier: 2.3,
            effect: .poison(damage: 3, turns: 2),
            cooldown: 4,
            unlockTier: 2,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "necro_deaths_embrace",
            name: "Death's Embrace",
            icon: "moon.stars.fill",
            description: "Channel the power of death itself. Massive damage with life drain.",
            damageMultiplier: 2.8,
            effect: .lifesteal(percent: 0.5),
            cooldown: 5,
            unlockTier: 3,
            branch: .offense,
            isDefensive: false
        ),
    ]

    // MARK: - Dragon Knight

    static let dragonAbilities: [CombatAbility] = [
        CombatAbility(
            id: "dragon_claw",
            name: "Dragon Claw",
            icon: "flame.fill",
            description: "Rake the enemy with searing claws.",
            damageMultiplier: 1.0,
            effect: nil,
            cooldown: 0,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "dragon_scale_armor",
            name: "Scale Armor",
            icon: "checkerboard.shield",
            description: "Harden your scales, reducing incoming damage by 50%.",
            damageMultiplier: 0,
            effect: .shield(damageReduction: 0.5),
            cooldown: 2,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "dragon_fire_breath",
            name: "Fire Breath",
            icon: "flame.circle.fill",
            description: "Exhale a stream of fire that burns the target.",
            damageMultiplier: 1.5,
            effect: .burn(damage: 4, turns: 2),
            cooldown: 3,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "dragon_tail_sweep",
            name: "Tail Sweep",
            icon: "arrow.triangle.2.circlepath",
            description: "Sweep your tail to knock the enemy off balance.",
            damageMultiplier: 1.2,
            effect: .stun(turns: 1),
            cooldown: 3,
            unlockTier: 0,
            branch: .defense,
            isDefensive: false
        ),
        CombatAbility(
            id: "dragon_inferno",
            name: "Inferno",
            icon: "tornado",
            description: "Unleash a devastating firestorm.",
            damageMultiplier: 2.2,
            effect: .burn(damage: 3, turns: 2),
            cooldown: 4,
            unlockTier: 2,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "dragon_cataclysm",
            name: "Cataclysm",
            icon: "bolt.circle.fill",
            description: "Unleash primal fury in a world-shattering attack.",
            damageMultiplier: 3.0,
            effect: .strengthen(value: 3, turns: 2),
            cooldown: 6,
            unlockTier: 3,
            branch: .offense,
            isDefensive: false
        ),
    ]

    // MARK: - Angel Warrior

    static let angelAbilities: [CombatAbility] = [
        CombatAbility(
            id: "angel_holy_strike",
            name: "Holy Strike",
            icon: "bolt.fill",
            description: "Strike with divine radiance.",
            damageMultiplier: 1.0,
            effect: nil,
            cooldown: 0,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "angel_divine_shield",
            name: "Divine Shield",
            icon: "shield.fill",
            description: "Invoke a barrier of holy light, reducing damage by 50%.",
            damageMultiplier: 0,
            effect: .shield(damageReduction: 0.5),
            cooldown: 2,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "angel_smite",
            name: "Smite",
            icon: "sun.max.fill",
            description: "Call down holy fire that burns the wicked.",
            damageMultiplier: 1.5,
            effect: .burn(damage: 3, turns: 2),
            cooldown: 3,
            unlockTier: 0,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "angel_healing_light",
            name: "Healing Light",
            icon: "cross.fill",
            description: "Bathe in celestial light, restoring health over time.",
            damageMultiplier: 0,
            effect: .regenerate(value: 6, turns: 3),
            cooldown: 3,
            unlockTier: 0,
            branch: .defense,
            isDefensive: true
        ),
        CombatAbility(
            id: "angel_radiant_blade",
            name: "Radiant Blade",
            icon: "sparkle",
            description: "Your blade blazes with celestial light for a devastating strike.",
            damageMultiplier: 2.2,
            effect: nil,
            cooldown: 4,
            unlockTier: 2,
            branch: .offense,
            isDefensive: false
        ),
        CombatAbility(
            id: "angel_divine_judgment",
            name: "Divine Judgment",
            icon: "sun.max.trianglebadge.exclamationmark.fill",
            description: "Pass judgment upon the wicked with overwhelming holy power.",
            damageMultiplier: 2.8,
            effect: .stun(turns: 1),
            cooldown: 5,
            unlockTier: 3,
            branch: .offense,
            isDefensive: false
        ),
    ]
}
