import Foundation
import SwiftUI

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var showAchievementUnlocked = false
    @Published var unlockedAchievement: Achievement?
    
    init() {
        loadAchievements()
    }
    
    // MARK: - Check Achievements
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
    }
    
    func checkCollectionAchievements(uniqueClasses: Int, categoriesCompleted: Int) {
        checkAndUnlock("all_classes", currentValue: uniqueClasses)
        checkAndUnlock("all_categories", currentValue: categoriesCompleted)
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
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            saveAchievements()
        }
    }
    
    // MARK: - Persistence
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            // Initialize with all achievements
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
        Double(unlockedCount) / Double(totalCount)
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