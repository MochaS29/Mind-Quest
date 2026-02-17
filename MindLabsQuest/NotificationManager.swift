import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestNotificationPermissions()
    }
    
    // MARK: - Permissions
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Timer Notifications
    func scheduleTimerNotification(questTitle: String, duration: TimeInterval, timerType: TimerType = .focus) {
        let content = UNMutableNotificationContent()
        
        switch timerType {
        case .focus:
            content.title = "Timer Complete! 🎉"
            content.body = "Great job focusing on: \(questTitle)"
            content.sound = UNNotificationSound(named: UNNotificationSoundName("success_sound.caf"))
        case .pomodoro:
            content.title = "Pomodoro Complete! 🍅"
            content.body = "Time for a break! You've completed a focus session."
            content.sound = UNNotificationSound(named: UNNotificationSoundName("pomodoro_complete.caf"))
        case .shortBreak:
            content.title = "Break's Over! ☕️"
            content.body = "Ready to get back to work?"
            content.sound = .default
        case .longBreak:
            content.title = "Long Break Complete! 🌟"
            content.body = "You've earned it! Ready for another round?"
            content.sound = .default
        }
        
        // Fallback to default sound if custom sound not available
        if content.sound == nil {
            content.sound = .default
        }
        
        content.categoryIdentifier = "TIMER_COMPLETE"
        content.userInfo = [
            "questTitle": questTitle,
            "duration": duration,
            "timerType": timerType.rawValue
        ]
        
        // Add haptic feedback request
        content.interruptionLevel = .timeSensitive
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "timer_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling timer notification: \(error.localizedDescription)")
            }
        }
    }
    
    enum TimerType: String {
        case focus = "focus"
        case pomodoro = "pomodoro"
        case shortBreak = "short_break"
        case longBreak = "long_break"
    }
    
    func cancelTimerNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Quest Reminders
    func scheduleQuestReminder(quest: Quest) {
        guard let dueDate = quest.dueDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(quest.category.icon) Quest Deadline!"
        content.body = "\(quest.title) - \(quest.difficulty.rawValue) difficulty"
        content.sound = .default
        content.categoryIdentifier = "QUEST_REMINDER"
        content.userInfo = ["questId": quest.id.uuidString]
        
        // Schedule multiple reminders at different intervals
        let reminderIntervals = [
            (minutes: -24 * 60, title: "📅 Quest Due Tomorrow"),  // 1 day before
            (minutes: -2 * 60, title: "⏰ Quest Due in 2 Hours"), // 2 hours before
            (minutes: -30, title: "🚨 Quest Due Soon!")           // 30 minutes before
        ]
        
        for (index, reminder) in reminderIntervals.enumerated() {
            let reminderDate = dueDate.addingTimeInterval(TimeInterval(reminder.minutes * 60))
            guard reminderDate > Date() else { continue }
            
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = content.body
            notificationContent.sound = content.sound
            notificationContent.categoryIdentifier = content.categoryIdentifier
            notificationContent.userInfo = content.userInfo
            notificationContent.title = reminder.title
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "quest_\(quest.id.uuidString)_\(index)",
                content: notificationContent,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling quest reminder: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelQuestReminder(questId: UUID) {
        // Remove all reminder intervals for this quest
        let identifiers = (0..<3).map { "quest_\(questId.uuidString)_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Daily Quest Reminders
    func scheduleDailyQuestReminder(at hour: Int, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Quests Available! 🌟"
        content.body = "Your daily adventures await! Start your quest to level up."
        content.sound = .default
        content.categoryIdentifier = "DAILY_QUEST"
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_quest_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily quest reminder: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Break Reminders
    func scheduleBreakReminder(after minutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time for a Break! 🧘"
        content.body = "You've been focusing for \(minutes) minutes. Take a quick break to recharge."
        content.sound = .default
        content.categoryIdentifier = "BREAK_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "break_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling break reminder: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Hyperfocus Protection
    func scheduleHyperfocusProtection(intervalMinutes: Int = 90, message: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "🎯 Hyperfocus Check-In"
        content.body = message ?? "Time to check in! Are you still on track? Consider a 5-minute break to reset."
        content.sound = .default
        content.categoryIdentifier = "HYPERFOCUS_PROTECTION"
        content.userInfo = ["type": "hyperfocus_protection"]
        
        // Add action buttons
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_HYPERFOCUS",
            title: "Snooze 15 min",
            options: []
        )
        let breakAction = UNNotificationAction(
            identifier: "TAKE_BREAK",
            title: "Take a Break",
            options: .foreground
        )
        let continueAction = UNNotificationAction(
            identifier: "CONTINUE_FOCUS",
            title: "Keep Going",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "HYPERFOCUS_PROTECTION",
            actions: [snoozeAction, breakAction, continueAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(intervalMinutes * 60),
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: "hyperfocus_protection",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling hyperfocus protection: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelHyperfocusProtection() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["hyperfocus_protection"])
    }
    
    // MARK: - Medication Reminders
    func scheduleMedicationReminder(
        name: String,
        time: DateComponents,
        dosage: String? = nil,
        notes: String? = nil,
        id: UUID = UUID()
    ) {
        let content = UNMutableNotificationContent()
        content.title = "💊 Medication Reminder"
        
        var bodyText = "Time to take \(name)"
        if let dosage = dosage {
            bodyText += " (\(dosage))"
        }
        if let notes = notes {
            bodyText += "\n\(notes)"
        }
        content.body = bodyText
        
        content.sound = UNNotificationSound(named: UNNotificationSoundName("medication_sound.caf"))
        if content.sound == nil {
            content.sound = .default
        }
        
        content.categoryIdentifier = "MEDICATION_REMINDER"
        content.userInfo = [
            "medicationId": id.uuidString,
            "medicationName": name,
            "type": "medication"
        ]
        
        // Add action buttons
        let takenAction = UNNotificationAction(
            identifier: "MEDICATION_TAKEN",
            title: "✓ Taken",
            options: []
        )
        let snoozeAction = UNNotificationAction(
            identifier: "MEDICATION_SNOOZE",
            title: "Snooze 10 min",
            options: []
        )
        let skipAction = UNNotificationAction(
            identifier: "MEDICATION_SKIP",
            title: "Skip",
            options: .destructive
        )
        
        let category = UNNotificationCategory(
            identifier: "MEDICATION_REMINDER",
            actions: [takenAction, snoozeAction, skipAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(
            identifier: "medication_\(id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling medication reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelMedicationReminder(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["medication_\(id.uuidString)"])
    }
    
    // MARK: - Calendar Event Reminders
    func scheduleEventReminder(event: CalendarEvent) {
        guard let reminder = event.reminder,
              let minutes = reminder.minutes else { return }
        
        let reminderDate = event.date.addingTimeInterval(TimeInterval(minutes * 60))
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(event.eventType.icon) \(event.title)"
        content.body = event.description.isEmpty ? "Event reminder" : event.description
        content.sound = .default
        content.categoryIdentifier = "EVENT_REMINDER"
        content.userInfo = ["eventId": event.id.uuidString]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "event_\(event.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling event reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelEventReminder(eventId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["event_\(eventId.uuidString)"])
    }
    
    // MARK: - Streak Notifications
    func scheduleStreakReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Alive! 🔥"
        content.body = "Complete a quest today to maintain your streak!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_REMINDER"
        
        var components = DateComponents()
        components.hour = 20  // 8 PM reminder
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak reminder: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Notification Settings
    func updateNotificationSettings(enableSound: Bool, enableBadges: Bool, enableBanners: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var options: UNAuthorizationOptions = []
            
            if enableSound && settings.soundSetting == .enabled {
                options.insert(.sound)
            }
            if enableBadges && settings.badgeSetting == .enabled {
                options.insert(.badge)
            }
            if enableBanners && settings.alertSetting == .enabled {
                options.insert(.alert)
            }
            
            UNUserNotificationCenter.current().requestAuthorization(options: options) { _, _ in }
        }
    }
    
    // MARK: - Notification Categories Setup
    func setupNotificationCategories() {
        let categories: Set<UNNotificationCategory> = [
            // Timer Complete
            UNNotificationCategory(
                identifier: "TIMER_COMPLETE",
                actions: [
                    UNNotificationAction(identifier: "START_BREAK", title: "Start Break", options: .foreground),
                    UNNotificationAction(identifier: "CONTINUE_FOCUS", title: "Continue", options: [])
                ],
                intentIdentifiers: [],
                options: []
            ),
            
            // Quest Reminder
            UNNotificationCategory(
                identifier: "QUEST_REMINDER",
                actions: [
                    UNNotificationAction(identifier: "START_QUEST", title: "Start Now", options: .foreground),
                    UNNotificationAction(identifier: "SNOOZE_QUEST", title: "Snooze", options: [])
                ],
                intentIdentifiers: [],
                options: []
            ),
            
            // Daily Quest
            UNNotificationCategory(
                identifier: "DAILY_QUEST",
                actions: [
                    UNNotificationAction(identifier: "VIEW_QUESTS", title: "View Quests", options: .foreground)
                ],
                intentIdentifiers: [],
                options: []
            ),
            
            // Break Reminder
            UNNotificationCategory(
                identifier: "BREAK_REMINDER",
                actions: [
                    UNNotificationAction(identifier: "TAKE_BREAK", title: "Take Break", options: .foreground),
                    UNNotificationAction(identifier: "SNOOZE_BREAK", title: "5 More Minutes", options: [])
                ],
                intentIdentifiers: [],
                options: []
            )
        ]
        
        UNUserNotificationCenter.current().setNotificationCategories(categories)
    }
}