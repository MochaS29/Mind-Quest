import Foundation

// MARK: - Story Content
// Contains all chapter data and story content for MindQuest RPG

struct StoryContent {

    // MARK: - All Chapters
    static var allChapters: [StoryChapter] {
        [chapter1, chapter2A, chapter2B, chapter3, chapter4A, chapter4B]
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

    // MARK: - Chapter 3: The Cursed Hollow (converges both Ch2 paths)

    private static let node3_1 = UUID()
    private static let node3_2 = UUID()
    private static let node3_3 = UUID()
    private static let node3_4 = UUID()
    private static let node3_5 = UUID()
    private static let node3_6 = UUID()
    private static let node3_7 = UUID()

    static var chapter3: StoryChapter {
        StoryChapter(
            id: "chapter_3",
            title: "The Cursed Hollow",
            description: "Whether you defended the village or sought answers alone, your path leads to the Cursed Hollow — the source of the shadow corruption. An ancient evil stirs beneath the twisted trees.",
            unlockRequirements: UnlockRequirements(tasksRequired: 8, previousChapters: ["chapter_2a", "chapter_2b"], unlockMode: .any),
            isUnlocked: false,
            isCompleted: false,
            nodes: chapter3Nodes,
            rewards: ChapterRewards(xp: 200, gold: 100, items: ["Story Key"]),
            backgroundImage: "cursed_hollow",
            nextChapterOptions: ["chapter_4a", "chapter_4b"]
        )
    }

    private static var chapter3Nodes: [StoryNode] {
        [
            // Node 1: Paths converge
            StoryNode(
                id: node3_1,
                type: .dialogue,
                title: "Paths Converge",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The road to the Cursed Hollow narrows. The air grows thick with an unnatural fog.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Whether you chose to defend or to pursue, the shadows have brought you here.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Something ahead moves through the mist — a figure, human, stumbling toward you.", emotion: nil),
                    DialogueLine(speaker: "???", speakerAvatar: nil, text: "Wait! Don't attack — I'm not one of them!", emotion: "desperate")
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "cursed_hollow_entrance",
                nextNodeId: node3_2
            ),

            // Node 2: Corrupted forest exploration
            StoryNode(
                id: node3_2,
                type: .exploration,
                title: "The Corrupted Forest",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The trees here are twisted into unnatural shapes. Dark sap oozes from their bark.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The ground pulses with a faint, sickly light. Something is very wrong with this place.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Animals lie petrified in the undergrowth — frozen mid-stride, eyes wide.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Ahead, the ruins of an ancient structure emerge from the corruption.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "corrupted_forest",
                nextNodeId: node3_3
            ),

            // Node 3: Meet Lyra the scholar
            StoryNode(
                id: node3_3,
                type: .dialogue,
                title: "The Scholar",
                dialogue: [
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "My name is Lyra. I'm a scholar of the old histories.", emotion: "cautious"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "I've been studying this corruption. It's not random — it's deliberate.", emotion: "serious"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Long ago, there existed a barrier between our world and the Shadow Realm — the Boundary.", emotion: "scholarly"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "It was maintained by warriors called the Wardens. But the last Wardens vanished years ago.", emotion: "concerned"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Without them, the Boundary weakens. And things... slip through.", emotion: "worried"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Something about the word 'Warden' stirs a deep, instinctive recognition within you.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "ruined_outpost",
                nextNodeId: node3_4
            ),

            // Node 4: The Watcher vision
            StoryNode(
                id: node3_4,
                type: .dialogue,
                title: "The Watcher",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "A chill runs through you. The air shimmers, and a spectral figure appears.", emotion: nil),
                    DialogueLine(speaker: "The Watcher", speakerAvatar: "the_watcher", text: "At last... one who can see me.", emotion: "ethereal"),
                    DialogueLine(speaker: "The Watcher", speakerAvatar: "the_watcher", text: "The Boundary fractures. Three Heralds of Shadow work to tear it apart.", emotion: "urgent"),
                    DialogueLine(speaker: "The Watcher", speakerAvatar: "the_watcher", text: "Each Herald holds a Key Fragment. Unite them to seal the Boundary.", emotion: "commanding"),
                    DialogueLine(speaker: "The Watcher", speakerAvatar: "the_watcher", text: "But beware — the Heralds are not mindless beasts. They are cunning, powerful, and afraid.", emotion: "warning"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The vision fades, leaving you with a sense of purpose — and dread.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "watcher_vision",
                nextNodeId: node3_5
            ),

            // Node 5: Shadow Stalker battle
            StoryNode(
                id: node3_5,
                type: .battle,
                title: "Shadow Stalker Pack",
                dialogue: nil,
                battle: BattleEncounter(
                    enemyName: "Shadow Stalker",
                    enemyAvatar: "shadow_stalker",
                    enemyDescription: "A pack leader of the shadow creatures, faster and more vicious than its kin.",
                    enemyLevel: 5,
                    enemyHP: 65,
                    enemyMaxHP: 65,
                    enemyAttack: 16,
                    enemyDefense: 8,
                    abilities: [
                        EnemyAbility(name: "Lunge", damage: 20, description: "A lightning-fast pounce", chance: 0.35),
                        EnemyAbility(name: "Shadow Venom", damage: 12, description: "Injects corrupting poison", chance: 0.3,
                                     statusEffect: StatusEffect(type: .poison, duration: 3, value: 5, sourceDescription: "Shadow Venom")),
                        EnemyAbility(name: "Pack Howl", damage: 8, description: "Rallying cry that strengthens the stalker", chance: 0.35)
                    ],
                    rewards: BattleRewards(xp: 100, gold: 50),
                    backgroundImage: "corrupted_forest",
                    preBattleText: "A low growl echoes through the twisted trees. Glowing eyes surround you as a Shadow Stalker emerges.",
                    victoryText: "The stalker falls with a piercing shriek. The pack scatters into the darkness."
                ),
                choices: nil,
                backgroundImage: "corrupted_forest",
                nextNodeId: node3_6
            ),

            // Node 6: Ruined outpost exploration
            StoryNode(
                id: node3_6,
                type: .exploration,
                title: "The Warden Outpost",
                dialogue: [
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Look — this is a Warden outpost! I've read about these!", emotion: "excited"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "The symbols on these walls... they're a map of the Boundary's weak points.", emotion: "scholarly"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You find old weapons, journals, and a faded banner bearing a familiar crest.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Your hand trembles as you touch the crest. You KNOW this symbol.", emotion: nil),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "According to these records, the first Herald was last seen near Starfall City.", emotion: "determined"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "But there are also reports of Herald activity in the Ash Wastes. What should we do?", emotion: "questioning")
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "warden_outpost",
                nextNodeId: node3_7
            ),

            // Node 7: Chapter choice
            StoryNode(
                id: node3_7,
                type: .choice,
                title: "The Path Forward",
                dialogue: [
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "The Academy in Starfall City may have answers about the Wardens — and about you.", emotion: "thoughtful"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Or we could track the Herald directly through the Ash Wastes.", emotion: "cautious"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Either way, we'll find the first Key Fragment.", emotion: "determined")
                ],
                battle: nil,
                choices: [
                    StoryChoice(
                        text: "Seek the Academy",
                        consequence: "Knowledge is power. The scholars may reveal your true identity.",
                        icon: "book.fill",
                        leadsToNodeId: nil,
                        leadsToChapterId: "chapter_4a"
                    ),
                    StoryChoice(
                        text: "Hunt the Heralds",
                        consequence: "Strike directly. Track the Herald through the dangerous Ash Wastes.",
                        icon: "flame.fill",
                        leadsToNodeId: nil,
                        leadsToChapterId: "chapter_4b"
                    )
                ],
                backgroundImage: "crossroads",
                nextNodeId: nil
            )
        ]
    }

    // MARK: - Chapter 4A: The Academy of Starlight (seek knowledge path)

    private static let node4a_1 = UUID()
    private static let node4a_2 = UUID()
    private static let node4a_3 = UUID()
    private static let node4a_4 = UUID()
    private static let node4a_5 = UUID()
    private static let node4a_6 = UUID()
    private static let node4a_7 = UUID()

    static var chapter4A: StoryChapter {
        StoryChapter(
            id: "chapter_4a",
            title: "The Academy of Starlight",
            description: "You journey to Starfall City and its legendary Academy, seeking knowledge about the Wardens, the Boundary, and your forgotten past.",
            unlockRequirements: UnlockRequirements(tasksRequired: 10, previousChapter: "chapter_3"),
            isUnlocked: false,
            isCompleted: false,
            nodes: chapter4ANodes,
            rewards: ChapterRewards(xp: 300, gold: 150, items: ["Key Fragment #1"]),
            backgroundImage: "starfall_city",
            nextChapterOptions: ["chapter_5"]
        )
    }

    private static var chapter4ANodes: [StoryNode] {
        [
            // Node 1: Starfall City exploration
            StoryNode(
                id: node4a_1,
                type: .exploration,
                title: "Starfall City",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "After days of travel, the spires of Starfall City rise before you.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The city gleams with crystalline towers that catch the sunlight.", emotion: nil),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "The Academy is at the center. But we should speak to the city guard first.", emotion: "cautious"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Even here, you notice signs of the spreading corruption — dark stains on walls, worried faces.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "starfall_city",
                nextNodeId: node4a_2
            ),

            // Node 2: Meet Captain Voss
            StoryNode(
                id: node4a_2,
                type: .dialogue,
                title: "Captain Voss",
                dialogue: [
                    DialogueLine(speaker: "Captain Voss", speakerAvatar: "captain_voss", text: "Halt. State your business in Starfall City.", emotion: "stern"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "I'm Lyra, a scholar. We seek audience with the Academy. We have information about the shadow threat.", emotion: "professional"),
                    DialogueLine(speaker: "Captain Voss", speakerAvatar: "captain_voss", text: "The shadows... yes. We've had our own encounters. Three attacks this week alone.", emotion: "grim"),
                    DialogueLine(speaker: "Captain Voss", speakerAvatar: "captain_voss", text: "If you can help, the Academy council will want to hear from you.", emotion: "hopeful"),
                    DialogueLine(speaker: "Captain Voss", speakerAvatar: "captain_voss", text: "But be warned — they are scholars, not warriors. They deal in knowledge, not swords.", emotion: "pragmatic")
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "city_gate",
                nextNodeId: node4a_3
            ),

            // Node 3: Academy recognition
            StoryNode(
                id: node4a_3,
                type: .dialogue,
                title: "The Academy",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The Academy's great hall is lined with ancient tomes and glowing artifacts.", emotion: nil),
                    DialogueLine(speaker: "Archivist Theron", speakerAvatar: "archivist_theron", text: "Fascinating. You say you saw the Watcher? Only those with Warden blood can perceive them.", emotion: "intrigued"),
                    DialogueLine(speaker: "Archivist Theron", speakerAvatar: "archivist_theron", text: "And this symbol you recognized... it is the Crest of the Last Ward.", emotion: "astonished"),
                    DialogueLine(speaker: "Archivist Theron", speakerAvatar: "archivist_theron", text: "We believed the Wardens extinct. If you carry their lineage...", emotion: "reverent"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Then the Boundary can be restored! We need to find the Key Fragments!", emotion: "excited"),
                    DialogueLine(speaker: "Archivist Theron", speakerAvatar: "archivist_theron", text: "Indeed. Our records indicate the first Herald — the Herald of Fear — lurks beneath the city.", emotion: "grave")
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "academy_interior",
                nextNodeId: node4a_4
            ),

            // Node 4: Research montage
            StoryNode(
                id: node4a_4,
                type: .exploration,
                title: "Research",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Days pass as you study the Warden archives with Lyra and Theron.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You learn to read the old Warden script. Your hands remember the motions before your mind does.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Memories surface — training drills, a mentor's face, the weight of an oath.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You were a Warden. Perhaps the last. And you were betrayed.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "academy_library",
                nextNodeId: node4a_5
            ),

            // Node 5: Watcher warning
            StoryNode(
                id: node4a_5,
                type: .dialogue,
                title: "The Warning",
                dialogue: [
                    DialogueLine(speaker: "The Watcher", speakerAvatar: "the_watcher", text: "Warden... the Herald of Fear knows you are here.", emotion: "urgent"),
                    DialogueLine(speaker: "The Watcher", speakerAvatar: "the_watcher", text: "It feeds on terror. Do not let it into your mind.", emotion: "warning"),
                    DialogueLine(speaker: "The Watcher", speakerAvatar: "the_watcher", text: "The catacombs beneath the Academy... it waits there. It has always been close.", emotion: "grim"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "A tremor shakes the Academy. Dust falls from the ceiling. Screams echo from below.", emotion: nil),
                    DialogueLine(speaker: "Captain Voss", speakerAvatar: "captain_voss", text: "Something's broken through the lower levels! We need you — NOW!", emotion: "panicked")
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "academy_shaking",
                nextNodeId: node4a_6
            ),

            // Node 6: Herald of Fear boss battle
            StoryNode(
                id: node4a_6,
                type: .battle,
                title: "Herald of Fear",
                dialogue: nil,
                battle: BattleEncounter(
                    enemyName: "Herald of Fear",
                    enemyAvatar: "herald_of_fear",
                    enemyDescription: "A towering entity of shadow and nightmare. It wears the faces of your deepest fears.",
                    enemyLevel: 8,
                    enemyHP: 150,
                    enemyMaxHP: 150,
                    enemyAttack: 22,
                    enemyDefense: 12,
                    isBoss: true,
                    abilities: [
                        EnemyAbility(name: "Nightmare Vision", damage: 25, description: "Assaults your mind with terrifying visions", chance: 0.3,
                                     statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Nightmare Vision")),
                        EnemyAbility(name: "Creeping Dread", damage: 15, description: "Weakens your will to fight", chance: 0.35,
                                     statusEffect: StatusEffect(type: .weaken, duration: 2, value: 3, sourceDescription: "Creeping Dread")),
                        EnemyAbility(name: "Phantom Strike", damage: 20, description: "Strikes from impossible angles", chance: 0.35)
                    ],
                    rewards: BattleRewards(xp: 200, gold: 100),
                    backgroundImage: "catacombs",
                    preBattleText: "The Herald of Fear rises from the shadows, a mass of writhing darkness. Its voice echoes in your skull: 'I know what you fear, little Warden...'",
                    victoryText: "The Herald screams as it dissolves. A glowing fragment falls from its core — the first Key Fragment! Lyra rushes to your side."
                ),
                choices: nil,
                backgroundImage: "catacombs",
                nextNodeId: node4a_7
            ),

            // Node 7: Key Fragment obtained, Lyra joins
            StoryNode(
                id: node4a_7,
                type: .checkpoint,
                title: "Key Fragment Recovered",
                dialogue: [
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "You did it! The first Key Fragment!", emotion: "overjoyed"),
                    DialogueLine(speaker: "Archivist Theron", speakerAvatar: "archivist_theron", text: "Two more Heralds remain. The Boundary can yet be saved.", emotion: "hopeful"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "I'm coming with you. You'll need a scholar's knowledge for what lies ahead.", emotion: "determined"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The Key Fragment pulses with a warm light. Two more pieces remain.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The road ahead is long, but you are no longer alone.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "academy_dawn",
                nextNodeId: nil
            )
        ]
    }

    // MARK: - Chapter 4B: The Herald's Trail (hunt directly path)

    private static let node4b_1 = UUID()
    private static let node4b_2 = UUID()
    private static let node4b_3 = UUID()
    private static let node4b_4 = UUID()
    private static let node4b_5 = UUID()
    private static let node4b_6 = UUID()

    static var chapter4B: StoryChapter {
        StoryChapter(
            id: "chapter_4b",
            title: "The Herald's Trail",
            description: "You choose to hunt the Herald directly, tracking it through the desolate Ash Wastes. The direct path is dangerous, but you won't give the enemy time to prepare.",
            unlockRequirements: UnlockRequirements(tasksRequired: 10, previousChapter: "chapter_3"),
            isUnlocked: false,
            isCompleted: false,
            nodes: chapter4BNodes,
            rewards: ChapterRewards(xp: 300, gold: 150, items: ["Key Fragment #1"]),
            backgroundImage: "ash_wastes",
            nextChapterOptions: ["chapter_5"]
        )
    }

    private static var chapter4BNodes: [StoryNode] {
        [
            // Node 1: Companion concern
            StoryNode(
                id: node4b_1,
                type: .dialogue,
                title: "Into the Wastes",
                dialogue: [
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Are you sure about this? The Ash Wastes are... not kind to travelers.", emotion: "worried"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "But I see that look in your eyes. You've made up your mind.", emotion: "resigned"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "I'll track signs of the Herald's corruption. You handle anything that tries to kill us.", emotion: "pragmatic"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You set out toward the Ash Wastes, following the trail of corruption.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "road_to_wastes",
                nextNodeId: node4b_2
            ),

            // Node 2: Ash Wastes exploration
            StoryNode(
                id: node4b_2,
                type: .exploration,
                title: "The Ash Wastes",
                dialogue: [
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "A landscape of gray and ruin stretches to every horizon.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The ground crunches underfoot — ash, bone, and blackened earth.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "Nothing grows here. The corruption has drained the land of all life.", emotion: nil),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Look at these tracks — something large came through here recently.", emotion: "alert"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "In the distance, smoke rises from what was once a village.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "ash_wastes",
                nextNodeId: node4b_3
            ),

            // Node 3: Displaced villagers
            StoryNode(
                id: node4b_3,
                type: .dialogue,
                title: "Survivors",
                dialogue: [
                    DialogueLine(speaker: "Displaced Villager", speakerAvatar: "villager", text: "Please... stay away from Ironhold. The shadow creatures have overrun it.", emotion: "terrified"),
                    DialogueLine(speaker: "Displaced Villager", speakerAvatar: "villager", text: "There's something in the old fortress... something that commands them.", emotion: "haunted"),
                    DialogueLine(speaker: "Displaced Villager", speakerAvatar: "villager", text: "It speaks inside your head. Shows you things. Terrible things.", emotion: "trembling"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "The Herald of Fear. It uses terror as a weapon.", emotion: "grim"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Steel your mind. We're getting close.", emotion: "determined")
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "refugee_camp",
                nextNodeId: node4b_4
            ),

            // Node 4: Shadow Sentinels battle
            StoryNode(
                id: node4b_4,
                type: .battle,
                title: "Shadow Sentinels",
                dialogue: nil,
                battle: BattleEncounter(
                    enemyName: "Shadow Sentinel",
                    enemyAvatar: "shadow_sentinel",
                    enemyDescription: "A heavily armored shadow creature guarding the approach to the Herald's fortress.",
                    enemyLevel: 7,
                    enemyHP: 100,
                    enemyMaxHP: 100,
                    enemyAttack: 20,
                    enemyDefense: 14,
                    abilities: [
                        EnemyAbility(name: "Dark Shield Bash", damage: 22, description: "Slams with a shield of condensed shadow", chance: 0.35),
                        EnemyAbility(name: "Intimidating Presence", damage: 10, description: "Its aura saps your strength", chance: 0.3,
                                     statusEffect: StatusEffect(type: .weaken, duration: 2, value: 4, sourceDescription: "Intimidating Presence")),
                        EnemyAbility(name: "Shadow Impale", damage: 18, description: "Thrusts a spear of darkness", chance: 0.35)
                    ],
                    rewards: BattleRewards(xp: 120, gold: 60),
                    backgroundImage: "fortress_approach",
                    preBattleText: "Two massive shadow sentinels block the fortress gate. Their hollow eyes burn with malice.",
                    victoryText: "The sentinels crumble to ash. The fortress gates stand open before you."
                ),
                choices: nil,
                backgroundImage: "fortress_approach",
                nextNodeId: node4b_5
            ),

            // Node 5: Herald of Fear boss battle (same boss, different context)
            StoryNode(
                id: node4b_5,
                type: .battle,
                title: "Herald of Fear",
                dialogue: nil,
                battle: BattleEncounter(
                    enemyName: "Herald of Fear",
                    enemyAvatar: "herald_of_fear",
                    enemyDescription: "A towering entity of shadow and nightmare. It wears the faces of your deepest fears.",
                    enemyLevel: 8,
                    enemyHP: 150,
                    enemyMaxHP: 150,
                    enemyAttack: 22,
                    enemyDefense: 12,
                    isBoss: true,
                    abilities: [
                        EnemyAbility(name: "Nightmare Vision", damage: 25, description: "Assaults your mind with terrifying visions", chance: 0.3,
                                     statusEffect: StatusEffect(type: .stun, duration: 1, value: 0, sourceDescription: "Nightmare Vision")),
                        EnemyAbility(name: "Creeping Dread", damage: 15, description: "Weakens your will to fight", chance: 0.35,
                                     statusEffect: StatusEffect(type: .weaken, duration: 2, value: 3, sourceDescription: "Creeping Dread")),
                        EnemyAbility(name: "Phantom Strike", damage: 20, description: "Strikes from impossible angles", chance: 0.35)
                    ],
                    rewards: BattleRewards(xp: 200, gold: 100),
                    backgroundImage: "fortress_throne",
                    preBattleText: "In the heart of the fortress, the Herald of Fear sits upon a throne of solidified nightmares. 'You came to ME? Bold... and foolish.'",
                    victoryText: "The Herald shrieks as your blade finds its core. The fortress trembles as its master falls. A glowing fragment rolls across the stone floor."
                ),
                choices: nil,
                backgroundImage: "fortress_throne",
                nextNodeId: node4b_6
            ),

            // Node 6: Key Fragment obtained, converges with 4A
            StoryNode(
                id: node4b_6,
                type: .checkpoint,
                title: "Key Fragment Recovered",
                dialogue: [
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "The Key Fragment! You actually did it!", emotion: "amazed"),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "The direct approach worked. I have to admit, I'm impressed.", emotion: "admiring"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "As you hold the fragment, memories flood back — faces of fellow Wardens, a sacred oath.", emotion: nil),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "You were a Warden. And you were betrayed. But by whom?", emotion: nil),
                    DialogueLine(speaker: "Lyra", speakerAvatar: "lyra_scholar", text: "Two more Heralds remain. We should seek allies for the battles ahead.", emotion: "thoughtful"),
                    DialogueLine(speaker: "Narrator", speakerAvatar: nil, text: "The Key Fragment pulses with a warm light. Two more pieces remain.", emotion: nil)
                ],
                battle: nil,
                choices: nil,
                backgroundImage: "fortress_dawn",
                nextNodeId: nil
            )
        ]
    }
}
