import Foundation
import SwiftUI

// MARK: - Task Verification
enum TaskVerification: String, CaseIterable, Codable {
    case selfReport = "Self Report"
    case timerBased = "Timer Based"
    case parentConfirm = "Parent Confirm"

    var icon: String {
        switch self {
        case .selfReport: return "checkmark.circle"
        case .timerBased: return "timer"
        case .parentConfirm: return "person.badge.shield.checkmark"
        }
    }
}

// MARK: - Gate Mode
enum GateMode: String, CaseIterable, Codable {
    case none = "None"
    case soft = "Soft"
    case hard = "Hard"

    var description: String {
        switch self {
        case .none: return "No restrictions"
        case .soft: return "Complete some tasks first"
        case .hard: return "Complete all tasks first"
        }
    }
}

// MARK: - Parent Task
struct ParentTask: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String = ""
    var category: TaskCategory
    var isRecurring: Bool = false
    var recurringDays: Set<Int> = [] // 1=Sun, 2=Mon, ..., 7=Sat
    var isCompleted: Bool = false
    var completedAt: Date?
    var createdAt: Date = Date()
    var assignedDate: Date?
    var verification: TaskVerification = .selfReport
    var energyReward: Int = 1
    var bonusXP: Int = 0
    var bonusGold: Int = 0
    var epicTitle: String?
    var mapRegionId: String?
}

// MARK: - Parent Task Settings
struct ParentTaskSettings: Codable {
    var gateMode: GateMode = .soft
    var softGateThreshold: Int = 3
    var isEnabled: Bool = false
}

// MARK: - Daily Task Progress
struct DailyTaskProgress: Codable {
    var date: Date = Date()
    var completedTaskIds: Set<UUID> = []
    var totalTasksToday: Int = 0
    var travelEnergyEarned: [String: Int] = [:]
    var taskStreakDays: Int = 0

    var isGateCleared: Bool {
        totalTasksToday > 0 && completedTaskIds.count >= totalTasksToday
    }

    var completedCount: Int {
        completedTaskIds.count
    }
}

// MARK: - Parent Task Result
struct ParentTaskResult {
    var energyEarned: Int = 0
    var regionId: String?
    var bonusXP: Int = 0
    var bonusGold: Int = 0
}
