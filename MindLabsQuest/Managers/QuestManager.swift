import Foundation

class QuestManager: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var timeEstimateHistory = TimeEstimateHistory()
    @Published var activeTimerQuestId: UUID?
    @Published var showQuestCompletionAnimation = false
    @Published var completedQuest: Quest?
    @Published var lastXPEarned = 0
    @Published var lastGoldEarned = 0

    // MARK: - Quest Management
    func addQuest(_ quest: Quest) {
        quests.append(quest)
    }

    func completeQuest(_ quest: Quest, character: inout Character, achievementManager: AchievementManager, onLevelUp: () -> Void) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }

        quests[index].isCompleted = true
        quests[index].completedAt = Date()

        if quests[index].actualTimeSpent > 0 {
            timeEstimateHistory.updateWithCompletedQuest(quests[index])
        }

        // Calculate XP reward
        var xpReward = quest.xpReward
        if let characterClass = character.characterClass,
           quest.category.primaryStat == characterClass.primaryStat {
            xpReward *= 2
        }

        character.xp += xpReward
        character.gold += quest.goldReward

        lastXPEarned = xpReward
        lastGoldEarned = quest.goldReward
        completedQuest = quests[index]

        // Increase stats
        character.stats[quest.category.primaryStat, default: 10] += 1
        character.stats[quest.category.secondaryStat, default: 10] += 1

        showQuestCompletionAnimation = true

        // Level up check
        while character.xp >= character.xpToNext {
            onLevelUp()
        }

        // Restore some health
        character.health = min(character.maxHealth, character.health + 5)

        // Update achievement tracking
        character.totalQuestsCompleted += 1
        character.questCategoriesCompleted.insert(quest.category.rawValue)

        achievementManager.checkQuestAchievements(totalCompleted: character.totalQuestsCompleted)
        achievementManager.checkCollectionAchievements(
            uniqueClasses: character.uniqueClassesPlayed.count,
            categoriesCompleted: character.questCategoriesCompleted.count
        )
    }

    func reactivateQuest(_ quest: Quest, character: inout Character) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }

        if let completedAt = quests[index].completedAt,
           Date().timeIntervalSince(completedAt) < 3600 {
            quests[index].isCompleted = false
            quests[index].completedAt = nil

            var xpToRemove = quest.xpReward
            if let characterClass = character.characterClass,
               quest.category.primaryStat == characterClass.primaryStat {
                xpToRemove *= 2
            }

            character.xp = max(0, character.xp - xpToRemove)
            character.gold = max(0, character.gold - quest.goldReward)
            character.stats[quest.category.primaryStat, default: 10] = max(1, character.stats[quest.category.primaryStat, default: 10] - 1)
            character.stats[quest.category.secondaryStat, default: 10] = max(1, character.stats[quest.category.secondaryStat, default: 10] - 1)
        }
    }

    // MARK: - Subtask Management
    func toggleSubtask(_ subtaskId: UUID, in questId: UUID, character: inout Character, onLevelUp: () -> Void) {
        guard let questIndex = quests.firstIndex(where: { $0.id == questId }),
              let subtaskIndex = quests[questIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) else {
            return
        }

        quests[questIndex].subtasks[subtaskIndex].toggleCompletion()

        if quests[questIndex].subtasks[subtaskIndex].isCompleted {
            let totalSubtasks = quests[questIndex].subtasks.count
            let baseXP = quests[questIndex].difficulty.xpReward
            let xpPerSubtask = baseXP / totalSubtasks

            character.xp += xpPerSubtask

            while character.xp >= character.xpToNext {
                onLevelUp()
            }
        }
    }

    func updateQuestSubtasks(_ questId: UUID, subtasks: [Subtask]) {
        guard let index = quests.firstIndex(where: { $0.id == questId }) else { return }
        quests[index].subtasks = subtasks
    }

    func convertSubtaskToQuest(_ subtaskId: UUID, from questId: UUID) {
        guard let questIndex = quests.firstIndex(where: { $0.id == questId }),
              let subtaskIndex = quests[questIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) else {
            return
        }

        let subtask = quests[questIndex].subtasks[subtaskIndex]
        let parentQuest = quests[questIndex]

        let newQuest = Quest(
            title: subtask.title,
            description: "Converted from subtask of: \(parentQuest.title)",
            category: parentQuest.category,
            difficulty: .easy,
            estimatedTime: subtask.estimatedTime,
            dueDate: parentQuest.dueDate
        )

        quests[questIndex].subtasks.remove(at: subtaskIndex)
        addQuest(newQuest)
    }

    // MARK: - Daily Quest Management
    func checkAndRefreshDailyQuests(character: Character) {
        let today = Calendar.current.startOfDay(for: Date())
        let hasQuestsForToday = quests.contains { quest in
            quest.isDaily && Calendar.current.isDate(quest.createdDate, inSameDayAs: today)
        }

        if !hasQuestsForToday {
            createDailyQuests(character: character)
        }
    }

    func createDailyQuests(character: Character) {
        let today = Calendar.current.startOfDay(for: Date())
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!

        quests = quests.filter { quest in
            if quest.isDaily {
                return quest.createdDate >= sevenDaysAgo
            }
            return true
        }

        let hasQuestsForToday = quests.contains { quest in
            quest.isDaily && Calendar.current.isDate(quest.createdDate, inSameDayAs: today)
        }

        if hasQuestsForToday { return }

        for templateId in character.dailyQuestIds {
            if let template = DailyQuestTemplate.allTemplates.first(where: { $0.id == templateId }) {
                var quest = Quest(
                    title: template.epicTitle,
                    description: template.normalTitle,
                    category: template.category,
                    difficulty: template.difficulty,
                    estimatedTime: template.estimatedTime,
                    isDaily: true,
                    questTemplate: template
                )
                quest.createdDate = today
                quests.append(quest)
            }
        }
    }

    // MARK: - Time Tracking
    func startTimeTracking(for questId: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == questId }) else { return }
        quests[index].startedAt = Date()
        activeTimerQuestId = questId
    }

    func stopTimeTracking(for questId: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == questId }),
              let startedAt = quests[index].startedAt else { return }

        let endTime = Date()
        let session = TimeSession(startTime: startedAt, endTime: endTime)
        quests[index].timeSpentSessions.append(session)
        quests[index].actualTimeSpent += session.duration
        quests[index].startedAt = nil

        if activeTimerQuestId == questId {
            activeTimerQuestId = nil
        }
    }

    func getTimeEstimateSuggestion(for category: TaskCategory, originalEstimate: Int) -> TimeEstimateSuggestion {
        return timeEstimateHistory.getSuggestion(for: category, originalEstimate: originalEstimate)
    }

    // MARK: - Computed Properties
    var todayQuests: [Quest] {
        let calendar = Calendar.current
        return quests.filter { quest in
            if let dueDate = quest.dueDate {
                return calendar.isDateInToday(dueDate)
            }
            return false
        }
    }

    var completedQuestsToday: Int {
        let calendar = Calendar.current
        return quests.filter { quest in
            guard quest.isCompleted else { return false }
            if let completedDate = quest.completedAt {
                return calendar.isDateInToday(completedDate)
            }
            return false
        }.count
    }

    var activeQuests: [Quest] {
        quests.filter { !$0.isCompleted }
    }

    var pendingQuestsCount: Int {
        quests.filter { !$0.isCompleted }.count
    }
}
