import SwiftUI

struct ShopView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCategory: ShopCategory = .daily
    @State private var showSellMode = false
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage = ""

    enum ShopCategory: String, CaseIterable {
        case daily = "Daily Deals"
        case consumables = "Consumables"
        case sell = "Sell Items"
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Gold header
                    goldHeader

                    // Category tabs
                    categoryTabs

                    // Content
                    ScrollView {
                        switch selectedCategory {
                        case .daily:
                            dailyStockGrid
                        case .consumables:
                            permanentStockGrid
                        case .sell:
                            sellItemsList
                        }
                    }
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                gameManager.shopManager.refreshDailyStock(
                    playerLevel: gameManager.character.level,
                    playerClass: gameManager.character.characterClass
                )
            }
            .alert("Purchase", isPresented: $showPurchaseAlert) {
                Button("OK") {}
            } message: {
                Text(purchaseMessage)
            }
        }
    }

    // MARK: - Gold Header
    private var goldHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                Text("\(gameManager.character.gold)")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Gold")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if selectedCategory == .daily {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Refreshes: \(gameManager.shopManager.formattedTimeUntilRefresh)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }

    // MARK: - Category Tabs
    private var categoryTabs: some View {
        HStack(spacing: 8) {
            ForEach(ShopCategory.allCases, id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    Text(category.rawValue)
                        .font(.subheadline.bold())
                        .foregroundColor(selectedCategory == category ? .white : .primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedCategory == category ? Color.purple : Color.gray.opacity(0.15))
                        )
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    // MARK: - Daily Stock Grid
    private var dailyStockGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(gameManager.shopManager.dailyStock) { shopItem in
                ShopCardView(shopItem: shopItem) {
                    buyItem(shopItem)
                }
            }
        }
        .padding()
    }

    // MARK: - Permanent Stock Grid
    private var permanentStockGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(gameManager.shopManager.permanentStock) { shopItem in
                ShopCardView(shopItem: shopItem) {
                    buyItem(shopItem)
                }
            }
        }
        .padding()
    }

    // MARK: - Sell Items List
    private var sellItemsList: some View {
        VStack(spacing: 8) {
            if gameManager.character.inventory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bag")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No items to sell")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
            } else {
                ForEach(gameManager.character.inventory) { entry in
                    HStack(spacing: 12) {
                        Text(entry.item.icon)
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(entry.item.rarity.color.opacity(0.15))
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.item.name)
                                .font(.subheadline.bold())
                            Text(entry.item.rarity.rawValue)
                                .font(.caption)
                                .foregroundColor(entry.item.rarity.color)
                        }

                        Spacer()

                        if entry.quantity > 1 {
                            Text("x\(entry.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Button {
                            sellItem(entry.item.id)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                Text("\(entry.item.sellPrice)")
                                    .font(.caption.bold())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.green))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }

    // MARK: - Actions

    private func buyItem(_ shopItem: ShopItem) {
        if gameManager.shopManager.buyItem(shopItem, character: &gameManager.character) {
            purchaseMessage = "Bought \(shopItem.item.name) for \(shopItem.displayPrice) gold!"
            gameManager.saveData()
        } else if gameManager.character.gold < shopItem.displayPrice {
            purchaseMessage = "Not enough gold! Need \(shopItem.displayPrice) gold."
        } else {
            purchaseMessage = "Inventory is full!"
        }
        showPurchaseAlert = true
    }

    private func sellItem(_ itemId: UUID) {
        let gold = gameManager.shopManager.sellItem(itemId, character: &gameManager.character)
        if gold > 0 {
            gameManager.saveData()
        }
    }
}

// MARK: - Shop Card View
struct ShopCardView: View {
    let shopItem: ShopItem
    let onBuy: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Text(shopItem.item.icon)
                .font(.system(size: 32))
                .frame(width: 50, height: 50)

            // Name
            Text(shopItem.item.name)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Rarity
            Text(shopItem.item.rarity.rawValue)
                .font(.caption2)
                .foregroundColor(shopItem.item.rarity.color)

            // Price
            HStack(spacing: 4) {
                if shopItem.isDiscounted {
                    Text("\(shopItem.originalPrice)")
                        .font(.caption2)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 2) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("\(shopItem.displayPrice)")
                        .font(.caption.bold())
                        .foregroundColor(shopItem.isDiscounted ? .green : .primary)
                }
            }

            // Buy button
            Button(action: onBuy) {
                Text("BUY")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.purple))
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(shopItem.item.rarity.color.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}
