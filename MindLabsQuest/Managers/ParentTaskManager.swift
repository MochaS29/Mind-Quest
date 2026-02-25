import Foundation
import SwiftUI
import Combine

class ParentTaskManager: ObservableObject {
    @Published var tasks: [ParentTask] = []
    @Published var settings: ParentTaskSettings = ParentTaskSettings()
    @Published var dailyProgress: DailyTaskProgress = DailyTaskProgress()

    private let tasksKey = "parentTasks"
    private let settingsKey = "parentTaskSettings"
    private let progressKey = "parentDailyProgress"

    // MARK: - CRUD

    func addTask(_ task: ParentTask) {
        var newTask = task
        newTask.createdAt = Date()
        tasks.append(newTask)
        saveData()
    }

    func updateTask(_ task: ParentTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveData()
        }
    }

    func deleteTask(_ taskId: UUID) {
        tasks.removeAll { $0.id == taskId }
        saveData()
    }

    // MARK: - Task Completion

    func completeTask(_ taskId: UUID) -> ParentTaskResult? {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return nil }
        guard !tasks[index].isCompleted else { return nil }

        tasks[index].isCompleted = true
        tasks[index].completedAt = Date()

        dailyProgress.completedTaskIds.insert(taskId)

        let task = tasks[index]
        var result = ParentTaskResult()
        result.energyEarned = task.energyReward
        result.regionId = task.mapRegionId ?? RegionDatabase.categoryRegionMap[task.category]
        result.bonusXP = task.bonusXP
        result.bonusGold = task.bonusGold

        // Track travel energy earned
        if let regionId = result.regionId {
            let current = dailyProgress.travelEnergyEarned[regionId] ?? 0
            dailyProgress.travelEnergyEarned[regionId] = current + task.energyReward
        }

        saveData()
        return result
    }

    // MARK: - Gate Logic

    var isGameGated: Bool {
        guard settings.isEnabled else { return false }

        switch settings.gateMode {
        case .none:
            return false
        case .soft:
            return dailyProgress.completedCount < settings.softGateThreshold
                && dailyProgress.completedCount < dailyProgress.totalTasksToday
        case .hard:
            return !dailyProgress.isGateCleared
        }
    }

    var gateProgress: (completed: Int, required: Int) {
        switch settings.gateMode {
        case .none:
            return (dailyProgress.completedCount, 0)
        case .soft:
            let required = min(settings.softGateThreshold, dailyProgress.totalTasksToday)
            return (dailyProgress.completedCount, required)
        case .hard:
            return (dailyProgress.completedCount, dailyProgress.totalTasksToday)
        }
    }

    // MARK: - Today's Tasks

    var todaysTasks: [ParentTask] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date()) // 1=Sun, 7=Sat
        return tasks.filter { task in
            if task.isRecurring {
                return task.recurringDays.contains(weekday)
            }
            // Non-recurring: show if created today or not yet completed
            if let assigned = task.assignedDate {
                return calendar.isDateInToday(assigned)
            }
            return !task.isCompleted
        }
    }

    var todaysCompletedTasks: [ParentTask] {
        todaysTasks.filter { $0.isCompleted }
    }

    var todaysPendingTasks: [ParentTask] {
        todaysTasks.filter { !$0.isCompleted }
    }

    // MARK: - Travel Energy

    func travelEnergyForRegion(_ regionId: String) -> Int {
        dailyProgress.travelEnergyEarned[regionId] ?? 0
    }

    func hasTravelEnergyForRegion(_ regionId: String) -> Bool {
        travelEnergyForRegion(regionId) > 0
    }

    // MARK: - Daily Refresh

    func refreshDailyIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        let progressDate = Calendar.current.startOfDay(for: dailyProgress.date)

        if !Calendar.current.isDate(progressDate, inSameDayAs: today) {
            // Update streak: if yesterday's tasks were all completed, increment; else reset
            let previousStreak = dailyProgress.taskStreakDays
            let allDoneYesterday = dailyProgress.isGateCleared && dailyProgress.totalTasksToday > 0

            // Reset completed status for recurring tasks
            for i in 0..<tasks.count {
                if tasks[i].isRecurring {
                    tasks[i].isCompleted = false
                    tasks[i].completedAt = nil
                }
            }

            dailyProgress = DailyTaskProgress()
            dailyProgress.date = today
            dailyProgress.totalTasksToday = todaysTasks.count
            dailyProgress.taskStreakDays = allDoneYesterday ? previousStreak + 1 : 0
            saveData()
        } else {
            dailyProgress.totalTasksToday = todaysTasks.count
        }
    }

    // MARK: - Persistence

    func saveData() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
        if let encoded = try? JSONEncoder().encode(dailyProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([ParentTask].self, from: data) {
            tasks = decoded
        }
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(ParentTaskSettings.self, from: data) {
            settings = decoded
        }
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(DailyTaskProgress.self, from: data) {
            dailyProgress = decoded
        }
    }

    func resetAll() {
        tasks = []
        settings = ParentTaskSettings()
        dailyProgress = DailyTaskProgress()
        UserDefaults.standard.removeObject(forKey: tasksKey)
        UserDefaults.standard.removeObject(forKey: settingsKey)
        UserDefaults.standard.removeObject(forKey: progressKey)
    }
}
