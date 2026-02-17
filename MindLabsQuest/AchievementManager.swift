import Foundation
import SwiftUI

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var showAchievementUnlocked = false
    @Published var unlockedAchievement: Achievement?

    // Callback for reward claiming (set by GameManager)
    var onRewardClaimed: ((AchievementReward) -> Void)?

    init() {
        loadAchievements()
    }

    // MARK: - Existing Check Methods
    func checkQuestAchievements(totalCompleted: Int) {
        checkAndUnlock("first_quest", currentValue: totalCompleted)
        checkAndUnlock("quest_10", currentValue: totalCompleted)
        checkAndUnlock("quest_50", currentValue: totalCompleted)
        checkAndUnlock("quest_100", currentValue: totalCompleted)
    }

    func checkStreakAchievements(currentStreak: Int) {
        checkAndUnlock("streak_3", currentValue: currentStreak)
        checkAndUnlock("streak_7", currentValue: currentStreak)
        checkAndUnlock("streak_30", currentValue: currentStreak)
    }

    func checkLevelAchievements(currentLevel: Int) {
        checkAndUnlock("level_5", currentValue: currentLevel)
        checkAndUnlock("level_10", currentValue: currentLevel)
        checkAndUnlock("level_25", currentValue: currentLevel)
    }

    func checkFocusAchievements(sessionMinutes: Int, totalMinutes: Int) {
        checkAndUnlock("focus_60", currentValue: sessionMinutes)
        checkAndUnlock("focus_total_300", currentValue: totalMinutes)
        checkAndUnlock("focus_total_1000", currentValue: totalMinutes)
        checkAndUnlock("focus_120_min", currentValue: sessionMinutes)
        checkAndUnlock("focus_total_5000", currentValue: totalMinutes)
    }

    func checkCollectionAchievements(uniqueClasses: Int, categoriesCompleted: Int) {
        checkAndUnlock("all_classes", currentValue: uniqueClasses)
        checkAndUnlock("all_categories", currentValue: categoriesCompleted)
    }

    // MARK: - Phase 5 Check Methods
    func checkBattleAchievements(totalWins: Int, totalDamage: Int, highestHit: Int) {
        checkAndUnlock("battle_first", currentValue: totalWins)
        checkAndUnlock("battle_25", currentValue: totalWins)
        checkAndUnlock("battle_100", currentValue: totalWins)
        checkAndUnlock("battle_500", currentValue: totalWins)
        checkAndUnlock("battle_hit_100", currentValue: highestHit)
        checkAndUnlock("battle_dmg_5000", currentValue: totalDamage)
    }

    func checkBattleItemsUsed(count: Int) {
        checkAndUnlock("battle_items_10", currentValue: count)
    }

    func checkComebackWin() {
        checkAndUnlock("battle_comeback", currentValue: 1)
    }

    func checkArenaAchievements(rating: Int, winStreak: Int) {
        checkAndUnlock("arena_debut", currentValue: 1) // called after first match
        checkAndUnlock("arena_silver", currentValue: rating)
        checkAndUnlock("arena_gold", currentValue: rating)
        checkAndUnlock("arena_diamond", currentValue: rating)
        checkAndUnlock("arena_champion", currentValue: rating)
        checkAndUnlock("arena_streak_10", currentValue: winStreak)
    }

    func checkCraftingAchievements(totalCrafted: Int, materialsOwned: Int, recipesKnown: Int) {
        checkAndUnlock("craft_1", currentValue: totalCrafted)
        checkAndUnlock("craft_10", currentValue: totalCrafted)
        checkAndUnlock("craft_25", currentValue: totalCrafted)
        checkAndUnlock("craft_materials_50", currentValue: materialsOwned)
        checkAndUnlock("craft_recipes_10", currentValue: recipesKnown)
    }

    func checkDungeonAchievements(totalClears: Int, highestFloor: Int) {
        checkAndUnlock("dungeon_1", currentValue: totalClears)
        checkAndUnlock("dungeon_5", currentValue: totalClears)
        checkAndUnlock("dungeon_15", currentValue: totalClears)
        checkAndUnlock("dungeon_floor_10", currentValue: highestFloor)
    }

    func checkDungeonSpeedRun() {
        checkAndUnlock("dungeon_speed", currentValue: 1)
    }

    func checkPrestigeAchievements(prestigeLevel: Int) {
        checkAndUnlock("prestige_1", currentValue: prestigeLevel)
        checkAndUnlock("prestige_2", currentValue: prestigeLevel)
        checkAndUnlock("prestige_3", currentValue: prestigeLevel)
        checkAndUnlock("prestige_5", currentValue: prestigeLevel)
    }

    func checkEconomyAchievements(totalGold: Int, itemsBought: Int, barterTrades: Int, arenaTokensSpent: Int) {
        checkAndUnlock("gold_5000", currentValue: totalGold)
        checkAndUnlock("gold_10000", currentValue: totalGold)
        checkAndUnlock("shop_25", currentValue: itemsBought)
        checkAndUnlock("barter_5", currentValue: barterTrades)
        checkAndUnlock("arena_tokens_500", currentValue: arenaTokensSpent)
    }

    func checkDedicationAchievements(daysPlayed: Int) {
        checkAndUnlock("days_7", currentValue: daysPlayed)
        checkAndUnlock("days_30", currentValue: daysPlayed)
        checkAndUnlock("days_90", currentValue: daysPlayed)
        checkAndUnlock("days_180", currentValue: daysPlayed)
        checkAndUnlock("days_365", currentValue: daysPlayed)
    }

    func checkCollectionDetailAchievements(rareItems: Int, epicItems: Int, legendaryItems: Int, equippedSlots: Int, cosmeticsUnlocked: Int) {
        checkAndUnlock("rare_items_5", currentValue: rareItems)
        checkAndUnlock("epic_items_3", currentValue: epicItems)
        checkAndUnlock("legendary_item", currentValue: legendaryItems)
        checkAndUnlock("full_equip", currentValue: equippedSlots)
        checkAndUnlock("cosmetics_10", currentValue: cosmeticsUnlocked)
    }

    func checkSeasonalAchievements(challengesCompleted: Int, eventsParticipated: Int, seasonalItemsEarned: Int, allChallengesInEvent: Bool) {
        checkAndUnlock("seasonal_participate", currentValue: challengesCompleted)
        if allChallengesInEvent {
            checkAndUnlock("seasonal_champion", currentValue: 1)
        }
        checkAndUnlock("seasonal_veteran", currentValue: eventsParticipated)
        checkAndUnlock("seasonal_collector", currentValue: seasonalItemsEarned)
    }

    func checkFocusSessionAchievements(totalSessions: Int, focusStreakDays: Int) {
        checkAndUnlock("focus_5_sessions", currentValue: totalSessions)
        checkAndUnlock("focus_25_sessions", currentValue: totalSessions)
        checkAndUnlock("focus_streak_7", currentValue: focusStreakDays)
    }

    // MARK: - Core Functions
    private func checkAndUnlock(_ key: String, currentValue: Int) {
        guard let index = achievements.firstIndex(where: { $0.key == key }) else { return }

        // Update progress
        achievements[index].progress = currentValue

        // Check if should unlock
        if !achievements[index].isUnlocked && currentValue >= achievements[index].requiredValue {
            achievements[index].isUnlocked = true
            achievements[index].unlockedDate = Date()

            // Show notification
            unlockedAchievement = achievements[index]
            showAchievementUnlocked = true

            // Haptic feedback via HapticService
            HapticService.impact(.heavy)

            // Claim reward
            if let reward = achievements[index].reward {
                onRewardClaimed?(reward)
            }

            saveAchievements()
        }
    }

    // MARK: - Persistence
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
    }

    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            // Merge-on-load: keep unlocked state from save, add any new achievements from code
            let allDefined = Achievement.allAchievements
            var merged: [Achievement] = []
            for defined in allDefined {
                if let saved = decoded.first(where: { $0.key == defined.key }) {
                    // Preserve saved state (unlocked, progress, date) but use latest definition
                    var updated = defined
                    updated.isUnlocked = saved.isUnlocked
                    updated.unlockedDate = saved.unlockedDate
                    updated.progress = saved.progress
                    merged.append(updated)
                } else {
                    // New achievement from code, add as locked
                    merged.append(defined)
                }
            }
            achievements = merged
        } else {
            achievements = Achievement.allAchievements
        }
    }

    // MARK: - Computed Properties
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }

    var totalCount: Int {
        achievements.count
    }

    var progressPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }

    var groupedAchievements: [Achievement.AchievementCategory: [Achievement]] {
        Dictionary(grouping: achievements, by: { $0.category })
    }

    // MARK: - Reset
    func resetAll() {
        achievements = Achievement.allAchievements
        showAchievementUnlocked = false
        unlockedAchievement = nil
        UserDefaults.standard.removeObject(forKey: "achievements")
    }
}
