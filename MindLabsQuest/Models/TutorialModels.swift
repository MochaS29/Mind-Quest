import Foundation

// MARK: - Tutorial Action
enum TutorialAction: Codable, Equatable {
    case next
    case navigate(String) // AppView name as string for Codable
    case dismiss
}

// MARK: - Tutorial Step
struct TutorialStep: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var message: String
    var targetView: String? // AppView name
    var highlightElement: String? // for future spotlight
    var action: TutorialAction = .next
}

// MARK: - Tutorial Trigger
enum TutorialTrigger: Codable, Equatable {
    case firstLaunch
    case firstBattle
    case levelUp(Int)
    case firstArena
    case reachLevel(Int)
    case firstCraft
    case firstDungeon
}

// MARK: - Tutorial Sequence
struct TutorialSequence: Identifiable, Codable {
    var id: String
    var name: String
    var steps: [TutorialStep]
    var triggerCondition: TutorialTrigger
}

// MARK: - Tutorial State
struct TutorialState: Codable {
    var completedSequenceIds: Set<String> = []
    var currentSequenceId: String? = nil
    var currentStepIndex: Int = 0
}

// MARK: - Tutorial Database
struct TutorialDatabase {
    static let allSequences: [TutorialSequence] = [
        TutorialSequence(
            id: "welcome",
            name: "Welcome",
            steps: [
                TutorialStep(id: "welcome_1", title: "Welcome to MindQuest!", message: "Transform your daily tasks into epic adventures. Complete quests to level up your character!"),
                TutorialStep(id: "welcome_2", title: "Complete Quests", message: "Your daily quests appear on the Quest tab. Complete them to earn XP and gold."),
                TutorialStep(id: "welcome_3", title: "Explore & Battle", message: "Visit the Adventure tab to battle enemies, enter dungeons, and compete in the arena!", action: .dismiss)
            ],
            triggerCondition: .firstLaunch
        ),
        TutorialSequence(
            id: "first_battle",
            name: "Battle Basics",
            steps: [
                TutorialStep(id: "battle_1", title: "Battle Basics", message: "Choose your actions wisely: Attack, Defend, use items, or use special abilities."),
                TutorialStep(id: "battle_2", title: "Use Items", message: "Consumable items like potions can turn the tide of battle. Stock up at the shop!"),
                TutorialStep(id: "battle_3", title: "Collect Loot", message: "Defeated enemies drop gold, XP, and sometimes rare items!", action: .dismiss)
            ],
            triggerCondition: .firstBattle
        ),
        TutorialSequence(
            id: "arena_intro",
            name: "Arena Introduction",
            steps: [
                TutorialStep(id: "arena_1", title: "Welcome to the Arena!", message: "Arena battles cost 2 energy. Fight opponents to earn arena tokens and climb the ranks."),
                TutorialStep(id: "arena_2", title: "Arena Tokens", message: "Win matches to earn arena tokens. Spend them in the Arena Shop for exclusive gear!"),
                TutorialStep(id: "arena_3", title: "Rank Up", message: "Win consistently to increase your rating and unlock higher ranks.", action: .dismiss)
            ],
            triggerCondition: .firstArena
        ),
        TutorialSequence(
            id: "crafting_intro",
            name: "Crafting Introduction",
            steps: [
                TutorialStep(id: "craft_1", title: "Crafting Unlocked!", message: "Gather materials from battles and quests to craft powerful items."),
                TutorialStep(id: "craft_2", title: "Recipes", message: "Discover new recipes as you progress. Combine materials at the crafting station.", action: .dismiss)
            ],
            triggerCondition: .firstCraft
        ),
        TutorialSequence(
            id: "prestige_intro",
            name: "Prestige Introduction",
            steps: [
                TutorialStep(id: "prestige_1", title: "Prestige Available!", message: "You've reached level 20! You can now prestige to start a new journey with permanent bonuses."),
                TutorialStep(id: "prestige_2", title: "What You Keep", message: "Prestige keeps your inventory, equipment, cosmetics, achievements, and story progress."),
                TutorialStep(id: "prestige_3", title: "Permanent Bonuses", message: "Each prestige grants bonus XP, gold, skill points, and a unique perk of your choice!", action: .dismiss)
            ],
            triggerCondition: .reachLevel(20)
        )
    ]
}
