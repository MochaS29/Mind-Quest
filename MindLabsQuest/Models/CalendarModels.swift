import Foundation
import SwiftUI

// MARK: - Recurrence Rule
struct RecurrenceRule: Codable, Equatable {
    enum Frequency: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"

        var calendarComponent: Calendar.Component {
            switch self {
            case .daily: return .day
            case .weekly, .biweekly: return .weekOfYear
            case .monthly: return .month
            case .yearly: return .year
            }
        }

        var interval: Int {
            switch self {
            case .biweekly: return 2
            default: return 1
            }
        }
    }

    var frequency: Frequency
    var interval: Int = 1
    var daysOfWeek: [Int] = []
    var dayOfMonth: Int?
    var monthOfYear: Int?

    var description: String {
        switch frequency {
        case .daily:
            return interval == 1 ? "Daily" : "Every \(interval) days"
        case .weekly:
            if daysOfWeek.isEmpty {
                return "Weekly"
            } else {
                let dayNames = daysOfWeek.map { dayName(for: $0) }.joined(separator: ", ")
                return "Weekly on \(dayNames)"
            }
        case .biweekly:
            return "Every 2 weeks"
        case .monthly:
            if let day = dayOfMonth {
                return "Monthly on day \(day)"
            }
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }

    private func dayName(for dayNumber: Int) -> String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[dayNumber - 1]
    }
}

// MARK: - Calendar Event
struct CalendarEvent: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String = ""
    var date: Date
    var duration: Int = 60
    var eventType: EventType
    var category: TaskCategory
    var priority: EventPriority = .medium
    var courseOrSubject: String = ""
    var location: String = ""
    var reminder: ReminderTime?
    var isCompleted: Bool = false
    var convertedToQuest: Bool = false
    var relatedQuestId: UUID?
    var calendarIdentifier: String?

    var isRecurring: Bool = false
    var recurrenceRule: RecurrenceRule?
    var recurrenceEndDate: Date?
    var recurrenceCount: Int?
    var originalEventId: UUID?
    var exceptionDates: [Date] = []
    var attendees: [String] = []

    var endDate: Date {
        Calendar.current.date(byAdding: .minute, value: duration, to: date) ?? date
    }

    enum EventType: String, CaseIterable, Codable {
        case classSession = "Class Session"
        case assignment = "Assignment"
        case exam = "Exam"
        case project = "Project"
        case presentation = "Presentation"
        case meeting = "Meeting"
        case studySession = "Study Session"
        case deadline = "Deadline"
        case extracurricular = "Activity"
        case personal = "Personal"
        case other = "Other"

        var icon: String {
            switch self {
            case .classSession: return "📚"
            case .assignment: return "📝"
            case .exam: return "📋"
            case .project: return "🎯"
            case .presentation: return "🎤"
            case .meeting: return "👥"
            case .studySession: return "🧠"
            case .deadline: return "⏰"
            case .extracurricular: return "🎭"
            case .personal: return "⭐"
            case .other: return "📌"
            }
        }

        var defaultDifficulty: Difficulty {
            switch self {
            case .exam, .presentation: return .hard
            case .project, .assignment: return .medium
            default: return .easy
            }
        }
    }

    enum EventPriority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"

        var color: Color {
            switch self {
            case .low: return .mindLabsTextSecondary
            case .medium: return .mindLabsWarning
            case .high: return .mindLabsError
            case .critical: return .red
            }
        }

        var xpMultiplier: Double {
            switch self {
            case .low: return 0.8
            case .medium: return 1.0
            case .high: return 1.3
            case .critical: return 1.6
            }
        }
    }
}

// MARK: - Reminder Time
enum ReminderTime: String, CaseIterable, Codable {
    case none = "None"
    case atTime = "At time of event"
    case fiveMinutes = "5 minutes before"
    case fifteenMinutes = "15 minutes before"
    case thirtyMinutes = "30 minutes before"
    case oneHour = "1 hour before"
    case oneDay = "1 day before"

    var minutes: Int? {
        switch self {
        case .none: return nil
        case .atTime: return 0
        case .fiveMinutes: return -5
        case .fifteenMinutes: return -15
        case .thirtyMinutes: return -30
        case .oneHour: return -60
        case .oneDay: return -1440
        }
    }
}

// MARK: - Calendar Sync Settings
struct CalendarSyncSettings: Codable {
    var isEnabled: Bool = false
    var selectedCalendarIdentifier: String?
    var autoConvertToQuests: Bool = false
    var syncPastDays: Int = 7
    var syncFutureDays: Int = 30
}

// MARK: - CalendarEvent Convenience Init
extension CalendarEvent {
    init(
        title: String,
        description: String = "",
        date: Date,
        duration: Int = 60,
        eventType: EventType,
        category: TaskCategory,
        priority: EventPriority = .medium,
        courseOrSubject: String = "",
        location: String = "",
        reminder: ReminderTime? = nil,
        attendees: [String] = [],
        isRecurring: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        recurrenceEndDate: Date? = nil,
        recurrenceCount: Int? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.date = date
        self.duration = duration
        self.eventType = eventType
        self.category = category
        self.priority = priority
        self.courseOrSubject = courseOrSubject
        self.location = location
        self.reminder = reminder
        self.isCompleted = false
        self.convertedToQuest = false
        self.relatedQuestId = nil
        self.calendarIdentifier = nil
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.recurrenceEndDate = recurrenceEndDate
        self.recurrenceCount = recurrenceCount
        self.originalEventId = nil
        self.exceptionDates = []
        self.attendees = attendees
    }

    func toQuest() -> Quest {
        let baseTitle = "\(eventType.icon) \(title)"
        let questTitle = priority == .critical ? "⚡ \(baseTitle)" : baseTitle

        return Quest(
            title: questTitle,
            description: "\(courseOrSubject.isEmpty ? "" : "[\(courseOrSubject)] ")\(description)",
            category: category,
            difficulty: eventType.defaultDifficulty,
            estimatedTime: duration,
            dueDate: date
        )
    }
}
