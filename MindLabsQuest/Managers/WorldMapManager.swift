import Foundation
import SwiftUI
import Combine

class WorldMapManager: ObservableObject {
    @Published var progress: WorldMapProgress = WorldMapProgress()
    @Published var currentRegionId: String = "millbrook_village"

    private let progressKey = "worldMapProgress"

    // MARK: - Region Access

    func canAccessRegion(_ regionId: String, playerLevel: Int, storyProgress: StoryProgress? = nil) -> Bool {
        guard let region = RegionDatabase.region(byId: regionId) else { return false }

        // Must be unlocked
        guard progress.unlockedRegionIds.contains(regionId) else { return false }

        // Must meet minimum level
        guard playerLevel >= region.unlockRequirements.minimumLevel else { return false }

        // Check story requirements if applicable
        if let story = storyProgress, !region.unlockRequirements.requiredChapterIds.isEmpty {
            let met = region.unlockRequirements.requiredChapterIds.allSatisfy {
                story.completedChapters.contains($0)
            }
            if !met { return false }
        }

        return true
    }

    func canUnlockRegion(_ regionId: String, playerLevel: Int) -> Bool {
        guard let region = RegionDatabase.region(byId: regionId) else { return false }
        guard !progress.unlockedRegionIds.contains(regionId) else { return false }
        guard playerLevel >= region.unlockRequirements.minimumLevel else { return false }

        // Check all required regions are unlocked
        let requiredMet = region.unlockRequirements.requiredRegionIds.allSatisfy {
            progress.unlockedRegionIds.contains($0)
        }

        return requiredMet
    }

    // MARK: - Discovery & Unlock

    func discoverRegion(_ regionId: String) {
        guard !progress.discoveredRegionIds.contains(regionId) else { return }
        progress.discoveredRegionIds.insert(regionId)
        progress.totalRegionsDiscovered += 1
    }

    func unlockRegion(_ regionId: String) {
        progress.unlockedRegionIds.insert(regionId)
        discoverRegion(regionId)

        // Also discover connected regions
        if let region = RegionDatabase.region(byId: regionId) {
            for connectedId in region.connectedRegionIds {
                discoverRegion(connectedId)
            }
        }
    }

    // MARK: - Auto-unlock regions based on level

    func checkAutoUnlocks(playerLevel: Int) {
        for region in RegionDatabase.allRegions {
            if canUnlockRegion(region.id, playerLevel: playerLevel) {
                unlockRegion(region.id)
            }
        }
    }

    // MARK: - Daily Energy

    func grantDailyAccess(regionId: String, energy: Int) {
        let current = progress.dailyRegionEnergy[regionId] ?? 0
        progress.dailyRegionEnergy[regionId] = current + energy
    }

    func hasDailyAccess(regionId: String) -> Bool {
        (progress.dailyRegionEnergy[regionId] ?? 0) > 0
    }

    func spendRegionEnergy(_ regionId: String, amount: Int = 1) -> Bool {
        let current = progress.dailyRegionEnergy[regionId] ?? 0
        guard current >= amount else { return false }
        progress.dailyRegionEnergy[regionId] = current - amount
        return true
    }

    func energyForRegion(_ regionId: String) -> Int {
        progress.dailyRegionEnergy[regionId] ?? 0
    }

    func resetDailyEnergyIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastReset = progress.lastDailyResetDate {
            if !Calendar.current.isDate(lastReset, inSameDayAs: today) {
                progress.dailyRegionEnergy = [:]
                progress.lastDailyResetDate = today
            }
        } else {
            progress.lastDailyResetDate = today
        }
    }

    // MARK: - Navigation Helpers

    func connectedRegions(from regionId: String) -> [MapRegion] {
        RegionDatabase.connectedRegions(from: regionId)
    }

    func availableEnemies(in regionId: String, playerLevel: Int) -> [EnemyTemplate] {
        RegionDatabase.enemies(forRegion: regionId, playerLevel: playerLevel)
    }

    func availableDungeons(in regionId: String) -> [String] {
        RegionDatabase.region(byId: regionId)?.dungeonIds ?? []
    }

    // MARK: - Persistence

    func saveData() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(WorldMapProgress.self, from: data) {
            progress = decoded
        }
    }

    func resetAll() {
        progress = WorldMapProgress()
        UserDefaults.standard.removeObject(forKey: progressKey)
    }
}
