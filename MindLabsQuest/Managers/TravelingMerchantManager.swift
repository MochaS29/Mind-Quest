import Foundation
import SwiftUI

class TravelingMerchantManager: ObservableObject {
    @Published var state: TravelingMerchantState = TravelingMerchantState()

    private let persistenceKey = "travelingMerchantState"

    private static let merchantNames = [
        "Zara the Wanderer",
        "Old Hemlock",
        "Sylphi the Trader",
        "Grizzled Gideon",
        "Mira Moonveil"
    ]

    private static let greetings = [
        "Ah, a fellow adventurer! Come see my wares...",
        "Rare goods, fair prices! Well, mostly fair...",
        "I've traveled far to bring you these treasures!",
        "You look like someone with discerning taste!",
        "Everything must go before I move on!"
    ]

    init() {
        loadData()
    }

    // MARK: - Weekly Refresh
    func refreshIfNeeded(playerLevel: Int) {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        let currentYear = calendar.component(.yearForWeekOfYear, from: Date())
        let lastWeek = calendar.component(.weekOfYear, from: state.lastRefreshDate)
        let lastYear = calendar.component(.yearForWeekOfYear, from: state.lastRefreshDate)

        guard currentWeek != lastWeek || currentYear != lastYear else { return }

        // Seed from ISO week for deterministic rotation
        let weekHash = UInt64(currentYear * 52 + currentWeek)
        var rng = SeedableRNG(seed: weekHash &+ 31337)

        // Pick merchant name and greeting
        let nameIndex = Int(rng.next() % UInt64(Self.merchantNames.count))
        let greetingIndex = Int(rng.next() % UInt64(Self.greetings.count))

        // Generate 3-5 rare/epic items with markup
        let itemCount = 3 + Int(rng.next() % 3)
        let eligibleItems = ItemDatabase.allShopItems.filter {
            $0.levelRequirement <= playerLevel + 2 &&
            ($0.rarity == .rare || $0.rarity == .epic) &&
            $0.type != .consumable && $0.type != .material
        }

        var shuffledItems = eligibleItems
        // Fisher-Yates shuffle with seeded RNG
        for i in stride(from: shuffledItems.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffledItems.swapAt(i, j)
        }

        var inventory: [MerchantItem] = []
        for item in shuffledItems.prefix(itemCount) {
            let markup = 1.2 + Double(rng.next() % 31) / 100.0 // 120-150% of buy price
            let price = max(item.buyPrice, Int(Double(item.buyPrice) * markup))
            inventory.append(MerchantItem(item: item, goldPrice: price, stock: 1))
        }

        // Always include some consumables
        let consumableMarkup = 1.3
        inventory.append(MerchantItem(
            item: ItemDatabase.greaterHealthPotion,
            goldPrice: Int(Double(ItemDatabase.greaterHealthPotion.buyPrice) * consumableMarkup),
            stock: 3
        ))

        // Generate 2-3 barter trades
        let tradeCount = 2 + Int(rng.next() % 2)
        let barterTemplates = Self.allBarterTemplates(playerLevel: playerLevel)
        var shuffledTrades = barterTemplates
        for i in stride(from: shuffledTrades.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffledTrades.swapAt(i, j)
        }

        let barterTrades = Array(shuffledTrades.prefix(tradeCount))

        state = TravelingMerchantState(
            inventory: inventory,
            barterTrades: barterTrades,
            lastRefreshDate: Date(),
            merchantName: Self.merchantNames[nameIndex],
            greeting: Self.greetings[greetingIndex]
        )

        saveData()
    }

    // MARK: - Buy Item
    func buyItem(merchantItemId: UUID, character: inout Character) -> Bool {
        guard let index = state.inventory.firstIndex(where: { $0.id == merchantItemId }) else { return false }
        let merchantItem = state.inventory[index]

        guard character.gold >= merchantItem.goldPrice else { return false }
        guard merchantItem.stock > 0 else { return false }

        character.gold -= merchantItem.goldPrice
        var itemCopy = merchantItem.item
        itemCopy.id = UUID()
        guard character.addItem(itemCopy) else {
            character.gold += merchantItem.goldPrice // refund
            return false
        }

        state.inventory[index].stock -= 1
        if state.inventory[index].stock <= 0 {
            state.inventory.remove(at: index)
        }

        saveData()
        return true
    }

    // MARK: - Execute Barter Trade
    func executeTrade(tradeId: UUID, character: inout Character) -> Bool {
        guard let tradeIndex = state.barterTrades.firstIndex(where: { $0.id == tradeId }) else { return false }
        let trade = state.barterTrades[tradeIndex]

        // Check gold
        guard character.gold >= trade.goldCost else { return false }

        // Check requested materials by templateId
        guard let materialEntry = character.inventory.first(where: {
            $0.item.templateId == trade.requestedItem.templateId && $0.quantity >= trade.requestedQuantity
        }) else { return false }

        // Deduct gold and materials
        character.gold -= trade.goldCost
        guard character.removeItem(materialEntry.item.id, quantity: trade.requestedQuantity) else {
            character.gold += trade.goldCost // refund
            return false
        }

        // Add offered item
        var offeredItem = trade.offeredItem
        offeredItem.id = UUID()
        guard character.addItem(offeredItem, quantity: trade.offeredQuantity) else {
            // Refund — best effort, materials already consumed
            character.gold += trade.goldCost
            return false
        }

        // Remove completed trade
        state.barterTrades.remove(at: tradeIndex)
        saveData()
        return true
    }

    // MARK: - Barter Trade Templates
    private static func allBarterTemplates(playerLevel: Int) -> [BarterTrade] {
        var trades: [BarterTrade] = []

        // Crystal Shard → Frostbite Staff
        if playerLevel >= 8 {
            trades.append(BarterTrade(
                offeredItem: ItemDatabase.frostStaff,
                offeredQuantity: 1,
                requestedItem: ItemDatabase.crystalShard,
                requestedQuantity: 5,
                goldCost: 50
            ))
        }

        // Iron Ore → Steel Longsword
        if playerLevel >= 5 {
            trades.append(BarterTrade(
                offeredItem: ItemDatabase.steelSword,
                offeredQuantity: 1,
                requestedItem: ItemDatabase.ironOre,
                requestedQuantity: 5,
                goldCost: 30
            ))
        }

        // Shadow Essence → Shadow Blade
        if playerLevel >= 8 {
            trades.append(BarterTrade(
                offeredItem: ItemDatabase.shadowBlade,
                offeredQuantity: 1,
                requestedItem: ItemDatabase.shadowEssence,
                requestedQuantity: 4,
                goldCost: 60
            ))
        }

        // Dragon Scale → Plate Armor
        if playerLevel >= 10 {
            trades.append(BarterTrade(
                offeredItem: ItemDatabase.plateArmor,
                offeredQuantity: 1,
                requestedItem: ItemDatabase.dragonScale,
                requestedQuantity: 3,
                goldCost: 80
            ))
        }

        // Enchanted Thread → Arcane Robes
        if playerLevel >= 10 {
            trades.append(BarterTrade(
                offeredItem: ItemDatabase.mageRobes,
                offeredQuantity: 1,
                requestedItem: ItemDatabase.enchantedThread,
                requestedQuantity: 6,
                goldCost: 70
            ))
        }

        return trades
    }

    // MARK: - Persistence
    func saveData() {
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: persistenceKey),
           let decoded = try? JSONDecoder().decode(TravelingMerchantState.self, from: data) {
            state = decoded
        }
    }
}
