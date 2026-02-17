import Foundation

// MARK: - Routine
struct Routine: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var type: RoutineType
    var steps: [RoutineStep] = []
    var isActive: Bool = true
    var targetTime: Int
    var color: String = "mindLabsPurple"
    var notificationTime: Date?
    var completionStreak: Int = 0
    var lastCompletedDate: Date?
    var createdDate: Date = Date()

    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }

    var totalEstimatedTime: Int {
        steps.reduce(0) { $0 + $1.estimatedTime }
    }

    var completedStepsToday: Int {
        steps.filter { step in
            guard let completedAt = step.lastCompletedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }.count
    }

    var progressToday: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedStepsToday) / Double(steps.count)
    }
}

// MARK: - Routine Step
struct RoutineStep: Identifiable, Codable {
    var id = UUID()
    var title: String
    var icon: String
    var estimatedTime: Int
    var order: Int
    var isOptional: Bool = false
    var lastCompletedAt: Date?
    var completionCount: Int = 0

    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompletedAt else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }

    mutating func markCompleted() {
        lastCompletedAt = Date()
        completionCount += 1
    }

    mutating func markIncomplete() {
        if isCompletedToday {
            lastCompletedAt = nil
            completionCount = max(0, completionCount - 1)
        }
    }
}

// MARK: - Routine Type
enum RoutineType: String, CaseIterable, Codable {
    case morning = "Morning"
    case evening = "Evening"
    case study = "Study"
    case exercise = "Exercise"
    case custom = "Custom"

    var defaultIcon: String {
        switch self {
        case .morning: return "☀️"
        case .evening: return "🌙"
        case .study: return "📚"
        case .exercise: return "💪"
        case .custom: return "⭐"
        }
    }

    var suggestedSteps: [(title: String, icon: String, time: Int)] {
        switch self {
        case .morning:
            return [
                ("Wake up & stretch", "🛏️", 5),
                ("Brush teeth", "🪥", 3),
                ("Shower", "🚿", 10),
                ("Get dressed", "👕", 5),
                ("Eat breakfast", "🥣", 15),
                ("Take medications", "💊", 2),
                ("Pack bag", "🎒", 5),
                ("Check schedule", "📅", 3)
            ]
        case .evening:
            return [
                ("Set out clothes for tomorrow", "👔", 5),
                ("Pack tomorrow's bag", "🎒", 5),
                ("Brush teeth", "🪥", 3),
                ("Wash face", "🧼", 2),
                ("Take medications", "💊", 2),
                ("Read or relax", "📖", 15),
                ("Set alarms", "⏰", 2),
                ("Lights out", "🛏️", 1)
            ]
        case .study:
            return [
                ("Clear desk space", "🧹", 3),
                ("Gather materials", "📚", 5),
                ("Review goals", "🎯", 3),
                ("Focus session 1", "🧠", 25),
                ("Short break", "☕", 5),
                ("Focus session 2", "🧠", 25),
                ("Review & organize notes", "📝", 10)
            ]
        case .exercise:
            return [
                ("Change into workout clothes", "👟", 5),
                ("Warm up", "🏃", 5),
                ("Main exercise", "💪", 20),
                ("Cool down", "🧘", 5),
                ("Shower", "🚿", 10),
                ("Hydrate", "💧", 2)
            ]
        case .custom:
            return []
        }
    }
}
