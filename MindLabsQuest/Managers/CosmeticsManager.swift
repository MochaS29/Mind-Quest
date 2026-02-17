import Foundation
import SwiftUI

class CosmeticsManager: ObservableObject {
    @Published var unlockedCosmeticIds: Set<String> = []
    @Published var loadout: CosmeticLoadout = CosmeticLoadout()
    @Published var showCosmeticUnlocked = false
    @Published var lastUnlockedCosmetic: CosmeticItem?

    private let unlockedKey = "unlockedCosmetics"
    private let loadoutKey = "cosmeticLoadout"

    init() {
        loadData()
    }

    // MARK: - Check Unlocks
    func checkUnlocks(
        character: Character,
        arenaRank: ArenaRank,
        totalBattlesWon: Int,
        totalDungeonClears: Int
    ) {
        for cosmetic in CosmeticDatabase.allCosmetics {
            guard !unlockedCosmeticIds.contains(cosmetic.id) else { continue }

            if isRequirementMet(cosmetic.unlockRequirement,
                                character: character,
                                arenaRank: arenaRank,
                                totalBattlesWon: totalBattlesWon,
                                totalDungeonClears: totalDungeonClears) {
                unlock(cosmetic)
            }
        }
    }

    private func isRequirementMet(
        _ requirement: CosmeticUnlockRequirement,
        character: Character,
        arenaRank: ArenaRank,
        totalBattlesWon: Int,
        totalDungeonClears: Int
    ) -> Bool {
        switch requirement {
        case .level(let lvl):
            return character.level >= lvl
        case .achievement(let achievementId):
            // Checked externally if needed
            return false && !achievementId.isEmpty
        case .prestigeLevel(let lvl):
            return character.prestigeData.prestigeLevel >= lvl
        case .arenaRank(let requiredRank):
            return arenaRank.ratingRange.lowerBound >= requiredRank.ratingRange.lowerBound
        case .questsCompleted(let count):
            return character.totalQuestsCompleted >= count
        case .dungeonClears(let count):
            return totalDungeonClears >= count
        case .battleWins(let count):
            return totalBattlesWon >= count
        case .gold(let amount):
            return character.gold >= amount
        case .seasonal:
            return false // handled by SeasonalEventManager
        case .characterClass(let cc):
            return character.characterClass == cc
        case .classAndLevel(let cc, let lvl):
            return character.characterClass == cc && character.level >= lvl
        }
    }

    private func unlock(_ cosmetic: CosmeticItem) {
        unlockedCosmeticIds.insert(cosmetic.id)
        lastUnlockedCosmetic = cosmetic
        showCosmeticUnlocked = true
        HapticService.notification(.success)
        saveData()
    }

    // MARK: - Equip/Unequip
    func equip(_ cosmeticId: String) {
        guard unlockedCosmeticIds.contains(cosmeticId),
              let cosmetic = CosmeticDatabase.cosmetic(for: cosmeticId) else { return }

        switch cosmetic.type {
        case .title:
            loadout.equippedTitle = cosmeticId
        case .border:
            loadout.equippedBorder = cosmeticId
        case .battleEffect:
            loadout.equippedBattleEffect = cosmeticId
        }

        HapticService.selection()
        saveData()
    }

    func unequip(type: CosmeticType) {
        switch type {
        case .title:
            loadout.equippedTitle = nil
        case .border:
            loadout.equippedBorder = nil
        case .battleEffect:
            loadout.equippedBattleEffect = nil
        }

        saveData()
    }

    // MARK: - Accessors
    var equippedTitle: CosmeticItem? {
        guard let id = loadout.equippedTitle else { return nil }
        return CosmeticDatabase.cosmetic(for: id)
    }

    var equippedBorder: CosmeticItem? {
        guard let id = loadout.equippedBorder else { return nil }
        return CosmeticDatabase.cosmetic(for: id)
    }

    var equippedBattleEffect: CosmeticItem? {
        guard let id = loadout.equippedBattleEffect else { return nil }
        return CosmeticDatabase.cosmetic(for: id)
    }

    var unlockedCount: Int { unlockedCosmeticIds.count }
    var totalCount: Int { CosmeticDatabase.allCosmetics.count }

    // MARK: - Persistence
    func saveData() {
        if let encoded = try? JSONEncoder().encode(Array(unlockedCosmeticIds)) {
            UserDefaults.standard.set(encoded, forKey: unlockedKey)
        }
        if let encoded = try? JSONEncoder().encode(loadout) {
            UserDefaults.standard.set(encoded, forKey: loadoutKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: unlockedKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            unlockedCosmeticIds = Set(decoded)
        }
        if let data = UserDefaults.standard.data(forKey: loadoutKey),
           let decoded = try? JSONDecoder().decode(CosmeticLoadout.self, from: data) {
            loadout = decoded
        }
    }

    func resetAll() {
        unlockedCosmeticIds = []
        loadout = CosmeticLoadout()
        showCosmeticUnlocked = false
        lastUnlockedCosmetic = nil
        UserDefaults.standard.removeObject(forKey: unlockedKey)
        UserDefaults.standard.removeObject(forKey: loadoutKey)
    }
}
