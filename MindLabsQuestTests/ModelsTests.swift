import Testing
import Foundation
@testable import MindLabsQuest

struct ModelsTests {
    
    // MARK: - Character Tests
    
    @Test func testCharacterInitialization() async throws {
        let character = Character(
            name: "Test Hero",
            avatar: "🦸",
            characterClass: .warrior,
            background: .freshman,
            primaryGoal: .academic
        )
        
        #expect(character.name == "Test Hero")
        #expect(character.avatar == "🦸")
        #expect(character.level == 1)
        #expect(character.xp == 0)
        #expect(character.gold == 50) // Starting gold
        #expect(character.health == 100)
        #expect(character.maxHealth == 100)
        #expect(character.streak == 0)
    }
    
    @Test func testCharacterXPForNextLevel() async throws {
        var character = Character(name: "Test", avatar: "🧙", characterClass: .mage, background: .scholarship, primaryGoal: .timeManagement)
        
        // Level 1
        #expect(character.xpForNextLevel == 100)
        
        // Level 2
        character.level = 2
        #expect(character.xpForNextLevel == 200)
        
        // Level 10
        character.level = 10
        #expect(character.xpForNextLevel == 1000)
    }
    
    @Test func testCharacterProgress() async throws {
        var character = Character(name: "Test", avatar: "🧙", characterClass: .mage, background: .scholarship, primaryGoal: .timeManagement)
        
        character.xp = 0
        #expect(character.progress == 0.0)
        
        character.xp = 50
        #expect(character.progress == 0.5)
        
        character.xp = 100
        #expect(character.progress == 1.0)
    }
    
    // MARK: - Quest Tests
    
    @Test func testQuestInitialization() async throws {
        let dueDate = Date().addingTimeInterval(86400)
        let quest = Quest(
            title: "Complete Assignment",
            description: "Finish the math homework",
            category: .academic,
            difficulty: .medium,
            estimatedTime: 60,
            dueDate: dueDate,
            isDaily: true
        )
        
        #expect(quest.title == "Complete Assignment")
        #expect(quest.description == "Finish the math homework")
        #expect(quest.category == .academic)
        #expect(quest.difficulty == .medium)
        #expect(quest.estimatedTime == 60)
        #expect(quest.dueDate == dueDate)
        #expect(quest.isDaily)
        #expect(!quest.isCompleted)
        #expect(quest.xpReward == 30) // Medium difficulty XP
        #expect(quest.goldReward == 15) // Medium difficulty gold
    }
    
    @Test func testQuestRewards() async throws {
        // Easy quest
        let easyQuest = Quest(title: "Easy", category: .academic, difficulty: .easy, estimatedTime: 30)
        #expect(easyQuest.xpReward == 15)
        #expect(easyQuest.goldReward == 10)
        
        // Medium quest
        let mediumQuest = Quest(title: "Medium", category: .academic, difficulty: .medium, estimatedTime: 30)
        #expect(mediumQuest.xpReward == 30)
        #expect(mediumQuest.goldReward == 15)
        
        // Hard quest
        let hardQuest = Quest(title: "Hard", category: .academic, difficulty: .hard, estimatedTime: 30)
        #expect(hardQuest.xpReward == 50)
        #expect(hardQuest.goldReward == 25)
    }
    
    @Test func testQuestSubtasks() async throws {
        var quest = Quest(
            title: "Main Quest",
            category: .academic,
            difficulty: .hard,
            estimatedTime: 120,
            hasSubtasks: true
        )
        
        quest.subtasks = [
            Quest.Subtask(title: "Research", estimatedTime: 30),
            Quest.Subtask(title: "Write draft", estimatedTime: 60),
            Quest.Subtask(title: "Review", estimatedTime: 30)
        ]
        
        #expect(quest.hasSubtasks)
        #expect(quest.subtasks.count == 3)
        #expect(quest.completedSubtaskCount == 0)
        #expect(quest.subtaskProgress == 0.0)
        
        // Complete one subtask
        quest.subtasks[0].isCompleted = true
        #expect(quest.completedSubtaskCount == 1)
        #expect(quest.subtaskProgress ≈ 0.333, accuracy: 0.01)
    }
    
    // MARK: - Routine Tests
    
    @Test func testRoutineInitialization() async throws {
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
        
        #expect(routine.name == "Morning Routine")
        #expect(routine.icon == "☀️")
        #expect(routine.type == .morning)
        #expect(routine.steps.count == 3)
        #expect(routine.totalDuration == 40)
        #expect(routine.completedStepsCount == 0)
        #expect(routine.progress == 0.0)
    }
    
    @Test func testRoutineProgress() async throws {
        var routine = Routine(
            name: "Test Routine",
            icon: "🧪",
            type: .custom,
            steps: [
                RoutineStep(title: "Step 1", duration: 10),
                RoutineStep(title: "Step 2", duration: 10),
                RoutineStep(title: "Step 3", duration: 10)
            ]
        )
        
        #expect(routine.progress == 0.0)
        
        routine.steps[0].isCompleted = true
        #expect(routine.progress ≈ 0.333, accuracy: 0.01)
        
        routine.steps[1].isCompleted = true
        #expect(routine.progress ≈ 0.667, accuracy: 0.01)
        
        routine.steps[2].isCompleted = true
        #expect(routine.progress == 1.0)
    }
    
    // MARK: - Achievement Tests
    
    @Test func testAchievementStructure() async throws {
        let achievement = Achievement(
            key: "test_achievement",
            title: "Test Achievement",
            description: "Complete the test",
            icon: "🏆",
            requiredValue: 10,
            category: .quests
        )
        
        #expect(achievement.key == "test_achievement")
        #expect(achievement.title == "Test Achievement")
        #expect(!achievement.isUnlocked)
        #expect(achievement.progress == 0)
        #expect(achievement.unlockedDate == nil)
    }
    
    @Test func testAllAchievements() async throws {
        let achievements = Achievement.allAchievements
        
        #expect(achievements.count > 0)
        
        // Check that all categories are represented
        let categories = Set(achievements.map { $0.category })
        #expect(categories.count == Achievement.AchievementCategory.allCases.count)
        
        // Check that all achievements have unique keys
        let keys = Set(achievements.map { $0.key })
        #expect(keys.count == achievements.count)
    }
    
    // MARK: - CalendarEvent Tests
    
    @Test func testCalendarEventInitialization() async throws {
        let startDate = Date()
        let event = CalendarEvent(
            title: "Study Session",
            description: "Review for upcoming exam",
            date: startDate,
            duration: 90,
            eventType: .study,
            category: .academic,
            priority: .high,
            courseOrSubject: "Physics",
            location: "Library",
            reminder: ReminderTime(option: .minutes30)
        )
        
        #expect(event.title == "Study Session")
        #expect(event.duration == 90)
        #expect(event.eventType == .study)
        #expect(event.priority == .high)
        
        let expectedEndDate = Calendar.current.date(byAdding: .minute, value: 90, to: startDate)!
        #expect(event.endDate == expectedEndDate)
    }
    
    @Test func testReminderTime() async throws {
        let reminder15 = ReminderTime(option: .minutes15)
        #expect(reminder15.minutes == -15)
        
        let reminder30 = ReminderTime(option: .minutes30)
        #expect(reminder30.minutes == -30)
        
        let reminder1Hour = ReminderTime(option: .hour1)
        #expect(reminder1Hour.minutes == -60)
        
        let reminder1Day = ReminderTime(option: .day1)
        #expect(reminder1Day.minutes == -1440)
    }
    
    // MARK: - Enum Tests
    
    @Test func testDifficultyValues() async throws {
        #expect(Difficulty.easy.xpReward == 15)
        #expect(Difficulty.easy.goldReward == 10)
        #expect(Difficulty.easy.color.description.contains("green"))
        
        #expect(Difficulty.medium.xpReward == 30)
        #expect(Difficulty.medium.goldReward == 15)
        #expect(Difficulty.medium.color.description.contains("orange"))
        
        #expect(Difficulty.hard.xpReward == 50)
        #expect(Difficulty.hard.goldReward == 25)
        #expect(Difficulty.hard.color.description.contains("red"))
    }
    
    @Test func testTaskCategoryValues() async throws {
        let categories = TaskCategory.allCases
        #expect(categories.count == 6)
        
        for category in categories {
            #expect(!category.icon.isEmpty)
            #expect(!category.rawValue.isEmpty)
        }
    }
}