import SwiftUI

struct QuickBattleView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss

    @State private var encounter: BattleEncounter?
    @State private var showBattle = false
    @State private var showNoEnergy = false
    @State private var isSearching = false

    var body: some View {
        ZStack {
            // Dark adventure background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.08, blue: 0.15),
                    Color(red: 0.15, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.12, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Close button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("Quick Battle")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Text("Test your strength against random foes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Energy display
                energyDisplay

                if let encounter = encounter {
                    // Enemy preview
                    enemyPreview(encounter)
                } else if isSearching {
                    // Searching animation
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)
                        Text("Searching for enemies...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 40)
                } else {
                    // Find battle button
                    Button {
                        findBattle()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "bolt.fill")
                                .font(.title2)
                            Text("Find Battle")
                                .font(.title3.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    gameManager.energyManager.canStartBattle
                                        ? LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                        .shadow(color: gameManager.energyManager.canStartBattle ? .purple.opacity(0.5) : .clear, radius: 10)
                    }
                    .disabled(!gameManager.energyManager.canStartBattle)
                }

                Spacer()
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showBattle) {
            if let enc = encounter {
                BattleView(encounter: enc, onComplete: { victory in
                    gameManager.completeBattle(victory: victory)
                    showBattle = false
                    encounter = nil
                }, gameManager: gameManager)
            }
        }
        .alert("Not Enough Energy", isPresented: $showNoEnergy) {
            Button("OK") {}
        } message: {
            Text("You need at least 1 energy to battle. Complete quests or wait for energy to regenerate.")
        }
    }

    // MARK: - Energy Display
    private var energyDisplay: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<gameManager.energyManager.maxEnergy, id: \.self) { i in
                    Image(systemName: i < gameManager.energyManager.currentEnergy ? "bolt.fill" : "bolt")
                        .font(.title3)
                        .foregroundColor(i < gameManager.energyManager.currentEnergy ? .yellow : .gray.opacity(0.4))
                }
            }

            Text("Energy: \(gameManager.energyManager.currentEnergy)/\(gameManager.energyManager.maxEnergy)")
                .font(.subheadline)
                .foregroundColor(.white)

            if let timeStr = gameManager.energyManager.formattedTimeUntilNext {
                Text("Next in \(timeStr)")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    // MARK: - Enemy Preview
    private func enemyPreview(_ encounter: BattleEncounter) -> some View {
        VStack(spacing: 16) {
            Text("Enemy Found!")
                .font(.headline)
                .foregroundColor(.red)

            // Enemy card
            VStack(spacing: 12) {
                Text(encounter.enemyAvatar)
                    .font(.system(size: 60))

                Text(encounter.enemyName)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Level \(encounter.enemyLevel)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(encounter.enemyDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Stats preview
                HStack(spacing: 20) {
                    StatPill(icon: "heart.fill", value: "\(encounter.enemyHP)", color: .red)
                    StatPill(icon: "burst.fill", value: "\(encounter.enemyAttack)", color: .orange)
                    StatPill(icon: "shield.fill", value: "\(encounter.enemyDefense)", color: .blue)
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

            // Fight button
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

            // Back button
            Button {
                self.encounter = nil
            } label: {
                Text("Find Another")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Find Battle
    private func findBattle() {
        guard gameManager.energyManager.canStartBattle else {
            showNoEnergy = true
            return
        }

        isSearching = true

        // Brief delay for visual effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            gameManager.energyManager.spendEnergy()
            gameManager.energyManager.syncToCharacter(&gameManager.character)
            gameManager.saveData()

            encounter = gameManager.encounterManager.generateEncounter(playerLevel: gameManager.character.level)
            isSearching = false
        }
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.2))
        )
    }
}
