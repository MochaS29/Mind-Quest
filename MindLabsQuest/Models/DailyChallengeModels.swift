import Foundation

// MARK: - Daily Challenge Type
enum DailyChallengeType: String, Codable, CaseIterable {
    case killEnemies = "Kill Enemies"
    case dealDamage = "Deal Damage"
    case winBattles = "Win Battles"
    case useItems = "Use Items"
    case earnGold = "Earn Gold"
    case completeQuests = "Complete Quests"

    var icon: String {
        switch self {
        case .killEnemies: return "target"
        case .dealDamage: return "bolt.fill"
        case .winBattles: return "trophy.fill"
        case .useItems: return "bag.fill"
        case .earnGold: return "dollarsign.circle.fill"
        case .completeQuests: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Challenge Rewards
struct ChallengeRewards: Codable {
    var xp: Int
    var gold: Int
}

// MARK: - Daily Challenge
struct DailyChallenge: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var type: DailyChallengeType
    var target: Int
    var progress: Int = 0
    var isCompleted: Bool { progress >= target }
    var isClaimed: Bool = false
    var rewards: ChallengeRewards
    var dateAssigned: Date
}

// MARK: - Daily Challenge Template
struct DailyChallengeTemplate {
    var id: String
    var titleFormat: String
    var descriptionFormat: String
    var icon: String
    var type: DailyChallengeType
    var baseTarget: Int
    var levelScaling: Double  // target = baseTarget + Int(playerLevel * levelScaling)
    var baseXP: Int
    var baseGold: Int

    func challenge(forLevel level: Int, date: Date) -> DailyChallenge {
        let scaledTarget = baseTarget + Int(Double(level) * levelScaling)
        let scaledXP = baseXP + level * 5
        let scaledGold = baseGold + level * 3
        return DailyChallenge(
            id: "\(id)_\(Int(date.timeIntervalSince1970))",
            title: titleFormat,
            description: String(format: descriptionFormat, scaledTarget),
            icon: icon,
            type: type,
            target: scaledTarget,
            rewards: ChallengeRewards(xp: scaledXP, gold: scaledGold),
            dateAssigned: date
        )
    }

    static let allTemplates: [DailyChallengeTemplate] = [
        DailyChallengeTemplate(id: "kill_enemies", titleFormat: "Monster Hunter", descriptionFormat: "Defeat %d enemies in battle", icon: "target", type: .killEnemies, baseTarget: 2, levelScaling: 0.5, baseXP: 30, baseGold: 15),
        DailyChallengeTemplate(id: "deal_damage", titleFormat: "Damage Dealer", descriptionFormat: "Deal %d total damage", icon: "bolt.fill", type: .dealDamage, baseTarget: 50, levelScaling: 10.0, baseXP: 25, baseGold: 12),
        DailyChallengeTemplate(id: "win_battles", titleFormat: "Battle Champion", descriptionFormat: "Win %d battles", icon: "trophy.fill", type: .winBattles, baseTarget: 1, levelScaling: 0.3, baseXP: 40, baseGold: 20),
        DailyChallengeTemplate(id: "use_items", titleFormat: "Item Master", descriptionFormat: "Use %d items in battle", icon: "bag.fill", type: .useItems, baseTarget: 1, levelScaling: 0.2, baseXP: 20, baseGold: 10),
        DailyChallengeTemplate(id: "earn_gold", titleFormat: "Gold Rush", descriptionFormat: "Earn %d gold", icon: "dollarsign.circle.fill", type: .earnGold, baseTarget: 30, levelScaling: 8.0, baseXP: 25, baseGold: 15),
        DailyChallengeTemplate(id: "complete_quests", titleFormat: "Quest Master", descriptionFormat: "Complete %d quests", icon: "checkmark.seal.fill", type: .completeQuests, baseTarget: 1, levelScaling: 0.2, baseXP: 35, baseGold: 18),
    ]
}
