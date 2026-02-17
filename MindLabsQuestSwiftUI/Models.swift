import Foundation
import SwiftUI

// MARK: - Character Classes
enum CharacterClass: String, CaseIterable, Codable {
    case scholar = "Scholar"
    case warrior = "Warrior"
    case diplomat = "Diplomat"
    case ranger = "Ranger"
    case artificer = "Artificer"
    case cleric = "Cleric"
    
    var icon: String {
        switch self {
        case .scholar: return "📚"
        case .warrior: return "⚔️"
        case .diplomat: return "🤝"
        case .ranger: return "🏹"
        case .artificer: return "🔧"
        case .cleric: return "✨"
        }
    }
    
    var description: String {
        switch self {
        case .scholar: return "Master of knowledge and learning"
        case .warrior: return "Champion of physical prowess"
        case .diplomat: return "Expert in social connections"
        case .ranger: return "Balanced adventurer and survivalist"
        case .artificer: return "Creative maker and innovator"
        case .cleric: return "Healer and wellness guardian"
        }
    }
    
    var primaryStat: StatType {
        switch self {
        case .scholar, .artificer: return .intelligence
        case .warrior: return .strength
        case .diplomat: return .charisma
        case .ranger: return .dexterity
        case .cleric: return .wisdom
        }
    }
    
    var statBonuses: [StatType: Int] {
        switch self {
        case .scholar: return [.intelligence: 3, .wisdom: 2, .charisma: 1]
        case .warrior: return [.strength: 3, .constitution: 2, .dexterity: 1]
        case .diplomat: return [.charisma: 3, .wisdom: 2, .intelligence: 1]
        case .ranger: return [.dexterity: 2, .strength: 2, .wisdom: 2]
        case .artificer: return [.intelligence: 2, .dexterity: 2, .constitution: 2]
        case .cleric: return [.wisdom: 3, .constitution: 2, .charisma: 1]
        }
    }
}

// MARK: - Background
enum Background: String, CaseIterable, Codable {
    case student = "Student"
    case athlete = "Athlete"
    case artist = "Artist"
    case leader = "Leader"
    case explorer = "Explorer"
    
    var description: String {
        switch self {
        case .student: return "Academic life is your main quest"
        case .athlete: return "Physical excellence drives you"
        case .artist: return "Creativity flows through everything you do"
        case .leader: return "You inspire and guide others"
        case .explorer: return "Adventure and discovery call to you"
        }
    }
    
    var bonuses: [StatType: Int] {
        switch self {
        case .student: return [.intelligence: 1, .wisdom: 1]
        case .athlete: return [.strength: 1, .constitution: 1]
        case .artist: return [.dexterity: 1, .charisma: 1]
        case .leader: return [.charisma: 1, .wisdom: 1]
        case .explorer: return [.dexterity: 1, .constitution: 1]
        }
    }
}

// MARK: - Stats
enum StatType: String, CaseIterable, Codable {
    case strength = "Strength"
    case dexterity = "Dexterity"
    case constitution = "Constitution"
    case intelligence = "Intelligence"
    case wisdom = "Wisdom"
    case charisma = "Charisma"
    
    var icon: String {
        switch self {
        case .strength: return "💪"
        case .dexterity: return "🤸"
        case .constitution: return "❤️"
        case .intelligence: return "🧠"
        case .wisdom: return "🧘"
        case .charisma: return "✨"
        }
    }
    
    var color: Color {
        switch self {
        case .strength: return .red
        case .dexterity: return .orange
        case .constitution: return .green
        case .intelligence: return .blue
        case .wisdom: return .purple
        case .charisma: return .pink
        }
    }
}

// MARK: - Task Category
enum TaskCategory: String, CaseIterable, Codable {
    case academic = "Academic"
    case social = "Social"
    case fitness = "Fitness"
    case health = "Health"
    case creative = "Creative"
    case lifeSkills = "Life Skills"
    
    var icon: String {
        switch self {
        case .academic: return "📚"
        case .social: return "👥"
        case .fitness: return "💪"
        case .health: return "🏥"
        case .creative: return "🎨"
        case .lifeSkills: return "🏠"
        }
    }
    
    var primaryStat: StatType {
        switch self {
        case .academic: return .intelligence
        case .social: return .charisma
        case .fitness: return .strength
        case .health: return .constitution
        case .creative: return .dexterity
        case .lifeSkills: return .wisdom
        }
    }
    
    var secondaryStat: StatType {
        switch self {
        case .academic: return .wisdom
        case .social: return .wisdom
        case .fitness: return .constitution
        case .health: return .wisdom
        case .creative: return .charisma
        case .lifeSkills: return .intelligence
        }
    }
    
    var color: Color {
        switch self {
        case .academic: return .blue
        case .social: return .pink
        case .fitness: return .green
        case .health: return .red
        case .creative: return .purple
        case .lifeSkills: return .yellow
        }
    }
}

// MARK: - Difficulty
enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case legendary = "Legendary"
    
    var xpReward: Int {
        switch self {
        case .easy: return 25
        case .medium: return 50
        case .hard: return 100
        case .legendary: return 200
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .legendary: return .red
        }
    }
}

// MARK: - Character Model
struct Character: Codable {
    var name: String = ""
    var characterClass: CharacterClass?
    var background: Background?
    var level: Int = 1
    var xp: Int = 0
    var xpToNext: Int = 100
    var stats: [StatType: Int] = [
        .strength: 10,
        .dexterity: 10,
        .constitution: 10,
        .intelligence: 10,
        .wisdom: 10,
        .charisma: 10
    ]
    var health: Int = 100
    var maxHealth: Int = 100
    var gold: Int = 100
    var streak: Int = 0
    var avatar: String = "🧙‍♂️"
    
    var modifier: (StatType) -> Int {
        return { stat in
            (self.stats[stat, default: 10] - 10) / 2
        }
    }
}

// MARK: - Quest/Task Model
struct Quest: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String = ""
    var category: TaskCategory
    var difficulty: Difficulty
    var estimatedTime: Int = 25 // minutes
    var dueDate: Date?
    var isCompleted: Bool = false
    var completedAt: Date?
    
    var xpReward: Int {
        difficulty.xpReward
    }
    
    var goldReward: Int {
        xpReward / 2
    }
}