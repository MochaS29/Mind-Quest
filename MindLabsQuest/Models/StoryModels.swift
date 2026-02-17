import Foundation

// MARK: - Story Chapter
struct StoryChapter: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var unlockRequirements: UnlockRequirements
    var isUnlocked: Bool = false
    var isCompleted: Bool = false
    var nodes: [StoryNode]
    var rewards: ChapterRewards
    var backgroundImage: String?
    var nextChapterOptions: [String]
}

enum ChapterUnlockMode: String, Codable {
    case any   // Complete any one of the prerequisites
    case all   // Complete all prerequisites
}

struct UnlockRequirements: Codable {
    var tasksRequired: Int
    var previousChapters: [String]
    var unlockMode: ChapterUnlockMode

    // Convenience init for single chapter (backward compat)
    init(tasksRequired: Int, previousChapter: String?) {
        self.tasksRequired = tasksRequired
        self.previousChapters = previousChapter.map { [$0] } ?? []
        self.unlockMode = .any
    }

    // Full init for branching chapters
    init(tasksRequired: Int, previousChapters: [String], unlockMode: ChapterUnlockMode = .any) {
        self.tasksRequired = tasksRequired
        self.previousChapters = previousChapters
        self.unlockMode = unlockMode
    }

    // Custom decoder for backward compatibility with old single-chapter format
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tasksRequired = try container.decode(Int.self, forKey: .tasksRequired)
        unlockMode = try container.decodeIfPresent(ChapterUnlockMode.self, forKey: .unlockMode) ?? .any

        if let chapters = try? container.decode([String].self, forKey: .previousChapters) {
            previousChapters = chapters
        } else if let single = try? container.decode(String.self, forKey: .previousChapter) {
            previousChapters = [single]
        } else {
            previousChapters = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tasksRequired, forKey: .tasksRequired)
        try container.encode(previousChapters, forKey: .previousChapters)
        try container.encode(unlockMode, forKey: .unlockMode)
    }

    private enum CodingKeys: String, CodingKey {
        case tasksRequired, previousChapters, previousChapter, unlockMode
    }
}

struct ChapterRewards: Codable {
    var xp: Int
    var gold: Int
    var items: [String]?
}

// MARK: - Story Node
struct StoryNode: Identifiable, Codable {
    var id: UUID
    var type: NodeType
    var title: String
    var dialogue: [DialogueLine]?
    var battle: BattleEncounter?
    var choices: [StoryChoice]?
    var backgroundImage: String?
    var nextNodeId: UUID?
}

enum NodeType: String, Codable {
    case dialogue
    case exploration
    case battle
    case choice
    case reward
    case checkpoint
}

// MARK: - Dialogue Line
struct DialogueLine: Identifiable, Codable {
    var id: UUID = UUID()
    var speaker: String
    var speakerAvatar: String?
    var text: String
    var emotion: String?
}

// MARK: - Story Choice
struct StoryChoice: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var consequence: String
    var icon: String?
    var leadsToNodeId: UUID?
    var leadsToChapterId: String?
}

// MARK: - Story Progress
struct StoryProgress: Codable {
    var currentChapterId: String = "chapter_1"
    var currentNodeIndex: Int = 0
    var completedChapters: Set<String> = []
    var unlockedChapters: Set<String> = ["chapter_1"]
    var storyKeys: Int = 0
    var choicesMade: [String: String] = [:]
    var totalBattlesWon: Int = 0
    var memoryFragmentsCollected: Set<String> = []
    var companionsRecruited: Set<String> = []
}
