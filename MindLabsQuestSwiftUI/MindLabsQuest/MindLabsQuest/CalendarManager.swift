import Foundation
import EventKit
import SwiftUI

class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var calendars: [EKCalendar] = []
    @Published var syncSettings = CalendarSyncSettings()
    
    init() {
        checkAuthorizationStatus()
        loadSyncSettings()
    }
    
    // MARK: - Authorization
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if authorizationStatus == .authorized {
            loadCalendars()
        }
    }
    
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.authorizationStatus = granted ? .authorized : .denied
                if granted {
                    self?.loadCalendars()
                }
                completion(granted)
            }
        }
    }
    
    // MARK: - Calendar Management
    private func loadCalendars() {
        calendars = eventStore.calendars(for: .event).filter { $0.allowsContentModifications }
    }
    
    var selectedCalendar: EKCalendar? {
        guard let identifier = syncSettings.selectedCalendarIdentifier else { return nil }
        return calendars.first { $0.calendarIdentifier == identifier }
    }
    
    // MARK: - Event Syncing
    func syncEventsFromCalendar(completion: @escaping ([CalendarEvent]) -> Void) {
        guard authorizationStatus == .authorized,
              let calendar = selectedCalendar else {
            completion([])
            return
        }
        
        let startDate = Calendar.current.date(byAdding: .day, value: -syncSettings.syncPastDays, to: Date()) ?? Date()
        let endDate = Calendar.current.date(byAdding: .day, value: syncSettings.syncFutureDays, to: Date()) ?? Date()
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        let events = eventStore.events(matching: predicate)
        
        let calendarEvents = events.compactMap { ekEvent -> CalendarEvent? in
            return CalendarEvent(
                title: ekEvent.title ?? "Untitled Event",
                description: ekEvent.notes ?? "",
                date: ekEvent.startDate,
                duration: Int(ekEvent.endDate.timeIntervalSince(ekEvent.startDate) / 60),
                eventType: determineEventType(from: ekEvent),
                category: determineCategory(from: ekEvent),
                priority: determinePriority(from: ekEvent),
                courseOrSubject: extractCourse(from: ekEvent),
                location: ekEvent.location ?? "",
                reminder: determineReminder(from: ekEvent),
                calendarIdentifier: ekEvent.eventIdentifier
            )
        }
        
        completion(calendarEvents)
    }
    
    func addEventToCalendar(_ event: CalendarEvent, completion: @escaping (Bool, String?) -> Void) {
        guard authorizationStatus == .authorized,
              let calendar = selectedCalendar else {
            completion(false, nil)
            return
        }
        
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.title = event.title
        ekEvent.notes = event.description
        ekEvent.startDate = event.date
        ekEvent.endDate = event.endDate
        ekEvent.location = event.location
        ekEvent.calendar = calendar
        
        // Add reminder if specified
        if let reminderTime = event.reminder,
           let minutes = reminderTime.minutes,
           minutes != 0 {
            let alarm = EKAlarm(relativeOffset: TimeInterval(minutes * 60))
            ekEvent.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(ekEvent, span: .thisEvent)
            completion(true, ekEvent.eventIdentifier)
        } catch {
            print("Error saving event: \(error)")
            completion(false, nil)
        }
    }
    
    func updateEventInCalendar(_ event: CalendarEvent, completion: @escaping (Bool) -> Void) {
        guard authorizationStatus == .authorized,
              let identifier = event.calendarIdentifier,
              let ekEvent = eventStore.event(withIdentifier: identifier) else {
            completion(false)
            return
        }
        
        ekEvent.title = event.title
        ekEvent.notes = event.description
        ekEvent.startDate = event.date
        ekEvent.endDate = event.endDate
        ekEvent.location = event.location
        
        // Update reminder
        if let alarm = ekEvent.alarms?.first {
            ekEvent.removeAlarm(alarm)
        }
        if let reminderTime = event.reminder,
           let minutes = reminderTime.minutes,
           minutes != 0 {
            let alarm = EKAlarm(relativeOffset: TimeInterval(minutes * 60))
            ekEvent.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(ekEvent, span: .thisEvent)
            completion(true)
        } catch {
            print("Error updating event: \(error)")
            completion(false)
        }
    }
    
    func deleteEventFromCalendar(_ event: CalendarEvent, completion: @escaping (Bool) -> Void) {
        guard authorizationStatus == .authorized,
              let identifier = event.calendarIdentifier,
              let ekEvent = eventStore.event(withIdentifier: identifier) else {
            completion(false)
            return
        }
        
        do {
            try eventStore.remove(ekEvent, span: .thisEvent)
            completion(true)
        } catch {
            print("Error deleting event: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Helper Functions
    private func determineEventType(from ekEvent: EKEvent) -> CalendarEvent.EventType {
        let title = ekEvent.title?.lowercased() ?? ""
        
        if title.contains("exam") || title.contains("test") || title.contains("quiz") {
            return .exam
        } else if title.contains("assignment") || title.contains("homework") || title.contains("hw") {
            return .assignment
        } else if title.contains("meeting") || title.contains("appointment") {
            return .meeting
        } else if title.contains("class") || title.contains("lecture") {
            return .classSession
        } else if title.contains("study") || title.contains("review") {
            return .studySession
        } else if title.contains("due") || title.contains("deadline") {
            return .deadline
        }
        
        return .other
    }
    
    private func determineCategory(from ekEvent: EKEvent) -> TaskCategory {
        let title = ekEvent.title?.lowercased() ?? ""
        let notes = ekEvent.notes?.lowercased() ?? ""
        let combined = title + " " + notes
        
        if combined.contains("study") || combined.contains("homework") || combined.contains("class") {
            return .academic
        } else if combined.contains("exercise") || combined.contains("gym") || combined.contains("workout") {
            return .fitness
        } else if combined.contains("meeting") || combined.contains("social") || combined.contains("friend") {
            return .social
        } else if combined.contains("create") || combined.contains("design") || combined.contains("art") {
            return .creative
        } else if combined.contains("health") || combined.contains("doctor") || combined.contains("therapy") {
            return .health
        }
        
        return .academic  // Default category
    }
    
    private func determinePriority(from ekEvent: EKEvent) -> CalendarEvent.EventPriority {
        let title = ekEvent.title?.lowercased() ?? ""
        
        if title.contains("urgent") || title.contains("critical") || title.contains("important") {
            return .critical
        } else if title.contains("exam") || title.contains("deadline") {
            return .high
        }
        
        return .medium
    }
    
    private func extractCourse(from ekEvent: EKEvent) -> String {
        // Try to extract course codes like "CS101" or "MATH 200"
        let title = ekEvent.title ?? ""
        let pattern = #"[A-Z]{2,4}\s*\d{3,4}"#
        
        if let range = title.range(of: pattern, options: .regularExpression) {
            return String(title[range])
        }
        
        return ""
    }
    
    private func determineReminder(from ekEvent: EKEvent) -> ReminderTime? {
        guard let alarm = ekEvent.alarms?.first else { return nil }
        
        let minutes = Int(alarm.relativeOffset / 60)
        
        switch minutes {
        case 0: return .atTime
        case -5: return .fiveMinutes
        case -15: return .fifteenMinutes
        case -30: return .thirtyMinutes
        case -60: return .oneHour
        case -1440: return .oneDay
        default: return .fifteenMinutes
        }
    }
    
    // MARK: - Settings Persistence
    func saveSyncSettings() {
        if let encoded = try? JSONEncoder().encode(syncSettings) {
            UserDefaults.standard.set(encoded, forKey: "calendarSyncSettings")
        }
    }
    
    private func loadSyncSettings() {
        if let data = UserDefaults.standard.data(forKey: "calendarSyncSettings"),
           let decoded = try? JSONDecoder().decode(CalendarSyncSettings.self, from: data) {
            syncSettings = decoded
        }
    }
    
    // MARK: - Quest Conversion
    func createQuestFromEvent(_ event: CalendarEvent) -> Quest {
        var quest = Quest(
            title: event.title,
            description: event.description,
            category: event.category,
            difficulty: priorityToDifficulty(event.priority),
            estimatedTime: event.duration,
            dueDate: event.date
        )
        
        // Add subtasks based on event type
        if event.eventType == .exam {
            quest.subtasks = [
                Subtask(title: "Review lecture notes", estimatedTime: 30, order: 0),
                Subtask(title: "Complete practice problems", estimatedTime: 45, order: 1),
                Subtask(title: "Review past assignments", estimatedTime: 20, order: 2),
                Subtask(title: "Create summary sheet", estimatedTime: 25, order: 3)
            ]
        } else if event.eventType == .assignment {
            quest.subtasks = [
                Subtask(title: "Read requirements", estimatedTime: 10, order: 0),
                Subtask(title: "Research and gather resources", estimatedTime: 20, order: 1),
                Subtask(title: "Create outline", estimatedTime: 15, order: 2),
                Subtask(title: "Complete first draft", estimatedTime: event.duration / 2, order: 3),
                Subtask(title: "Review and finalize", estimatedTime: event.duration / 4, order: 4)
            ]
        }
        
        return quest
    }
    
    private func priorityToDifficulty(_ priority: CalendarEvent.EventPriority) -> Difficulty {
        switch priority {
        case .low: return .easy
        case .medium: return .medium
        case .high, .critical: return .hard
        }
    }
}