import Foundation

// MARK: - Prestige Data
struct PrestigeData: Codable, Equatable {
    var prestigeLevel: Int = 0
    var totalPrestigeXP: Int = 0
    var prestigeHistory: [PrestigeRecord] = []
    var activePerkIds: Set<String> = []
}

// MARK: - Prestige Record
struct PrestigeRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var levelAtPrestige: Int
    var perkChosen: String
}

// MARK: - Prestige Perk
struct PrestigePerk: Identifiable {
    var id: String
    var name: String
    var description: String
    var icon: String
    var tier: Int

    static let allPerks: [PrestigePerk] = [
        PrestigePerk(id: "veterans_wisdom", name: "Veteran's Wisdom", description: "+10% XP from all sources", icon: "brain.head.profile", tier: 1),
        PrestigePerk(id: "fortunes_favor", name: "Fortune's Favor", description: "+15% gold from all sources", icon: "bitcoinsign.circle.fill", tier: 1),
        PrestigePerk(id: "battle_hardened", name: "Battle Hardened", description: "+5% crit chance in combat", icon: "bolt.shield.fill", tier: 1),
        PrestigePerk(id: "quick_learner", name: "Quick Learner", description: "-10% XP required per level", icon: "hare.fill", tier: 1),
        PrestigePerk(id: "energy_reserve", name: "Energy Reserve", description: "+1 max energy permanently", icon: "bolt.fill", tier: 1)
    ]

    static func perk(for id: String) -> PrestigePerk? {
        allPerks.first(where: { $0.id == id })
    }
}

// MARK: - Prestige Rewards (computed from prestige level)
struct PrestigeRewards {
    var starterGold: Int
    var bonusXPPercent: Int
    var bonusGoldPercent: Int
    var extraSkillPoints: Int

    static func rewards(for prestigeLevel: Int) -> PrestigeRewards {
        PrestigeRewards(
            starterGold: 100 * (prestigeLevel + 1),
            bonusXPPercent: 5 * prestigeLevel,
            bonusGoldPercent: 5 * prestigeLevel,
            extraSkillPoints: 2 * prestigeLevel
        )
    }
}
