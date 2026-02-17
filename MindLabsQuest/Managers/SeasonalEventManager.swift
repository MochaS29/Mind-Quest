import Foundation
import SwiftUI

class SeasonalEventManager: ObservableObject {
    @Published var activeEvent: SeasonalEvent?
    @Published var seasonalProgress: SeasonalProgress = SeasonalProgress()

    private let progressKey = "seasonalProgress"

    init() {
        loadData()
        refreshEvent()
    }

    // MARK: - Event Management
    func refreshEvent() {
        activeEvent = SeasonalEventDatabase.activeEvent
        if let event = activeEvent {
            // Mark participation
            seasonalProgress.participatedEventIds.insert(event.id)

            // Restore challenge progress from saved state
            if var event = activeEvent {
                for i in 0..<event.challenges.count {
                    let challengeId = event.challenges[i].id
                    if seasonalProgress.claimedRewardIds.contains(challengeId) {
                        event.challenges[i].isClaimed = true
                        event.challenges[i].progress = event.challenges[i].target
                    }
                }
                activeEvent = event
            }

            saveData()
        }
    }

    // MARK: - Progress Recording
    func recordBattleWin(enemyName: String) {
        guard activeEvent != nil else { return }
        updateChallengeProgress(type: .winBattles, increment: 1)

        // Check if it's a seasonal boss
        if let event = activeEvent {
            for challenge in event.challenges where challenge.type == .defeatEnemy {
                if event.exclusiveEnemies.contains(where: { $0.enemyName == enemyName }) {
                    updateChallengeProgress(for: challenge.id, increment: 1)
                }
            }
        }
    }

    func recordQuestComplete() {
        guard activeEvent != nil else { return }
        updateChallengeProgress(type: .completeQuests, increment: 1)
    }

    func recordCraft() {
        guard activeEvent != nil else { return }
        updateChallengeProgress(type: .craftItems, increment: 1)
    }

    func recordGoldEarned(_ amount: Int) {
        guard activeEvent != nil else { return }
        updateChallengeProgress(type: .earnGold, increment: amount)
    }

    func recordArenaWin() {
        guard activeEvent != nil else { return }
        updateChallengeProgress(type: .winArenaMatches, increment: 1)
    }

    func recordDungeonClear() {
        guard activeEvent != nil else { return }
        updateChallengeProgress(type: .clearDungeons, increment: 1)
    }

    func recordWinStreak(_ streak: Int) {
        guard var event = activeEvent else { return }
        for i in 0..<event.challenges.count {
            if event.challenges[i].type == .reachWinStreak && !event.challenges[i].isClaimed {
                event.challenges[i].progress = max(event.challenges[i].progress, streak)
                if event.challenges[i].isCompleted {
                    seasonalProgress.completedChallengeIds.insert(event.challenges[i].id)
                }
            }
        }
        activeEvent = event
        saveData()
    }

    // MARK: - Challenge Progress
    private func updateChallengeProgress(type: SeasonalChallengeType, increment: Int) {
        guard var event = activeEvent else { return }
        for i in 0..<event.challenges.count {
            if event.challenges[i].type == type && !event.challenges[i].isClaimed {
                event.challenges[i].progress += increment
                if event.challenges[i].isCompleted {
                    seasonalProgress.completedChallengeIds.insert(event.challenges[i].id)
                }
            }
        }
        activeEvent = event
        saveData()
    }

    private func updateChallengeProgress(for challengeId: String, increment: Int) {
        guard var event = activeEvent else { return }
        if let idx = event.challenges.firstIndex(where: { $0.id == challengeId }) {
            if !event.challenges[idx].isClaimed {
                event.challenges[idx].progress += increment
                if event.challenges[idx].isCompleted {
                    seasonalProgress.completedChallengeIds.insert(challengeId)
                }
            }
        }
        activeEvent = event
        saveData()
    }

    // MARK: - Reward Claiming
    func claimReward(challengeId: String) -> SeasonalRewardSet? {
        guard var event = activeEvent,
              let idx = event.challenges.firstIndex(where: { $0.id == challengeId }),
              event.challenges[idx].isCompleted,
              !event.challenges[idx].isClaimed else { return nil }

        let rewards = event.challenges[idx].rewards
        event.challenges[idx].isClaimed = true
        seasonalProgress.claimedRewardIds.insert(challengeId)
        activeEvent = event

        HapticService.notification(.success)
        saveData()
        return rewards
    }

    // MARK: - Seasonal Encounter
    func getSeasonalEncounter(playerLevel: Int) -> BattleEncounter? {
        guard let event = activeEvent else { return nil }
        let eligible = event.exclusiveEnemies.filter { $0.enemyLevel <= playerLevel + 3 }
        return eligible.randomElement()
    }

    // MARK: - Computed
    var completedChallengeCount: Int {
        guard let event = activeEvent else { return 0 }
        return event.challenges.filter { $0.isCompleted }.count
    }

    var totalChallengeCount: Int {
        activeEvent?.challenges.count ?? 0
    }

    // MARK: - Persistence
    func saveData() {
        if let encoded = try? JSONEncoder().encode(seasonalProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
        // Save active challenge progress separately
        if let event = activeEvent {
            let progressDict = Dictionary(uniqueKeysWithValues: event.challenges.map { ($0.id, $0.progress) })
            if let encoded = try? JSONEncoder().encode(progressDict) {
                UserDefaults.standard.set(encoded, forKey: "seasonalChallengeProgress_\(event.id)")
            }
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(SeasonalProgress.self, from: data) {
            seasonalProgress = decoded
        }
    }

    func loadChallengeProgress(for eventId: String) {
        guard var event = activeEvent, event.id == eventId else { return }
        if let data = UserDefaults.standard.data(forKey: "seasonalChallengeProgress_\(eventId)"),
           let progressDict = try? JSONDecoder().decode([String: Int].self, from: data) {
            for i in 0..<event.challenges.count {
                if let saved = progressDict[event.challenges[i].id] {
                    event.challenges[i].progress = saved
                }
                if seasonalProgress.claimedRewardIds.contains(event.challenges[i].id) {
                    event.challenges[i].isClaimed = true
                }
            }
            activeEvent = event
        }
    }

    func resetAll() {
        seasonalProgress = SeasonalProgress()
        activeEvent = nil
        UserDefaults.standard.removeObject(forKey: progressKey)
    }
}
