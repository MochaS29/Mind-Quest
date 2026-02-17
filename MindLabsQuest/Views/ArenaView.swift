import SwiftUI

struct ArenaView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss

    @State private var opponent: ArenaOpponent?
    @State private var matchResult: ArenaMatchResult?
    @State private var showBattle = false
    @State private var showNoEnergy = false
    @State private var showArenaShop = false
    @State private var showMatchHistory = false
    @State private var isSearching = false

    private let energyCost = 2

    var body: some View {
        ZStack {
            // Dark red/orange gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.05, blue: 0.05),
                    Color(red: 0.2, green: 0.08, blue: 0.02),
                    Color(red: 0.12, green: 0.06, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                arenaHeader

                if let result = matchResult {
                    // Post-match results
                    postMatchView(result)
                } else if let opp = opponent {
                    // Opponent preview
                    opponentPreview(opp)
                } else if isSearching {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(1.5)
                        Text("Finding opponent...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    // Idle state
                    idleView
                }
            }
        }
        .fullScreenCover(isPresented: $showBattle) {
            if let opp = opponent {
                BattleView(encounter: opp.toBattleEncounter(), onComplete: { victory in
                    handleBattleComplete(victory: victory, opponent: opp)
                    showBattle = false
                }, gameManager: gameManager)
            }
        }
        .sheet(isPresented: $showArenaShop) {
            ArenaShopView()
                .environmentObject(gameManager)
        }
        .alert("Not Enough Energy", isPresented: $showNoEnergy) {
            Button("OK") {}
        } message: {
            Text("You need \(energyCost) energy for arena battles. Complete quests or wait for energy to regenerate.")
        }
    }

    // MARK: - Header
    private var arenaHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Arena Tokens
                HStack(spacing: 4) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .foregroundColor(.orange)
                    Text("\(gameManager.arenaManager.stats.arenaTokens)")
                        .font(.headline.bold())
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.15))
                )
            }
            .padding(.horizontal)

            // Rank badge + rating
            HStack(spacing: 12) {
                Text(gameManager.arenaManager.stats.rank.emoji)
                    .font(.system(size: 36))

                VStack(alignment: .leading, spacing: 2) {
                    Text(gameManager.arenaManager.stats.rank.rawValue)
                        .font(.title2.bold())
                        .foregroundColor(gameManager.arenaManager.stats.rank.color)
                    Text("Rating: \(gameManager.arenaManager.stats.rating)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Win streak
                if gameManager.arenaManager.stats.currentWinStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(gameManager.arenaManager.stats.currentWinStreak)")
                            .font(.headline.bold())
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.2))
                    )
                }
            }
            .padding(.horizontal)

            // Rank progress bar
            rankProgressBar
        }
        .padding(.top, 8)
    }

    private var rankProgressBar: some View {
        let rank = gameManager.arenaManager.stats.rank
        let rating = gameManager.arenaManager.stats.rating
        let range = rank.ratingRange
        let progress = Double(rating - range.lowerBound) / Double(range.upperBound - range.lowerBound + 1)

        return VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(rank.color)
                        .frame(width: geometry.size.width * min(1.0, max(0, progress)))
                }
            }
            .frame(height: 6)

            HStack {
                Text("\(range.lowerBound)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(range.upperBound + 1)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Idle State
    private var idleView: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("PvP Arena")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            Text("Battle AI-generated opponents to climb the ranks!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Stats summary
            HStack(spacing: 24) {
                VStack {
                    Text("\(gameManager.arenaManager.stats.totalWins)")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Text("Wins")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                VStack {
                    Text("\(gameManager.arenaManager.stats.totalLosses)")
                        .font(.title2.bold())
                        .foregroundColor(.red)
                    Text("Losses")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                VStack {
                    Text("\(gameManager.arenaManager.stats.highestWinStreak)")
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.4))
            )

            // Enter Arena button
            Button {
                findOpponent()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Enter Arena")
                            .font(.title3.bold())
                        Text("\(energyCost) Energy")
                            .font(.caption)
                            .opacity(0.8)
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            gameManager.energyManager.canStartArena
                                ? LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .shadow(color: gameManager.energyManager.canStartArena ? .red.opacity(0.5) : .clear, radius: 10)
            }
            .disabled(!gameManager.energyManager.canStartArena)

            // Links
            HStack(spacing: 20) {
                Button {
                    showArenaShop = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "cart.fill")
                        Text("Arena Shop")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }

                Button {
                    showMatchHistory = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                        Text("History")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - Opponent Preview
    private func opponentPreview(_ opponent: ArenaOpponent) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Text("Opponent Found!")
                .font(.headline)
                .foregroundColor(.red)

            VStack(spacing: 12) {
                Text(opponent.avatar)
                    .font(.system(size: 60))

                Text(opponent.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("Lv \(opponent.level)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(opponent.rank.emoji)
                    Text(opponent.rank.rawValue)
                        .font(.subheadline)
                        .foregroundColor(opponent.rank.color)
                }

                Text(opponent.characterClass.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 20) {
                    StatPill(icon: "heart.fill", value: "\(opponent.maxHP)", color: .red)
                    StatPill(icon: "burst.fill", value: "\(opponent.attackPower)", color: .orange)
                    StatPill(icon: "shield.fill", value: "\(opponent.defensePower)", color: .blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal)

            Button {
                showBattle = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                    Text("Fight!")
                        .font(.title3.bold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 50)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing))
                )
                .shadow(color: .red.opacity(0.5), radius: 10)
            }

            Button {
                self.opponent = nil
            } label: {
                Text("Find Another")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - Post-Match View
    private func postMatchView(_ result: ArenaMatchResult) -> some View {
        VStack(spacing: 20) {
            Spacer()

            Text(result.victory ? "Victory!" : "Defeat")
                .font(.largeTitle.bold())
                .foregroundColor(result.victory ? .green : .red)

            VStack(spacing: 12) {
                Text("vs \(result.opponentName)")
                    .font(.headline)
                    .foregroundColor(.white)

                // Rating change
                HStack(spacing: 8) {
                    Text("Rating")
                        .foregroundColor(.gray)
                    Text(result.ratingChange >= 0 ? "+\(result.ratingChange)" : "\(result.ratingChange)")
                        .font(.title2.bold())
                        .foregroundColor(result.ratingChange >= 0 ? .green : .red)
                }

                if result.tokensEarned > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .foregroundColor(.orange)
                        Text("+\(result.tokensEarned) tokens")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                }

                if gameManager.arenaManager.stats.currentWinStreak > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(gameManager.arenaManager.stats.currentWinStreak) win streak!")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke((result.victory ? Color.green : Color.red).opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal)

            Button {
                matchResult = nil
                opponent = nil
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                    )
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - Actions
    private func findOpponent() {
        guard gameManager.energyManager.canStartArena else {
            showNoEnergy = true
            return
        }

        isSearching = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            gameManager.energyManager.spendEnergy(energyCost)
            gameManager.personalRecordsManager.recordEnergySpent(energyCost)
            gameManager.energyManager.syncToCharacter(&gameManager.character)
            gameManager.saveData()

            opponent = gameManager.arenaManager.generateOpponent(
                playerLevel: gameManager.character.level,
                playerRating: gameManager.arenaManager.stats.rating,
                playerClass: gameManager.character.characterClass
            )
            isSearching = false
        }
    }

    private func handleBattleComplete(victory: Bool, opponent: ArenaOpponent) {
        let result = gameManager.completeArenaBattle(victory: victory, opponent: opponent)
        matchResult = result
    }
}
