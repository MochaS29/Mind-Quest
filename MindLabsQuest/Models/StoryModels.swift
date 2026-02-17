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

struct UnlockRequirements: Codable {
    var tasksRequired: Int
    var previousChapter: String?
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
