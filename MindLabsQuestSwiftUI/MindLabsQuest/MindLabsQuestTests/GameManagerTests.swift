import Testing
import SwiftUI
@testable import MindLabsQuest

struct GameManagerTests {
    
    // MARK: - Character Tests
    
    @Test func testCharacterCreation() async throws {
        let gameManager = GameManager()
        
        // Test initial state
        #expect(!gameManager.isCharacterCreated)
        
        // Create character
        gameManager.createCharacter(
            name: "Test Hero",
            avatar: "🧙‍♂️",
            characterClass: .mage,
            background: .scholarship,
            primaryGoal: .timeManagement
        )
        
        // Verify character was created
        #expect(gameManager.isCharacterCreated)
        #expect(gameManager.character.name == "Test Hero")
        #expect(gameManager.character.avatar == "🧙‍♂️")
        #expect(gameManager.character.characterClass == .mage)
        #expect(gameManager.character.background == .scholarship)
        #expect(gameManager.character.primaryGoal == .timeManagement)
        #expect(gameManager.character.level == 1)
        #expect(gameManager.character.xp == 0)
    }
    
    @Test func testLevelProgression() async throws {
        let gameManager = GameManager()
        gameManager.createCharacter(name: "Test", avatar: "🦸", characterClass: .warrior, background: .transfer, primaryGoal: .academic)
        
        // Test XP gain and level up
        gameManager.character.xp = 95
        gameManager.checkForLevelUp()
        #expect(gameManager.character.level == 1)
        
        gameManager.character.xp = 100
        gameManager.checkForLevelUp()
        #expect(gameManager.character.level == 2)
        #expect(gameManager.showLevelUpAnimation)
    }
    
    // MARK: - Quest Tests
    
    @Test func testQuestCreation() async throws {
        let gameManager = GameManager()
        let initialCount = gameManager.quests.count
        
        let quest = Quest(
            title: "Test Quest",
            category: .academic,
            difficulty: .medium,
            estimatedTime: 30
        )
        
        gameManager.addQuest(quest)
        #expect(gameManager.quests.count == initialCount + 1)
        #expect(gameManager.quests.last?.title == "Test Quest")
    }
    
    @Test func testQuestCompletion() async throws {
        let gameManager = GameManager()
        gameManager.createCharacter(name: "Test", avatar: "🦸", characterClass: .warrior, background: .transfer, primaryGoal: .academic)
        
        let quest = Quest(
            title: "Complete Assignment",
            category: .academic,
            difficulty: .hard,
            estimatedTime: 60
        )
        
        gameManager.addQuest(quest)
        let initialXP = gameManager.character.xp
        let initialGold = gameManager.character.gold
        
        gameManager.completeQuest(quest)
        
        #expect(gameManager.character.xp > initialXP)
        #expect(gameManager.character.gold > initialGold)
        #expect(gameManager.quests.first(where: { $0.id == quest.id })?.isCompleted == true)
    }
    
    @Test func testDailyQuestGeneration() async throws {
        let gameManager = GameManager()
        gameManager.createCharacter(name: "Test", avatar: "🦸", characterClass: .warrior, background: .transfer, primaryGoal: .academic)
        
        gameManager.generateDailyQuests()
        
        let dailyQuests = gameManager.quests.filter { $0.isDaily }
        #expect(dailyQuests.count == 3)
        #expect(dailyQuests.allSatisfy { $0.category == .academic })
    }
    
    // MARK: - Streak Tests
    
    @Test func testStreakMaintenance() async throws {
        let gameManager = GameManager()
        gameManager.createCharacter(name: "Test", avatar: "🦸", characterClass: .warrior, background: .transfer, primaryGoal: .academic)
        
        // Simulate quest completion today
        gameManager.character.streak = 5
        gameManager.lastStreakCheck = Date()
        
        let quest = Quest(title: "Test", category: .academic, difficulty: .easy, estimatedTime: 10)
        gameManager.addQuest(quest)
        gameManager.completeQuest(quest)
        
        // Streak should be maintained or increased
        #expect(gameManager.character.streak >= 5)
    }
    
    // MARK: - Routine Tests
    
    @Test func testRoutineCreation() async throws {
        let gameManager = GameManager()
        
        let routine = Routine(
            name: "Morning Routine",
            icon: "☀️",
            type: .morning,
            steps: [
                RoutineStep(title: "Wake up", duration: 5),
                RoutineStep(title: "Shower", duration: 15),
                RoutineStep(title: "Breakfast", duration: 20)
            ],
            scheduledTime: DateComponents(hour: 7, minute: 0)
        )
        
        gameManager.addRoutine(routine)
        #expect(gameManager.routines.count == 1)
        #expect(gameManager.routines.first?.steps.count == 3)
        #expect(gameManager.routines.first?.totalDuration == 40)
    }
    
    @Test func testRoutineStepCompletion() async throws {
        let gameManager = GameManager()
        
        var routine = Routine(
            name: "Test Routine",
            icon: "🧪",
            type: .custom,
            steps: [
                RoutineStep(title: "Step 1", duration: 5),
                RoutineStep(title: "Step 2", duration: 5)
            ]
        )
        
        gameManager.addRoutine(routine)
        
        // Complete first step
        gameManager.toggleRoutineStep(routineId: routine.id, stepId: routine.steps[0].id)
        
        if let updatedRoutine = gameManager.routines.first(where: { $0.id == routine.id }) {
            #expect(updatedRoutine.steps[0].isCompleted == true)
            #expect(updatedRoutine.steps[1].isCompleted == false)
            #expect(updatedRoutine.completedStepsCount == 1)
        }
    }
    
    // MARK: - Time Tracking Tests
    
    @Test func testTimeTracking() async throws {
        let gameManager = GameManager()
        
        let quest = Quest(title: "Study", category: .academic, difficulty: .medium, estimatedTime: 30)
        gameManager.addQuest(quest)
        
        // Start tracking
        gameManager.startTimeTracking(for: quest.id)
        #expect(gameManager.activeTimerQuestId == quest.id)
        
        // Simulate time passing
        if let index = gameManager.quests.firstIndex(where: { $0.id == quest.id }) {
            gameManager.quests[index].startedAt = Date().addingTimeInterval(-600) // 10 minutes ago
        }
        
        // Stop tracking
        gameManager.stopTimeTracking(for: quest.id)
        
        if let trackedQuest = gameManager.quests.first(where: { $0.id == quest.id }) {
            #expect(trackedQuest.actualTime ?? 0 > 0)
        }
    }
    
    // MARK: - Achievement Tests
    
    @Test func testAchievementUnlocking() async throws {
        let gameManager = GameManager()
        gameManager.createCharacter(name: "Test", avatar: "🦸", characterClass: .warrior, background: .transfer, primaryGoal: .academic)
        
        // Complete first quest achievement
        let quest = Quest(title: "First Quest", category: .academic, difficulty: .easy, estimatedTime: 10)
        gameManager.addQuest(quest)
        gameManager.completeQuest(quest)
        
        // Check if first quest achievement was unlocked
        if let achievement = gameManager.achievementManager.achievements.first(where: { $0.key == "first_quest" }) {
            #expect(achievement.isUnlocked)
        }
    }
    
    // MARK: - Save/Load Tests
    
    @Test func testDataPersistence() async throws {
        let gameManager1 = GameManager()
        
        // Create and save data
        gameManager1.createCharacter(name: "Persistent Hero", avatar: "💾", characterClass: .rogue, background: .returning, primaryGoal: .social)
        gameManager1.character.xp = 250
        gameManager1.character.gold = 150
        gameManager1.saveData()
        
        // Create new instance and load data
        let gameManager2 = GameManager()
        
        #expect(gameManager2.isCharacterCreated)
        #expect(gameManager2.character.name == "Persistent Hero")
        #expect(gameManager2.character.xp == 250)
        #expect(gameManager2.character.gold == 150)
    }
}

// MARK: - Helper Extensions

extension Quest {
    static func testQuest(
        title: String = "Test Quest",
        category: TaskCategory = .academic,
        difficulty: Difficulty = .medium
    ) -> Quest {
        return Quest(
            title: title,
            category: category,
            difficulty: difficulty,
            estimatedTime: 30
        )
    }
}