import Foundation

// MARK: - Shop Item (wraps Item with shop-specific data)
struct ShopItem: Identifiable {
    var id: UUID { item.id }
    var item: Item
    var isDiscounted: Bool = false
    var discountPercent: Int = 0

    var displayPrice: Int {
        if isDiscounted {
            return max(1, item.buyPrice - (item.buyPrice * discountPercent / 100))
        }
        return item.buyPrice
    }

    var originalPrice: Int { item.buyPrice }
}

// MARK: - Seedable RNG (deterministic daily rotation)
struct SeedableRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // LCG parameters (Knuth)
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - Shop Manager
class ShopManager: ObservableObject {
    @Published var dailyStock: [ShopItem] = []
    @Published var lastRefreshDate: Date?

    // Permanent stock: all consumables always available
    var permanentStock: [ShopItem] {
        let consumables = ItemDatabase.allShopItems.filter { $0.type == .consumable }
        return consumables.map { ShopItem(item: $0) }
    }

    init() {}

    // MARK: - Daily Stock Refresh

    func refreshDailyStock(playerLevel: Int, playerClass: CharacterClass?) {
        let today = Calendar.current.startOfDay(for: Date())

        // Skip if already refreshed today
        if let lastRefresh = lastRefreshDate,
           Calendar.current.isDate(lastRefresh, inSameDayAs: today) {
            return
        }

        // Date-seeded RNG for deterministic daily rotation
        let dateHash = UInt64(today.timeIntervalSince1970)
        var rng = SeedableRNG(seed: dateHash)

        // Filter eligible items (non-consumable, level-appropriate)
        let eligible = ItemDatabase.allShopItems.filter { item in
            item.type != .consumable && item.levelRequirement <= playerLevel + 2
        }

        // Shuffle with seeded RNG
        var shuffled = eligible
        for i in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffled.swapAt(i, j)
        }

        // Pick 8-12 items
        let countRange = 8...min(12, shuffled.count)
        let count = countRange.lowerBound + Int(rng.next() % UInt64(countRange.count))
        let selected = Array(shuffled.prefix(count))

        // Apply random discounts (20% chance, 10-25% off)
        dailyStock = selected.map { item in
            let hasDiscount = rng.next() % 5 == 0 // 20% chance
            let discountAmount = hasDiscount ? (10 + Int(rng.next() % 16)) : 0
            return ShopItem(item: item, isDiscounted: hasDiscount, discountPercent: discountAmount)
        }

        lastRefreshDate = today
    }

    // MARK: - Buy Item

    func buyItem(_ shopItem: ShopItem, character: inout Character) -> Bool {
        let price = shopItem.displayPrice
        guard character.gold >= price else { return false }

        var itemCopy = shopItem.item
        itemCopy.id = UUID() // Unique instance
        guard character.addItem(itemCopy) else { return false }

        character.gold -= price
        return true
    }

    // MARK: - Sell Item

    func sellItem(_ itemId: UUID, character: inout Character) -> Int {
        guard let entry = character.inventory.first(where: { $0.item.id == itemId }) else { return 0 }
        let sellPrice = entry.item.sellPrice
        guard character.removeItem(itemId) else { return 0 }
        character.gold += sellPrice
        return sellPrice
    }

    // MARK: - Time Until Refresh

    var timeUntilRefresh: TimeInterval {
        let now = Date()
        let tomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: now)!)
        return tomorrow.timeIntervalSince(now)
    }

    var formattedTimeUntilRefresh: String {
        let remaining = timeUntilRefresh
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }
}
