import SwiftUI

// MARK: - Daily Challenge Manager
class DailyChallengeManager: ObservableObject {
    @Published var activeChallenges: [DailyChallenge] = []
    @Published var lastRefreshDate: Date?

    private let persistenceKey = "dailyChallengeProgress"

    init() {
        loadProgress()
    }

    // MARK: - Refresh Challenges

    func refreshIfNeeded(playerLevel: Int) {
        let today = Calendar.current.startOfDay(for: Date())

        // Skip if already refreshed today
        if let lastRefresh = lastRefreshDate,
           Calendar.current.isDate(lastRefresh, inSameDayAs: today) {
            return
        }

        // Date-seeded RNG for deterministic daily selection
        let dateHash = UInt64(today.timeIntervalSince1970)
        var rng = SeedableRNG(seed: dateHash &+ 7919) // offset from ShopManager seed

        // Shuffle all templates with seeded RNG
        var templates = DailyChallengeTemplate.allTemplates
        for i in stride(from: templates.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            templates.swapAt(i, j)
        }

        // Pick 3 challenges for today
        let selected = Array(templates.prefix(3))
        activeChallenges = selected.map { $0.challenge(forLevel: playerLevel, date: today) }
        lastRefreshDate = today
        saveProgress()
    }

    // MARK: - Progress Tracking

    func recordKill() {
        updateProgress(for: .killEnemies, amount: 1)
    }

    func recordDamage(_ amount: Int) {
        updateProgress(for: .dealDamage, amount: amount)
    }

    func recordBattleWin() {
        updateProgress(for: .winBattles, amount: 1)
    }

    func recordItemUsed() {
        updateProgress(for: .useItems, amount: 1)
    }

    func recordQuestComplete() {
        updateProgress(for: .completeQuests, amount: 1)
    }

    func recordGoldEarned(_ amount: Int) {
        updateProgress(for: .earnGold, amount: amount)
    }

    private func updateProgress(for type: DailyChallengeType, amount: Int) {
        for i in activeChallenges.indices {
            if activeChallenges[i].type == type && !activeChallenges[i].isClaimed {
                activeChallenges[i].progress = min(
                    activeChallenges[i].progress + amount,
                    activeChallenges[i].target
                )
            }
        }
        saveProgress()
    }

    // MARK: - Claim Rewards

    func claimReward(_ challengeId: String) -> ChallengeRewards? {
        guard let index = activeChallenges.firstIndex(where: { $0.id == challengeId }) else {
            return nil
        }

        let challenge = activeChallenges[index]
        guard challenge.isCompleted && !challenge.isClaimed else {
            return nil
        }

        activeChallenges[index].isClaimed = true
        saveProgress()
        return challenge.rewards
    }

    // MARK: - Computed Properties

    var allClaimed: Bool {
        activeChallenges.allSatisfy { $0.isClaimed }
    }

    var completedCount: Int {
        activeChallenges.filter { $0.isCompleted }.count
    }

    var timeUntilRefresh: TimeInterval {
        let now = Date()
        let tomorrow = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: now)!
        )
        return tomorrow.timeIntervalSince(now)
    }

    var formattedTimeUntilRefresh: String {
        let remaining = timeUntilRefresh
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }

    // MARK: - Persistence

    private func saveProgress() {
        let data = DailyChallengeData(
            challenges: activeChallenges,
            lastRefreshDate: lastRefreshDate
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        }
    }

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey),
              let decoded = try? JSONDecoder().decode(DailyChallengeData.self, from: data) else {
            return
        }

        activeChallenges = decoded.challenges
        lastRefreshDate = decoded.lastRefreshDate
    }
}

// MARK: - Persistence Data
private struct DailyChallengeData: Codable {
    var challenges: [DailyChallenge]
    var lastRefreshDate: Date?
}
