import SwiftUI

struct PersonalRecordsView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss

    let badgeColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview card
                    overviewCard

                    // Battle Records
                    battleRecordsCard

                    // Arena Records
                    arenaRecordsCard

                    // Economy Records
                    economyRecordsCard

                    // Dungeon Records
                    dungeonRecordsCard

                    // Badge Grid
                    badgeGridSection
                }
                .padding()
            }
            .navigationTitle("Personal Records")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - Overview
    private var overviewCard: some View {
        HStack(spacing: 24) {
            VStack {
                Text("\(gameManager.personalRecordsManager.records.totalBattlesWon)")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Battles Won")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            VStack {
                Text("\(gameManager.personalRecordsManager.records.totalQuestsCompleted)")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Quests Done")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            VStack {
                Text("\(gameManager.personalRecordsManager.records.totalPlayDays)")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Days Played")
                    .font(.caption)
                    .foregroundColor(.secondary)
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

    // MARK: - Battle Records
    private var battleRecordsCard: some View {
        recordSection(title: "Battle", icon: "burst.fill", color: .red) {
            recordRow(icon: "checkmark.circle", label: "Battles Won", value: "\(gameManager.personalRecordsManager.records.totalBattlesWon)")
            recordRow(icon: "xmark.circle", label: "Battles Lost", value: "\(gameManager.personalRecordsManager.records.totalBattlesLost)")
            recordRow(icon: "flame.fill", label: "Longest Win Streak", value: "\(gameManager.personalRecordsManager.records.longestBattleWinStreak)")
            recordRow(icon: "bolt.fill", label: "Highest Single Hit", value: "\(gameManager.personalRecordsManager.records.highestSingleHit)")
            recordRow(icon: "burst.fill", label: "Total Damage Dealt", value: "\(gameManager.personalRecordsManager.records.totalDamageDealt)")
        }
    }

    // MARK: - Arena Records
    private var arenaRecordsCard: some View {
        recordSection(title: "Arena", icon: "person.2.fill", color: .orange) {
            recordRow(icon: "checkmark.circle", label: "Arena Wins", value: "\(gameManager.personalRecordsManager.records.arenaWins)")
            recordRow(icon: "xmark.circle", label: "Arena Losses", value: "\(gameManager.personalRecordsManager.records.arenaLosses)")
            recordRow(icon: "star.fill", label: "Highest Rating", value: "\(gameManager.personalRecordsManager.records.highestArenaRating)")
        }
    }

    // MARK: - Economy Records
    private var economyRecordsCard: some View {
        recordSection(title: "Economy", icon: "dollarsign.circle.fill", color: .yellow) {
            recordRow(icon: "dollarsign.circle", label: "Total Gold Earned", value: "\(gameManager.personalRecordsManager.records.totalGoldEarned)")
            recordRow(icon: "cart.fill", label: "Total Gold Spent", value: "\(gameManager.personalRecordsManager.records.totalGoldSpent)")
            recordRow(icon: "bag.fill", label: "Items Purchased", value: "\(gameManager.personalRecordsManager.records.itemsPurchased)")
            recordRow(icon: "arrow.triangle.2.circlepath", label: "Barter Trades", value: "\(gameManager.personalRecordsManager.records.barterTradesCompleted)")
        }
    }

    // MARK: - Dungeon Records
    private var dungeonRecordsCard: some View {
        recordSection(title: "Dungeon", icon: "building.columns.fill", color: .green) {
            recordRow(icon: "checkmark.circle", label: "Dungeons Cleared", value: "\(gameManager.personalRecordsManager.records.totalDungeonClears)")
            recordRow(icon: "arrow.up", label: "Highest Floor", value: "\(gameManager.personalRecordsManager.records.highestFloor)")
        }
    }

    // MARK: - Badge Grid
    private var badgeGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "rosette")
                    .foregroundColor(.purple)
                Text("Badges")
                    .font(.headline)

                Spacer()

                Text("\(gameManager.personalRecordsManager.unlockedBadgeCount)/\(gameManager.personalRecordsManager.badges.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: badgeColumns, spacing: 12) {
                ForEach(gameManager.personalRecordsManager.badges) { badge in
                    badgeCell(badge)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
    }

    private func badgeCell(_ badge: RecordBadge) -> some View {
        VStack(spacing: 6) {
            Image(systemName: badge.isUnlocked ? badge.icon : "lock.fill")
                .font(.title2)
                .foregroundColor(badge.isUnlocked ? badge.category.color : .gray.opacity(0.4))
                .frame(width: 40, height: 40)

            Text(badge.title)
                .font(.caption.bold())
                .foregroundColor(badge.isUnlocked ? .primary : .gray)
                .lineLimit(1)

            Text(badge.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(badge.isUnlocked ? badge.category.color.opacity(0.08) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(badge.isUnlocked ? badge.category.color.opacity(0.3) : Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Helpers
    private func recordSection<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
    }

    private func recordRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
        }
    }
}
