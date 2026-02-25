import Foundation

struct MapMissionDatabase {

    // MARK: - Parent Task Templates

    static let taskTemplates: [ParentTask] = [
        // Life Skills → Whispering Woods
        ParentTask(title: "Clean Room", category: .lifeSkills, energyReward: 1, bonusXP: 15, bonusGold: 5,
                   epicTitle: "Restore Order to Your Sanctuary", mapRegionId: "whispering_woods"),
        ParentTask(title: "Do the Dishes", category: .lifeSkills, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Cleanse the Enchanted Vessels", mapRegionId: "whispering_woods"),
        ParentTask(title: "Take Out Trash", category: .lifeSkills, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Banish the Refuse to the Outer Lands", mapRegionId: "whispering_woods"),
        ParentTask(title: "Do Laundry", category: .lifeSkills, energyReward: 1, bonusXP: 15, bonusGold: 5,
                   epicTitle: "Purify the Garments of Power", mapRegionId: "whispering_woods"),
        ParentTask(title: "Organize Backpack", category: .lifeSkills, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Ready the Explorer's Arsenal", mapRegionId: "whispering_woods"),

        // Academic → Academy of Starlight
        ParentTask(title: "Complete Homework (30 min)", category: .academic, energyReward: 2, bonusXP: 25, bonusGold: 8,
                   epicTitle: "Conquer the Academic Trials", mapRegionId: "academy_starlight"),
        ParentTask(title: "Study for Test (30 min)", category: .academic, energyReward: 2, bonusXP: 30, bonusGold: 10,
                   epicTitle: "Forge Knowledge in the Crucible of Study", mapRegionId: "academy_starlight"),
        ParentTask(title: "Read for 20 Minutes", category: .academic, energyReward: 1, bonusXP: 15, bonusGold: 5,
                   epicTitle: "Journey Through Literary Realms", mapRegionId: "academy_starlight"),
        ParentTask(title: "Practice Math Problems", category: .academic, energyReward: 1, bonusXP: 20, bonusGold: 7,
                   epicTitle: "Decipher the Arcane Equations", mapRegionId: "academy_starlight"),

        // Health → Crystal Springs
        ParentTask(title: "Shower / Bathe", category: .health, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Cleanse at the Crystal Springs", mapRegionId: "crystal_springs"),
        ParentTask(title: "Brush Teeth (Morning & Night)", category: .health, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Defend the Ivory Gates", mapRegionId: "crystal_springs"),
        ParentTask(title: "Drink 8 Glasses of Water", category: .health, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Channel the Living Waters", mapRegionId: "crystal_springs"),
        ParentTask(title: "Get 8+ Hours of Sleep", category: .health, energyReward: 1, bonusXP: 15, bonusGold: 5,
                   epicTitle: "Rest in the Healing Springs", mapRegionId: "crystal_springs"),

        // Fitness → Training Grounds
        ParentTask(title: "30 Minutes Exercise", category: .fitness, energyReward: 2, bonusXP: 25, bonusGold: 8,
                   epicTitle: "Train at the Proving Grounds", mapRegionId: "training_grounds"),
        ParentTask(title: "Walk the Dog", category: .fitness, energyReward: 1, bonusXP: 15, bonusGold: 5,
                   epicTitle: "Patrol with Your Faithful Companion", mapRegionId: "training_grounds"),
        ParentTask(title: "Stretch for 10 Minutes", category: .fitness, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Master the Art of Flexibility", mapRegionId: "training_grounds"),
        ParentTask(title: "Play a Sport", category: .fitness, energyReward: 2, bonusXP: 25, bonusGold: 8,
                   epicTitle: "Compete in the Grand Tournament", mapRegionId: "training_grounds"),

        // Social → Starfall City
        ParentTask(title: "Help a Family Member", category: .social, energyReward: 1, bonusXP: 15, bonusGold: 5,
                   epicTitle: "Aid the Citizens of Starfall", mapRegionId: "starfall_city"),
        ParentTask(title: "Call a Friend or Relative", category: .social, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Forge New Alliances Across the Realm", mapRegionId: "starfall_city"),
        ParentTask(title: "Write a Thank-You Note", category: .social, energyReward: 1, bonusXP: 10, bonusGold: 3,
                   epicTitle: "Send a Scroll of Gratitude", mapRegionId: "starfall_city"),

        // Creative → Starfall City
        ParentTask(title: "Creative Time (30 min)", category: .creative, energyReward: 1, bonusXP: 20, bonusGold: 7,
                   epicTitle: "Channel Your Creative Energy in the City", mapRegionId: "starfall_city"),
        ParentTask(title: "Practice Instrument (20 min)", category: .creative, energyReward: 1, bonusXP: 15, bonusGold: 5,
                   epicTitle: "Perform at the Starfall Amphitheater", mapRegionId: "starfall_city"),
        ParentTask(title: "Journal / Write", category: .creative, energyReward: 1, bonusXP: 15, bonusGold: 5,
                   epicTitle: "Chronicle Tales in the City Archives", mapRegionId: "starfall_city"),
    ]

    // MARK: - Templates by Category

    static func templates(for category: TaskCategory) -> [ParentTask] {
        taskTemplates.filter { $0.category == category }
    }

    static var templatesByCategory: [TaskCategory: [ParentTask]] {
        Dictionary(grouping: taskTemplates, by: { $0.category })
    }
}
