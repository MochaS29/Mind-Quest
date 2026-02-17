import Testing
import SwiftUI
@testable import MindLabsQuest

struct AchievementManagerTests {
    
    @Test func testAchievementInitialization() async throws {
        let achievementManager = AchievementManager()
        
        #expect(achievementManager.achievements.count > 0)
        #expect(achievementManager.unlockedCount == 0) // Initially no achievements unlocked
        #expect(achievementManager.progressPercentage == 0.0)
    }
    
    @Test func testQuestAchievements() async throws {
        let achievementManager = AchievementManager()
        
        // Test first quest achievement
        achievementManager.checkQuestAchievements(totalCompleted: 1)
        
        if let firstQuestAchievement = achievementManager.achievements.first(where: { $0.key == "first_quest" }) {
            #expect(firstQuestAchievement.isUnlocked)
            #expect(firstQuestAchievement.progress == 1)
        }
        
        // Test 10 quests achievement
        achievementManager.checkQuestAchievements(totalCompleted: 10)
        
        if let quest10Achievement = achievementManager.achievements.first(where: { $0.key == "quest_10" }) {
            #expect(quest10Achievement.isUnlocked)
            #expect(quest10Achievement.progress == 10)
        }
        
        // Test that 50 quest achievement is not yet unlocked
        if let quest50Achievement = achievementManager.achievements.first(where: { $0.key == "quest_50" }) {
            #expect(!quest50Achievement.isUnlocked)
            #expect(quest50Achievement.progress == 10)
        }
    }
    
    @Test func testStreakAchievements() async throws {
        let achievementManager = AchievementManager()
        
        // Test 3-day streak
        achievementManager.checkStreakAchievements(currentStreak: 3)
        
        if let streak3Achievement = achievementManager.achievements.first(where: { $0.key == "streak_3" }) {
            #expect(streak3Achievement.isUnlocked)
        }
        
        // Test 7-day streak
        achievementManager.checkStreakAchievements(currentStreak: 7)
        
        if let streak7Achievement = achievementManager.achievements.first(where: { $0.key == "streak_7" }) {
            #expect(streak7Achievement.isUnlocked)
        }
        
        // Test that 30-day streak is not yet unlocked
        if let streak30Achievement = achievementManager.achievements.first(where: { $0.key == "streak_30" }) {
            #expect(!streak30Achievement.isUnlocked)
            #expect(streak30Achievement.progress == 7)
        }
    }
    
    @Test func testLevelAchievements() async throws {
        let achievementManager = AchievementManager()
        
        // Test level 5 achievement
        achievementManager.checkLevelAchievements(currentLevel: 5)
        
        if let level5Achievement = achievementManager.achievements.first(where: { $0.key == "level_5" }) {
            #expect(level5Achievement.isUnlocked)
        }
        
        // Test level 10 achievement
        achievementManager.checkLevelAchievements(currentLevel: 10)
        
        if let level10Achievement = achievementManager.achievements.first(where: { $0.key == "level_10" }) {
            #expect(level10Achievement.isUnlocked)
        }
    }
    
    @Test func testFocusAchievements() async throws {
        let achievementManager = AchievementManager()
        
        // Test 60-minute session achievement
        achievementManager.checkFocusAchievements(sessionMinutes: 60, totalMinutes: 60)
        
        if let focus60Achievement = achievementManager.achievements.first(where: { $0.key == "focus_60" }) {
            #expect(focus60Achievement.isUnlocked)
        }
        
        // Test total focus time achievements
        achievementManager.checkFocusAchievements(sessionMinutes: 30, totalMinutes: 300)
        
        if let focus300Achievement = achievementManager.achievements.first(where: { $0.key == "focus_total_300" }) {
            #expect(focus300Achievement.isUnlocked)
        }
        
        if let focus1000Achievement = achievementManager.achievements.first(where: { $0.key == "focus_total_1000" }) {
            #expect(!focus1000Achievement.isUnlocked)
            #expect(focus1000Achievement.progress == 300)
        }
    }
    
    @Test func testCollectionAchievements() async throws {
        let achievementManager = AchievementManager()
        
        // Test all classes achievement
        achievementManager.checkCollectionAchievements(uniqueClasses: 6, categoriesCompleted: 3)
        
        if let allClassesAchievement = achievementManager.achievements.first(where: { $0.key == "all_classes" }) {
            #expect(allClassesAchievement.isUnlocked)
        }
        
        // Test all categories achievement
        achievementManager.checkCollectionAchievements(uniqueClasses: 6, categoriesCompleted: 6)
        
        if let allCategoriesAchievement = achievementManager.achievements.first(where: { $0.key == "all_categories" }) {
            #expect(allCategoriesAchievement.isUnlocked)
        }
    }
    
    @Test func testAchievementProgress() async throws {
        let achievementManager = AchievementManager()
        
        // Unlock some achievements
        achievementManager.checkQuestAchievements(totalCompleted: 1)
        achievementManager.checkStreakAchievements(currentStreak: 3)
        achievementManager.checkLevelAchievements(currentLevel: 5)
        
        let unlockedCount = achievementManager.unlockedCount
        let totalCount = achievementManager.totalCount
        let progress = achievementManager.progressPercentage
        
        #expect(unlockedCount == 3)
        #expect(totalCount > unlockedCount)
        #expect(progress > 0 && progress < 1)
    }
    
    @Test func testGroupedAchievements() async throws {
        let achievementManager = AchievementManager()
        
        let grouped = achievementManager.groupedAchievements
        
        #expect(grouped.keys.count == Achievement.AchievementCategory.allCases.count)
        
        for category in Achievement.AchievementCategory.allCases {
            #expect(grouped[category] != nil)
            #expect(grouped[category]!.count > 0)
        }
    }
    
    @Test func testAchievementNotification() async throws {
        let achievementManager = AchievementManager()
        
        // Initially no achievement unlocked
        #expect(!achievementManager.showAchievementUnlocked)
        #expect(achievementManager.unlockedAchievement == nil)
        
        // Unlock an achievement
        achievementManager.checkQuestAchievements(totalCompleted: 1)
        
        // Check notification state
        #expect(achievementManager.showAchievementUnlocked)
        #expect(achievementManager.unlockedAchievement != nil)
        #expect(achievementManager.unlockedAchievement?.key == "first_quest")
    }
    
    @Test func testAchievementPersistence() async throws {
        // First manager unlocks achievements
        let manager1 = AchievementManager()
        manager1.checkQuestAchievements(totalCompleted: 10)
        manager1.checkStreakAchievements(currentStreak: 7)
        
        // Create new manager instance (simulating app restart)
        let manager2 = AchievementManager()
        
        // Verify achievements persist
        if let quest10 = manager2.achievements.first(where: { $0.key == "quest_10" }) {
            #expect(quest10.isUnlocked)
        }
        
        if let streak7 = manager2.achievements.first(where: { $0.key == "streak_7" }) {
            #expect(streak7.isUnlocked)
        }
    }
}