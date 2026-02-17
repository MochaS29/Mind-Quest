import Foundation
import SwiftUI

class GameManager: ObservableObject {
    @Published var character = Character()
    @Published var quests: [Quest] = []
    @Published var isCharacterCreated = false
    @Published var currentView: AppView = .characterCreation
    
    enum AppView {
        case characterCreation
        case dashboard
        case quests
        case character
        case timer
    }
    
    init() {
        loadData()
    }
    
    // MARK: - Character Creation
    func createCharacter(name: String, characterClass: CharacterClass, background: Background, avatar: String) {
        character.name = name
        character.characterClass = characterClass
        character.background = background
        character.avatar = avatar
        
        // Apply class bonuses
        if let bonuses = characterClass.statBonuses as? [StatType: Int] {
            for (stat, bonus) in bonuses {
                character.stats[stat, default: 10] += bonus
            }
        }
        
        // Apply background bonuses
        for (stat, bonus) in background.bonuses {
            character.stats[stat, default: 10] += bonus
        }
        
        isCharacterCreated = true
        currentView = .dashboard
        saveData()
    }
    
    // MARK: - Quest Management
    func addQuest(_ quest: Quest) {
        quests.append(quest)
        saveData()
    }
    
    func completeQuest(_ quest: Quest) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        
        quests[index].isCompleted = true
        quests[index].completedAt = Date()
        
        // Award XP and Gold
        var xpReward = quest.xpReward
        
        // Double XP if quest category matches class primary stat
        if let characterClass = character.characterClass,
           quest.category.primaryStat == characterClass.primaryStat {
            xpReward *= 2
        }
        
        character.xp += xpReward
        character.gold += quest.goldReward
        
        // Increase stats
        character.stats[quest.category.primaryStat, default: 10] += 1
        character.stats[quest.category.secondaryStat, default: 10] += 1
        
        // Check for level up
        while character.xp >= character.xpToNext {
            levelUp()
        }
        
        // Restore some health
        character.health = min(character.maxHealth, character.health + 5)
        
        saveData()
    }
    
    private func levelUp() {
        character.xp -= character.xpToNext
        character.level += 1
        character.xpToNext = character.level * 100
        character.maxHealth += 10
        character.health = character.maxHealth
        character.gold += character.level * 10
    }
    
    // MARK: - Persistence
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(character) {
            UserDefaults.standard.set(encoded, forKey: "character")
        }
        if let encoded = try? JSONEncoder().encode(quests) {
            UserDefaults.standard.set(encoded, forKey: "quests")
        }
        UserDefaults.standard.set(isCharacterCreated, forKey: "isCharacterCreated")
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
        isCharacterCreated = UserDefaults.standard.bool(forKey: "isCharacterCreated")
        if isCharacterCreated {
            currentView = .dashboard
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
    
    var completedTodayCount: Int {
        todayQuests.filter { $0.isCompleted }.count
    }
    
    var pendingQuestsCount: Int {
        quests.filter { !$0.isCompleted }.count
    }
}