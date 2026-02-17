import Foundation

// MARK: - Dungeon
struct Dungeon: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var icon: String
    var floors: [DungeonFloor]
    var energyCost: Int
    var levelRequirement: Int
}

// MARK: - Dungeon Floor
struct DungeonFloor: Identifiable, Codable {
    var id: String
    var floorNumber: Int
    var enemyTemplateId: String   // references EnemyDatabase
    var isBossFloor: Bool = false
    var flavorText: String?
}

// MARK: - Dungeon Run State
struct DungeonRunState: Codable {
    var dungeonId: String
    var currentFloor: Int = 0
    var playerHP: Int
    var playerMaxHP: Int
    var totalFloors: Int
    var isActive: Bool = true
    var floorsCompleted: Int = 0
    var totalGoldEarned: Int = 0
    var totalXPEarned: Int = 0
    var itemsCollected: Int = 0
}

// MARK: - Dungeon Progress (persisted)
struct DungeonProgress: Codable {
    var completedDungeonIds: Set<String> = []
    var totalDungeonRuns: Int = 0
    var totalFloorsCleared: Int = 0
    var bestFloorReached: [String: Int] = [:]  // dungeonId -> highest floor
}
