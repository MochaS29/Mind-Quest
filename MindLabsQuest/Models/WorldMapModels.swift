import Foundation
import SwiftUI

// MARK: - Region Biome
enum RegionBiome: String, CaseIterable, Codable {
    case village, forest, academy, springs, arena, hollow, city, frozen, shadow, wastes, boundary

    var icon: String {
        switch self {
        case .village: return "house.fill"
        case .forest: return "leaf.fill"
        case .academy: return "book.fill"
        case .springs: return "drop.fill"
        case .arena: return "figure.martial.arts"
        case .hollow: return "moon.fill"
        case .city: return "building.2.fill"
        case .frozen: return "snowflake"
        case .shadow: return "eye.fill"
        case .wastes: return "flame.fill"
        case .boundary: return "sparkles"
        }
    }

    var primaryColor: Color {
        switch self {
        case .village: return Color(red: 0.6, green: 0.8, blue: 0.5)
        case .forest: return Color(red: 0.2, green: 0.6, blue: 0.3)
        case .academy: return Color(red: 0.4, green: 0.5, blue: 0.9)
        case .springs: return Color(red: 0.3, green: 0.7, blue: 0.9)
        case .arena: return Color(red: 0.9, green: 0.5, blue: 0.2)
        case .hollow: return Color(red: 0.4, green: 0.2, blue: 0.5)
        case .city: return Color(red: 0.8, green: 0.7, blue: 0.3)
        case .frozen: return Color(red: 0.7, green: 0.85, blue: 0.95)
        case .shadow: return Color(red: 0.3, green: 0.1, blue: 0.3)
        case .wastes: return Color(red: 0.7, green: 0.3, blue: 0.1)
        case .boundary: return Color(red: 0.6, green: 0.4, blue: 0.8)
        }
    }

    var accentColor: Color {
        switch self {
        case .village: return Color(red: 0.9, green: 0.7, blue: 0.4)
        case .forest: return Color(red: 0.5, green: 0.8, blue: 0.4)
        case .academy: return Color(red: 0.7, green: 0.6, blue: 1.0)
        case .springs: return Color(red: 0.5, green: 0.9, blue: 1.0)
        case .arena: return Color(red: 1.0, green: 0.7, blue: 0.3)
        case .hollow: return Color(red: 0.6, green: 0.3, blue: 0.7)
        case .city: return Color(red: 1.0, green: 0.9, blue: 0.5)
        case .frozen: return Color(red: 0.85, green: 0.95, blue: 1.0)
        case .shadow: return Color(red: 0.5, green: 0.2, blue: 0.5)
        case .wastes: return Color(red: 0.9, green: 0.5, blue: 0.2)
        case .boundary: return Color(red: 0.8, green: 0.6, blue: 1.0)
        }
    }
}

// MARK: - Map Position
struct MapPosition: Codable {
    let x: Double
    let y: Double
}

// MARK: - Region Unlock Requirements
struct RegionUnlockRequirements: Codable {
    var minimumLevel: Int = 1
    var requiredRegionIds: [String] = []
    var requiredChapterIds: [String] = []
}

// MARK: - Landmark Type
enum LandmarkType: String, CaseIterable, Codable {
    case shop, arena, dungeon, npc, crafting, merchant
}

// MARK: - Map Landmark
struct MapLandmark: Identifiable, Codable {
    var id: String
    var name: String
    var icon: String
    var type: LandmarkType
    var regionId: String
}

// MARK: - Map Region
struct MapRegion: Identifiable, Codable {
    var id: String
    var name: String
    var subtitle: String
    var biome: RegionBiome
    var levelRange: ClosedRange<Int>
    var position: MapPosition
    var isDiscovered: Bool = false
    var isUnlocked: Bool = false
    var connectedRegionIds: [String]
    var taskCategory: TaskCategory?
    var storyChapterIds: [String] = []
    var dungeonIds: [String] = []
    var enemyTemplateIds: [String] = []
    var landmarkIds: [String] = []
    var unlockRequirements: RegionUnlockRequirements = RegionUnlockRequirements()
    var backgroundColorHex: String = ""
    var icon: String

    // Codable support for ClosedRange<Int>
    enum CodingKeys: String, CodingKey {
        case id, name, subtitle, biome, levelMin, levelMax, position
        case isDiscovered, isUnlocked, connectedRegionIds, taskCategory
        case storyChapterIds, dungeonIds, enemyTemplateIds, landmarkIds
        case unlockRequirements, backgroundColorHex, icon
    }

    init(id: String, name: String, subtitle: String, biome: RegionBiome, levelRange: ClosedRange<Int>, position: MapPosition, isDiscovered: Bool = false, isUnlocked: Bool = false, connectedRegionIds: [String], taskCategory: TaskCategory? = nil, storyChapterIds: [String] = [], dungeonIds: [String] = [], enemyTemplateIds: [String] = [], landmarkIds: [String] = [], unlockRequirements: RegionUnlockRequirements = RegionUnlockRequirements(), backgroundColorHex: String = "", icon: String) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.biome = biome
        self.levelRange = levelRange
        self.position = position
        self.isDiscovered = isDiscovered
        self.isUnlocked = isUnlocked
        self.connectedRegionIds = connectedRegionIds
        self.taskCategory = taskCategory
        self.storyChapterIds = storyChapterIds
        self.dungeonIds = dungeonIds
        self.enemyTemplateIds = enemyTemplateIds
        self.landmarkIds = landmarkIds
        self.unlockRequirements = unlockRequirements
        self.backgroundColorHex = backgroundColorHex
        self.icon = icon
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        subtitle = try c.decode(String.self, forKey: .subtitle)
        biome = try c.decode(RegionBiome.self, forKey: .biome)
        let min = try c.decode(Int.self, forKey: .levelMin)
        let max = try c.decode(Int.self, forKey: .levelMax)
        levelRange = min...max
        position = try c.decode(MapPosition.self, forKey: .position)
        isDiscovered = try c.decodeIfPresent(Bool.self, forKey: .isDiscovered) ?? false
        isUnlocked = try c.decodeIfPresent(Bool.self, forKey: .isUnlocked) ?? false
        connectedRegionIds = try c.decode([String].self, forKey: .connectedRegionIds)
        taskCategory = try c.decodeIfPresent(TaskCategory.self, forKey: .taskCategory)
        storyChapterIds = try c.decodeIfPresent([String].self, forKey: .storyChapterIds) ?? []
        dungeonIds = try c.decodeIfPresent([String].self, forKey: .dungeonIds) ?? []
        enemyTemplateIds = try c.decodeIfPresent([String].self, forKey: .enemyTemplateIds) ?? []
        landmarkIds = try c.decodeIfPresent([String].self, forKey: .landmarkIds) ?? []
        unlockRequirements = try c.decodeIfPresent(RegionUnlockRequirements.self, forKey: .unlockRequirements) ?? RegionUnlockRequirements()
        backgroundColorHex = try c.decodeIfPresent(String.self, forKey: .backgroundColorHex) ?? ""
        icon = try c.decode(String.self, forKey: .icon)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(subtitle, forKey: .subtitle)
        try c.encode(biome, forKey: .biome)
        try c.encode(levelRange.lowerBound, forKey: .levelMin)
        try c.encode(levelRange.upperBound, forKey: .levelMax)
        try c.encode(position, forKey: .position)
        try c.encode(isDiscovered, forKey: .isDiscovered)
        try c.encode(isUnlocked, forKey: .isUnlocked)
        try c.encode(connectedRegionIds, forKey: .connectedRegionIds)
        try c.encodeIfPresent(taskCategory, forKey: .taskCategory)
        try c.encode(storyChapterIds, forKey: .storyChapterIds)
        try c.encode(dungeonIds, forKey: .dungeonIds)
        try c.encode(enemyTemplateIds, forKey: .enemyTemplateIds)
        try c.encode(landmarkIds, forKey: .landmarkIds)
        try c.encode(unlockRequirements, forKey: .unlockRequirements)
        try c.encode(backgroundColorHex, forKey: .backgroundColorHex)
        try c.encode(icon, forKey: .icon)
    }
}

// MARK: - World Map Progress
struct WorldMapProgress: Codable {
    var discoveredRegionIds: Set<String> = ["millbrook_village"]
    var unlockedRegionIds: Set<String> = ["millbrook_village"]
    var dailyRegionEnergy: [String: Int] = [:]
    var lastDailyResetDate: Date?
    var totalRegionsDiscovered: Int = 1
}
