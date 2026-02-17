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

    // MARK: - Story System Properties
    @Published var storyProgress = StoryProgress()
    @Published var storyChapters: [StoryChapter] = []
    @Published var isInStoryMode = false
    @Published var showStoryKeyEarned = false
    @Published var battleManager: BattleManager?

    // MARK: - Inventory Properties
    @Published var lastLootResult: LootResult?
    @Published var showLootAnimation = false

    // MARK: - Phase 2 Managers
    let energyManager = EnergyManager()
    let shopManager = ShopManager()
    let encounterManager = RandomEncounterManager()

    // MARK: - Phase 3 Managers
    let dailyChallengeManager = DailyChallengeManager()
    let craftingManager = CraftingManager()
    let dungeonRunManager = DungeonRunManager()

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
        case adventure
        case inventory
        case shop
    }

    init() {
        loadData()
        energyManager.syncFromCharacter(character)
        dailyChallengeManager.refreshIfNeeded(playerLevel: character.level)
        checkAndRefreshDailyQuests()
        checkAndUpdateStreak()
        loadStoryContent()
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

        // Award starter items
        awardStarterItems(for: characterClass)

        // Create initial daily quests
        createDailyQuests()

        isCharacterCreated = true
        currentView = .dashboard
        saveData()
    }

    // MARK: - Starter Items
    private func awardStarterItems(for characterClass: CharacterClass) {
        // Class-specific starter weapon
        var starterWeapon = ItemDatabase.starterWeapon(for: characterClass)
        starterWeapon.id = UUID() // Unique instance
        _ = character.addItem(starterWeapon)
        _ = character.equip(starterWeapon)

        // Basic armor for everyone
        var basicArmor = ItemDatabase.basicArmor
        basicArmor.id = UUID()
        _ = character.addItem(basicArmor)
        _ = character.equip(basicArmor)
    }

    // MARK: - Inventory Management
    func addItemToInventory(_ item: Item, quantity: Int = 1) -> Bool {
        let result = character.addItem(item, quantity: quantity)
        if result { saveData() }
        return result
    }

    func removeItemFromInventory(_ itemId: UUID, quantity: Int = 1) -> Bool {
        let result = character.removeItem(itemId, quantity: quantity)
        if result { saveData() }
        return result
    }

    func equipItem(_ item: Item) -> Item? {
        let previous = character.equip(item)
        saveData()
        return previous
    }

    func unequipSlot(_ slot: EquipmentSlot) -> Bool {
        let result = character.unequip(slot: slot)
        if result { saveData() }
        return result
    }

    func sellItem(_ itemId: UUID, quantity: Int = 1) -> Int {
        guard let entry = character.inventory.first(where: { $0.item.id == itemId }) else { return 0 }
        let sellPrice = entry.item.sellPrice * quantity
        guard character.removeItem(itemId, quantity: quantity) else { return 0 }
        character.gold += sellPrice
        saveData()
        return sellPrice
    }

    func useConsumable(_ itemId: UUID) -> ConsumableResult? {
        guard let entry = character.inventory.first(where: { $0.item.id == itemId }) else { return nil }
        let item = entry.item
        guard item.type == .consumable else { return nil }

        var result = ConsumableResult()

        if let healAmount = item.healAmount {
            let actualHeal = min(healAmount, character.maxHealth - character.health)
            character.health += actualHeal
            result.healedAmount = actualHeal
        }

        _ = character.removeItem(itemId)
        saveData()
        return result
    }

    // MARK: - Loot from Battles
    func awardBattleLoot(from encounter: BattleEncounter) {
        guard let lootTable = encounter.lootTable else { return }

        let roll = lootTable.roll()
        var result = LootResult()
        result.goldEarned = roll.gold
        character.gold += roll.gold

        for (item, quantity) in roll.items {
            var uniqueItem = item
            uniqueItem.id = UUID()
            if character.addItem(uniqueItem, quantity: quantity) {
                result.itemsReceived.append((uniqueItem, quantity))
            } else {
                result.itemsDropped.append((uniqueItem, quantity))
            }
        }

        lastLootResult = result
        showLootAnimation = !result.itemsReceived.isEmpty
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

        if quests[questIndex].subtasks[subtaskIndex].isCompleted {
            let totalSubtasks = quests[questIndex].subtasks.count
            let baseXP = quests[questIndex].difficulty.xpReward
            let xpPerSubtask = baseXP / totalSubtasks

            character.xp += xpPerSubtask

            while character.xp >= character.xpToNext {
                levelUp()
            }
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

    func completeQuest(_ quest: Quest) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }

        quests[index].isCompleted = true
        quests[index].completedAt = Date()

        if quests[index].actualTimeSpent > 0 {
            timeEstimateHistory.updateWithCompletedQuest(quests[index])
        }

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

        character.stats[quest.category.primaryStat, default: 10] += 1
        character.stats[quest.category.secondaryStat, default: 10] += 1

        showQuestCompletionAnimation = true

        while character.xp >= character.xpToNext {
            levelUp()
        }

        character.health = min(character.maxHealth, character.health + 5)

        updateStreakForCompletion()

        character.totalQuestsCompleted += 1
        character.questCategoriesCompleted.insert(quest.category.rawValue)

        achievementManager.checkQuestAchievements(totalCompleted: character.totalQuestsCompleted)
        achievementManager.checkCollectionAchievements(
            uniqueClasses: character.uniqueClassesPlayed.count,
            categoriesCompleted: character.questCategoriesCompleted.count
        )

        energyManager.earnEnergyFromQuest()

        // Daily challenge tracking
        dailyChallengeManager.recordQuestComplete()
        dailyChallengeManager.recordGoldEarned(quest.goldReward)

        awardStoryKey()
        saveData()
    }

    func reactivateQuest(_ quest: Quest) {
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

        // Award skill points on level up
        character.skillProgress.skillPoints += 2
        character.skillProgress.totalSkillPointsEarned += 2

        newLevel = character.level
        showLevelUpAnimation = true

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

            character.xp += 5

            if routines[routineIndex].steps.allSatisfy({ $0.isCompletedToday || $0.isOptional }) {
                completeRoutine(&routines[routineIndex])
            }
        }

        saveData()
    }

    private func completeRoutine(_ routine: inout Routine) {
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
            levelUp()
        }

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
        energyManager.syncToCharacter(&character)
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
            energyManager.syncFromCharacter(character)
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

        loadStoryProgress()
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

        if !calendar.isDate(today, inSameDayAs: lastCheck) {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

            let completedYesterday = quests.contains { quest in
                if let completedAt = quest.completedAt {
                    return calendar.isDate(completedAt, inSameDayAs: yesterday)
                }
                return false
            }

            if completedYesterday {
                if calendar.isDate(lastCheck, inSameDayAs: yesterday) {
                    // Already updated yesterday, keep streak
                } else {
                    character.streak = 0
                }
            } else if calendar.dateComponents([.day], from: lastCheck, to: today).day ?? 0 > 1 {
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

        let completionsToday = quests.filter { quest in
            if let completedAt = quest.completedAt {
                return calendar.isDate(completedAt, inSameDayAs: today)
            }
            return false
        }.count

        if completionsToday == 1 {
            if calendar.isDate(lastCheck, inSameDayAs: today) {
                // Already checked today
            } else {
                character.streak += 1
                lastStreakCheck = today

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
                achievementManager.checkStreakAchievements(currentStreak: character.streak)
            }

            saveData()
        }
    }

    // MARK: - Reset Data
    func resetAllData() {
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
        lastLootResult = nil
        showLootAnimation = false

        storyProgress = StoryProgress()
        storyChapters = []
        isInStoryMode = false
        battleManager = nil

        UserDefaults.standard.removeObject(forKey: "character")
        UserDefaults.standard.removeObject(forKey: "quests")
        UserDefaults.standard.removeObject(forKey: "routines")
        UserDefaults.standard.removeObject(forKey: "timeEstimateHistory")
        UserDefaults.standard.removeObject(forKey: "isCharacterCreated")
        UserDefaults.standard.removeObject(forKey: "lastStreakCheck")
        UserDefaults.standard.removeObject(forKey: "storyProgress")

        achievementManager.resetAll()
        parentRewardManager.resetAll()

        loadStoryContent()
    }

    // MARK: - Story System
    func loadStoryContent() {
        storyChapters = StoryContent.allChapters

        for i in 0..<storyChapters.count {
            if storyProgress.unlockedChapters.contains(storyChapters[i].id) {
                storyChapters[i].isUnlocked = true
            }
            if storyProgress.completedChapters.contains(storyChapters[i].id) {
                storyChapters[i].isCompleted = true
            }
        }
    }

    func awardStoryKey() {
        storyProgress.storyKeys += 1
        showStoryKeyEarned = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showStoryKeyEarned = false
        }

        saveStoryProgress()
    }

    func unlockChapter(_ chapterId: String) -> Bool {
        guard let chapterIndex = storyChapters.firstIndex(where: { $0.id == chapterId }) else {
            return false
        }

        let chapter = storyChapters[chapterIndex]
        if chapter.isUnlocked { return true }

        guard storyProgress.storyKeys >= chapter.unlockRequirements.tasksRequired else {
            return false
        }

        let required = chapter.unlockRequirements.previousChapters
        if !required.isEmpty {
            switch chapter.unlockRequirements.unlockMode {
            case .any:
                guard required.contains(where: { storyProgress.completedChapters.contains($0) }) else { return false }
            case .all:
                guard required.allSatisfy({ storyProgress.completedChapters.contains($0) }) else { return false }
            }
        }

        storyProgress.storyKeys -= chapter.unlockRequirements.tasksRequired
        storyProgress.unlockedChapters.insert(chapterId)
        storyChapters[chapterIndex].isUnlocked = true

        saveStoryProgress()
        return true
    }

    func completeChapter(_ chapterId: String, choiceMade: String? = nil) {
        guard let chapterIndex = storyChapters.firstIndex(where: { $0.id == chapterId }) else {
            return
        }

        let chapter = storyChapters[chapterIndex]

        storyChapters[chapterIndex].isCompleted = true
        storyProgress.completedChapters.insert(chapterId)

        if let choice = choiceMade {
            storyProgress.choicesMade[chapterId] = choice
        }

        character.xp += chapter.rewards.xp
        character.gold += chapter.rewards.gold

        while character.xp >= character.xpToNext {
            levelUp()
        }

        storyProgress.storyKeys += 1

        saveStoryProgress()
        saveData()
    }

    func getBattleManager() -> BattleManager {
        if battleManager == nil {
            battleManager = BattleManager(character: character)
        }
        battleManager?.updateCharacter(character)
        battleManager?.onItemUsed = { [weak self] itemId in
            self?.dailyChallengeManager.recordItemUsed()
            self?.saveData()
        }
        return battleManager!
    }

    func completeBattle(victory: Bool) {
        if victory, let rewards = battleManager?.collectRewards() {
            character.xp += rewards.xp
            character.gold += rewards.gold
            storyProgress.totalBattlesWon += 1

            // Award loot drops from the encounter
            if let encounter = battleManager?.currentEncounter {
                awardBattleLoot(from: encounter)
            }

            // Daily challenge tracking
            dailyChallengeManager.recordBattleWin()
            dailyChallengeManager.recordKill()
            dailyChallengeManager.recordGoldEarned(rewards.gold)
            if let totalDmg = battleManager?.battleState?.totalDamageDealt {
                dailyChallengeManager.recordDamage(totalDmg)
            }

            while character.xp >= character.xpToNext {
                levelUp()
            }

            saveData()
        }

        battleManager?.endBattle()
    }

    func getChapter(_ chapterId: String) -> StoryChapter? {
        return storyChapters.first(where: { $0.id == chapterId })
    }

    func keysNeededForChapter(_ chapterId: String) -> Int {
        guard let chapter = getChapter(chapterId) else { return 0 }
        return max(0, chapter.unlockRequirements.tasksRequired - storyProgress.storyKeys)
    }

    func canUnlockChapter(_ chapterId: String) -> Bool {
        guard let chapter = getChapter(chapterId) else { return false }

        if chapter.isUnlocked { return false }

        if storyProgress.storyKeys < chapter.unlockRequirements.tasksRequired {
            return false
        }

        let required = chapter.unlockRequirements.previousChapters
        if !required.isEmpty {
            switch chapter.unlockRequirements.unlockMode {
            case .any:
                guard required.contains(where: { storyProgress.completedChapters.contains($0) }) else { return false }
            case .all:
                guard required.allSatisfy({ storyProgress.completedChapters.contains($0) }) else { return false }
            }
        }

        return true
    }

    // MARK: - Story Progress Persistence
    func saveStoryProgress() {
        if let encoded = try? JSONEncoder().encode(storyProgress) {
            UserDefaults.standard.set(encoded, forKey: "storyProgress")
        }
    }

    private func loadStoryProgress() {
        if let data = UserDefaults.standard.data(forKey: "storyProgress"),
           let decoded = try? JSONDecoder().decode(StoryProgress.self, from: data) {
            storyProgress = decoded
        }
    }
}
