import SwiftUI

struct ArenaShopView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedEntry: ArenaShopEntry?
    @State private var showBuyConfirmation = false
    @State private var showInsufficientTokens = false
    @State private var showRankLocked = false
    @State private var showLevelLocked = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header: token balance + rank
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "circle.hexagongrid.fill")
                                .foregroundColor(.orange)
                            Text("\(gameManager.arenaManager.stats.arenaTokens)")
                                .font(.title3.bold())
                                .foregroundColor(.orange)
                            Text("Tokens")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                        )

                        Spacer()

                        HStack(spacing: 4) {
                            Text(gameManager.arenaManager.stats.rank.emoji)
                            Text(gameManager.arenaManager.stats.rank.rawValue)
                                .font(.subheadline.bold())
                                .foregroundColor(gameManager.arenaManager.stats.rank.color)
                        }
                    }
                    .padding(.horizontal)

                    // Item grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(ArenaItemDatabase.shopEntries) { entry in
                            arenaShopCard(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Arena Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .alert("Purchase Item?", isPresented: $showBuyConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Buy") {
                if let entry = selectedEntry {
                    purchaseItem(entry)
                }
            }
        } message: {
            if let entry = selectedEntry {
                Text("Buy \(entry.item.name) for \(entry.tokenPrice) Arena Tokens?")
            }
        }
        .alert("Not Enough Tokens", isPresented: $showInsufficientTokens) {
            Button("OK") {}
        } message: {
            Text("You need more Arena Tokens. Win arena matches to earn tokens!")
        }
        .alert("Rank Locked", isPresented: $showRankLocked) {
            Button("OK") {}
        } message: {
            if let entry = selectedEntry {
                Text("This item requires \(entry.rankRequired.rawValue) rank. Keep climbing!")
            }
        }
        .alert("Level Locked", isPresented: $showLevelLocked) {
            Button("OK") {}
        } message: {
            if let entry = selectedEntry {
                Text("This item requires level \(entry.levelRequired).")
            }
        }
    }

    private func arenaShopCard(entry: ArenaShopEntry) -> some View {
        let isOwned = gameManager.character.inventory.contains { $0.item.templateId == entry.item.templateId }
        let meetsRank = rankMeetsRequirement(entry.rankRequired)
        let meetsLevel = gameManager.character.level >= entry.levelRequired
        let canBuy = !isOwned && meetsRank && meetsLevel

        return Button {
            selectedEntry = entry
            if isOwned { return }
            if !meetsRank {
                showRankLocked = true
            } else if !meetsLevel {
                showLevelLocked = true
            } else if gameManager.arenaManager.stats.arenaTokens < entry.tokenPrice {
                showInsufficientTokens = true
            } else {
                showBuyConfirmation = true
            }
        } label: {
            VStack(spacing: 8) {
                // Item icon with rarity border
                Text(entry.item.icon)
                    .font(.system(size: 36))
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(entry.item.rarity.color.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(entry.item.rarity.color.opacity(0.5), lineWidth: 2)
                    )

                Text(entry.item.name)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(entry.item.rarity.rawValue)
                    .font(.caption2)
                    .foregroundColor(entry.item.rarity.color)

                if isOwned {
                    Text("OWNED")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.15))
                        )
                } else {
                    // Token price
                    HStack(spacing: 4) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("\(entry.tokenPrice)")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                    }
                }

                // Requirements
                if !meetsRank {
                    HStack(spacing: 2) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8))
                        Text(entry.rankRequired.rawValue)
                            .font(.caption2)
                    }
                    .foregroundColor(.red.opacity(0.7))
                } else if !meetsLevel {
                    HStack(spacing: 2) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8))
                        Text("Lv \(entry.levelRequired)")
                            .font(.caption2)
                    }
                    .foregroundColor(.red.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground).opacity(canBuy ? 1.0 : 0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isOwned ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .opacity(canBuy || isOwned ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func rankMeetsRequirement(_ required: ArenaRank) -> Bool {
        let currentRating = gameManager.arenaManager.stats.rating
        let requiredMin = required.ratingRange.lowerBound
        return currentRating >= requiredMin
    }

    private func purchaseItem(_ entry: ArenaShopEntry) {
        guard gameManager.arenaManager.spendTokens(entry.tokenPrice) else { return }

        var itemCopy = entry.item
        itemCopy.id = UUID()
        _ = gameManager.addItemToInventory(itemCopy)
        gameManager.personalRecordsManager.recordItemPurchased()
        gameManager.saveData()
    }
}
