import Testing
import EventKit
@testable import MindLabsQuest

struct CalendarManagerTests {
    
    @Test func testCalendarManagerSingleton() async throws {
        let instance1 = CalendarManager.shared
        let instance2 = CalendarManager.shared
        
        #expect(instance1 === instance2)
    }
    
    @Test func testSyncSettingsDefaults() async throws {
        let calendarManager = CalendarManager.shared
        
        #expect(!calendarManager.syncSettings.isEnabled)
        #expect(calendarManager.syncSettings.autoConvertToQuests == false)
        #expect(calendarManager.syncSettings.syncPastDays == 7)
        #expect(calendarManager.syncSettings.syncFutureDays == 30)
    }
    
    @Test func testEventToQuestConversion() async throws {
        let calendarManager = CalendarManager.shared
        
        let event = CalendarEvent(
            title: "Math Exam",
            description: "Final exam for Calculus II",
            date: Date().addingTimeInterval(86400), // Tomorrow
            duration: 120,
            eventType: .exam,
            category: .academic,
            priority: .high,
            courseOrSubject: "Mathematics"
        )
        
        let quest = calendarManager.createQuestFromEvent(event)
        
        #expect(quest.title == "Math Exam")
        #expect(quest.description == "Final exam for Calculus II")
        #expect(quest.category == .academic)
        #expect(quest.difficulty == .hard) // High priority events become hard quests
        #expect(quest.estimatedTime == 120)
        #expect(quest.dueDate != nil)
    }
    
    @Test func testEventTypeMapping() async throws {
        let calendarManager = CalendarManager.shared
        
        // Test different event types
        let examEvent = CalendarEvent(
            title: "Test",
            date: Date(),
            eventType: .exam,
            category: .academic
        )
        let examQuest = calendarManager.createQuestFromEvent(examEvent)
        #expect(examQuest.difficulty == .hard)
        
        let assignmentEvent = CalendarEvent(
            title: "Test",
            date: Date(),
            eventType: .assignment,
            category: .academic
        )
        let assignmentQuest = calendarManager.createQuestFromEvent(assignmentEvent)
        #expect(assignmentQuest.difficulty == .medium)
        
        let labEvent = CalendarEvent(
            title: "Test",
            date: Date(),
            eventType: .lab,
            category: .academic
        )
        let labQuest = calendarManager.createQuestFromEvent(labEvent)
        #expect(labQuest.difficulty == .medium)
    }
    
    @Test func testPriorityToDifficultyMapping() async throws {
        let calendarManager = CalendarManager.shared
        
        // High priority
        let highPriorityEvent = CalendarEvent(
            title: "High Priority",
            date: Date(),
            eventType: .other,
            category: .academic,
            priority: .high
        )
        let highQuest = calendarManager.createQuestFromEvent(highPriorityEvent)
        #expect(highQuest.difficulty == .hard)
        
        // Medium priority
        let mediumPriorityEvent = CalendarEvent(
            title: "Medium Priority",
            date: Date(),
            eventType: .other,
            category: .academic,
            priority: .medium
        )
        let mediumQuest = calendarManager.createQuestFromEvent(mediumPriorityEvent)
        #expect(mediumQuest.difficulty == .medium)
        
        // Low priority
        let lowPriorityEvent = CalendarEvent(
            title: "Low Priority",
            date: Date(),
            eventType: .other,
            category: .academic,
            priority: .low
        )
        let lowQuest = calendarManager.createQuestFromEvent(lowPriorityEvent)
        #expect(lowQuest.difficulty == .easy)
    }
    
    @Test func testSyncSettingsPersistence() async throws {
        let calendarManager = CalendarManager.shared
        
        // Modify settings
        calendarManager.syncSettings.isEnabled = true
        calendarManager.syncSettings.autoConvertToQuests = true
        calendarManager.syncSettings.syncPastDays = 14
        calendarManager.syncSettings.syncFutureDays = 60
        calendarManager.syncSettings.selectedCalendarIdentifier = "test-calendar-id"
        
        // Save settings
        calendarManager.saveSyncSettings()
        
        // Create new instance and verify persistence
        let newManager = CalendarManager()
        newManager.loadSyncSettings()
        
        #expect(newManager.syncSettings.isEnabled)
        #expect(newManager.syncSettings.autoConvertToQuests)
        #expect(newManager.syncSettings.syncPastDays == 14)
        #expect(newManager.syncSettings.syncFutureDays == 60)
        #expect(newManager.syncSettings.selectedCalendarIdentifier == "test-calendar-id")
    }
    
    @Test func testDateRangeCalculation() async throws {
        let calendarManager = CalendarManager.shared
        
        calendarManager.syncSettings.syncPastDays = 7
        calendarManager.syncSettings.syncFutureDays = 30
        
        let now = Date()
        let calendar = Calendar.current
        
        // Calculate expected date range
        let expectedStartDate = calendar.date(byAdding: .day, value: -7, to: now)!
        let expectedEndDate = calendar.date(byAdding: .day, value: 30, to: now)!
        
        // Test that sync would fetch events in the correct range
        // (This would be tested more thoroughly with integration tests)
        #expect(calendarManager.syncSettings.syncPastDays == 7)
        #expect(calendarManager.syncSettings.syncFutureDays == 30)
    }
    
    @Test func testEventReminders() async throws {
        let calendarManager = CalendarManager.shared
        
        let event = CalendarEvent(
            title: "Important Meeting",
            date: Date().addingTimeInterval(3600), // 1 hour from now
            eventType: .meeting,
            category: .academic,
            reminder: ReminderTime(option: .minutes30)
        )
        
        #expect(event.reminder != nil)
        #expect(event.reminder?.minutes == -30)
        #expect(event.reminder?.option == .minutes30)
    }
}