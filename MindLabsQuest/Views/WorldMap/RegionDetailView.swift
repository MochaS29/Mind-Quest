import SwiftUI

struct RegionDetailView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    let region: MapRegion

    @State private var showQuickBattle = false
    @State private var showDungeons = false
    @State private var selectedEnemy: EnemyTemplate?

    private var enemies: [EnemyTemplate] {
        region.enemyTemplateIds.compactMap { templateId in
            EnemyDatabase.allEnemies.first { $0.id == templateId }
        }
    }

    private var dungeons: [Dungeon] {
        region.dungeonIds.compactMap { dungeonId in
            DungeonDatabase.dungeon(byId: dungeonId)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    regionHeader

                    // Task category info
                    if let category = region.taskCategory {
                        taskCategoryBanner(category)
                    }

                    // Enemies section
                    if !enemies.isEmpty {
                        enemiesSection
                    }

                    // Dungeons section
                    if !dungeons.isEmpty {
                        dungeonsSection
                    }

                    // Story chapters
                    if !region.storyChapterIds.isEmpty {
                        storySection
                    }

                    // Actions
                    actionsSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        region.biome.primaryColor.opacity(0.15),
                        Color(red: 0.1, green: 0.1, blue: 0.15)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(region.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(region.biome.accentColor)
                }
            }
        }
        .fullScreenCover(isPresented: $showQuickBattle) {
            QuickBattleView(regionId: region.id)
                .environmentObject(gameManager)
        }
        .sheet(isPresented: $showDungeons) {
            DungeonListView(regionId: region.id)
                .environmentObject(gameManager)
        }
    }

    // MARK: - Header

    private var regionHeader: some View {
        VStack(spacing: 12) {
            // Biome icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [region.biome.primaryColor, region.biome.accentColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: region.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }

            Text(region.subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            // Level range + biome badge
            HStack(spacing: 12) {
                Label("Lv \(region.levelRange.lowerBound)-\(region.levelRange.upperBound)", systemImage: "star.fill")
                    .font(.caption.bold())
                    .foregroundColor(.yellow)

                Label(region.biome.rawValue.capitalized, systemImage: region.biome.icon)
                    .font(.caption.bold())
                    .foregroundColor(region.biome.primaryColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
            )

            // Travel energy (if parent mode enabled)
            if gameManager.parentTaskManager.settings.isEnabled {
                let energy = gameManager.worldMapManager.energyForRegion(region.id)
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                    Text("Travel Energy: \(energy)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.2))
                )
            }
        }
    }

    // MARK: - Task Category Banner

    private func taskCategoryBanner(_ category: TaskCategory) -> some View {
        HStack(spacing: 8) {
            Text(category.icon)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Linked to \(category.rawValue) tasks")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text("Complete \(category.rawValue) tasks to earn travel energy here")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(category.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(category.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Enemies Section

    private var enemiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Enemies", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundColor(.red)

            ForEach(enemies, id: \.id) { enemy in
                HStack(spacing: 12) {
                    Text(enemy.avatar)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(enemy.name)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Text("Tier \(enemy.tier) \u{2022} Lv \(enemy.levelRange.lowerBound)-\(enemy.levelRange.upperBound)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        StatPill(icon: "heart.fill", value: "\(enemy.baseHP)", color: .red)
                        StatPill(icon: "burst.fill", value: "\(enemy.baseAttack)", color: .orange)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
    }

    // MARK: - Dungeons Section

    private var dungeonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Dungeons", systemImage: "building.columns.fill")
                .font(.headline)
                .foregroundColor(.orange)

            ForEach(dungeons, id: \.id) { dungeon in
                HStack(spacing: 12) {
                    Image(systemName: "building.columns.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(dungeon.name)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Text("\(dungeon.floors.count) floors \u{2022} Lv \(dungeon.levelRequirement)+")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
    }

    // MARK: - Story Section

    private var storySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Story", systemImage: "book.fill")
                .font(.headline)
                .foregroundColor(.purple)

            ForEach(region.storyChapterIds, id: \.self) { chapterId in
                if let chapter = gameManager.getChapter(chapterId) {
                    HStack(spacing: 12) {
                        Image(systemName: chapter.isCompleted ? "checkmark.circle.fill" : (chapter.isUnlocked ? "play.circle.fill" : "lock.circle.fill"))
                            .font(.title2)
                            .foregroundColor(chapter.isCompleted ? .green : (chapter.isUnlocked ? .purple : .gray))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(chapter.title)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            Text(chapter.isCompleted ? "Completed" : (chapter.isUnlocked ? "Available" : "Locked"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Battle button
            if !enemies.isEmpty {
                Button {
                    showQuickBattle = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.title3)
                        Text("Battle Here")
                            .font(.headline)
                        Spacer()
                        Text("1 Energy")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.yellow.opacity(0.3)))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [region.biome.primaryColor.opacity(0.6), region.biome.accentColor.opacity(0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Dungeon button
            if !dungeons.isEmpty {
                Button {
                    showDungeons = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "building.columns.fill")
                            .font(.title3)
                        Text("Enter Dungeon")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.5), Color.red.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
