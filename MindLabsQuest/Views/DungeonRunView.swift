import SwiftUI

struct DungeonRunView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    let dungeon: Dungeon

    @State private var showBattle = false
    @State private var currentEncounter: BattleEncounter?

    var run: DungeonRunState? {
        gameManager.dungeonRunManager.currentRun
    }

    var body: some View {
        ZStack {
            // Dark dungeon background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.06, blue: 0.12),
                    Color(red: 0.12, green: 0.08, blue: 0.18),
                    Color(red: 0.06, green: 0.08, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if let run = run {
                if !run.isActive {
                    // Run complete or defeated
                    completionView(run)
                } else {
                    // Active run
                    activeRunView(run)
                }
            } else {
                // No run — shouldn't happen, dismiss
                VStack {
                    Text("No active dungeon run")
                        .foregroundColor(.gray)
                    Button("Back") { dismiss() }
                        .foregroundColor(.purple)
                }
            }
        }
        .fullScreenCover(isPresented: $showBattle) {
            if let encounter = currentEncounter {
                BattleView(encounter: encounter, onComplete: { victory in
                    handleBattleComplete(victory: victory)
                    showBattle = false
                }, gameManager: gameManager)
            }
        }
    }

    // MARK: - Active Run View

    private func activeRunView(_ run: DungeonRunState) -> some View {
        VStack(spacing: 24) {
            // Header with close/abandon
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Text("Leave")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                Spacer()
                Text(dungeon.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    gameManager.dungeonRunManager.abandonRun()
                    dismiss()
                } label: {
                    Text("Abandon")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)

            // Floor progress
            floorProgress(run)

            // HP bar
            hpBar(run)

            Spacer()

            // Current floor info
            if let floor = gameManager.dungeonRunManager.currentFloor(in: dungeon) {
                floorCard(floor, run: run)
            }

            Spacer()

            // Fight button
            Button {
                if let encounter = gameManager.dungeonRunManager.currentFloorEncounter(in: dungeon, playerLevel: gameManager.character.level) {
                    currentEncounter = encounter
                    showBattle = true
                }
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

            Spacer()
        }
        .padding(.top)
    }

    // MARK: - Floor Progress

    private func floorProgress(_ run: DungeonRunState) -> some View {
        VStack(spacing: 8) {
            Text("Floor \(run.currentFloor + 1) of \(run.totalFloors)")
                .font(.subheadline)
                .foregroundColor(.white)

            HStack(spacing: 6) {
                ForEach(0..<run.totalFloors, id: \.self) { i in
                    Circle()
                        .fill(floorDotColor(i, currentFloor: run.currentFloor))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
    }

    private func floorDotColor(_ floor: Int, currentFloor: Int) -> Color {
        if floor < currentFloor {
            return .green
        } else if floor == currentFloor {
            return .orange
        } else {
            return .gray.opacity(0.3)
        }
    }

    // MARK: - HP Bar

    private func hpBar(_ run: DungeonRunState) -> some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                Text("\(run.playerHP)/\(run.playerMaxHP)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: hpBarColors(run),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(run.playerHP) / CGFloat(max(1, run.playerMaxHP)), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
    }

    private func hpBarColors(_ run: DungeonRunState) -> [Color] {
        let ratio = Double(run.playerHP) / Double(max(1, run.playerMaxHP))
        if ratio > 0.5 {
            return [.green, .green.opacity(0.8)]
        } else if ratio > 0.25 {
            return [.yellow, .orange]
        } else {
            return [.red, .red.opacity(0.8)]
        }
    }

    // MARK: - Floor Card

    private func floorCard(_ floor: DungeonFloor, run: DungeonRunState) -> some View {
        VStack(spacing: 16) {
            if floor.isBossFloor {
                Text("BOSS FLOOR")
                    .font(.caption.bold())
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
            }

            if let flavorText = floor.flavorText {
                Text(flavorText)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Enemy preview
            if let template = EnemyDatabase.allEnemies.first(where: { $0.id == floor.enemyTemplateId }) {
                VStack(spacing: 8) {
                    Text(template.avatar)
                        .font(.system(size: 50))
                    Text(template.name)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    HStack(spacing: 16) {
                        StatPill(icon: "heart.fill", value: "\(template.baseHP)", color: .red)
                        StatPill(icon: "burst.fill", value: "\(template.baseAttack)", color: .orange)
                        StatPill(icon: "shield.fill", value: "\(template.baseDefense)", color: .blue)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(floor.isBossFloor ? Color.red.opacity(0.5) : Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Completion View

    private func completionView(_ run: DungeonRunState) -> some View {
        let isVictory = run.floorsCompleted >= run.totalFloors

        return VStack(spacing: 24) {
            Spacer()

            Text(isVictory ? "Dungeon Cleared!" : "Defeated...")
                .font(.largeTitle.bold())
                .foregroundColor(isVictory ? .yellow : .red)

            Text(dungeon.name)
                .font(.title2)
                .foregroundColor(.white)

            // Stats summary
            VStack(spacing: 12) {
                summaryRow(icon: "building.columns", label: "Floors Cleared", value: "\(run.floorsCompleted)/\(run.totalFloors)", color: .purple)
                summaryRow(icon: "star.fill", label: "XP Earned", value: "\(run.totalXPEarned)", color: .blue)
                summaryRow(icon: "bitcoinsign.circle.fill", label: "Gold Earned", value: "\(run.totalGoldEarned)", color: .yellow)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.5))
            )
            .padding(.horizontal)

            Spacer()

            Button {
                gameManager.dungeonRunManager.abandonRun()
                dismiss()
            } label: {
                Text("Return to Town")
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
        }
    }

    private func summaryRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .bold()
        }
    }

    // MARK: - Battle Complete Handler

    private func handleBattleComplete(victory: Bool) {
        // Get remaining HP from battle state
        let remainingHP = gameManager.battleManager?.battleState?.playerHP ?? 0
        let rewards = victory ? gameManager.battleManager?.collectRewards() : nil

        // Complete battle in GameManager (awards XP/gold/loot/challenges)
        gameManager.completeBattle(victory: victory)

        // Update dungeon run state
        gameManager.dungeonRunManager.completeFloor(
            victory: victory,
            remainingHP: remainingHP,
            rewards: rewards
        )

        currentEncounter = nil
    }
}
