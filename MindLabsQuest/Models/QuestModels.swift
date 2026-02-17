import Foundation
import SwiftUI

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

// MARK: - Quest/Task Model
struct Quest: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String = ""
    var category: TaskCategory
    var difficulty: Difficulty
    var estimatedTime: Int = 25
    var dueDate: Date?
    var isCompleted: Bool = false
    var completedAt: Date?
    var isDaily: Bool = false
    var questTemplate: DailyQuestTemplate?
    var createdDate: Date = Date()
    var subtasks: [Subtask] = []
    var parentQuestId: UUID? = nil
    var actualTimeSpent: Int = 0
    var startedAt: Date?
    var timeSpentSessions: [TimeSession] = []

    var xpReward: Int {
        if let template = questTemplate {
            return template.baseXP
        }
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
    var duration: Int {
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
    var estimatedTime: Int = 10
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
        for template in templates {
            if template.category == category {
                let keywords = template.taskType.lowercased().components(separatedBy: " ")
                let titleLower = title.lowercased()

                if keywords.contains(where: { titleLower.contains($0) }) {
                    return template.suggestedSteps
                }
            }
        }

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
        DailyQuestTemplate(id: "morning_shower", epicTitle: "The Cleansing Ritual of Dawn", normalTitle: "Morning Shower", category: .health, difficulty: .easy, estimatedTime: 15, baseXP: 30, baseGold: 5, icon: "🚿", timeOfDay: .morning),
        DailyQuestTemplate(id: "brush_teeth_morning", epicTitle: "Defend the Ivory Gates", normalTitle: "Brush Teeth (Morning)", category: .health, difficulty: .easy, estimatedTime: 3, baseXP: 20, baseGold: 3, icon: "🦷", timeOfDay: .morning),
        DailyQuestTemplate(id: "floss_teeth", epicTitle: "Thread the Needle of Dental Excellence", normalTitle: "Floss Teeth", category: .health, difficulty: .medium, estimatedTime: 5, baseXP: 25, baseGold: 4, icon: "🦷✨", timeOfDay: .evening),
        DailyQuestTemplate(id: "hair_care", epicTitle: "Tame the Wild Mane", normalTitle: "Brush/Style Hair", category: .health, difficulty: .easy, estimatedTime: 5, baseXP: 15, baseGold: 2, icon: "💇", timeOfDay: .morning),

        // School Preparation
        DailyQuestTemplate(id: "pack_lunch", epicTitle: "Prepare the Adventurer's Feast", normalTitle: "Pack Lunch", category: .lifeSkills, difficulty: .easy, estimatedTime: 10, baseXP: 25, baseGold: 4, icon: "🍱", timeOfDay: .morning),
        DailyQuestTemplate(id: "pack_homework", epicTitle: "Secure the Sacred Scrolls", normalTitle: "Pack Homework", category: .academic, difficulty: .easy, estimatedTime: 5, baseXP: 20, baseGold: 3, icon: "📝", timeOfDay: .morning),
        DailyQuestTemplate(id: "pack_backpack", epicTitle: "Ready the Explorer's Arsenal", normalTitle: "Pack Backpack", category: .lifeSkills, difficulty: .easy, estimatedTime: 10, baseXP: 25, baseGold: 4, icon: "🎒", timeOfDay: .morning),

        // Academic Quests
        DailyQuestTemplate(id: "complete_homework", epicTitle: "Conquer the Academic Challenges", normalTitle: "Complete Homework", category: .academic, difficulty: .medium, estimatedTime: 45, baseXP: 60, baseGold: 10, icon: "📚", timeOfDay: .afternoon),
        DailyQuestTemplate(id: "study_session", epicTitle: "Delve into the Tomes of Knowledge", normalTitle: "Study Session", category: .academic, difficulty: .medium, estimatedTime: 30, baseXP: 50, baseGold: 8, icon: "🧠", timeOfDay: .afternoon),
        DailyQuestTemplate(id: "read_20min", epicTitle: "Journey Through Literary Realms", normalTitle: "Read for 20 Minutes", category: .academic, difficulty: .easy, estimatedTime: 20, baseXP: 35, baseGold: 5, icon: "📖", timeOfDay: .anytime),

        // Physical Activity
        DailyQuestTemplate(id: "morning_exercise", epicTitle: "Train at the Dawn Dojo", normalTitle: "Morning Exercise", category: .fitness, difficulty: .medium, estimatedTime: 20, baseXP: 45, baseGold: 7, icon: "🏃", timeOfDay: .morning),
        DailyQuestTemplate(id: "stretch_routine", epicTitle: "Master the Art of Flexibility", normalTitle: "Stretching Routine", category: .fitness, difficulty: .easy, estimatedTime: 10, baseXP: 25, baseGold: 4, icon: "🧘", timeOfDay: .anytime),
        DailyQuestTemplate(id: "outdoor_activity", epicTitle: "Venture into the Wild", normalTitle: "30 Min Outdoor Activity", category: .fitness, difficulty: .medium, estimatedTime: 30, baseXP: 50, baseGold: 8, icon: "🌳", timeOfDay: .afternoon),

        // Life Skills & Chores
        DailyQuestTemplate(id: "tidy_room", epicTitle: "Restore Order to Your Sanctuary", normalTitle: "Tidy Room", category: .lifeSkills, difficulty: .easy, estimatedTime: 15, baseXP: 30, baseGold: 5, icon: "🧹", timeOfDay: .anytime),
        DailyQuestTemplate(id: "make_bed", epicTitle: "Craft the Perfect Resting Chamber", normalTitle: "Make Bed", category: .lifeSkills, difficulty: .easy, estimatedTime: 5, baseXP: 15, baseGold: 2, icon: "🛏️", timeOfDay: .morning),
        DailyQuestTemplate(id: "organize_desk", epicTitle: "Master Your Command Center", normalTitle: "Organize Desk/Workspace", category: .lifeSkills, difficulty: .easy, estimatedTime: 10, baseXP: 25, baseGold: 4, icon: "🗂️", timeOfDay: .anytime),

        // Evening Routines
        DailyQuestTemplate(id: "prepare_tomorrow", epicTitle: "Plan Tomorrow's Campaign", normalTitle: "Prepare for Tomorrow", category: .lifeSkills, difficulty: .easy, estimatedTime: 10, baseXP: 25, baseGold: 4, icon: "📅", timeOfDay: .evening),
        DailyQuestTemplate(id: "evening_reflection", epicTitle: "Meditate on Today's Adventures", normalTitle: "Evening Reflection/Journal", category: .health, difficulty: .easy, estimatedTime: 10, baseXP: 30, baseGold: 5, icon: "📔", timeOfDay: .evening),
        DailyQuestTemplate(id: "brush_teeth_night", epicTitle: "The Nighttime Dental Defense", normalTitle: "Brush Teeth (Night)", category: .health, difficulty: .easy, estimatedTime: 3, baseXP: 20, baseGold: 3, icon: "🦷🌙", timeOfDay: .evening),

        // Social & Creative
        DailyQuestTemplate(id: "help_family", epicTitle: "Aid Your Fellow Adventurers", normalTitle: "Help Family Member", category: .social, difficulty: .easy, estimatedTime: 15, baseXP: 35, baseGold: 6, icon: "🤝", timeOfDay: .anytime),
        DailyQuestTemplate(id: "creative_time", epicTitle: "Channel Your Creative Energy", normalTitle: "Creative Activity (Draw/Music/Write)", category: .creative, difficulty: .medium, estimatedTime: 30, baseXP: 45, baseGold: 7, icon: "🎨", timeOfDay: .anytime),
        DailyQuestTemplate(id: "practice_skill", epicTitle: "Hone Your Chosen Craft", normalTitle: "Practice Instrument/Skill", category: .creative, difficulty: .medium, estimatedTime: 20, baseXP: 40, baseGold: 6, icon: "🎵", timeOfDay: .anytime),

        // Test & Study
        DailyQuestTemplate(id: "study_for_test", epicTitle: "Forge Knowledge in the Crucible of Study", normalTitle: "Study for Test/Quiz", category: .academic, difficulty: .hard, estimatedTime: 45, baseXP: 60, baseGold: 10, icon: "📚", timeOfDay: .anytime),
        DailyQuestTemplate(id: "complete_quiz", epicTitle: "Face the Trial of Knowledge", normalTitle: "Complete Quiz/Test", category: .academic, difficulty: .hard, estimatedTime: 30, baseXP: 50, baseGold: 8, icon: "📋", timeOfDay: .anytime),
        DailyQuestTemplate(id: "review_notes", epicTitle: "Decipher the Ancient Scrolls", normalTitle: "Review Class Notes", category: .academic, difficulty: .medium, estimatedTime: 20, baseXP: 30, baseGold: 5, icon: "📓", timeOfDay: .anytime),

        // New Activities & Challenges
        DailyQuestTemplate(id: "try_new_activity", epicTitle: "Venture Into the Unknown", normalTitle: "Try a New Activity", category: .social, difficulty: .medium, estimatedTime: 30, baseXP: 40, baseGold: 6, icon: "🌟", timeOfDay: .anytime),
        DailyQuestTemplate(id: "join_club_meeting", epicTitle: "Gather with the Alliance", normalTitle: "Attend Club/Group Meeting", category: .social, difficulty: .medium, estimatedTime: 60, baseXP: 45, baseGold: 7, icon: "👥", timeOfDay: .afternoon),
        DailyQuestTemplate(id: "talk_to_new_person", epicTitle: "Forge New Alliances", normalTitle: "Talk to Someone New", category: .social, difficulty: .hard, estimatedTime: 10, baseXP: 35, baseGold: 5, icon: "🗣️", timeOfDay: .anytime),

        // Focus & Organization
        DailyQuestTemplate(id: "organize_workspace", epicTitle: "Restore Order to the Chaos Realm", normalTitle: "Organize Desk/Workspace", category: .lifeSkills, difficulty: .medium, estimatedTime: 15, baseXP: 25, baseGold: 4, icon: "🗂️", timeOfDay: .anytime),
        DailyQuestTemplate(id: "use_planner", epicTitle: "Chart the Path of Destiny", normalTitle: "Update Planner/Calendar", category: .lifeSkills, difficulty: .easy, estimatedTime: 10, baseXP: 20, baseGold: 3, icon: "📅", timeOfDay: .anytime),
        DailyQuestTemplate(id: "break_task_chunks", epicTitle: "Divide and Conquer the Mountain", normalTitle: "Break Big Task into Steps", category: .lifeSkills, difficulty: .medium, estimatedTime: 15, baseXP: 30, baseGold: 5, icon: "📊", timeOfDay: .anytime),

        // Emotional Regulation
        DailyQuestTemplate(id: "mindfulness_break", epicTitle: "Commune with the Inner Spirit", normalTitle: "5-Minute Mindfulness", category: .health, difficulty: .easy, estimatedTime: 5, baseXP: 15, baseGold: 2, icon: "🧘", timeOfDay: .anytime),
        DailyQuestTemplate(id: "journal_feelings", epicTitle: "Chronicle the Emotional Journey", normalTitle: "Journal Thoughts/Feelings", category: .health, difficulty: .medium, estimatedTime: 15, baseXP: 25, baseGold: 4, icon: "📔", timeOfDay: .evening),
        DailyQuestTemplate(id: "ask_for_help", epicTitle: "Summon the Wisdom of Allies", normalTitle: "Ask for Help When Needed", category: .social, difficulty: .hard, estimatedTime: 10, baseXP: 40, baseGold: 6, icon: "🤝", timeOfDay: .anytime),

        // Movement & Energy
        DailyQuestTemplate(id: "movement_break", epicTitle: "Dance with the Energy Dragons", normalTitle: "5-Minute Movement Break", category: .fitness, difficulty: .easy, estimatedTime: 5, baseXP: 15, baseGold: 2, icon: "💃", timeOfDay: .anytime),
        DailyQuestTemplate(id: "fidget_tool", epicTitle: "Channel the Restless Energy", normalTitle: "Use Fidget Tool During Task", category: .health, difficulty: .easy, estimatedTime: 30, baseXP: 20, baseGold: 3, icon: "🎯", timeOfDay: .anytime)
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
