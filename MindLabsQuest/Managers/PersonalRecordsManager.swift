import Foundation
import SwiftUI

class PersonalRecordsManager: ObservableObject {
    @Published var records: PersonalRecords = PersonalRecords()
    @Published var badges: [RecordBadge] = BadgeDatabase.allBadges

    private let recordsKey = "personalRecords"
    private let badgesKey = "personalBadges"

    init() {
        loadData()
    }

    // MARK: - Battle Records
    func recordBattleWin(damageDealt: Int, goldEarned: Int, duration: TimeInterval? = nil) {
        records.totalBattlesWon += 1
        records.totalDamageDealt += damageDealt
        records.currentBattleWinStreak += 1
        records.longestBattleWinStreak = max(records.longestBattleWinStreak, records.currentBattleWinStreak)
        records.totalGoldEarned += goldEarned
        records.mostGoldInOneBattle = max(records.mostGoldInOneBattle, goldEarned)

        if let duration = duration {
            if let fastest = records.fastestBattleWin {
                records.fastestBattleWin = min(fastest, duration)
            } else {
                records.fastestBattleWin = duration
            }
        }

        checkBadgeUnlocks()
        saveData()
    }

    func recordBattleLoss() {
        records.totalBattlesLost += 1
        records.currentBattleWinStreak = 0
        checkBadgeUnlocks()
        saveData()
    }

    func recordHighestHit(_ damage: Int) {
        if damage > records.highestSingleHit {
            records.highestSingleHit = damage
            checkBadgeUnlocks()
            saveData()
        }
    }

    // MARK: - Arena Records
    func recordArenaResult(victory: Bool, newRating: Int) {
        if victory {
            records.arenaWins += 1
        } else {
            records.arenaLosses += 1
        }
        records.highestArenaRating = max(records.highestArenaRating, newRating)
        checkBadgeUnlocks()
        saveData()
    }

    // MARK: - Quest Records
    func recordQuestCompleted() {
        records.totalQuestsCompleted += 1
        checkBadgeUnlocks()
        saveData()
    }

    // MARK: - Economy Records
    func recordGoldSpent(_ amount: Int) {
        records.totalGoldSpent += amount
        saveData()
    }

    func recordItemPurchased() {
        records.itemsPurchased += 1
        checkBadgeUnlocks()
        saveData()
    }

    func recordItemSold() {
        records.itemsSold += 1
        saveData()
    }

    func recordBarterTrade() {
        records.barterTradesCompleted += 1
        checkBadgeUnlocks()
        saveData()
    }

    // MARK: - Dungeon Records
    func recordDungeonClear(floor: Int, duration: TimeInterval? = nil) {
        records.totalDungeonClears += 1
        records.highestFloor = max(records.highestFloor, floor)

        if let duration = duration {
            if let fastest = records.fastestDungeonClear {
                records.fastestDungeonClear = min(fastest, duration)
            } else {
                records.fastestDungeonClear = duration
            }
        }

        checkBadgeUnlocks()
        saveData()
    }

    // MARK: - General Records
    func recordLevelReached(_ level: Int) {
        records.highestLevel = max(records.highestLevel, level)
        checkBadgeUnlocks()
        saveData()
    }

    func recordEnergySpent(_ amount: Int) {
        records.totalEnergySpent += amount
        saveData()
    }

    func updatePlayDays() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let firstPlay = calendar.startOfDay(for: records.firstPlayDate)
        let days = (calendar.dateComponents([.day], from: firstPlay, to: today).day ?? 0) + 1
        records.totalPlayDays = max(records.totalPlayDays, days)
        checkBadgeUnlocks()
        saveData()
    }

    // MARK: - Badge Unlock Checks
    func checkBadgeUnlocks() {
        // Battle badges
        unlockBadgeIf("first_blood", condition: records.totalBattlesWon >= 1)
        unlockBadgeIf("seasoned_warrior", condition: records.totalBattlesWon >= 10)
        unlockBadgeIf("battle_hardened", condition: records.totalBattlesWon >= 50)
        unlockBadgeIf("war_hero", condition: records.totalBattlesWon >= 100)
        unlockBadgeIf("on_a_roll", condition: records.longestBattleWinStreak >= 5)
        unlockBadgeIf("unstoppable", condition: records.longestBattleWinStreak >= 10)
        unlockBadgeIf("heavy_hitter", condition: records.highestSingleHit >= 100)
        unlockBadgeIf("damage_dealer", condition: records.totalDamageDealt >= 1000)

        // Arena badges
        unlockBadgeIf("arena_debut", condition: (records.arenaWins + records.arenaLosses) >= 1)
        unlockBadgeIf("silver_rank", condition: records.highestArenaRating >= 500)
        unlockBadgeIf("gold_rank", condition: records.highestArenaRating >= 1000)
        unlockBadgeIf("diamond_rank", condition: records.highestArenaRating >= 1500)
        unlockBadgeIf("champion_rank", condition: records.highestArenaRating >= 2000)
        // Arena dominator tracked via ArenaManager's win streak
        // Will be checked externally

        // Economy badges
        unlockBadgeIf("wealthy", condition: records.totalGoldEarned >= 1000)
        unlockBadgeIf("rich", condition: records.totalGoldEarned >= 10000)
        unlockBadgeIf("big_spender", condition: records.itemsPurchased >= 20)
        unlockBadgeIf("merchants_friend", condition: records.barterTradesCompleted >= 5)

        // Exploration badges
        unlockBadgeIf("dungeon_crawler", condition: records.totalDungeonClears >= 1)
        unlockBadgeIf("dungeon_master", condition: records.totalDungeonClears >= 10)
        unlockBadgeIf("quest_legend", condition: records.totalQuestsCompleted >= 50)

        // Dedication badges
        unlockBadgeIf("rising_star", condition: records.highestLevel >= 10)
        unlockBadgeIf("veteran", condition: records.highestLevel >= 20)
        unlockBadgeIf("one_week_in", condition: records.totalPlayDays >= 7)
        unlockBadgeIf("monthly_dedication", condition: records.totalPlayDays >= 30)
    }

    private func unlockBadgeIf(_ badgeId: String, condition: Bool) {
        guard condition else { return }
        guard let index = badges.firstIndex(where: { $0.id == badgeId }) else { return }
        if !badges[index].isUnlocked {
            badges[index].isUnlocked = true
            badges[index].dateUnlocked = Date()
        }
    }

    // MARK: - Computed
    var unlockedBadgeCount: Int {
        badges.filter { $0.isUnlocked }.count
    }

    // MARK: - Arena Dominator (called externally)
    func checkArenaDominator(arenaWinStreak: Int) {
        unlockBadgeIf("arena_dominator", condition: arenaWinStreak >= 5)
        saveData()
    }

    // MARK: - Persistence
    func saveData() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
        if let encoded = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(encoded, forKey: badgesKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode(PersonalRecords.self, from: data) {
            records = decoded
        }
        if let data = UserDefaults.standard.data(forKey: badgesKey),
           let decoded = try? JSONDecoder().decode([RecordBadge].self, from: data) {
            // Merge loaded badges with database (in case new badges were added)
            var loadedMap: [String: RecordBadge] = [:]
            for badge in decoded { loadedMap[badge.id] = badge }

            badges = BadgeDatabase.allBadges.map { dbBadge in
                if let loaded = loadedMap[dbBadge.id] {
                    return loaded
                }
                return dbBadge
            }
        }
    }
}
