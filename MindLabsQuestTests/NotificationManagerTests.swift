import Testing
import UserNotifications
@testable import MindLabsQuest

struct NotificationManagerTests {
    
    @Test func testNotificationManagerSingleton() async throws {
        let instance1 = NotificationManager.shared
        let instance2 = NotificationManager.shared
        
        #expect(instance1 === instance2)
    }
    
    @Test func testQuestReminderScheduling() async throws {
        let notificationManager = NotificationManager.shared
        
        // Create a quest with due date
        let dueDate = Date().addingTimeInterval(3600) // 1 hour from now
        let quest = Quest(
            title: "Test Quest",
            category: .academic,
            difficulty: .medium,
            estimatedTime: 30,
            dueDate: dueDate
        )
        
        // Schedule reminder
        notificationManager.scheduleQuestReminder(quest: quest)
        
        // Verify notifications were scheduled
        let expectation = try await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let questReminders = requests.filter { $0.identifier.contains("quest_\(quest.id.uuidString)") }
                continuation.resume(returning: questReminders.count > 0)
            }
        }
        
        #expect(expectation)
    }
    
    @Test func testMedicationReminderScheduling() async throws {
        let notificationManager = NotificationManager.shared
        
        let medicationId = UUID()
        var timeComponents = DateComponents()
        timeComponents.hour = 9
        timeComponents.minute = 0
        
        notificationManager.scheduleMedicationReminder(
            name: "Test Medication",
            time: timeComponents,
            dosage: "10mg",
            notes: "Take with food",
            id: medicationId
        )
        
        // Verify notification was scheduled
        let expectation = try await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let medicationReminder = requests.first { $0.identifier == "medication_\(medicationId.uuidString)" }
                continuation.resume(returning: medicationReminder != nil)
            }
        }
        
        #expect(expectation)
    }
    
    @Test func testHyperfocusProtectionScheduling() async throws {
        let notificationManager = NotificationManager.shared
        
        notificationManager.scheduleHyperfocusProtection(intervalMinutes: 90)
        
        // Verify notification was scheduled
        let expectation = try await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let hyperfocusReminder = requests.first { $0.identifier == "hyperfocus_protection" }
                continuation.resume(returning: hyperfocusReminder != nil)
            }
        }
        
        #expect(expectation)
    }
    
    @Test func testNotificationCancellation() async throws {
        let notificationManager = NotificationManager.shared
        let questId = UUID()
        
        // First cancel any existing notifications
        notificationManager.cancelQuestReminder(questId: questId)
        
        // Verify notifications were cancelled
        let expectation = try await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let questReminders = requests.filter { $0.identifier.contains("quest_\(questId.uuidString)") }
                continuation.resume(returning: questReminders.isEmpty)
            }
        }
        
        #expect(expectation)
    }
    
    @Test func testTimerNotificationTypes() async throws {
        let notificationManager = NotificationManager.shared
        
        // Test different timer types
        let timerTypes: [NotificationManager.TimerType] = [.focus, .pomodoro, .shortBreak, .longBreak]
        
        for timerType in timerTypes {
            notificationManager.scheduleTimerNotification(
                questTitle: "Test Timer",
                duration: 60,
                timerType: timerType
            )
        }
        
        // Verify all timer notifications were scheduled
        let expectation = try await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let timerNotifications = requests.filter { $0.identifier.starts(with: "timer_") }
                continuation.resume(returning: timerNotifications.count >= timerTypes.count)
            }
        }
        
        #expect(expectation)
    }
    
    @Test func testDailyQuestReminder() async throws {
        let notificationManager = NotificationManager.shared
        
        notificationManager.scheduleDailyQuestReminder(at: 9, minute: 0)
        
        // Verify daily reminder was scheduled
        let expectation = try await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let dailyReminder = requests.first { $0.identifier == "daily_quest_reminder" }
                
                if let trigger = dailyReminder?.trigger as? UNCalendarNotificationTrigger {
                    let components = trigger.dateComponents
                    continuation.resume(returning: components.hour == 9 && components.minute == 0 && trigger.repeats)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
        
        #expect(expectation)
    }
}