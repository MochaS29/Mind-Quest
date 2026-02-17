import Foundation
import SwiftUI

class GameManager: ObservableObject {
    let achievementManager = AchievementManager()
    let parentRewardManager = ParentRewardManager()
    @Published var character = Character()
    @Published var quests: [Quest] = []
    @Published var isCharacterCreated = false
    @Published var currentView: AppView = .characterCreation
    @Published var showLevelUpAnimation = false
    @Published var newLevel = 1
    @Published var showQuestCompletionAnimation = false
    @Published var completedQuest: Quest?
    @Published var lastXPEarned = 0
    @Published var lastGoldEarned = 0
    @Published var lastStreakCheck = Date()
    @Published var showStreakMessage = false
    @Published var streakMessage = ""
    @Published var routines: [Routine] = []
    @Published var timeEstimateHistory = TimeEstimateHistory()
    @Published var activeTimerQuestId: UUID?
    
    enum AppView {
        case characterCreation
        case dashboard
        case quests
        case character
        case timer
        case calendar
        case routines
        case analytics
        case settings
        case social
        case support
        case challenges
    }
    
    init() {
        loadData()
        checkAndRefreshDailyQuests()
        checkAndUpdateStreak()
    }
    
    // MARK: - Character Creation
    func createCharacter(name: String, characterClass: CharacterClass, background: Background, avatar: String, traits: [CharacterTrait] = [], motivation: CharacterMotivation, dailyQuestIds: Set<String> = []) {
        character.name = name
        character.characterClass = characterClass
        character.background = background
        character.avatar = avatar
        character.traits = traits
        character.motivation = motivation
        character.dailyQuestIds = dailyQuestIds
        
        // Apply class bonuses
        let bonuses = characterClass.statBonuses
        for (stat, bonus) in bonuses {
            character.stats[stat, default: 10] += bonus
        }
        
        // Apply background bonuses
        for (stat, bonus) in background.bonuses {
            character.stats[stat, default: 10] += bonus
        }
        
        // Apply trait bonuses
        character.applyTraitBonuses()
        
        // Track unique classes played
        if let className = characterClass.rawValue as String? {
            character.uniqueClassesPlayed.insert(className)
        }
        
        // Create initial daily quests
        createDailyQuests()
        
        isCharacterCreated = true
        currentView = .dashboard
        saveData()
    }
    
    // MARK: - Daily Quest Management
    func checkAndRefreshDailyQuests() {
        guard isCharacterCreated else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let hasQuestsForToday = quests.contains { quest in
            quest.isDaily && Calendar.current.isDate(quest.createdDate, inSameDayAs: today)
        }
        
        if !hasQuestsForToday {
            createDailyQuests()
        }
    }
    
    func createDailyQuests() {
        let today = Calendar.current.startOfDay(for: Date())
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        
        // Remove daily quests older than 7 days
        quests = quests.filter { quest in
            if quest.isDaily {
                return quest.createdDate >= sevenDaysAgo
            }
            return true
        }
        
        // Check if we already have quests for today
        let hasQuestsForToday = quests.contains { quest in
            quest.isDaily && Calendar.current.isDate(quest.createdDate, inSameDayAs: today)
        }
        
        if hasQuestsForToday {
            return
        }
        
        // Create quests from selected templates
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
        
        saveData()
    }
    
    // MARK: - Quest Management
    func addQuest(_ quest: Quest) {
        quests.append(quest)
        saveData()
    }
    
    // MARK: - Subtask Management
    func toggleSubtask(_ subtaskId: UUID, in questId: UUID) {
        guard let questIndex = quests.firstIndex(where: { $0.id == questId }),
              let subtaskIndex = quests[questIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) else {
            return
        }
        
        quests[questIndex].subtasks[subtaskIndex].toggleCompletion()
        
        // Award partial XP for subtask completion
        if quests[questIndex].subtasks[subtaskIndex].isCompleted {
            let totalSubtasks = quests[questIndex].subtasks.count
            let baseXP = quests[questIndex].difficulty.xpReward
            let xpPerSubtask = baseXP / totalSubtasks
            
            character.xp += xpPerSubtask
            
            // Check for level up
            while character.xp >= character.xpToNext {
                levelUp()
            }
        }
        
        // Check if all subtasks are complete
        if quests[questIndex].subtasks.allSatisfy({ $0.isCompleted }) && !quests[questIndex].isCompleted {
            // Optionally auto-complete the quest
            // completeQuest(quests[questIndex])
        }
        
        saveData()
    }
    
    func updateQuestSubtasks(_ questId: UUID, subtasks: [Subtask]) {
        guard let index = quests.firstIndex(where: { $0.id == questId }) else { return }
        quests[index].subtasks = subtasks
        saveData()
    }
    
    func convertSubtaskToQuest(_ subtaskId: UUID, from questId: UUID) {
        guard let questIndex = quests.firstIndex(where: { $0.id == questId }),
              let subtaskIndex = quests[questIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) else {
            return
        }
        
        let subtask = quests[questIndex].subtasks[subtaskIndex]
        let parentQuest = quests[questIndex]
        
        // Create new quest from subtask
        let newQuest = Quest(
            title: subtask.title,
            description: "Converted from subtask of: \(parentQuest.title)",
            category: parentQuest.category,
            difficulty: .easy,
            estimatedTime: subtask.estimatedTime,
            dueDate: parentQuest.dueDate
        )
        
        // Remove subtask and add quest
        quests[questIndex].subtasks.remove(at: subtaskIndex)
        addQuest(newQuest)
    }
    
    func completeQuest(_ quest: Quest) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        
        quests[index].isCompleted = true
        quests[index].completedAt = Date()
        
        // Update time tracking if quest was tracked
        if quests[index].actualTimeSpent > 0 {
            timeEstimateHistory.updateWithCompletedQuest(quests[index])
        }
        
        // Award XP and Gold
        var xpReward = quest.xpReward
        
        // Double XP if quest category matches class primary stat
        if let characterClass = character.characterClass,
           quest.category.primaryStat == characterClass.primaryStat {
            xpReward *= 2
        }
        
        character.xp += xpReward
        character.gold += quest.goldReward
        
        // Store for animation
        lastXPEarned = xpReward
        lastGoldEarned = quest.goldReward
        completedQuest = quests[index]
        
        // Increase stats
        character.stats[quest.category.primaryStat, default: 10] += 1
        character.stats[quest.category.secondaryStat, default: 10] += 1
        
        // Show quest completion animation
        showQuestCompletionAnimation = true
        
        // Check for level up
        while character.xp >= character.xpToNext {
            levelUp()
        }
        
        // Restore some health
        character.health = min(character.maxHealth, character.health + 5)
        
        // Update streak
        updateStreakForCompletion()
        
        // Update achievement tracking
        character.totalQuestsCompleted += 1
        character.questCategoriesCompleted.insert(quest.category.rawValue)
        
        // Check achievements
        achievementManager.checkQuestAchievements(totalCompleted: character.totalQuestsCompleted)
        achievementManager.checkCollectionAchievements(
            uniqueClasses: character.uniqueClassesPlayed.count,
            categoriesCompleted: character.questCategoriesCompleted.count
        )
        
        saveData()
    }
    
    func reactivateQuest(_ quest: Quest) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        
        // Only allow reactivation if quest was completed recently (within 1 hour)
        if let completedAt = quests[index].completedAt,
           Date().timeIntervalSince(completedAt) < 3600 { // 1 hour
            
            quests[index].isCompleted = false
            quests[index].completedAt = nil
            
            // Remove the rewards
            var xpToRemove = quest.xpReward
            
            // Double XP if quest category matches class primary stat
            if let characterClass = character.characterClass,
               quest.category.primaryStat == characterClass.primaryStat {
                xpToRemove *= 2
            }
            
            character.xp = max(0, character.xp - xpToRemove)
            character.gold = max(0, character.gold - quest.goldReward)
            
            // Decrease stats
            character.stats[quest.category.primaryStat, default: 10] = max(1, character.stats[quest.category.primaryStat, default: 10] - 1)
            character.stats[quest.category.secondaryStat, default: 10] = max(1, character.stats[quest.category.secondaryStat, default: 10] - 1)
            
            saveData()
        }
    }
    
    private func levelUp() {
        character.xp -= character.xpToNext
        character.level += 1
        character.xpToNext = character.level * 100
        character.maxHealth += 10
        character.health = character.maxHealth
        character.gold += character.level * 10
        
        // Trigger level up animation
        newLevel = character.level
        showLevelUpAnimation = true
        
        // Check level achievements
        achievementManager.checkLevelAchievements(currentLevel: character.level)
    }
    
    // MARK: - Routine Management
    func addRoutine(_ routine: Routine) {
        routines.append(routine)
        saveData()
    }
    
    func updateRoutine(_ routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index] = routine
            saveData()
        }
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        saveData()
    }
    
    func toggleRoutineStep(_ stepId: UUID, in routineId: UUID) {
        guard let routineIndex = routines.firstIndex(where: { $0.id == routineId }),
              let stepIndex = routines[routineIndex].steps.firstIndex(where: { $0.id == stepId }) else {
            return
        }
        
        if routines[routineIndex].steps[stepIndex].isCompletedToday {
            routines[routineIndex].steps[stepIndex].markIncomplete()
        } else {
            routines[routineIndex].steps[stepIndex].markCompleted()
            
            // Award XP for completing a step
            character.xp += 5
            
            // Check if routine is complete
            if routines[routineIndex].steps.allSatisfy({ $0.isCompletedToday || $0.isOptional }) {
                completeRoutine(&routines[routineIndex])
            }
        }
        
        saveData()
    }
    
    private func completeRoutine(_ routine: inout Routine) {
        routine.lastCompletedDate = Date()
        
        // Update streak
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
        
        // Award bonus XP for completing routine
        character.xp += 25
        character.gold += 10
        
        // Check for level up
        while character.xp >= character.xpToNext {
            levelUp()
        }
        
        // Achievement tracking
        character.totalQuestsCompleted += 1
        achievementManager.checkQuestAchievements(totalCompleted: character.totalQuestsCompleted)
    }
    
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
    
    // MARK: - Persistence
    func saveData() {
        if let encoded = try? JSONEncoder().encode(character) {
            UserDefaults.standard.set(encoded, forKey: "character")
        }
        if let encoded = try? JSONEncoder().encode(quests) {
            UserDefaults.standard.set(encoded, forKey: "quests")
        }
        if let encoded = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(encoded, forKey: "routines")
        }
        if let encoded = try? JSONEncoder().encode(timeEstimateHistory) {
            UserDefaults.standard.set(encoded, forKey: "timeEstimateHistory")
        }
        UserDefaults.standard.set(isCharacterCreated, forKey: "isCharacterCreated")
        UserDefaults.standard.set(lastStreakCheck, forKey: "lastStreakCheck")
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "character"),
           let decoded = try? JSONDecoder().decode(Character.self, from: data) {
            character = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "quests"),
           let decoded = try? JSONDecoder().decode([Quest].self, from: data) {
            quests = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "routines"),
           let decoded = try? JSONDecoder().decode([Routine].self, from: data) {
            routines = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "timeEstimateHistory"),
           let decoded = try? JSONDecoder().decode(TimeEstimateHistory.self, from: data) {
            timeEstimateHistory = decoded
        }
        isCharacterCreated = UserDefaults.standard.bool(forKey: "isCharacterCreated")
        if isCharacterCreated {
            currentView = .dashboard
        }
        
        if let streakDate = UserDefaults.standard.object(forKey: "lastStreakCheck") as? Date {
            lastStreakCheck = streakDate
        }
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
    
    var completedTodayCount: Int {
        todayQuests.filter { $0.isCompleted }.count
    }
    
    var activeQuests: [Quest] {
        quests.filter { !$0.isCompleted }
    }
    
    var pendingQuestsCount: Int {
        quests.filter { !$0.isCompleted }.count
    }
    
    // MARK: - Focus Time Tracking
    func addFocusMinutes(_ minutes: Int) {
        character.totalFocusMinutes += minutes
        
        // Check focus achievements
        achievementManager.checkFocusAchievements(
            sessionMinutes: minutes,
            totalMinutes: character.totalFocusMinutes
        )
        
        saveData()
    }
    
    // MARK: - Time Tracking for Quests
    func startTimeTracking(for questId: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == questId }) else { return }
        
        quests[index].startedAt = Date()
        activeTimerQuestId = questId
        saveData()
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
        
        saveData()
    }
    
    func getTimeEstimateSuggestion(for category: TaskCategory, originalEstimate: Int) -> TimeEstimateSuggestion {
        return timeEstimateHistory.getSuggestion(for: category, originalEstimate: originalEstimate)
    }
    
    // MARK: - Streak Management
    func checkAndUpdateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastCheck = calendar.startOfDay(for: lastStreakCheck)
        
        // If it's a new day
        if !calendar.isDate(today, inSameDayAs: lastCheck) {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            
            // Check if any quest was completed yesterday
            let completedYesterday = quests.contains { quest in
                if let completedAt = quest.completedAt {
                    return calendar.isDate(completedAt, inSameDayAs: yesterday)
                }
                return false
            }
            
            if completedYesterday {
                // Continue streak if completed something yesterday
                if calendar.isDate(lastCheck, inSameDayAs: yesterday) {
                    // Already updated yesterday, keep streak
                } else {
                    // Missed days in between, reset streak
                    character.streak = 0
                }
            } else if calendar.dateComponents([.day], from: lastCheck, to: today).day ?? 0 > 1 {
                // Missed more than one day, reset streak
                character.streak = 0
                streakMessage = "Streak lost! Complete a quest to start a new one."
                showStreakMessage = true
            }
            
            lastStreakCheck = today
            saveData()
        }
    }
    
    func updateStreakForCompletion() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastCheck = calendar.startOfDay(for: lastStreakCheck)
        
        // Check if this is the first completion today
        let completionsToday = quests.filter { quest in
            if let completedAt = quest.completedAt {
                return calendar.isDate(completedAt, inSameDayAs: today)
            }
            return false
        }.count
        
        if completionsToday == 1 {
            // First completion today
            if calendar.isDate(lastCheck, inSameDayAs: today) {
                // Already checked today, just update
            } else {
                // New day, increase streak
                character.streak += 1
                lastStreakCheck = today
                
                // Streak milestones
                switch character.streak {
                case 3:
                    streakMessage = "3-day streak! You're building momentum! 🔥"
                    character.gold += 25
                case 7:
                    streakMessage = "Week-long streak! Amazing consistency! 🔥🔥"
                    character.gold += 50
                    character.xp += 100
                case 14:
                    streakMessage = "2-week streak! You're unstoppable! 🔥🔥🔥"
                    character.gold += 100
                    character.xp += 200
                case 30:
                    streakMessage = "30-day streak! Legendary dedication! 🏆"
                    character.gold += 250
                    character.xp += 500
                default:
                    streakMessage = "\(character.streak)-day streak! Keep it up! 🔥"
                }
                
                showStreakMessage = true
                
                // Check streak achievements
                achievementManager.checkStreakAchievements(currentStreak: character.streak)
            }
            
            saveData()
        }
    }
    
    // MARK: - Reset Data
    func resetAllData() {
        // Reset all properties
        character = Character()
        quests = []
        routines = []
        timeEstimateHistory = TimeEstimateHistory()
        isCharacterCreated = false
        currentView = .characterCreation
        showLevelUpAnimation = false
        showQuestCompletionAnimation = false
        completedQuest = nil
        lastXPEarned = 0
        lastGoldEarned = 0
        lastStreakCheck = Date()
        showStreakMessage = false
        streakMessage = ""
        activeTimerQuestId = nil
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "character")
        UserDefaults.standard.removeObject(forKey: "quests")
        UserDefaults.standard.removeObject(forKey: "routines")
        UserDefaults.standard.removeObject(forKey: "timeEstimateHistory")
        UserDefaults.standard.removeObject(forKey: "isCharacterCreated")
        UserDefaults.standard.removeObject(forKey: "lastStreakCheck")
        
        // Reset managers
        achievementManager.resetAll()
        parentRewardManager.resetAll()
    }
}