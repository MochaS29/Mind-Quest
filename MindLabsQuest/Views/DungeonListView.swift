import SwiftUI

struct DungeonListView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedDungeon: Dungeon?
    @State private var showDungeonRun = false
    @State private var showNoEnergy = false
    @State private var showLevelLock = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Energy display
                    energyHeader

                    // Resume active run
                    if let run = gameManager.dungeonRunManager.currentRun, run.isActive {
                        if let dungeon = DungeonDatabase.dungeon(byId: run.dungeonId) {
                            activeRunCard(dungeon: dungeon, run: run)
                        }
                    }

                    // Dungeon list
                    ForEach(DungeonDatabase.allDungeons) { dungeon in
                        dungeonCard(dungeon)
                    }
                }
                .padding()
            }
            .navigationTitle("Dungeons")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
        }
        .fullScreenCover(isPresented: $showDungeonRun) {
            if let dungeon = selectedDungeon {
                DungeonRunView(dungeon: dungeon)
                    .environmentObject(gameManager)
            }
        }
        .alert("Not Enough Energy", isPresented: $showNoEnergy) {
            Button("OK") {}
        } message: {
            if let dungeon = selectedDungeon {
                Text("You need \(dungeon.energyCost) energy to enter this dungeon. Complete quests or wait for energy to regenerate.")
            }
        }
        .alert("Level Too Low", isPresented: $showLevelLock) {
            Button("OK") {}
        } message: {
            if let dungeon = selectedDungeon {
                Text("You need to be Level \(dungeon.levelRequirement) to enter \(dungeon.name). Keep questing!")
            }
        }
    }

    // MARK: - Energy Header

    private var energyHeader: some View {
        MindLabsCard {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("Energy")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    Text("\(gameManager.energyManager.currentEnergy)/\(gameManager.energyManager.maxEnergy)")
                        .font(MindLabsTypography.title())
                        .foregroundColor(.mindLabsText)
                }
                Spacer()
                if let timeStr = gameManager.energyManager.formattedTimeUntilNext {
                    Text("Next: \(timeStr)")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.orange)
                }
            }
        }
    }

    // MARK: - Active Run Card

    private func activeRunCard(dungeon: Dungeon, run: DungeonRunState) -> some View {
        Button {
            selectedDungeon = dungeon
            showDungeonRun = true
        } label: {
            MindLabsCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.orange)
                        Text("Active Run: \(dungeon.name)")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        Spacer()
                    }
                    HStack {
                        Text("Floor \(run.currentFloor + 1)/\(run.totalFloors)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text("\(run.playerHP)/\(run.playerMaxHP)")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsText)
                        }
                    }
                    Text("Tap to continue")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.orange)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.orange.opacity(0.5), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Dungeon Card

    private func dungeonCard(_ dungeon: Dungeon) -> some View {
        let isUnlocked = gameManager.character.level >= dungeon.levelRequirement
        let isCompleted = gameManager.dungeonRunManager.dungeonProgress.completedDungeonIds.contains(dungeon.id)
        let hasEnergy = gameManager.energyManager.currentEnergy >= dungeon.energyCost
        let hasActiveRun = gameManager.dungeonRunManager.isRunActive

        return Button {
            if !isUnlocked {
                selectedDungeon = dungeon
                showLevelLock = true
            } else if hasActiveRun {
                // Already in a run — resume or must finish
            } else if !hasEnergy {
                selectedDungeon = dungeon
                showNoEnergy = true
            } else {
                selectedDungeon = dungeon
                gameManager.energyManager.spendEnergy(dungeon.energyCost)
                gameManager.energyManager.syncToCharacter(&gameManager.character)
                _ = gameManager.dungeonRunManager.startRun(dungeon: dungeon, character: gameManager.character)
                gameManager.saveData()
                showDungeonRun = true
            }
        } label: {
            MindLabsCard {
                HStack(spacing: 12) {
                    // Dungeon icon
                    ZStack {
                        Circle()
                            .fill(isUnlocked ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                            .frame(width: 50, height: 50)
                        if isUnlocked {
                            Image(systemName: dungeon.icon)
                                .font(.title2)
                                .foregroundColor(.orange)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(dungeon.name)
                                .font(MindLabsTypography.headline())
                                .foregroundColor(isUnlocked ? .mindLabsText : .gray)
                            if isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.mindLabsSuccess)
                                    .font(.caption)
                            }
                        }
                        Text(dungeon.description)
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                            .lineLimit(2)

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                Text("\(dungeon.energyCost)")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(hasEnergy ? .mindLabsText : .mindLabsError)
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.circle")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                Text("Lv \(dungeon.levelRequirement)+")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(isUnlocked ? .mindLabsText : .mindLabsError)
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "building.columns")
                                    .font(.caption2)
                                    .foregroundColor(.purple)
                                Text("\(dungeon.floors.count) floors")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }

                    Spacer()

                    if isUnlocked && !hasActiveRun {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
            }
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(hasActiveRun && gameManager.dungeonRunManager.currentRun?.dungeonId != dungeon.id)
    }
}
