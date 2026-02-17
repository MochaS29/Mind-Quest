import Foundation

// MARK: - Barter Trade
struct BarterTrade: Identifiable, Codable {
    var id: UUID = UUID()
    var offeredItem: Item
    var offeredQuantity: Int
    var requestedItem: Item
    var requestedQuantity: Int
    var goldCost: Int
}

// MARK: - Merchant Item
struct MerchantItem: Identifiable, Codable {
    var id: UUID = UUID()
    var item: Item
    var goldPrice: Int
    var stock: Int = 1
}

// MARK: - Traveling Merchant State
struct TravelingMerchantState: Codable {
    var inventory: [MerchantItem] = []
    var barterTrades: [BarterTrade] = []
    var lastRefreshDate: Date = Date.distantPast
    var merchantName: String = "Zara the Wanderer"
    var greeting: String = "Welcome, traveler!"

    var isPresent: Bool {
        let calendar = Calendar.current
        // Present during the same ISO week as refresh
        guard lastRefreshDate != Date.distantPast else { return false }
        let refreshWeek = calendar.component(.weekOfYear, from: lastRefreshDate)
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        let refreshYear = calendar.component(.yearForWeekOfYear, from: lastRefreshDate)
        let currentYear = calendar.component(.yearForWeekOfYear, from: Date())
        return refreshWeek == currentWeek && refreshYear == currentYear
    }

    var daysUntilDeparture: Int {
        let calendar = Calendar.current
        // Merchant departs at end of Sunday
        let weekday = calendar.component(.weekday, from: Date()) // 1=Sun, 2=Mon...7=Sat
        let daysLeft = weekday == 1 ? 0 : (8 - weekday)
        return max(0, daysLeft)
    }
}
