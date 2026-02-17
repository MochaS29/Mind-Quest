import Foundation
import SwiftUI

struct SeasonalEventDatabase {

    // MARK: - All Events
    static let allEvents: [SeasonalEvent] = [springFestival, summerTrials]

    // MARK: - Spring Festival (March-April)
    static let springFestival = SeasonalEvent(
        id: "spring_festival",
        name: "Spring Festival",
        description: "Celebrate the season of growth! Battle nature spirits and earn exclusive spring rewards.",
        icon: "🌸",
        themeColorHex: "2ECC71",
        startMonth: 3,
        endMonth: 4,
        challenges: [
            SeasonalChallenge(
                id: "spring_battles", title: "Spring Warrior", description: "Win 10 battles during the Spring Festival",
                icon: "⚔️", type: .winBattles, target: 10,
                rewards: SeasonalRewardSet(xp: 200, gold: 100)
            ),
            SeasonalChallenge(
                id: "spring_quests", title: "Nature's Tasks", description: "Complete 20 quests during the festival",
                icon: "📜", type: .completeQuests, target: 20,
                rewards: SeasonalRewardSet(xp: 300, gold: 150)
            ),
            SeasonalChallenge(
                id: "spring_craft", title: "Spring Crafter", description: "Craft 5 items during the festival",
                icon: "🔨", type: .craftItems, target: 5,
                rewards: SeasonalRewardSet(xp: 150, gold: 200)
            ),
            SeasonalChallenge(
                id: "spring_gold", title: "Golden Harvest", description: "Earn 2000 gold during the festival",
                icon: "💰", type: .earnGold, target: 2000,
                rewards: SeasonalRewardSet(xp: 250, gold: 0)
            ),
            SeasonalChallenge(
                id: "spring_boss", title: "Spring Dragon Slayer", description: "Defeat the Spring Dragon",
                icon: "🐉", type: .defeatEnemy, target: 1,
                rewards: SeasonalRewardSet(xp: 500, gold: 300, cosmeticId: "title_the_brave")
            )
        ],
        exclusiveEnemies: [
            BattleEncounter(
                enemyName: "Blossom Sprite",
                enemyAvatar: "🌺",
                enemyDescription: "A playful nature spirit born from spring blossoms",
                enemyLevel: 5,
                enemyHP: 60,
                enemyMaxHP: 60,
                enemyAttack: 12,
                enemyDefense: 5,
                abilities: [
                    EnemyAbility(name: "Petal Storm", damage: 15, description: "A whirlwind of petals", chance: 0.4),
                    EnemyAbility(name: "Nature's Kiss", damage: 0, description: "Heals with nature energy", chance: 0.2,
                                 statusEffect: StatusEffect(type: .regenerate, duration: 2, value: 8))
                ],
                rewards: BattleRewards(xp: 50, gold: 30)
            ),
            BattleEncounter(
                enemyName: "Forest Guardian",
                enemyAvatar: "🌳",
                enemyDescription: "An ancient protector of the spring forests",
                enemyLevel: 10,
                enemyHP: 120,
                enemyMaxHP: 120,
                enemyAttack: 18,
                enemyDefense: 10,
                abilities: [
                    EnemyAbility(name: "Root Slam", damage: 22, description: "Massive roots strike from below", chance: 0.35),
                    EnemyAbility(name: "Bark Shield", damage: 0, description: "Hardens bark for protection", chance: 0.25,
                                 statusEffect: StatusEffect(type: .shield, duration: 2, value: 10))
                ],
                rewards: BattleRewards(xp: 100, gold: 60)
            ),
            BattleEncounter(
                enemyName: "Spring Dragon",
                enemyAvatar: "🐲",
                enemyDescription: "A majestic dragon awakened by the spring season",
                enemyLevel: 15,
                enemyHP: 200,
                enemyMaxHP: 200,
                enemyAttack: 25,
                enemyDefense: 12,
                isBoss: true,
                abilities: [
                    EnemyAbility(name: "Verdant Breath", damage: 30, description: "A blast of nature energy", chance: 0.35,
                                 statusEffect: StatusEffect(type: .poison, duration: 3, value: 5)),
                    EnemyAbility(name: "Tail Sweep", damage: 20, description: "A powerful tail attack", chance: 0.3),
                    EnemyAbility(name: "Bloom Burst", damage: 35, description: "An explosion of floral energy", chance: 0.2)
                ],
                rewards: BattleRewards(xp: 250, gold: 150)
            )
        ],
        exclusiveItems: [
            Item(templateId: "spring_blossom_staff", name: "Blossom Staff", icon: "🌸",
                 type: .weapon, rarity: .rare, levelRequirement: 8, buyPrice: 0, sellPrice: 100,
                 itemDescription: "A staff blooming with spring energy.",
                 statModifiers: [.intelligence: 5, .wisdom: 3], slot: .weapon),
            Item(templateId: "spring_crown", name: "Spring Crown", icon: "👑",
                 type: .accessory, rarity: .rare, buyPrice: 0, sellPrice: 80,
                 itemDescription: "A crown woven from enchanted spring flowers.",
                 statModifiers: [.charisma: 3, .wisdom: 2], slot: .accessory),
            Item(templateId: "renewal_potion", name: "Renewal Potion", icon: "🧪",
                 type: .consumable, rarity: .uncommon, buyPrice: 0, sellPrice: 30,
                 itemDescription: "Restores 50 HP with the power of spring.",
                 healAmount: 50)
        ]
    )

    // MARK: - Summer Trials (June-July)
    static let summerTrials = SeasonalEvent(
        id: "summer_trials",
        name: "Summer Trials",
        description: "Prove your worth in the scorching Summer Trials! Face fire enemies and compete for glory.",
        icon: "☀️",
        themeColorHex: "E74C3C",
        startMonth: 6,
        endMonth: 7,
        challenges: [
            SeasonalChallenge(
                id: "summer_battles", title: "Trial Fighter", description: "Win 15 battles during the Summer Trials",
                icon: "⚔️", type: .winBattles, target: 15,
                rewards: SeasonalRewardSet(xp: 250, gold: 125)
            ),
            SeasonalChallenge(
                id: "summer_arena", title: "Arena Champion", description: "Win 5 arena matches during the trials",
                icon: "🏟️", type: .winArenaMatches, target: 5,
                rewards: SeasonalRewardSet(xp: 300, gold: 200)
            ),
            SeasonalChallenge(
                id: "summer_dungeons", title: "Dungeon Clearer", description: "Clear 3 dungeons during the trials",
                icon: "🏰", type: .clearDungeons, target: 3,
                rewards: SeasonalRewardSet(xp: 350, gold: 175)
            ),
            SeasonalChallenge(
                id: "summer_streak", title: "Summer Streak", description: "Reach a 10 battle win streak",
                icon: "🔥", type: .reachWinStreak, target: 10,
                rewards: SeasonalRewardSet(xp: 400, gold: 250)
            ),
            SeasonalChallenge(
                id: "summer_boss", title: "Inferno Slayer", description: "Defeat the Inferno Titan",
                icon: "🔥", type: .defeatEnemy, target: 1,
                rewards: SeasonalRewardSet(xp: 500, gold: 350, cosmeticId: "effect_fire_entry")
            )
        ],
        exclusiveEnemies: [
            BattleEncounter(
                enemyName: "Sun Elemental",
                enemyAvatar: "☀️",
                enemyDescription: "A blazing spirit of pure solar energy",
                enemyLevel: 8,
                enemyHP: 80,
                enemyMaxHP: 80,
                enemyAttack: 16,
                enemyDefense: 6,
                abilities: [
                    EnemyAbility(name: "Solar Flare", damage: 18, description: "A burst of blinding light", chance: 0.4),
                    EnemyAbility(name: "Heat Wave", damage: 12, description: "A wave of scorching heat", chance: 0.3,
                                 statusEffect: StatusEffect(type: .burn, duration: 2, value: 5))
                ],
                rewards: BattleRewards(xp: 70, gold: 40)
            ),
            BattleEncounter(
                enemyName: "Flame Knight",
                enemyAvatar: "🔥",
                enemyDescription: "A warrior clad in living flame armor",
                enemyLevel: 12,
                enemyHP: 140,
                enemyMaxHP: 140,
                enemyAttack: 22,
                enemyDefense: 12,
                abilities: [
                    EnemyAbility(name: "Flame Slash", damage: 25, description: "A burning sword strike", chance: 0.35,
                                 statusEffect: StatusEffect(type: .burn, duration: 2, value: 6)),
                    EnemyAbility(name: "Fire Shield", damage: 0, description: "Wraps in protective flames", chance: 0.2,
                                 statusEffect: StatusEffect(type: .shield, duration: 2, value: 12))
                ],
                rewards: BattleRewards(xp: 120, gold: 70)
            ),
            BattleEncounter(
                enemyName: "Inferno Titan",
                enemyAvatar: "🌋",
                enemyDescription: "A colossal being of pure volcanic fury",
                enemyLevel: 18,
                enemyHP: 250,
                enemyMaxHP: 250,
                enemyAttack: 30,
                enemyDefense: 15,
                isBoss: true,
                abilities: [
                    EnemyAbility(name: "Magma Eruption", damage: 35, description: "Molten rock rains down", chance: 0.3,
                                 statusEffect: StatusEffect(type: .burn, duration: 3, value: 8)),
                    EnemyAbility(name: "Titan Crush", damage: 28, description: "A devastating ground pound", chance: 0.3),
                    EnemyAbility(name: "Infernal Rage", damage: 0, description: "Enrages, boosting power", chance: 0.15,
                                 statusEffect: StatusEffect(type: .strengthen, duration: 3, value: 10))
                ],
                rewards: BattleRewards(xp: 300, gold: 200)
            )
        ],
        exclusiveItems: [
            Item(templateId: "summer_sunfire_blade", name: "Sunfire Blade", icon: "🗡️",
                 type: .weapon, rarity: .rare, levelRequirement: 10, buyPrice: 0, sellPrice: 120,
                 itemDescription: "A blade forged in the heart of the sun.",
                 statModifiers: [.strength: 6, .dexterity: 2], slot: .weapon),
            Item(templateId: "summer_flameguard", name: "Flameguard Shield", icon: "🛡️",
                 type: .armor, rarity: .rare, levelRequirement: 10, buyPrice: 0, sellPrice: 100,
                 itemDescription: "Armor infused with fire resistance.",
                 statModifiers: [.constitution: 5, .strength: 2], slot: .armor),
            Item(templateId: "summer_blazing_ring", name: "Blazing Ring", icon: "💍",
                 type: .accessory, rarity: .rare, buyPrice: 0, sellPrice: 90,
                 itemDescription: "A ring that burns with inner flame.",
                 statModifiers: [.strength: 3, .dexterity: 3], slot: .accessory)
        ]
    )

    // MARK: - Active Event
    static var activeEvent: SeasonalEvent? {
        allEvents.first(where: { $0.isActive })
    }
}
