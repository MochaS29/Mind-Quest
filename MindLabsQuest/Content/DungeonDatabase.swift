import Foundation

struct DungeonDatabase {
    static let allDungeons: [Dungeon] = [forestCrypt, shadowMine, frozenCavern]

    static func dungeon(byId id: String) -> Dungeon? {
        allDungeons.first { $0.id == id }
    }

    // MARK: - Forest Crypt (Tier 1, Level 3+)
    static let forestCrypt = Dungeon(
        id: "dungeon_forest_crypt",
        name: "Forest Crypt",
        description: "An ancient crypt hidden beneath the forest floor, overrun by creatures of moss and shadow.",
        icon: "tree",
        floors: [
            DungeonFloor(
                id: "forest_crypt_f1",
                floorNumber: 1,
                enemyTemplateId: "enemy_moss_goblin",
                flavorText: "Damp stone corridors stretch before you..."
            ),
            DungeonFloor(
                id: "forest_crypt_f2",
                floorNumber: 2,
                enemyTemplateId: "enemy_cave_spider",
                flavorText: "Webs cover every surface..."
            ),
            DungeonFloor(
                id: "forest_crypt_f3",
                floorNumber: 3,
                enemyTemplateId: "enemy_bark_sentinel",
                isBossFloor: true,
                flavorText: "A massive wooden guardian blocks the exit!"
            )
        ],
        energyCost: 3,
        levelRequirement: 3
    )

    // MARK: - Shadow Mine (Tier 2, Level 6+)
    static let shadowMine = Dungeon(
        id: "dungeon_shadow_mine",
        name: "Shadow Mine",
        description: "A long-abandoned mine now infested with dark creatures and corrupted soldiers.",
        icon: "hammer",
        floors: [
            DungeonFloor(
                id: "shadow_mine_f1",
                floorNumber: 1,
                enemyTemplateId: "enemy_shadow_stalker",
                flavorText: "The mine shaft descends into darkness..."
            ),
            DungeonFloor(
                id: "shadow_mine_f2",
                floorNumber: 2,
                enemyTemplateId: "enemy_frost_imp",
                flavorText: "Frozen crystals line the walls..."
            ),
            DungeonFloor(
                id: "shadow_mine_f3",
                floorNumber: 3,
                enemyTemplateId: "enemy_corrupted_knight",
                flavorText: "An armored figure guards a narrow passage..."
            ),
            DungeonFloor(
                id: "shadow_mine_f4",
                floorNumber: 4,
                enemyTemplateId: "enemy_crystal_golem",
                flavorText: "The cavern glows with crystalline light..."
            ),
            DungeonFloor(
                id: "shadow_mine_f5",
                floorNumber: 5,
                enemyTemplateId: "enemy_shadow_stalker",
                isBossFloor: true,
                flavorText: "The Shadow Stalker alpha emerges!"
            )
        ],
        energyCost: 4,
        levelRequirement: 6
    )

    // MARK: - Frozen Cavern (Tier 3, Level 10+)
    static let frozenCavern = Dungeon(
        id: "dungeon_frozen_cavern",
        name: "Frozen Cavern",
        description: "A cavern of eternal ice ruled by the fearsome Frost Queen, Glaciara.",
        icon: "snowflake",
        floors: [
            DungeonFloor(
                id: "frozen_cavern_f1",
                floorNumber: 1,
                enemyTemplateId: "enemy_ice_revenant",
                flavorText: "Bitter cold cuts through your armor..."
            ),
            DungeonFloor(
                id: "frozen_cavern_f2",
                floorNumber: 2,
                enemyTemplateId: "enemy_storm_harpy",
                flavorText: "Wind howls through icy tunnels..."
            ),
            DungeonFloor(
                id: "frozen_cavern_f3",
                floorNumber: 3,
                enemyTemplateId: "enemy_bone_construct",
                flavorText: "Frozen bones animate in the darkness..."
            ),
            DungeonFloor(
                id: "frozen_cavern_f4",
                floorNumber: 4,
                enemyTemplateId: "enemy_plague_bearer",
                flavorText: "A noxious fog fills the chamber..."
            ),
            DungeonFloor(
                id: "frozen_cavern_f5",
                floorNumber: 5,
                enemyTemplateId: "boss_glaciara",
                isBossFloor: true,
                flavorText: "Glaciara, the Frost Queen, awaits on her frozen throne!"
            )
        ],
        energyCost: 5,
        levelRequirement: 10
    )
}
