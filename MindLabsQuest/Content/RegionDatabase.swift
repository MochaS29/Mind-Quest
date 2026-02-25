import Foundation

struct RegionDatabase {

    // MARK: - All Regions

    static let millbrookVillage = MapRegion(
        id: "millbrook_village",
        name: "Millbrook Village",
        subtitle: "Your home and starting point",
        biome: .village,
        levelRange: 1...3,
        position: MapPosition(x: 0.5, y: 0.08),
        isDiscovered: true,
        isUnlocked: true,
        connectedRegionIds: ["whispering_woods", "academy_starlight"],
        storyChapterIds: ["chapter1"],
        enemyTemplateIds: ["enemy_whiskered_rat", "enemy_shadow_wisp", "enemy_moss_goblin"],
        landmarkIds: ["landmark_village_shop"],
        icon: "house.fill"
    )

    static let whisperingWoods = MapRegion(
        id: "whispering_woods",
        name: "Whispering Woods",
        subtitle: "Ancient forest of chores and duties",
        biome: .forest,
        levelRange: 1...5,
        position: MapPosition(x: 0.25, y: 0.22),
        connectedRegionIds: ["millbrook_village", "crystal_springs", "cursed_hollow"],
        taskCategory: .lifeSkills,
        dungeonIds: ["forest_crypt"],
        enemyTemplateIds: ["enemy_cave_spider", "enemy_emerald_slime", "enemy_bark_sentinel"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 1, requiredRegionIds: ["millbrook_village"]),
        icon: "leaf.fill"
    )

    static let academyStarlight = MapRegion(
        id: "academy_starlight",
        name: "Academy of Starlight",
        subtitle: "Where knowledge illuminates the mind",
        biome: .academy,
        levelRange: 3...8,
        position: MapPosition(x: 0.75, y: 0.22),
        connectedRegionIds: ["millbrook_village", "training_grounds", "cursed_hollow"],
        taskCategory: .academic,
        enemyTemplateIds: ["enemy_shadow_stalker", "enemy_frost_imp", "enemy_crystal_golem"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 3, requiredRegionIds: ["millbrook_village"]),
        icon: "book.fill"
    )

    static let crystalSprings = MapRegion(
        id: "crystal_springs",
        name: "Crystal Springs",
        subtitle: "Healing waters of self-care",
        biome: .springs,
        levelRange: 5...10,
        position: MapPosition(x: 0.2, y: 0.38),
        connectedRegionIds: ["whispering_woods", "starfall_city", "frozen_reach"],
        taskCategory: .health,
        enemyTemplateIds: ["enemy_vine_weaver", "enemy_ember_hound"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 5, requiredRegionIds: ["whispering_woods"]),
        icon: "drop.fill"
    )

    static let trainingGrounds = MapRegion(
        id: "training_grounds",
        name: "Training Grounds",
        subtitle: "Proving grounds for the strong",
        biome: .arena,
        levelRange: 3...10,
        position: MapPosition(x: 0.8, y: 0.38),
        connectedRegionIds: ["academy_starlight", "starfall_city", "ash_wastes"],
        taskCategory: .fitness,
        dungeonIds: ["shadow_mine"],
        enemyTemplateIds: ["enemy_corrupted_knight", "enemy_storm_harpy"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 3, requiredRegionIds: ["academy_starlight"]),
        icon: "figure.martial.arts"
    )

    static let cursedHollow = MapRegion(
        id: "cursed_hollow",
        name: "Cursed Hollow",
        subtitle: "A dark place steeped in shadow",
        biome: .hollow,
        levelRange: 5...8,
        position: MapPosition(x: 0.5, y: 0.42),
        connectedRegionIds: ["whispering_woods", "academy_starlight", "starfall_city"],
        storyChapterIds: ["chapter2A", "chapter2B"],
        enemyTemplateIds: ["enemy_shadow_stalker", "enemy_bone_construct"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 5, requiredRegionIds: ["whispering_woods", "academy_starlight"]),
        icon: "moon.fill"
    )

    static let starfallCity = MapRegion(
        id: "starfall_city",
        name: "Starfall City",
        subtitle: "Hub of creativity and connection",
        biome: .city,
        levelRange: 5...12,
        position: MapPosition(x: 0.5, y: 0.55),
        connectedRegionIds: ["crystal_springs", "training_grounds", "cursed_hollow", "shadow_citadel"],
        taskCategory: .social,
        storyChapterIds: ["chapter3"],
        enemyTemplateIds: ["enemy_thunder_drake", "enemy_plague_bearer"],
        landmarkIds: ["landmark_arena", "landmark_merchant"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 5, requiredRegionIds: ["cursed_hollow"]),
        icon: "building.2.fill"
    )

    static let frozenReach = MapRegion(
        id: "frozen_reach",
        name: "Frozen Reach",
        subtitle: "Lands of eternal frost",
        biome: .frozen,
        levelRange: 12...15,
        position: MapPosition(x: 0.2, y: 0.7),
        connectedRegionIds: ["crystal_springs", "shadow_citadel"],
        storyChapterIds: ["chapter4A"],
        dungeonIds: ["frozen_cavern"],
        enemyTemplateIds: ["enemy_ice_revenant", "enemy_frost_wyrm"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 12, requiredRegionIds: ["crystal_springs"]),
        icon: "snowflake"
    )

    static let shadowCitadel = MapRegion(
        id: "shadow_citadel",
        name: "Shadow Citadel",
        subtitle: "Fortress of the shadow empire",
        biome: .shadow,
        levelRange: 15...18,
        position: MapPosition(x: 0.5, y: 0.75),
        connectedRegionIds: ["starfall_city", "frozen_reach", "ash_wastes", "the_boundary"],
        storyChapterIds: ["chapter4B"],
        enemyTemplateIds: ["enemy_shadow_lord", "enemy_lich_acolyte"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 15, requiredRegionIds: ["starfall_city", "frozen_reach"]),
        icon: "eye.fill"
    )

    static let ashWastes = MapRegion(
        id: "ash_wastes",
        name: "Ash Wastes",
        subtitle: "Scorched lands of fire and fury",
        biome: .wastes,
        levelRange: 13...16,
        position: MapPosition(x: 0.8, y: 0.7),
        connectedRegionIds: ["training_grounds", "shadow_citadel"],
        enemyTemplateIds: ["enemy_inferno_titan", "enemy_celestial_guardian"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 13, requiredRegionIds: ["training_grounds"]),
        icon: "flame.fill"
    )

    static let theBoundary = MapRegion(
        id: "the_boundary",
        name: "The Boundary",
        subtitle: "The edge of all known realms",
        biome: .boundary,
        levelRange: 18...25,
        position: MapPosition(x: 0.5, y: 0.92),
        connectedRegionIds: ["shadow_citadel"],
        enemyTemplateIds: ["boss_mindflayer", "boss_ignaroth", "boss_glaciara", "boss_nyx", "boss_solara"],
        unlockRequirements: RegionUnlockRequirements(minimumLevel: 18, requiredRegionIds: ["shadow_citadel"]),
        icon: "sparkles"
    )

    // MARK: - Collections

    static let allRegions: [MapRegion] = [
        millbrookVillage, whisperingWoods, academyStarlight,
        crystalSprings, trainingGrounds, cursedHollow,
        starfallCity, frozenReach, shadowCitadel,
        ashWastes, theBoundary
    ]

    // MARK: - Query Methods

    static func region(byId id: String) -> MapRegion? {
        allRegions.first { $0.id == id }
    }

    static func regions(forCategory category: TaskCategory) -> [MapRegion] {
        allRegions.filter { $0.taskCategory == category }
    }

    static func connectedRegions(from regionId: String) -> [MapRegion] {
        guard let current = region(byId: regionId) else { return [] }
        return current.connectedRegionIds.compactMap { region(byId: $0) }
    }

    static func enemies(forRegion regionId: String, playerLevel: Int) -> [EnemyTemplate] {
        guard let current = region(byId: regionId) else { return [] }
        return current.enemyTemplateIds.compactMap { templateId in
            EnemyDatabase.allEnemies.first { $0.id == templateId }
        }.filter { $0.levelRange.overlaps(current.levelRange) }
    }

    static let categoryRegionMap: [TaskCategory: String] = [
        .lifeSkills: "whispering_woods",
        .academic: "academy_starlight",
        .health: "crystal_springs",
        .fitness: "training_grounds",
        .social: "starfall_city",
        .creative: "starfall_city"
    ]

    static func regionId(forCategory category: TaskCategory) -> String? {
        categoryRegionMap[category]
    }
}
