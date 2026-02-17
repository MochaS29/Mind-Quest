import SwiftUI

struct TravelingMerchantView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedMerchantItem: MerchantItem?
    @State private var selectedTrade: BarterTrade?
    @State private var showBuyConfirmation = false
    @State private var showTradeConfirmation = false
    @State private var showInsufficientGold = false
    @State private var showInsufficientMaterials = false
    @State private var showInventoryFull = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Merchant header
                    merchantHeader

                    // For Sale section
                    if !gameManager.merchantManager.state.inventory.isEmpty {
                        forSaleSection
                    }

                    // Barter Trades section
                    if !gameManager.merchantManager.state.barterTrades.isEmpty {
                        barterSection
                    }

                    if gameManager.merchantManager.state.inventory.isEmpty &&
                       gameManager.merchantManager.state.barterTrades.isEmpty {
                        Text("The merchant has sold everything!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 30)
                    }
                }
                .padding()
            }
            .navigationTitle("Traveling Merchant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(gameManager.character.gold)")
                            .font(.subheadline.bold())
                    }
                }
            }
        }
        .alert("Buy Item?", isPresented: $showBuyConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Buy") {
                if let item = selectedMerchantItem {
                    buyItem(item)
                }
            }
        } message: {
            if let item = selectedMerchantItem {
                Text("Buy \(item.item.name) for \(item.goldPrice) gold?")
            }
        }
        .alert("Complete Trade?", isPresented: $showTradeConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Trade") {
                if let trade = selectedTrade {
                    executeTrade(trade)
                }
            }
        } message: {
            if let trade = selectedTrade {
                Text("Trade \(trade.requestedQuantity)x \(trade.requestedItem.name) + \(trade.goldCost)g for \(trade.offeredItem.name)?")
            }
        }
        .alert("Not Enough Gold", isPresented: $showInsufficientGold) {
            Button("OK") {}
        } message: {
            Text("You don't have enough gold for this purchase.")
        }
        .alert("Missing Materials", isPresented: $showInsufficientMaterials) {
            Button("OK") {}
        } message: {
            Text("You don't have the required materials for this trade.")
        }
        .alert("Inventory Full", isPresented: $showInventoryFull) {
            Button("OK") {}
        } message: {
            Text("Your inventory is full. Sell some items to make room.")
        }
    }

    // MARK: - Merchant Header
    private var merchantHeader: some View {
        VStack(spacing: 12) {
            Text("🧳")
                .font(.system(size: 50))

            Text(gameManager.merchantManager.state.merchantName)
                .font(.title2.bold())

            // Speech bubble
            Text("\"\(gameManager.merchantManager.state.greeting)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )

            // Departure countdown
            let daysLeft = gameManager.merchantManager.state.daysUntilDeparture
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("Departs in \(daysLeft) day\(daysLeft == 1 ? "" : "s")")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
    }

    // MARK: - For Sale Section
    private var forSaleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("For Sale")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(gameManager.merchantManager.state.inventory) { merchantItem in
                merchantItemRow(merchantItem)
            }
        }
    }

    private func merchantItemRow(_ merchantItem: MerchantItem) -> some View {
        let canAfford = gameManager.character.gold >= merchantItem.goldPrice

        return Button {
            selectedMerchantItem = merchantItem
            if !canAfford {
                showInsufficientGold = true
            } else {
                showBuyConfirmation = true
            }
        } label: {
            HStack(spacing: 12) {
                Text(merchantItem.item.icon)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(merchantItem.item.rarity.color.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(merchantItem.item.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    HStack(spacing: 4) {
                        Text(merchantItem.item.rarity.rawValue)
                            .font(.caption2)
                            .foregroundColor(merchantItem.item.rarity.color)
                        if merchantItem.stock > 1 {
                            Text("x\(merchantItem.stock)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(merchantItem.goldPrice)")
                        .font(.subheadline.bold())
                        .foregroundColor(canAfford ? .primary : .red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 3)
            )
            .opacity(canAfford ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Barter Section
    private var barterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Barter Trades")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(gameManager.merchantManager.state.barterTrades) { trade in
                barterTradeRow(trade)
            }
        }
    }

    private func barterTradeRow(_ trade: BarterTrade) -> some View {
        let ownedCount = gameManager.character.inventory
            .first(where: { $0.item.templateId == trade.requestedItem.templateId })?.quantity ?? 0
        let hasMaterials = ownedCount >= trade.requestedQuantity
        let hasGold = gameManager.character.gold >= trade.goldCost
        let canTrade = hasMaterials && hasGold

        return Button {
            selectedTrade = trade
            if !hasMaterials {
                showInsufficientMaterials = true
            } else if !hasGold {
                showInsufficientGold = true
            } else {
                showTradeConfirmation = true
            }
        } label: {
            VStack(spacing: 8) {
                // YOU GIVE
                HStack(spacing: 8) {
                    Text("YOU GIVE:")
                        .font(.caption2.bold())
                        .foregroundColor(.red.opacity(0.8))

                    Text("\(trade.requestedQuantity)x \(trade.requestedItem.icon) \(trade.requestedItem.name)")
                        .font(.caption)
                        .foregroundColor(.primary)

                    Text("(\(ownedCount)/\(trade.requestedQuantity))")
                        .font(.caption2)
                        .foregroundColor(hasMaterials ? .green : .red)

                    if trade.goldCost > 0 {
                        Text("+ \(trade.goldCost)g")
                            .font(.caption)
                            .foregroundColor(hasGold ? .yellow : .red)
                    }
                }

                Image(systemName: "arrow.down")
                    .font(.caption)
                    .foregroundColor(.gray)

                // YOU GET
                HStack(spacing: 8) {
                    Text("YOU GET:")
                        .font(.caption2.bold())
                        .foregroundColor(.green)

                    Text("\(trade.offeredItem.icon) \(trade.offeredItem.name)")
                        .font(.caption.bold())
                        .foregroundColor(.primary)

                    Text(trade.offeredItem.rarity.rawValue)
                        .font(.caption2)
                        .foregroundColor(trade.offeredItem.rarity.color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(canTrade ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .opacity(canTrade ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Actions
    private func buyItem(_ merchantItem: MerchantItem) {
        if gameManager.merchantManager.buyItem(merchantItemId: merchantItem.id, character: &gameManager.character) {
            gameManager.personalRecordsManager.recordItemPurchased()
            gameManager.personalRecordsManager.recordGoldSpent(merchantItem.goldPrice)
            gameManager.saveData()
        } else {
            showInventoryFull = true
        }
    }

    private func executeTrade(_ trade: BarterTrade) {
        if gameManager.merchantManager.executeTrade(tradeId: trade.id, character: &gameManager.character) {
            gameManager.personalRecordsManager.recordBarterTrade()
            gameManager.personalRecordsManager.recordGoldSpent(trade.goldCost)
            gameManager.saveData()
        }
    }
}
