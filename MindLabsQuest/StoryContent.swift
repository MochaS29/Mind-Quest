import Foundation

// MARK: - Story Content
// Contains all chapter data and story content for MindQuest RPG

struct StoryContent {

    // MARK: - All Chapters
    static var allChapters: [StoryChapter] {
        [chapter1, chapter2A, chapter2B]
    }

    // MARK: - Node IDs for Chapter 1
    private static let node1_awakening = UUID()
    private static let node2_village = UUID()
    private static let node3_threat = UUID()
    private static let node4_battle = UUID()
    private static let node5_decision = UUID()
    private static let node6_complete = UUID()

    // MARK: - Chapter 1: The Awakening
    static var chapter1: StoryChapter {
        StoryChapter(
            id: "chapter_1",
            title: "The Awakening",
            description: "You awaken in a small village with no memory of your past. As darkness threatens the land, you must discover who you are and what role you'll play in the coming conflict.",
            unlockRequirements: UnlockRequirements(tasksRequired: 0, previousChapter: nil),
            isUnlocked: true,
            isCompleted: false,
            nodes: chapter1Nodes,
            rewards: ChapterRewards(xp: 100, gold: 50, items: ["Story Key"]),
            backgroundImage: "village_background",
            nextChapterOptions: ["chapter_2a", "chapter_2b"]
        )
    }

    private static var chapter1Nodes: [StoryNode] {
        [
            // Node 1: Awakening (dialogue)
            StoryNode(
                id: node1_awakening,
                type: .dialogue,
                title: "Awakening",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Darkness. Then, a flicker of light...", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Voices, distant but growing clearer...", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You open your eyes.", emotion: nil),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "Easy now, young one. You've been unconscious for three days.", emotion: "concerned"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "We found you at the edge of the Whispering Woods, alone and wounded.", emotion: "concerned"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "Do you remember anything? Your name? Where you came from?", emotion: "curious"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Fragments of memory surface... a battle... shadows... a blinding light...", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "But the details slip away like water through your fingers.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "village_interior",
                nextNodeId: node2_village
            ),

            // Node 2: The Village (exploration)
            StoryNode(
                id: node2_village,
                type: .exploration,
                title: "The Village",
                dialogue: [
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "This is Millbrook Village. We are simple folk - farmers, craftsmen, healers.", emotion: "neutral"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "But these are dark times. The Shadow Blight spreads from the north.", emotion: "worried"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "Creatures of darkness attack our borders. We've lost... many.", emotion: "sad"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You notice the worried faces of villagers. Children clutch their parents.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Barricades have been hastily constructed. This village lives in fear.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "village_square",
                nextNodeId: node3_threat
            ),

            // Node 3: The Threat (dialogue)
            StoryNode(
                id: node3_threat,
                type: .dialogue,
                title: "The Threat",
                dialogue: [
                    DialogueLine(speaker: "Village Scout", speakerAvatar: "village_scout", text: "Elder! They're coming! A shadow creature was spotted near the eastern well!", emotion: "panicked"),
                    DialogueLine(speaker: "Village Scout", speakerAvatar: "village_scout", text: "It's alone, but where there's one, more follow!", emotion: "fearful"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "Stranger... I know I have no right to ask, but... will you help us?", emotion: "pleading"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "Something tells me you are more than you appear.", emotion: "hopeful"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You feel strength flowing through you. Perhaps fighting will help you remember.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You grip your weapon and nod.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "village_edge",
                nextNodeId: node4_battle
            ),

            // Node 4: First Battle - Shadow Scout
            StoryNode(
                id: node4_battle,
                type: .battle,
                title: "Shadow Scout",
                dialogue: nil,
                battle: BattleEncounter(
                    id: UUID(),
                    enemyName: "Shadow Scout",
                    enemyAvatar: "shadow_scout",
                    enemyDescription: "A creature of living shadow, sent to probe the village's defenses.",
                    enemyLevel: 1,
                    enemyHP: 50,
                    enemyMaxHP: 50,
                    enemyAttack: 12,
                    enemyDefense: 5,
                    isBoss: false,
                    abilities: [
                        EnemyAbility(name: "Shadow Strike", damage: 15, description: "A swift strike from the darkness", chance: 0.4),
                        EnemyAbility(name: "Fade", damage: 0, description: "Becomes harder to hit", chance: 0.2)
                    ],
                    rewards: BattleRewards(xp: 50, gold: 25),
                    backgroundImage: "forest_dark",
                    preBattleText: "A creature of living shadow emerges from the trees. Its hollow eyes fix on you.",
                    victoryText: "The shadow creature dissolves into wisps of darkness. The villagers cheer!"
                ),
                choices: nil,
                backgroundImage: "forest_dark",
                nextNodeId: node5_decision
            ),

            // Node 5: The Decision (choice)
            StoryNode(
                id: node5_decision,
                type: .choice,
                title: "The Decision",
                dialogue: [
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "You fight like a true warrior! Perhaps... perhaps you were sent to help us.", emotion: "amazed"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "More creatures will come. The source lies in the Cursed Hollow to the north.", emotion: "serious"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "But I see something in your eyes. You seek answers about yourself.", emotion: "understanding"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "What will you do?", emotion: "curious")
                ],
                battle: nil,
                choices: [
                    StoryChoice(
                        text: "Defend the Village",
                        consequence: "The villagers will become your allies. Strength in numbers.",
                        icon: "shield.fill",
                        leadsToNodeId: nil,
                        leadsToChapterId: "chapter_2a"
                    ),
                    StoryChoice(
                        text: "Pursue the Source",
                        consequence: "You may find answers... but the path is dangerous alone.",
                        icon: "magnifyingglass",
                        leadsToNodeId: nil,
                        leadsToChapterId: "chapter_2b"
                    )
                ],
                backgroundImage: "village_sunset",
                nextNodeId: node6_complete
            ),

            // Node 6: Chapter Complete (checkpoint)
            StoryNode(
                id: node6_complete,
                type: .checkpoint,
                title: "Chapter Complete",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Your path is chosen. Your journey has begun.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "But this is only the first chapter of your story...", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "sunset_road",
                nextNodeId: nil
            )
        ]
    }

    // MARK: - Chapter 2A: The Siege (Defend the Village path)
    static var chapter2A: StoryChapter {
        StoryChapter(
            id: "chapter_2a",
            title: "The Siege",
            description: "You've chosen to stand with the villagers. As night falls, the shadow forces gather for their assault. Can you hold the line until dawn?",
            unlockRequirements: UnlockRequirements(tasksRequired: 5, previousChapter: "chapter_1"),
            isUnlocked: false,
            isCompleted: false,
            nodes: chapter2ANodes,
            rewards: ChapterRewards(xp: 150, gold: 75, items: ["Village Champion Badge"]),
            backgroundImage: "village_night",
            nextChapterOptions: ["chapter_3"]
        )
    }

    private static let node2a_1 = UUID()
    private static let node2a_2 = UUID()
    private static let node2a_3 = UUID()

    private static var chapter2ANodes: [StoryNode] {
        [
            StoryNode(
                id: node2a_1,
                type: .dialogue,
                title: "Preparing Defenses",
                dialogue: [
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "Thank you for staying. The villagers draw courage from your presence.", emotion: "grateful"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "We have until nightfall to prepare our defenses.", emotion: "determined"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The villagers gather weapons - pitchforks, hunting bows, old swords.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You help reinforce the barricades as the sun begins to set.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "village_preparation",
                nextNodeId: node2a_2
            ),
            StoryNode(
                id: node2a_2,
                type: .dialogue,
                title: "The Night Falls",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Darkness descends. The forest grows silent.", emotion: nil),
                    DialogueLine(speaker: "Village Scout", speakerAvatar: "village_scout", text: "Movement in the treeline! They're coming!", emotion: "alert"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Dozens of glowing eyes emerge from the shadows.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "village_night",
                nextNodeId: node2a_3
            ),
            StoryNode(
                id: node2a_3,
                type: .battle,
                title: "Shadow Vanguard",
                dialogue: nil,
                battle: BattleEncounter(
                    id: UUID(),
                    enemyName: "Shadow Vanguard",
                    enemyAvatar: "shadow_vanguard",
                    enemyDescription: "A larger, more powerful shadow creature leading the assault.",
                    enemyLevel: 3,
                    enemyHP: 80,
                    enemyMaxHP: 80,
                    enemyAttack: 18,
                    enemyDefense: 8,
                    isBoss: true,
                    abilities: [
                        EnemyAbility(name: "Dark Surge", damage: 22, description: "A wave of shadow energy", chance: 0.3),
                        EnemyAbility(name: "Terrifying Howl", damage: 8, description: "Weakens your resolve", chance: 0.25),
                        EnemyAbility(name: "Shadow Claws", damage: 16, description: "Vicious slashing attack", chance: 0.45)
                    ],
                    rewards: BattleRewards(xp: 100, gold: 50),
                    backgroundImage: "village_battle",
                    preBattleText: "The Shadow Vanguard steps forward, towering over its lesser kin. It raises a clawed hand toward you.",
                    victoryText: "The Vanguard falls! The remaining shadows scatter into the night. Dawn is coming - you've held the line!"
                ),
                choices: nil,
                backgroundImage: "village_battle",
                nextNodeId: nil
            )
        ]
    }

    // MARK: - Chapter 2B: The Dark Road (Pursue the Source path)
    static var chapter2B: StoryChapter {
        StoryChapter(
            id: "chapter_2b",
            title: "The Dark Road",
            description: "You've chosen to seek answers. The path to the Cursed Hollow is treacherous, but perhaps the shadows hold secrets about your forgotten past.",
            unlockRequirements: UnlockRequirements(tasksRequired: 5, previousChapter: "chapter_1"),
            isUnlocked: false,
            isCompleted: false,
            nodes: chapter2BNodes,
            rewards: ChapterRewards(xp: 150, gold: 75, items: ["Memory Fragment"]),
            backgroundImage: "dark_road",
            nextChapterOptions: ["chapter_3"]
        )
    }

    private static let node2b_1 = UUID()
    private static let node2b_2 = UUID()
    private static let node2b_3 = UUID()

    private static var chapter2BNodes: [StoryNode] {
        [
            StoryNode(
                id: node2b_1,
                type: .dialogue,
                title: "Into the Unknown",
                dialogue: [
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "I understand. The need for answers can be overwhelming.", emotion: "understanding"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "Take this map. The Cursed Hollow lies beyond the Whispering Woods.", emotion: "helpful"),
                    DialogueLine(speaker: "Elder Maren", speakerAvatar: "elder_maren", text: "Be careful, stranger. Not all who seek the source return.", emotion: "worried"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You set out alone as the sun sets behind you.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "road_sunset",
                nextNodeId: node2b_2
            ),
            StoryNode(
                id: node2b_2,
                type: .exploration,
                title: "The Whispering Woods",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The trees seem to close in around you. Whispers fill the air.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You catch glimpses of movement in your peripheral vision.", emotion: nil),
                    DialogueLine(speaker: "???", speakerAvatar: nil, text: "...remember... you must remember...", emotion: "ethereal"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "A flash of memory - a face you knew. Gone before you can grasp it.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Something blocks your path ahead.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "whispering_woods",
                nextNodeId: node2b_3
            ),
            StoryNode(
                id: node2b_3,
                type: .battle,
                title: "Memory Guardian",
                dialogue: nil,
                battle: BattleEncounter(
                    id: UUID(),
                    enemyName: "Memory Guardian",
                    enemyAvatar: "memory_guardian",
                    enemyDescription: "A spectral entity that seems strangely familiar. It guards something precious.",
                    enemyLevel: 3,
                    enemyHP: 70,
                    enemyMaxHP: 70,
                    enemyAttack: 15,
                    enemyDefense: 10,
                    isBoss: true,
                    abilities: [
                        EnemyAbility(name: "Forgotten Pain", damage: 18, description: "Attacks with memories of past wounds", chance: 0.35),
                        EnemyAbility(name: "Spectral Shield", damage: 0, description: "Becomes ethereal and hard to hit", chance: 0.2),
                        EnemyAbility(name: "Memory Drain", damage: 12, description: "Steals fragments of your thoughts", chance: 0.45)
                    ],
                    rewards: BattleRewards(xp: 100, gold: 50),
                    backgroundImage: "ethereal_clearing",
                    preBattleText: "The spectral figure raises its hand. For a moment, you see your own face reflected in its form.",
                    victoryText: "The guardian fades, leaving behind a glowing fragment. As you touch it, a memory returns - you were a protector, sworn to fight the darkness. But there's more to discover..."
                ),
                choices: nil,
                backgroundImage: "ethereal_clearing",
                nextNodeId: nil
            )
        ]
    }
}
