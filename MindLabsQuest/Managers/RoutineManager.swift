import Foundation
import UserNotifications

class RoutineManager: ObservableObject {
    @Published var routines: [Routine] = []

    // MARK: - CRUD
    func addRoutine(_ routine: Routine) {
        routines.append(routine)
    }

    func updateRoutine(_ routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index] = routine
        }
    }

    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
    }

    // MARK: - Step Completion
    func toggleRoutineStep(_ stepId: UUID, in routineId: UUID, character: inout Character, onLevelUp: () -> Void) {
        guard let routineIndex = routines.firstIndex(where: { $0.id == routineId }),
              let stepIndex = routines[routineIndex].steps.firstIndex(where: { $0.id == stepId }) else {
            return
        }

        if routines[routineIndex].steps[stepIndex].isCompletedToday {
            routines[routineIndex].steps[stepIndex].markIncomplete()
        } else {
            routines[routineIndex].steps[stepIndex].markCompleted()

            character.xp += 5

            if routines[routineIndex].steps.allSatisfy({ $0.isCompletedToday || $0.isOptional }) {
                completeRoutine(&routines[routineIndex], character: &character, onLevelUp: onLevelUp)
            }
        }
    }

    private func completeRoutine(_ routine: inout Routine, character: inout Character, onLevelUp: () -> Void) {
        routine.lastCompletedDate = Date()

        let calendar = Calendar.current
        if let lastCompleted = routine.lastCompletedDate {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
            if calendar.isDate(lastCompleted, inSameDayAs: yesterday) {
                routine.completionStreak += 1
            } else if !calendar.isDateInToday(lastCompleted) {
                routine.completionStreak = 1
            }
        } else {
            routine.completionStreak = 1
        }

        character.xp += 25
        character.gold += 10

        while character.xp >= character.xpToNext {
            onLevelUp()
        }

        character.totalQuestsCompleted += 1
    }

    // MARK: - Notifications
    func scheduleRoutineNotification(_ routine: Routine) {
        guard let notificationTime = routine.notificationTime else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(routine.icon) Time for \(routine.name)!"
        content.body = "Start your \(routine.type.rawValue.lowercased()) routine to keep your streak going!"
        content.sound = .default
        content.categoryIdentifier = "ROUTINE_REMINDER"

        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "routine_\(routine.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
