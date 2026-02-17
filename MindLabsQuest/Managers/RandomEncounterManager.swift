import Foundation

class RandomEncounterManager: ObservableObject {
    @Published var currentEncounter: BattleEncounter?

    init() {}

    // MARK: - Generate Random Encounter

    func generateEncounter(playerLevel: Int) -> BattleEncounter? {
        let baseTier = EnemyDatabase.tierForLevel(playerLevel)

        // 70% same tier, 20% lower tier, 10% higher tier
        let roll = Double.random(in: 0...1)
        let selectedTier: Int
        if roll < 0.7 {
            selectedTier = baseTier
        } else if roll < 0.9 {
            selectedTier = max(1, baseTier - 1)
        } else {
            selectedTier = min(5, baseTier + 1)
        }

        // Get non-boss enemies from the selected tier
        let candidates = EnemyDatabase.enemies(forTier: selectedTier).filter { !$0.isBoss }
        guard let template = candidates.randomElement() else { return nil }

        // Scale to player level
        let encounter = template.encounter(atLevel: playerLevel)
        currentEncounter = encounter
        return encounter
    }

    // MARK: - Generate Boss Encounter

    func generateBossEncounter(playerLevel: Int) -> BattleEncounter? {
        guard playerLevel >= 15 else { return nil }

        let bosses = EnemyDatabase.bosses()
        guard let template = bosses.randomElement() else { return nil }

        let encounter = template.encounter(atLevel: playerLevel)
        currentEncounter = encounter
        return encounter
    }

    // MARK: - Clear

    func clearEncounter() {
        currentEncounter = nil
    }
}
