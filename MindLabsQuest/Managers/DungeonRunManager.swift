import Foundation

class DungeonRunManager: ObservableObject {
    @Published var currentRun: DungeonRunState?
    @Published var dungeonProgress = DungeonProgress()

    private let progressKey = "dungeonProgress"
    private let runKey = "dungeonRunState"

    init() {
        loadProgress()
        loadCurrentRun()
    }

    // MARK: - Start Run

    func startRun(dungeon: Dungeon, character: Character) -> Bool {
        guard currentRun == nil else { return false }

        currentRun = DungeonRunState(
            dungeonId: dungeon.id,
            currentFloor: 0,
            playerHP: character.health,
            playerMaxHP: character.maxHealth,
            totalFloors: dungeon.floors.count
        )
        dungeonProgress.totalDungeonRuns += 1
        saveCurrentRun()
        saveProgress()
        return true
    }

    // MARK: - Current Floor

    func currentFloor(in dungeon: Dungeon) -> DungeonFloor? {
        guard let run = currentRun, run.isActive else { return nil }
        guard run.currentFloor < dungeon.floors.count else { return nil }
        return dungeon.floors[run.currentFloor]
    }

    func currentFloorEncounter(in dungeon: Dungeon, playerLevel: Int) -> BattleEncounter? {
        guard let floor = currentFloor(in: dungeon) else { return nil }

        guard let template = EnemyDatabase.allEnemies.first(where: { $0.id == floor.enemyTemplateId }) else {
            return nil
        }

        var encounter = template.encounter(atLevel: playerLevel)
        if floor.isBossFloor {
            encounter.isBoss = true
        }
        return encounter
    }

    // MARK: - Complete Floor

    func completeFloor(victory: Bool, remainingHP: Int, rewards: BattleRewards?) {
        guard var run = currentRun, run.isActive else { return }

        if victory {
            run.playerHP = remainingHP
            run.floorsCompleted += 1
            run.currentFloor += 1

            if let rewards = rewards {
                run.totalGoldEarned += rewards.gold
                run.totalXPEarned += rewards.xp
            }

            // Update best floor reached
            let currentBest = dungeonProgress.bestFloorReached[run.dungeonId] ?? 0
            if run.floorsCompleted > currentBest {
                dungeonProgress.bestFloorReached[run.dungeonId] = run.floorsCompleted
            }
            dungeonProgress.totalFloorsCleared += 1

            // Check if dungeon is complete
            if run.currentFloor >= run.totalFloors {
                run.isActive = false
                dungeonProgress.completedDungeonIds.insert(run.dungeonId)
            }
        } else {
            // Defeat — run ends
            run.isActive = false
        }

        currentRun = run
        saveCurrentRun()
        saveProgress()
    }

    // MARK: - Abandon Run

    func abandonRun() {
        currentRun = nil
        UserDefaults.standard.removeObject(forKey: runKey)
    }

    // MARK: - State Queries

    var isRunActive: Bool {
        currentRun?.isActive ?? false
    }

    var isRunComplete: Bool {
        guard let run = currentRun else { return false }
        return !run.isActive && run.floorsCompleted >= run.totalFloors
    }

    func canEnterDungeon(_ dungeon: Dungeon, playerLevel: Int) -> Bool {
        playerLevel >= dungeon.levelRequirement
    }

    // MARK: - Persistence

    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(dungeonProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let decoded = try? JSONDecoder().decode(DungeonProgress.self, from: data) else {
            return
        }
        dungeonProgress = decoded
    }

    private func saveCurrentRun() {
        if let run = currentRun {
            if let encoded = try? JSONEncoder().encode(run) {
                UserDefaults.standard.set(encoded, forKey: runKey)
            }
        } else {
            UserDefaults.standard.removeObject(forKey: runKey)
        }
    }

    private func loadCurrentRun() {
        guard let data = UserDefaults.standard.data(forKey: runKey),
              let decoded = try? JSONDecoder().decode(DungeonRunState.self, from: data) else {
            return
        }
        if decoded.isActive {
            currentRun = decoded
        }
    }
}
