import Foundation

class StoryManager: ObservableObject {
    @Published var storyProgress = StoryProgress()
    @Published var storyChapters: [StoryChapter] = []
    @Published var isInStoryMode = false
    @Published var showStoryKeyEarned = false
    @Published var battleManager: BattleManager?

    // MARK: - Load Story Content
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

    // MARK: - Story Keys
    func awardStoryKey() {
        storyProgress.storyKeys += 1
        showStoryKeyEarned = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showStoryKeyEarned = false
        }

        saveStoryProgress()
    }

    // MARK: - Chapter Management
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

    func completeChapter(_ chapterId: String, choiceMade: String? = nil, character: inout Character, onLevelUp: () -> Void) {
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
            onLevelUp()
        }

        storyProgress.storyKeys += 1
        saveStoryProgress()
    }

    // MARK: - Battle Management
    func getBattleManager(character: Character) -> BattleManager {
        if battleManager == nil {
            battleManager = BattleManager(character: character)
        }
        return battleManager!
    }

    func completeBattle(victory: Bool, character: inout Character, onLevelUp: () -> Void) {
        if victory, let rewards = battleManager?.collectRewards() {
            character.xp += rewards.xp
            character.gold += rewards.gold
            storyProgress.totalBattlesWon += 1

            while character.xp >= character.xpToNext {
                onLevelUp()
            }
        }

        battleManager?.endBattle()
    }

    // MARK: - Chapter Queries
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
        if storyProgress.storyKeys < chapter.unlockRequirements.tasksRequired { return false }
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

    // MARK: - Persistence
    func saveStoryProgress() {
        if let encoded = try? JSONEncoder().encode(storyProgress) {
            UserDefaults.standard.set(encoded, forKey: "storyProgress")
        }
    }

    func loadStoryProgress() {
        if let data = UserDefaults.standard.data(forKey: "storyProgress"),
           let decoded = try? JSONDecoder().decode(StoryProgress.self, from: data) {
            storyProgress = decoded
        }
    }
}
