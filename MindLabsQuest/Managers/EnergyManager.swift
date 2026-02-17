import Foundation

class EnergyManager: ObservableObject {
    @Published var currentEnergy: Int = 5
    @Published var maxEnergy: Int = 5
    @Published var lastRegenTime: Date = Date()

    private let regenIntervalSeconds: TimeInterval = 3600 // 1 hour

    init() {}

    // MARK: - Sync with Character

    func syncFromCharacter(_ character: Character) {
        currentEnergy = character.energy
        maxEnergy = character.maxEnergy
        lastRegenTime = character.lastEnergyRegenTime
        recalculateEnergy()
    }

    func syncToCharacter(_ character: inout Character) {
        recalculateEnergy()
        character.energy = currentEnergy
        character.maxEnergy = maxEnergy
        character.lastEnergyRegenTime = lastRegenTime
    }

    // MARK: - Energy Regen (timestamp-based)

    func recalculateEnergy() {
        guard currentEnergy < maxEnergy else {
            lastRegenTime = Date()
            return
        }

        let now = Date()
        let elapsed = now.timeIntervalSince(lastRegenTime)
        let unitsToRegen = Int(elapsed / regenIntervalSeconds)

        if unitsToRegen > 0 {
            let newEnergy = min(maxEnergy, currentEnergy + unitsToRegen)
            currentEnergy = newEnergy
            // Advance lastRegenTime by the number of full intervals used
            lastRegenTime = lastRegenTime.addingTimeInterval(Double(unitsToRegen) * regenIntervalSeconds)

            if currentEnergy >= maxEnergy {
                lastRegenTime = now
            }
        }
    }

    // MARK: - Energy Actions

    var canStartBattle: Bool {
        recalculateEnergy()
        return currentEnergy >= 1
    }

    @discardableResult
    func spendEnergy(_ amount: Int = 1) -> Bool {
        recalculateEnergy()
        guard currentEnergy >= amount else { return false }
        currentEnergy -= amount
        if currentEnergy < maxEnergy {
            // Only reset regen timer if we weren't already regenerating
            let now = Date()
            let elapsed = now.timeIntervalSince(lastRegenTime)
            if elapsed >= regenIntervalSeconds {
                lastRegenTime = now
            }
        }
        return true
    }

    func earnEnergyFromQuest(_ amount: Int = 1) {
        currentEnergy = min(maxEnergy, currentEnergy + amount)
        if currentEnergy >= maxEnergy {
            lastRegenTime = Date()
        }
    }

    // MARK: - Display Helpers

    var timeUntilNextEnergy: TimeInterval? {
        guard currentEnergy < maxEnergy else { return nil }
        recalculateEnergy()
        let elapsed = Date().timeIntervalSince(lastRegenTime)
        let remaining = regenIntervalSeconds - elapsed
        return max(0, remaining)
    }

    var formattedTimeUntilNext: String? {
        guard let remaining = timeUntilNextEnergy else { return nil }
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
