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
    
    var xpReward: Int {
        switch self {
        case .easy: return 25
        case .medium: return 50
        case .hard: return 100
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        }
    }
}

// MARK: - Character Traits
enum CharacterTrait: String, CaseIterable, Codable {
    case disciplined = "Disciplined"
    case creative = "Creative"
    case social = "Social"
    case analytical = "Analytical"
    case resilient = "Resilient"
    case adventurous = "Adventurous"
    case focused = "Focused"
    case empathetic = "Empathetic"
    
    var description: String {
        switch self {
        case .disciplined: return "Gain +10% XP from completed daily quests"
        case .creative: return "+15% XP from creative tasks"
        case .social: return "+15% XP from social tasks"
        case .analytical: return "+15% XP from academic tasks"
        case .resilient: return "+5 max health per level"
        case .adventurous: return "+10% gold from all quests"
        case .focused: return "-20% estimated time for all tasks"
        case .empathetic: return "+1 to all social quest rewards"
        }
    }
    
    var icon: String {
        switch self {
        case .disciplined: return "⚔️"
        case .creative: return "🎨"
        case .social: return "💬"
        case .analytical: return "🔬"
        case .resilient: return "🛡️"
        case .adventurous: return "🗺️"
        case .focused: return "🎯"
        case .empathetic: return "❤️"
        }
    }
}

// MARK: - Character Motivation
enum CharacterMotivation: String, CaseIterable, Codable {
    case achievement = "Achievement Hunter"
    case knowledge = "Knowledge Seeker"
    case social = "Social Butterfly"
    case health = "Wellness Warrior"
    case creative = "Creative Soul"
    case balanced = "Balanced Life"
    
    var description: String {
        switch self {
        case .achievement: return "Live for completing challenges"
        case .knowledge: return "Driven by learning and discovery"
        case .social: return "Motivated by helping others"
        case .health: return "Focused on physical and mental wellness"
        case .creative: return "Inspired by artistic expression"
        case .balanced: return "Seek harmony in all things"
        }
    }
    
    var questBonus: TaskCategory? {
        switch self {
        case .achievement: return nil // bonus to all
        case .knowledge: return .academic
        case .social: return .social
        case .health: return .health
        case .creative: return .creative
        case .balanced: return nil // balanced rewards
        }
    }
}

// MARK: - Character Model
struct Character: Codable {
    var name: String = ""
    var characterClass: CharacterClass?
    var background: Background?
    var traits: [CharacterTrait] = []
    var motivation: CharacterMotivation?
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
    var preferredDifficulty: Difficulty = .medium
    var dailyQuestIds: Set<String> = []
    
    // Achievement tracking
    var totalQuestsCompleted: Int = 0
    var totalFocusMinutes: Int = 0
    var uniqueClassesPlayed: Set<String> = []
    var questCategoriesCompleted: Set<String> = []
    
    var modifier: (StatType) -> Int {
        return { stat in
            (self.stats[stat, default: 10] - 10) / 2
        }
    }
    
    mutating func applyTraitBonuses() {
        for trait in traits {
            switch trait {
            case .resilient:
                maxHealth += 5 * level
                health = maxHealth
            default:
                break
            }
        }
    }
}

// MARK: - Quest/Task Model
struct Quest: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String = ""
    var category: TaskCategory
    var difficulty: Difficulty
    var estimatedTime: Int = 25 // minutes
    var dueDate: Date?
    var isCompleted: Bool = false
    var completedAt: Date?
    var isDaily: Bool = false
    var questTemplate: DailyQuestTemplate?
    var createdDate: Date = Date()
    var subtasks: [Subtask] = []
    var parentQuestId: UUID? = nil // For subtasks that become standalone quests
    var actualTimeSpent: Int = 0 // in minutes
    var startedAt: Date?
    var timeSpentSessions: [TimeSession] = []
    
    var xpReward: Int {
        if let template = questTemplate {
            return template.baseXP
        }
        // If has subtasks, calculate based on completion
        if !subtasks.isEmpty {
            let baseXP = difficulty.xpReward
            let completedRatio = Double(completedSubtaskCount) / Double(subtasks.count)
            return Int(Double(baseXP) * completedRatio)
        }
        return difficulty.xpReward
    }
    
    var goldReward: Int {
        if let template = questTemplate {
            return template.baseGold
        }
        return xpReward / 2
    }
    
    var completedSubtaskCount: Int {
        subtasks.filter { $0.isCompleted }.count
    }
    
    var subtaskProgress: Double {
        guard !subtasks.isEmpty else { return 0 }
        return Double(completedSubtaskCount) / Double(subtasks.count)
    }
    
    var hasSubtasks: Bool {
        !subtasks.isEmpty
    }
    
    init(title: String, description: String = "", category: TaskCategory, difficulty: Difficulty, estimatedTime: Int = 25, dueDate: Date? = nil, isDaily: Bool = false, questTemplate: DailyQuestTemplate? = nil) {
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.dueDate = dueDate
        self.isDaily = isDaily
        self.questTemplate = questTemplate
        self.createdDate = Date()
    }
}

// MARK: - Time Tracking Models
struct TimeSession: Codable {
    let startTime: Date
    let endTime: Date
    var duration: Int { // in minutes
        Int(endTime.timeIntervalSince(startTime) / 60)
    }
}

struct TimeEstimateHistory: Codable {
    var categoryAverages: [String: CategoryTimeData] = [:]
    var overallAccuracy: Double = 0.0
    var totalTasksTracked: Int = 0
    
    struct CategoryTimeData: Codable {
        var totalEstimated: Int = 0
        var totalActual: Int = 0
        var taskCount: Int = 0
        var averageAccuracy: Double {
            guard taskCount > 0, totalEstimated > 0 else { return 0 }
            return Double(totalActual) / Double(totalEstimated)
        }
        var averageTimePerTask: Int {
            guard taskCount > 0 else { return 0 }
            return totalActual / taskCount
        }
    }
    
    mutating func updateWithCompletedQuest(_ quest: Quest) {
        guard quest.actualTimeSpent > 0 else { return }
        
        let categoryKey = quest.category.rawValue
        var categoryData = categoryAverages[categoryKey] ?? CategoryTimeData()
        
        categoryData.totalEstimated += quest.estimatedTime
        categoryData.totalActual += quest.actualTimeSpent
        categoryData.taskCount += 1
        
        categoryAverages[categoryKey] = categoryData
        totalTasksTracked += 1
        
        // Update overall accuracy
        let totalEstimated = categoryAverages.values.reduce(0) { $0 + $1.totalEstimated }
        let totalActual = categoryAverages.values.reduce(0) { $0 + $1.totalActual }
        overallAccuracy = totalEstimated > 0 ? Double(totalActual) / Double(totalEstimated) : 0
    }
    
    func getSuggestion(for category: TaskCategory, originalEstimate: Int) -> TimeEstimateSuggestion {
        let categoryData = categoryAverages[category.rawValue]
        
        guard let data = categoryData, data.taskCount >= 3 else {
            return TimeEstimateSuggestion(
                suggestedTime: originalEstimate,
                confidence: .low,
                reason: "Not enough data yet. Complete more \(category.rawValue) tasks to improve estimates."
            )
        }
        
        let accuracy = data.averageAccuracy
        let adjustedEstimate = Int(Double(originalEstimate) * accuracy)
        
        let confidence: TimeEstimateSuggestion.Confidence
        let reason: String
        
        if data.taskCount >= 10 {
            confidence = .high
            if accuracy > 1.2 {
                reason = "You typically take \(Int((accuracy - 1) * 100))% longer than estimated for \(category.rawValue) tasks."
            } else if accuracy < 0.8 {
                reason = "You're usually \(Int((1 - accuracy) * 100))% faster than estimated for \(category.rawValue) tasks!"
            } else {
                reason = "Your estimates for \(category.rawValue) tasks are pretty accurate!"
            }
        } else {
            confidence = .medium
            reason = "Based on \(data.taskCount) completed \(category.rawValue) tasks."
        }
        
        return TimeEstimateSuggestion(
            suggestedTime: adjustedEstimate,
            confidence: confidence,
            reason: reason,
            historicalAverage: data.averageTimePerTask
        )
    }
}

struct TimeEstimateSuggestion {
    let suggestedTime: Int
    let confidence: Confidence
    let reason: String
    var historicalAverage: Int = 0
    
    enum Confidence {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .mindLabsTextSecondary
            case .medium: return .mindLabsWarning
            case .high: return .mindLabsSuccess
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "questionmark.circle"
            case .medium: return "info.circle"
            case .high: return "checkmark.circle"
            }
        }
    }
}

// MARK: - Subtask Model
struct Subtask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var completedAt: Date?
    var estimatedTime: Int = 10 // minutes
    var order: Int = 0
    
    mutating func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

// MARK: - Task Breakdown Templates
struct TaskBreakdownTemplate {
    let category: TaskCategory
    let taskType: String
    let suggestedSteps: [String]
    
    static let templates: [TaskBreakdownTemplate] = [
        // Academic Templates
        TaskBreakdownTemplate(
            category: .academic,
            taskType: "Essay/Report",
            suggestedSteps: [
                "Research and gather sources",
                "Create outline",
                "Write introduction",
                "Write body paragraphs",
                "Write conclusion",
                "Proofread and edit",
                "Format and finalize"
            ]
        ),
        TaskBreakdownTemplate(
            category: .academic,
            taskType: "Study for Test",
            suggestedSteps: [
                "Review notes and materials",
                "Create study guide",
                "Make flashcards",
                "Practice problems",
                "Review mistakes",
                "Final review"
            ]
        ),
        TaskBreakdownTemplate(
            category: .academic,
            taskType: "Math Homework",
            suggestedSteps: [
                "Read instructions",
                "Review examples",
                "Complete easy problems",
                "Work on harder problems",
                "Check answers",
                "Fix mistakes"
            ]
        ),
        // Life Skills Templates
        TaskBreakdownTemplate(
            category: .lifeSkills,
            taskType: "Clean Room",
            suggestedSteps: [
                "Pick up clothes",
                "Make bed",
                "Clear desk/surfaces",
                "Organize items",
                "Vacuum/sweep floor",
                "Take out trash"
            ]
        ),
        TaskBreakdownTemplate(
            category: .lifeSkills,
            taskType: "Organize Workspace",
            suggestedSteps: [
                "Clear everything off desk",
                "Sort items into categories",
                "Throw away trash",
                "Put away items not needed",
                "Organize remaining items",
                "Wipe down surfaces"
            ]
        ),
        // Creative Templates
        TaskBreakdownTemplate(
            category: .creative,
            taskType: "Art Project",
            suggestedSteps: [
                "Brainstorm ideas",
                "Sketch rough draft",
                "Gather materials",
                "Create base/outline",
                "Add details",
                "Final touches"
            ]
        ),
        // Social Templates
        TaskBreakdownTemplate(
            category: .social,
            taskType: "Plan Event",
            suggestedSteps: [
                "Choose date and time",
                "Create guest list",
                "Send invitations",
                "Plan activities",
                "Prepare supplies",
                "Set up space"
            ]
        )
    ]
    
    static func getSuggestions(for category: TaskCategory, title: String) -> [String] {
        // Look for matching templates
        for template in templates {
            if template.category == category {
                let keywords = template.taskType.lowercased().components(separatedBy: " ")
                let titleLower = title.lowercased()
                
                if keywords.contains(where: { titleLower.contains($0) }) {
                    return template.suggestedSteps
                }
            }
        }
        
        // Return generic steps if no match
        return defaultSteps(for: category)
    }
    
    static func defaultSteps(for category: TaskCategory) -> [String] {
        switch category {
        case .academic:
            return ["Prepare materials", "Review instructions", "Complete main task", "Review work", "Submit/turn in"]
        case .fitness:
            return ["Warm up", "Main activity", "Cool down", "Hydrate", "Record progress"]
        case .social:
            return ["Prepare what to say", "Reach out", "Have conversation", "Follow up", "Reflect"]
        case .health:
            return ["Gather supplies", "Complete task", "Clean up", "Record completion"]
        case .creative:
            return ["Gather materials", "Plan approach", "Create", "Review", "Share or save"]
        case .lifeSkills:
            return ["Assess task", "Gather supplies", "Complete task", "Clean up", "Put things away"]
        }
    }
}

// MARK: - Daily Quest Templates
struct DailyQuestTemplate: Codable {
    let id: String
    let epicTitle: String
    let normalTitle: String
    let category: TaskCategory
    let difficulty: Difficulty
    let estimatedTime: Int
    let baseXP: Int
    let baseGold: Int
    let icon: String
    let timeOfDay: TimeOfDay
    
    enum TimeOfDay: String, CaseIterable, Codable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case anytime = "Anytime"
    }
}

// MARK: - Daily Quest Templates Data
extension DailyQuestTemplate {
    static let allTemplates: [DailyQuestTemplate] = [
        // Morning Hygiene Quests
        DailyQuestTemplate(
            id: "morning_shower",
            epicTitle: "The Cleansing Ritual of Dawn",
            normalTitle: "Morning Shower",
            category: .health,
            difficulty: .easy,
            estimatedTime: 15,
            baseXP: 30,
            baseGold: 5,
            icon: "🚿",
            timeOfDay: .morning
        ),
        DailyQuestTemplate(
            id: "brush_teeth_morning",
            epicTitle: "Defend the Ivory Gates",
            normalTitle: "Brush Teeth (Morning)",
            category: .health,
            difficulty: .easy,
            estimatedTime: 3,
            baseXP: 20,
            baseGold: 3,
            icon: "🦷",
            timeOfDay: .morning
        ),
        DailyQuestTemplate(
            id: "floss_teeth",
            epicTitle: "Thread the Needle of Dental Excellence",
            normalTitle: "Floss Teeth",
            category: .health,
            difficulty: .medium,
            estimatedTime: 5,
            baseXP: 25,
            baseGold: 4,
            icon: "🦷✨",
            timeOfDay: .evening
        ),
        DailyQuestTemplate(
            id: "hair_care",
            epicTitle: "Tame the Wild Mane",
            normalTitle: "Brush/Style Hair",
            category: .health,
            difficulty: .easy,
            estimatedTime: 5,
            baseXP: 15,
            baseGold: 2,
            icon: "💇",
            timeOfDay: .morning
        ),
        
        // School Preparation
        DailyQuestTemplate(
            id: "pack_lunch",
            epicTitle: "Prepare the Adventurer's Feast",
            normalTitle: "Pack Lunch",
            category: .lifeSkills,
            difficulty: .easy,
            estimatedTime: 10,
            baseXP: 25,
            baseGold: 4,
            icon: "🍱",
            timeOfDay: .morning
        ),
        DailyQuestTemplate(
            id: "pack_homework",
            epicTitle: "Secure the Sacred Scrolls",
            normalTitle: "Pack Homework",
            category: .academic,
            difficulty: .easy,
            estimatedTime: 5,
            baseXP: 20,
            baseGold: 3,
            icon: "📝",
            timeOfDay: .morning
        ),
        DailyQuestTemplate(
            id: "pack_backpack",
            epicTitle: "Ready the Explorer's Arsenal",
            normalTitle: "Pack Backpack",
            category: .lifeSkills,
            difficulty: .easy,
            estimatedTime: 10,
            baseXP: 25,
            baseGold: 4,
            icon: "🎒",
            timeOfDay: .morning
        ),
        
        // Academic Quests
        DailyQuestTemplate(
            id: "complete_homework",
            epicTitle: "Conquer the Academic Challenges",
            normalTitle: "Complete Homework",
            category: .academic,
            difficulty: .medium,
            estimatedTime: 45,
            baseXP: 60,
            baseGold: 10,
            icon: "📚",
            timeOfDay: .afternoon
        ),
        DailyQuestTemplate(
            id: "study_session",
            epicTitle: "Delve into the Tomes of Knowledge",
            normalTitle: "Study Session",
            category: .academic,
            difficulty: .medium,
            estimatedTime: 30,
            baseXP: 50,
            baseGold: 8,
            icon: "🧠",
            timeOfDay: .afternoon
        ),
        DailyQuestTemplate(
            id: "read_20min",
            epicTitle: "Journey Through Literary Realms",
            normalTitle: "Read for 20 Minutes",
            category: .academic,
            difficulty: .easy,
            estimatedTime: 20,
            baseXP: 35,
            baseGold: 5,
            icon: "📖",
            timeOfDay: .anytime
        ),
        
        // Physical Activity
        DailyQuestTemplate(
            id: "morning_exercise",
            epicTitle: "Train at the Dawn Dojo",
            normalTitle: "Morning Exercise",
            category: .fitness,
            difficulty: .medium,
            estimatedTime: 20,
            baseXP: 45,
            baseGold: 7,
            icon: "🏃",
            timeOfDay: .morning
        ),
        DailyQuestTemplate(
            id: "stretch_routine",
            epicTitle: "Master the Art of Flexibility",
            normalTitle: "Stretching Routine",
            category: .fitness,
            difficulty: .easy,
            estimatedTime: 10,
            baseXP: 25,
            baseGold: 4,
            icon: "🧘",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "outdoor_activity",
            epicTitle: "Venture into the Wild",
            normalTitle: "30 Min Outdoor Activity",
            category: .fitness,
            difficulty: .medium,
            estimatedTime: 30,
            baseXP: 50,
            baseGold: 8,
            icon: "🌳",
            timeOfDay: .afternoon
        ),
        
        // Life Skills & Chores
        DailyQuestTemplate(
            id: "tidy_room",
            epicTitle: "Restore Order to Your Sanctuary",
            normalTitle: "Tidy Room",
            category: .lifeSkills,
            difficulty: .easy,
            estimatedTime: 15,
            baseXP: 30,
            baseGold: 5,
            icon: "🧹",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "make_bed",
            epicTitle: "Craft the Perfect Resting Chamber",
            normalTitle: "Make Bed",
            category: .lifeSkills,
            difficulty: .easy,
            estimatedTime: 5,
            baseXP: 15,
            baseGold: 2,
            icon: "🛏️",
            timeOfDay: .morning
        ),
        DailyQuestTemplate(
            id: "organize_desk",
            epicTitle: "Master Your Command Center",
            normalTitle: "Organize Desk/Workspace",
            category: .lifeSkills,
            difficulty: .easy,
            estimatedTime: 10,
            baseXP: 25,
            baseGold: 4,
            icon: "🗂️",
            timeOfDay: .anytime
        ),
        
        // Evening Routines
        DailyQuestTemplate(
            id: "prepare_tomorrow",
            epicTitle: "Plan Tomorrow's Campaign",
            normalTitle: "Prepare for Tomorrow",
            category: .lifeSkills,
            difficulty: .easy,
            estimatedTime: 10,
            baseXP: 25,
            baseGold: 4,
            icon: "📅",
            timeOfDay: .evening
        ),
        DailyQuestTemplate(
            id: "evening_reflection",
            epicTitle: "Meditate on Today's Adventures",
            normalTitle: "Evening Reflection/Journal",
            category: .health,
            difficulty: .easy,
            estimatedTime: 10,
            baseXP: 30,
            baseGold: 5,
            icon: "📔",
            timeOfDay: .evening
        ),
        DailyQuestTemplate(
            id: "brush_teeth_night",
            epicTitle: "The Nighttime Dental Defense",
            normalTitle: "Brush Teeth (Night)",
            category: .health,
            difficulty: .easy,
            estimatedTime: 3,
            baseXP: 20,
            baseGold: 3,
            icon: "🦷🌙",
            timeOfDay: .evening
        ),
        
        // Social & Creative
        DailyQuestTemplate(
            id: "help_family",
            epicTitle: "Aid Your Fellow Adventurers",
            normalTitle: "Help Family Member",
            category: .social,
            difficulty: .easy,
            estimatedTime: 15,
            baseXP: 35,
            baseGold: 6,
            icon: "🤝",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "creative_time",
            epicTitle: "Channel Your Creative Energy",
            normalTitle: "Creative Activity (Draw/Music/Write)",
            category: .creative,
            difficulty: .medium,
            estimatedTime: 30,
            baseXP: 45,
            baseGold: 7,
            icon: "🎨",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "practice_skill",
            epicTitle: "Hone Your Chosen Craft",
            normalTitle: "Practice Instrument/Skill",
            category: .creative,
            difficulty: .medium,
            estimatedTime: 20,
            baseXP: 40,
            baseGold: 6,
            icon: "🎵",
            timeOfDay: .anytime
        ),
        
        // Test & Study Preparation
        DailyQuestTemplate(
            id: "study_for_test",
            epicTitle: "Forge Knowledge in the Crucible of Study",
            normalTitle: "Study for Test/Quiz",
            category: .academic,
            difficulty: .hard,
            estimatedTime: 45,
            baseXP: 60,
            baseGold: 10,
            icon: "📚",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "complete_quiz",
            epicTitle: "Face the Trial of Knowledge",
            normalTitle: "Complete Quiz/Test",
            category: .academic,
            difficulty: .hard,
            estimatedTime: 30,
            baseXP: 50,
            baseGold: 8,
            icon: "📋",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "review_notes",
            epicTitle: "Decipher the Ancient Scrolls",
            normalTitle: "Review Class Notes",
            category: .academic,
            difficulty: .medium,
            estimatedTime: 20,
            baseXP: 30,
            baseGold: 5,
            icon: "📓",
            timeOfDay: .anytime
        ),
        
        // New Activities & Challenges
        DailyQuestTemplate(
            id: "try_new_activity",
            epicTitle: "Venture Into the Unknown",
            normalTitle: "Try a New Activity",
            category: .social,
            difficulty: .medium,
            estimatedTime: 30,
            baseXP: 40,
            baseGold: 6,
            icon: "🌟",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "join_club_meeting",
            epicTitle: "Gather with the Alliance",
            normalTitle: "Attend Club/Group Meeting",
            category: .social,
            difficulty: .medium,
            estimatedTime: 60,
            baseXP: 45,
            baseGold: 7,
            icon: "👥",
            timeOfDay: .afternoon
        ),
        DailyQuestTemplate(
            id: "talk_to_new_person",
            epicTitle: "Forge New Alliances",
            normalTitle: "Talk to Someone New",
            category: .social,
            difficulty: .hard,
            estimatedTime: 10,
            baseXP: 35,
            baseGold: 5,
            icon: "🗣️",
            timeOfDay: .anytime
        ),
        
        // Focus & Organization
        DailyQuestTemplate(
            id: "organize_workspace",
            epicTitle: "Restore Order to the Chaos Realm",
            normalTitle: "Organize Desk/Workspace",
            category: .lifeSkills,
            difficulty: .medium,
            estimatedTime: 15,
            baseXP: 25,
            baseGold: 4,
            icon: "🗂️",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "use_planner",
            epicTitle: "Chart the Path of Destiny",
            normalTitle: "Update Planner/Calendar",
            category: .lifeSkills,
            difficulty: .easy,
            estimatedTime: 10,
            baseXP: 20,
            baseGold: 3,
            icon: "📅",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "break_task_chunks",
            epicTitle: "Divide and Conquer the Mountain",
            normalTitle: "Break Big Task into Steps",
            category: .lifeSkills,
            difficulty: .medium,
            estimatedTime: 15,
            baseXP: 30,
            baseGold: 5,
            icon: "📊",
            timeOfDay: .anytime
        ),
        
        // Emotional Regulation
        DailyQuestTemplate(
            id: "mindfulness_break",
            epicTitle: "Commune with the Inner Spirit",
            normalTitle: "5-Minute Mindfulness",
            category: .health,
            difficulty: .easy,
            estimatedTime: 5,
            baseXP: 15,
            baseGold: 2,
            icon: "🧘",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "journal_feelings",
            epicTitle: "Chronicle the Emotional Journey",
            normalTitle: "Journal Thoughts/Feelings",
            category: .health,
            difficulty: .medium,
            estimatedTime: 15,
            baseXP: 25,
            baseGold: 4,
            icon: "📔",
            timeOfDay: .evening
        ),
        DailyQuestTemplate(
            id: "ask_for_help",
            epicTitle: "Summon the Wisdom of Allies",
            normalTitle: "Ask for Help When Needed",
            category: .social,
            difficulty: .hard,
            estimatedTime: 10,
            baseXP: 40,
            baseGold: 6,
            icon: "🤝",
            timeOfDay: .anytime
        ),
        
        // Movement & Energy
        DailyQuestTemplate(
            id: "movement_break",
            epicTitle: "Dance with the Energy Dragons",
            normalTitle: "5-Minute Movement Break",
            category: .fitness,
            difficulty: .easy,
            estimatedTime: 5,
            baseXP: 15,
            baseGold: 2,
            icon: "💃",
            timeOfDay: .anytime
        ),
        DailyQuestTemplate(
            id: "fidget_tool",
            epicTitle: "Channel the Restless Energy",
            normalTitle: "Use Fidget Tool During Task",
            category: .health,
            difficulty: .easy,
            estimatedTime: 30,
            baseXP: 20,
            baseGold: 3,
            icon: "🎯",
            timeOfDay: .anytime
        )
    ]
    
    static var morningQuests: [DailyQuestTemplate] {
        allTemplates.filter { $0.timeOfDay == .morning || $0.timeOfDay == .anytime }
    }
    
    static var afternoonQuests: [DailyQuestTemplate] {
        allTemplates.filter { $0.timeOfDay == .afternoon || $0.timeOfDay == .anytime }
    }
    
    static var eveningQuests: [DailyQuestTemplate] {
        allTemplates.filter { $0.timeOfDay == .evening || $0.timeOfDay == .anytime }
    }
}

// MARK: - Achievement System
struct Achievement: Identifiable, Codable {
    var id = UUID()
    let key: String
    let title: String
    let description: String
    let icon: String
    let requiredValue: Int
    let category: AchievementCategory
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var progress: Int = 0
    
    enum AchievementCategory: String, CaseIterable, Codable {
        case quests = "Quests"
        case streak = "Streaks"
        case level = "Levels"
        case focus = "Focus"
        case collection = "Collection"
        
        var color: Color {
            switch self {
            case .quests: return .blue
            case .streak: return .orange
            case .level: return .purple
            case .focus: return .green
            case .collection: return .yellow
            }
        }
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        // Quest Achievements
        Achievement(key: "first_quest", title: "First Steps", description: "Complete your first quest", icon: "🎯", requiredValue: 1, category: .quests),
        Achievement(key: "quest_10", title: "Adventurer", description: "Complete 10 quests", icon: "⚔️", requiredValue: 10, category: .quests),
        Achievement(key: "quest_50", title: "Quest Master", description: "Complete 50 quests", icon: "🗡️", requiredValue: 50, category: .quests),
        Achievement(key: "quest_100", title: "Legendary Hero", description: "Complete 100 quests", icon: "🏆", requiredValue: 100, category: .quests),
        
        // Streak Achievements
        Achievement(key: "streak_3", title: "Warming Up", description: "Maintain a 3-day streak", icon: "🔥", requiredValue: 3, category: .streak),
        Achievement(key: "streak_7", title: "Week Warrior", description: "Maintain a 7-day streak", icon: "🔥🔥", requiredValue: 7, category: .streak),
        Achievement(key: "streak_30", title: "Unstoppable", description: "Maintain a 30-day streak", icon: "🔥🔥🔥", requiredValue: 30, category: .streak),
        
        // Level Achievements
        Achievement(key: "level_5", title: "Rising Star", description: "Reach level 5", icon: "⭐", requiredValue: 5, category: .level),
        Achievement(key: "level_10", title: "Seasoned Adventurer", description: "Reach level 10", icon: "🌟", requiredValue: 10, category: .level),
        Achievement(key: "level_25", title: "Epic Hero", description: "Reach level 25", icon: "💫", requiredValue: 25, category: .level),
        
        // Focus Achievements
        Achievement(key: "focus_60", title: "Deep Focus", description: "Complete a 60-minute focus session", icon: "🧘", requiredValue: 60, category: .focus),
        Achievement(key: "focus_total_300", title: "Focus Master", description: "Focus for 300 minutes total", icon: "🎯", requiredValue: 300, category: .focus),
        Achievement(key: "focus_total_1000", title: "Zen Master", description: "Focus for 1000 minutes total", icon: "🧘‍♂️", requiredValue: 1000, category: .focus),
        
        // Collection Achievements
        Achievement(key: "all_classes", title: "Jack of All Trades", description: "Try all character classes", icon: "🎭", requiredValue: 6, category: .collection),
        Achievement(key: "all_categories", title: "Well Rounded", description: "Complete quests in all categories", icon: "🌈", requiredValue: 6, category: .collection),
        
        // Additional Achievements
        Achievement(key: "early_bird", title: "Early Bird", description: "Complete a quest before 8 AM", icon: "🌅", requiredValue: 1, category: .quests),
        Achievement(key: "night_owl", title: "Night Owl", description: "Complete a quest after 10 PM", icon: "🦉", requiredValue: 1, category: .quests),
        Achievement(key: "perfect_week", title: "Perfect Week", description: "Complete all daily quests for 7 days", icon: "✨", requiredValue: 7, category: .quests),
        Achievement(key: "speed_demon", title: "Speed Demon", description: "Complete 5 quests in one day", icon: "⚡", requiredValue: 5, category: .quests),
        Achievement(key: "gold_hoarder", title: "Gold Hoarder", description: "Accumulate 1000 gold", icon: "💰", requiredValue: 1000, category: .collection),
        Achievement(key: "pomodoro_master", title: "Pomodoro Master", description: "Complete 25 Pomodoro sessions", icon: "🍅", requiredValue: 25, category: .focus),
        Achievement(key: "routine_champion", title: "Routine Champion", description: "Complete all routines for 7 days straight", icon: "🏅", requiredValue: 7, category: .streak)
    ]
}

// MARK: - Recurrence Rule
struct RecurrenceRule: Codable, Equatable {
    enum Frequency: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        var calendarComponent: Calendar.Component {
            switch self {
            case .daily: return .day
            case .weekly, .biweekly: return .weekOfYear
            case .monthly: return .month
            case .yearly: return .year
            }
        }
        
        var interval: Int {
            switch self {
            case .biweekly: return 2
            default: return 1
            }
        }
    }
    
    var frequency: Frequency
    var interval: Int = 1
    var daysOfWeek: [Int] = [] // 1 = Sunday, 7 = Saturday
    var dayOfMonth: Int? // For monthly recurrence
    var monthOfYear: Int? // For yearly recurrence
    
    var description: String {
        switch frequency {
        case .daily:
            return interval == 1 ? "Daily" : "Every \(interval) days"
        case .weekly:
            if daysOfWeek.isEmpty {
                return "Weekly"
            } else {
                let dayNames = daysOfWeek.map { dayName(for: $0) }.joined(separator: ", ")
                return "Weekly on \(dayNames)"
            }
        case .biweekly:
            return "Every 2 weeks"
        case .monthly:
            if let day = dayOfMonth {
                return "Monthly on day \(day)"
            }
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
    
    private func dayName(for dayNumber: Int) -> String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[dayNumber - 1]
    }
}

// MARK: - Calendar Event Model
struct CalendarEvent: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String = ""
    var date: Date
    var duration: Int = 60 // in minutes
    var eventType: EventType
    var category: TaskCategory
    var priority: EventPriority = .medium
    var courseOrSubject: String = ""
    var location: String = ""
    var reminder: ReminderTime?
    var isCompleted: Bool = false
    var convertedToQuest: Bool = false
    var relatedQuestId: UUID?
    var calendarIdentifier: String? // For syncing with iOS Calendar
    
    // Recurring event properties
    var isRecurring: Bool = false
    var recurrenceRule: RecurrenceRule?
    var recurrenceEndDate: Date?
    var recurrenceCount: Int?
    var originalEventId: UUID? // For recurring event instances
    var exceptionDates: [Date] = [] // Dates to skip in recurrence
    var attendees: [String] = [] // Event attendees
    
    var endDate: Date {
        Calendar.current.date(byAdding: .minute, value: duration, to: date) ?? date
    }
    
    enum EventType: String, CaseIterable, Codable {
        case classSession = "Class Session"
        case assignment = "Assignment"
        case exam = "Exam"
        case project = "Project"
        case presentation = "Presentation"
        case meeting = "Meeting"
        case studySession = "Study Session"
        case deadline = "Deadline"
        case extracurricular = "Activity"
        case personal = "Personal"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .classSession: return "📚"
            case .assignment: return "📝"
            case .exam: return "📋"
            case .project: return "🎯"
            case .presentation: return "🎤"
            case .meeting: return "👥"
            case .studySession: return "🧠"
            case .deadline: return "⏰"
            case .extracurricular: return "🎭"
            case .personal: return "⭐"
            case .other: return "📌"
            }
        }
        
        var defaultDifficulty: Difficulty {
            switch self {
            case .exam, .presentation: return .hard
            case .project, .assignment: return .medium
            default: return .easy
            }
        }
    }
    
    enum EventPriority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
        
        var color: Color {
            switch self {
            case .low: return .mindLabsTextSecondary
            case .medium: return .mindLabsWarning
            case .high: return .mindLabsError
            case .critical: return .red
            }
        }
        
        var xpMultiplier: Double {
            switch self {
            case .low: return 0.8
            case .medium: return 1.0
            case .high: return 1.3
            case .critical: return 1.6
            }
        }
    }
}

// MARK: - Reminder Time
enum ReminderTime: String, CaseIterable, Codable {
    case none = "None"
    case atTime = "At time of event"
    case fiveMinutes = "5 minutes before"
    case fifteenMinutes = "15 minutes before"
    case thirtyMinutes = "30 minutes before"
    case oneHour = "1 hour before"
    case oneDay = "1 day before"
    
    var minutes: Int? {
        switch self {
        case .none: return nil
        case .atTime: return 0
        case .fiveMinutes: return -5
        case .fifteenMinutes: return -15
        case .thirtyMinutes: return -30
        case .oneHour: return -60
        case .oneDay: return -1440
        }
    }
}

// MARK: - Calendar Sync Settings
struct CalendarSyncSettings: Codable {
    var isEnabled: Bool = false
    var selectedCalendarIdentifier: String?
    var autoConvertToQuests: Bool = false
    var syncPastDays: Int = 7
    var syncFutureDays: Int = 30
}

// Extension for CalendarEvent
extension CalendarEvent {
    // Custom initializer for convenience
    init(
        title: String,
        description: String = "",
        date: Date,
        duration: Int = 60,
        eventType: EventType,
        category: TaskCategory,
        priority: EventPriority = .medium,
        courseOrSubject: String = "",
        location: String = "",
        reminder: ReminderTime? = nil,
        attendees: [String] = [],
        isRecurring: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        recurrenceEndDate: Date? = nil,
        recurrenceCount: Int? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.date = date
        self.duration = duration
        self.eventType = eventType
        self.category = category
        self.priority = priority
        self.courseOrSubject = courseOrSubject
        self.location = location
        self.reminder = reminder
        self.isCompleted = false
        self.convertedToQuest = false
        self.relatedQuestId = nil
        self.calendarIdentifier = nil
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.recurrenceEndDate = recurrenceEndDate
        self.recurrenceCount = recurrenceCount
        self.originalEventId = nil
        self.exceptionDates = []
        self.attendees = attendees
    }
    
    func toQuest() -> Quest {
        let baseTitle = "\(eventType.icon) \(title)"
        let questTitle = priority == .critical ? "⚡ \(baseTitle)" : baseTitle
        
        return Quest(
            title: questTitle,
            description: "\(courseOrSubject.isEmpty ? "" : "[\(courseOrSubject)] ")\(description)",
            category: category,
            difficulty: eventType.defaultDifficulty,
            estimatedTime: duration,
            dueDate: date
        )
    }
}

// MARK: - Parent Rewards System
struct ParentReward: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var requiredLevel: Int
    var additionalRequirements: [RewardRequirement] = []
    var isActive: Bool = true
    var isClaimed: Bool = false
    var isApproved: Bool = false
    var claimedDate: Date?
    var approvedDate: Date?
    var createdDate: Date = Date()
    
    enum RewardRequirement: Codable {
        case minimumStreak(days: Int)
        case achievementCount(count: Int)
        case questsCompleted(count: Int)
        case focusMinutes(minutes: Int)
        
        var description: String {
            switch self {
            case .minimumStreak(let days):
                return "\(days)-day streak"
            case .achievementCount(let count):
                return "\(count) achievements unlocked"
            case .questsCompleted(let count):
                return "\(count) quests completed"
            case .focusMinutes(let minutes):
                return "\(minutes) minutes focused"
            }
        }
        
        func isMet(character: Character, achievements: [Achievement]) -> Bool {
            switch self {
            case .minimumStreak(let days):
                return character.streak >= days
            case .achievementCount(let count):
                return achievements.filter { $0.isUnlocked }.count >= count
            case .questsCompleted(let count):
                return character.totalQuestsCompleted >= count
            case .focusMinutes(let minutes):
                return character.totalFocusMinutes >= minutes
            }
        }
    }
}

extension ParentReward {
    static let defaultRewards: [ParentReward] = [
        ParentReward(
            title: "Extra Hour Screen Time",
            description: "One extra hour of screen time this weekend",
            requiredLevel: 5,
            additionalRequirements: [.minimumStreak(days: 3)]
        ),
        ParentReward(
            title: "Choose Family Movie Night",
            description: "Pick the movie for family movie night",
            requiredLevel: 10,
            additionalRequirements: [.questsCompleted(count: 50)]
        ),
        ParentReward(
            title: "Late Bedtime Weekend",
            description: "Stay up 1 hour later on Friday or Saturday",
            requiredLevel: 15,
            additionalRequirements: [.achievementCount(count: 10)]
        ),
        ParentReward(
            title: "Friend Outing",
            description: "Special outing with friends",
            requiredLevel: 20,
            additionalRequirements: [.focusMinutes(minutes: 600)]
        )
    ]
}

// MARK: - Routine Models
struct Routine: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var type: RoutineType
    var steps: [RoutineStep] = []
    var isActive: Bool = true
    var targetTime: Int // in minutes
    var color: String = "mindLabsPurple"
    var notificationTime: Date?
    var completionStreak: Int = 0
    var lastCompletedDate: Date?
    var createdDate: Date = Date()
    
    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    var totalEstimatedTime: Int {
        steps.reduce(0) { $0 + $1.estimatedTime }
    }
    
    var completedStepsToday: Int {
        steps.filter { step in
            guard let completedAt = step.lastCompletedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }.count
    }
    
    var progressToday: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedStepsToday) / Double(steps.count)
    }
}

struct RoutineStep: Identifiable, Codable {
    var id = UUID()
    var title: String
    var icon: String
    var estimatedTime: Int // in minutes
    var order: Int
    var isOptional: Bool = false
    var lastCompletedAt: Date?
    var completionCount: Int = 0
    
    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompletedAt else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    mutating func markCompleted() {
        lastCompletedAt = Date()
        completionCount += 1
    }
    
    mutating func markIncomplete() {
        if isCompletedToday {
            lastCompletedAt = nil
            completionCount = max(0, completionCount - 1)
        }
    }
}

enum RoutineType: String, CaseIterable, Codable {
    case morning = "Morning"
    case evening = "Evening"
    case study = "Study"
    case exercise = "Exercise"
    case custom = "Custom"
    
    var defaultIcon: String {
        switch self {
        case .morning: return "☀️"
        case .evening: return "🌙"
        case .study: return "📚"
        case .exercise: return "💪"
        case .custom: return "⭐"
        }
    }
    
    var suggestedSteps: [(title: String, icon: String, time: Int)] {
        switch self {
        case .morning:
            return [
                ("Wake up & stretch", "🛏️", 5),
                ("Brush teeth", "🪥", 3),
                ("Shower", "🚿", 10),
                ("Get dressed", "👕", 5),
                ("Eat breakfast", "🥣", 15),
                ("Take medications", "💊", 2),
                ("Pack bag", "🎒", 5),
                ("Check schedule", "📅", 3)
            ]
        case .evening:
            return [
                ("Set out clothes for tomorrow", "👔", 5),
                ("Pack tomorrow's bag", "🎒", 5),
                ("Brush teeth", "🪥", 3),
                ("Wash face", "🧼", 2),
                ("Take medications", "💊", 2),
                ("Read or relax", "📖", 15),
                ("Set alarms", "⏰", 2),
                ("Lights out", "🛏️", 1)
            ]
        case .study:
            return [
                ("Clear desk space", "🧹", 3),
                ("Gather materials", "📚", 5),
                ("Review goals", "🎯", 3),
                ("Focus session 1", "🧠", 25),
                ("Short break", "☕", 5),
                ("Focus session 2", "🧠", 25),
                ("Review & organize notes", "📝", 10)
            ]
        case .exercise:
            return [
                ("Change into workout clothes", "👟", 5),
                ("Warm up", "🏃", 5),
                ("Main exercise", "💪", 20),
                ("Cool down", "🧘", 5),
                ("Shower", "🚿", 10),
                ("Hydrate", "💧", 2)
            ]
        case .custom:
            return []
        }
    }
}