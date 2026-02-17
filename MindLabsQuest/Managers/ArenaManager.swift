import Foundation
import SwiftUI

class ArenaManager: ObservableObject {
    @Published var stats: ArenaStats = ArenaStats()

    private let persistenceKey = "arenaStats"

    init() {
        loadData()
    }

    // MARK: - Opponent Generation
    func generateOpponent(playerLevel: Int, playerRating: Int, playerClass: CharacterClass?) -> ArenaOpponent {
        let levelOffset = Int.random(in: -2...2)
        let opponentLevel = max(1, playerLevel + levelOffset)

        let ratingOffset = Int.random(in: -200...200)
        let opponentRating = max(0, playerRating + ratingOffset)

        // 70% chance of different class
        let allClasses = CharacterClass.allCases
        let opponentClass: CharacterClass
        if let pc = playerClass, Double.random(in: 0...1) < 0.7 {
            let otherClasses = allClasses.filter { $0 != pc }
            opponentClass = otherClasses.randomElement() ?? allClasses.randomElement()!
        } else {
            opponentClass = allClasses.randomElement()!
        }

        // Generate stats: base 10 + class bonus + level scaling
        var opponentStats: [StatType: Int] = [:]
        let classBonuses = opponentClass.statBonuses
        for stat in StatType.allCases {
            let base = 10
            let classBonus = classBonuses[stat] ?? 0
            let levelBonus = opponentLevel / 3
            opponentStats[stat] = base + classBonus + levelBonus
        }

        // Generate equipment from ItemDatabase
        let eligibleItems = ItemDatabase.allShopItems.filter {
            $0.levelRequirement <= opponentLevel && $0.type != .consumable && $0.type != .material && $0.type != .questItem
        }

        var loadout = EquipmentLoadout()
        if let weapon = eligibleItems.filter({ $0.slot == .weapon }).randomElement() {
            loadout.weapon = weapon
        }
        if let armor = eligibleItems.filter({ $0.slot == .armor }).randomElement() {
            loadout.armor = armor
        }
        if let accessory = eligibleItems.filter({ $0.slot == .accessory }).randomElement() {
            loadout.accessory = accessory
        }

        let name = ArenaNameBank.randomName()
        let avatar = opponentClass.icon

        return ArenaOpponent(
            name: name,
            characterClass: opponentClass,
            level: opponentLevel,
            avatar: avatar,
            rating: opponentRating,
            rank: ArenaRank.rank(for: opponentRating),
            equipment: loadout,
            stats: opponentStats
        )
    }

    // MARK: - Rating Calculation (Elo)
    func calculateRatingChange(playerRating: Int, opponentRating: Int, victory: Bool) -> Int {
        let k: Double = 32.0
        let expected = 1.0 / (1.0 + pow(10.0, Double(opponentRating - playerRating) / 400.0))
        let score: Double = victory ? 1.0 : 0.0
        let change = Int(round(k * (score - expected)))

        // Minimum change of +-5
        if victory {
            return max(5, change)
        } else {
            return min(-5, change)
        }
    }

    // MARK: - Token Calculation
    func calculateTokensEarned(rank: ArenaRank, winStreak: Int) -> Int {
        let baseTokens: Int
        switch rank {
        case .bronze: baseTokens = 10
        case .silver: baseTokens = 15
        case .gold: baseTokens = 20
        case .diamond: baseTokens = 30
        case .champion: baseTokens = 40
        }

        let streakBonus = min(25, winStreak * 5)
        return baseTokens + streakBonus
    }

    // MARK: - Complete Arena Match
    @discardableResult
    func completeArenaMatch(victory: Bool, opponent: ArenaOpponent) -> ArenaMatchResult {
        let ratingChange = calculateRatingChange(
            playerRating: stats.rating,
            opponentRating: opponent.rating,
            victory: victory
        )

        stats.rating = max(0, stats.rating + ratingChange)
        stats.highestRating = max(stats.highestRating, stats.rating)

        var tokensEarned = 0
        if victory {
            stats.totalWins += 1
            stats.currentWinStreak += 1
            stats.highestWinStreak = max(stats.highestWinStreak, stats.currentWinStreak)
            tokensEarned = calculateTokensEarned(rank: stats.rank, winStreak: stats.currentWinStreak)
            stats.arenaTokens += tokensEarned
        } else {
            stats.totalLosses += 1
            stats.currentWinStreak = 0
        }

        let result = ArenaMatchResult(
            opponentName: opponent.name,
            opponentClass: opponent.characterClass,
            opponentLevel: opponent.level,
            opponentRank: opponent.rank,
            victory: victory,
            ratingChange: ratingChange,
            tokensEarned: tokensEarned
        )

        stats.addMatchResult(result)
        saveData()
        return result
    }

    // MARK: - Token Spending
    @discardableResult
    func spendTokens(_ amount: Int) -> Bool {
        guard stats.arenaTokens >= amount else { return false }
        stats.arenaTokens -= amount
        saveData()
        return true
    }

    // MARK: - Persistence
    func saveData() {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: persistenceKey),
           let decoded = try? JSONDecoder().decode(ArenaStats.self, from: data) {
            stats = decoded
        }
    }
}
