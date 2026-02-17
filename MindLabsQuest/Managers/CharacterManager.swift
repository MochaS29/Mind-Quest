import Foundation
import SwiftUI

class CharacterManager: ObservableObject {
    @Published var character: Character
    let achievementManager: AchievementManager
    let parentRewardManager: ParentRewardManager

    @Published var showLevelUpAnimation = false
    @Published var newLevel = 1

    init(character: Character, achievementManager: AchievementManager, parentRewardManager: ParentRewardManager) {
        self.character = character
        self.achievementManager = achievementManager
        self.parentRewardManager = parentRewardManager
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
        for (stat, bonus) in characterClass.statBonuses {
            character.stats[stat, default: 10] += bonus
        }

        // Apply background bonuses
        for (stat, bonus) in background.bonuses {
            character.stats[stat, default: 10] += bonus
        }

        // Apply trait bonuses
        character.applyTraitBonuses()

        // Track unique classes played
        character.uniqueClassesPlayed.insert(characterClass.rawValue)
    }

    // MARK: - XP & Leveling
    func awardXP(_ amount: Int) {
        character.xp += amount
        while character.xp >= character.xpToNext {
            levelUp()
        }
    }

    func awardGold(_ amount: Int) {
        character.gold += amount
    }

    func levelUp() {
        character.xp -= character.xpToNext
        character.level += 1
        character.xpToNext = character.level * 100
        character.maxHealth += 10
        character.health = character.maxHealth
        character.gold += character.level * 10

        newLevel = character.level
        showLevelUpAnimation = true

        achievementManager.checkLevelAchievements(currentLevel: character.level)
    }

    // MARK: - Health Management
    func restoreHealth(_ amount: Int) {
        character.health = min(character.maxHealth, character.health + amount)
    }

    func takeDamage(_ amount: Int) {
        character.health = max(0, character.health - amount)
    }

    // MARK: - Stat Increases
    func increaseStat(_ stat: StatType, by amount: Int = 1) {
        character.stats[stat, default: 10] += amount
    }

    // MARK: - Focus Time
    func addFocusMinutes(_ minutes: Int) {
        character.totalFocusMinutes += minutes
        achievementManager.checkFocusAchievements(
            sessionMinutes: minutes,
            totalMinutes: character.totalFocusMinutes
        )
    }
}
