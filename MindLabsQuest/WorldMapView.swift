import SwiftUI

struct WorldMapView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedRegion: MapRegion?
    @State private var showRegionDetail = false
    @State private var selectedChapter: StoryChapter?
    @State private var showQuickBattle = false
    @State private var showDungeons = false
    @State private var showArena = false
    @State private var showMerchant = false
    @State private var showMapMissions = false

    private var regions: [MapRegion] {
        RegionDatabase.allRegions.map { region in
            var r = region
            r.isDiscovered = gameManager.worldMapManager.progress.discoveredRegionIds.contains(region.id)
            r.isUnlocked = gameManager.worldMapManager.progress.unlockedRegionIds.contains(region.id)
            return r
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.1, blue: 0.25),
                        Color(red: 0.1, green: 0.15, blue: 0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                StarsBackground()

                // Main map content
                VStack(spacing: 0) {
                    // Top bar
                    mapTopBar

                    // Map scroll area
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack {
                            // Path connections
                            GeometryReader { geo in
                                MapPathView(
                                    regions: regions,
                                    unlockedIds: gameManager.worldMapManager.progress.unlockedRegionIds,
                                    mapSize: geo.size
                                )
                            }

                            // Region nodes
                            GeometryReader { geo in
                                ForEach(regions, id: \.id) { region in
                                    RegionNodeView(
                                        region: region,
                                        isCurrentRegion: region.id == gameManager.worldMapManager.currentRegionId,
                                        playerLevel: gameManager.character.level,
                                        dailyEnergy: gameManager.worldMapManager.energyForRegion(region.id),
                                        isParentModeEnabled: gameManager.parentTaskManager.settings.isEnabled,
                                        onTap: {
                                            handleRegionTap(region)
                                        }
                                    )
                                    .position(
                                        x: region.position.x * geo.size.width,
                                        y: region.position.y * geo.size.height
                                    )
                                }
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height * 1.2)

                        // Activity buttons below the map
                        VStack(spacing: 12) {
                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.horizontal, 40)

                            // Arena Button
                            activityButton(
                                icon: "person.2.fill",
                                iconColor: .red,
                                title: "PvP Arena",
                                subtitle: "Battle opponents, climb the ranks!",
                                trailingContent: AnyView(
                                    HStack(spacing: 4) {
                                        Text(gameManager.arenaManager.stats.rank.emoji)
                                        Text("\(gameManager.arenaManager.stats.rating)")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.red.opacity(0.2)))
                                ),
                                gradientColors: [Color.red.opacity(0.5), Color.orange.opacity(0.3)],
                                borderColor: Color.red.opacity(0.4)
                            ) {
                                showArena = true
                            }

                            // Traveling Merchant
                            if gameManager.merchantManager.state.isPresent {
                                let daysLeft = gameManager.merchantManager.state.daysUntilDeparture
                                activityButton(
                                    icon: "cart.fill",
                                    iconColor: .teal,
                                    title: "Traveling Merchant",
                                    subtitle: gameManager.merchantManager.state.merchantName,
                                    trailingContent: AnyView(
                                        Text("Departs in \(daysLeft)d")
                                            .font(.caption.bold())
                                            .foregroundColor(.teal)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Capsule().fill(Color.teal.opacity(0.2)))
                                    ),
                                    gradientColors: [Color.teal.opacity(0.5), Color.green.opacity(0.3)],
                                    borderColor: Color.teal.opacity(0.4)
                                ) {
                                    showMerchant = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }

                // Gate overlay
                if !gameManager.isGameAccessible {
                    GateOverlayView()
                        .environmentObject(gameManager)
                }
            }
            .navigationTitle("Adventure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Aethermoor")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showRegionDetail) {
            if let region = selectedRegion {
                RegionDetailView(region: region)
                    .environmentObject(gameManager)
            }
        }
        .fullScreenCover(item: $selectedChapter) { chapter in
            ChapterIntroView(chapter: chapter)
                .environmentObject(gameManager)
        }
        .fullScreenCover(isPresented: $showArena) {
            ArenaView()
                .environmentObject(gameManager)
        }
        .sheet(isPresented: $showMerchant) {
            TravelingMerchantView()
                .environmentObject(gameManager)
        }
        .sheet(isPresented: $showMapMissions) {
            MapMissionView()
                .environmentObject(gameManager)
        }
        .overlay(
            Group {
                if gameManager.showStoryKeyEarned {
                    StoryKeyEarnedBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(), value: gameManager.showStoryKeyEarned)
        )
    }

    // MARK: - Top Bar

    private var mapTopBar: some View {
        HStack(spacing: 12) {
            // Story keys
            HStack(spacing: 6) {
                Image(systemName: "key.fill")
                    .foregroundColor(.yellow)
                Text("\(gameManager.storyProgress.storyKeys)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.4))
                    .overlay(Capsule().stroke(Color.yellow.opacity(0.3), lineWidth: 1))
            )

            Spacer()

            // Map missions badge (if parent mode enabled)
            if gameManager.parentTaskManager.settings.isEnabled {
                let pending = gameManager.parentTaskManager.todaysPendingTasks.count
                Button {
                    showMapMissions = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "scroll.fill")
                            .foregroundColor(.orange)
                        Text("Missions")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                        if pending > 0 {
                            Text("\(pending)")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                                .background(Circle().fill(Color.red))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                            .overlay(Capsule().stroke(Color.orange.opacity(0.3), lineWidth: 1))
                    )
                }
            }

            // Energy display
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                Text("\(gameManager.energyManager.currentEnergy)/\(gameManager.energyManager.maxEnergy)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.4))
                    .overlay(Capsule().stroke(Color.yellow.opacity(0.2), lineWidth: 1))
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Activity Button

    private func activityButton(icon: String, iconColor: Color, title: String, subtitle: String, trailingContent: AnyView, gradientColors: [Color], borderColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                trailingContent
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderColor, lineWidth: 1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Region Tap Handler

    private func handleRegionTap(_ region: MapRegion) {
        if region.isUnlocked {
            gameManager.worldMapManager.currentRegionId = region.id
            selectedRegion = region
            showRegionDetail = true
        }
    }
}

// MARK: - Stars Background
struct StarsBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
            }
        }
    }
}

// MARK: - Story Key Earned Banner
struct StoryKeyEarnedBanner: View {
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "key.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)

                Text("+1 Story Key!")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.yellow, lineWidth: 2)
                    )
            )

            Spacer()
        }
        .padding(.top, 60)
    }
}

// MARK: - Preview
struct WorldMapView_Previews: PreviewProvider {
    static var previews: some View {
        WorldMapView()
            .environmentObject(GameManager())
    }
}
