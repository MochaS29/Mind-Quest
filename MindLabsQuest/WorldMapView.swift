import SwiftUI

struct WorldMapView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedChapter: StoryChapter?
    @State private var showChapterIntro = false
    @State private var showUnlockConfirmation = false
    @State private var chapterToUnlock: StoryChapter?
    @State private var showQuickBattle = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
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

                // Stars background
                StarsBackground()

                VStack(spacing: 0) {
                    // Header with story keys
                    storyKeyHeader

                    // Chapter path
                    ScrollView {
                        VStack(spacing: 0) {
                            if gameManager.storyChapters.isEmpty {
                                Text("Loading story...")
                                    .foregroundColor(.gray)
                                    .padding(.top, 50)
                            }

                            ForEach(Array(gameManager.storyChapters.enumerated()), id: \.element.id) { index, chapter in
                                VStack(spacing: 0) {
                                    ChapterNode(
                                        chapter: chapter,
                                        isFirst: index == 0,
                                        onTap: {
                                            handleChapterTap(chapter)
                                        },
                                        onUnlock: {
                                            chapterToUnlock = chapter
                                            showUnlockConfirmation = true
                                        }
                                    )
                                    .environmentObject(gameManager)

                                    // Path connector (except for last chapter)
                                    if index < gameManager.storyChapters.count - 1 {
                                        PathConnector(isUnlocked: chapter.isCompleted)
                                    }
                                }
                            }

                            // Mystery chapters coming soon
                            VStack(spacing: 0) {
                                PathConnector(isUnlocked: false)
                                MysteryChapterNode()
                            }

                            // Quick Battle Section
                            VStack(spacing: 16) {
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                    .padding(.horizontal, 40)

                                Button {
                                    showQuickBattle = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "bolt.fill")
                                            .font(.title2)
                                            .foregroundColor(.yellow)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Quick Battle")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("Test your strength!")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        // Energy display
                                        HStack(spacing: 4) {
                                            Image(systemName: "bolt.fill")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                            Text("\(gameManager.energyManager.currentEnergy)/\(gameManager.energyManager.maxEnergy)")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.yellow.opacity(0.2))
                                        )
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 20)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Adventure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Adventure")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .fullScreenCover(isPresented: $showChapterIntro) {
            if let chapter = selectedChapter {
                ChapterIntroView(chapter: chapter)
                    .environmentObject(gameManager)
            }
        }
        .fullScreenCover(isPresented: $showQuickBattle) {
            QuickBattleView()
                .environmentObject(gameManager)
        }
        .alert("Unlock Chapter?", isPresented: $showUnlockConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Unlock") {
                if let chapter = chapterToUnlock {
                    _ = gameManager.unlockChapter(chapter.id)
                }
            }
        } message: {
            if let chapter = chapterToUnlock {
                Text("Spend \(chapter.unlockRequirements.tasksRequired) Story Keys to unlock \"\(chapter.title)\"?")
            }
        }
        .overlay(
            // Story key earned notification
            Group {
                if gameManager.showStoryKeyEarned {
                    StoryKeyEarnedBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(), value: gameManager.showStoryKeyEarned)
        )
    }

    // MARK: - Story Key Header
    private var storyKeyHeader: some View {
        HStack {
            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "key.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)

                Text("\(gameManager.storyProgress.storyKeys)")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Story Keys")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )

            Spacer()
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }

    // MARK: - Handle Chapter Tap
    private func handleChapterTap(_ chapter: StoryChapter) {
        if chapter.isUnlocked {
            selectedChapter = chapter
            showChapterIntro = true
        }
    }
}

// MARK: - Chapter Node
struct ChapterNode: View {
    let chapter: StoryChapter
    let isFirst: Bool
    let onTap: () -> Void
    let onUnlock: () -> Void
    @EnvironmentObject var gameManager: GameManager

    @State private var isGlowing = false

    var body: some View {
        Button(action: {
            if chapter.isUnlocked {
                onTap()
            } else if gameManager.canUnlockChapter(chapter.id) {
                onUnlock()
            }
        }) {
            VStack(spacing: 12) {
                // Chapter circle
                ZStack {
                    // Outer glow for unlocked chapters
                    if chapter.isUnlocked && !chapter.isCompleted {
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .blur(radius: 10)
                            .scaleEffect(isGlowing ? 1.1 : 1.0)
                    }

                    // Main circle
                    Circle()
                        .fill(circleGradient)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(borderColor, lineWidth: 3)
                        )
                        .shadow(color: shadowColor, radius: 10)

                    // Icon
                    chapterIcon
                }

                // Chapter info
                VStack(spacing: 4) {
                    Text(chapter.title)
                        .font(.headline)
                        .foregroundColor(chapter.isUnlocked ? .white : .gray)

                    if chapter.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("COMPLETED")
                        }
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    } else if chapter.isUnlocked {
                        Text("Tap to play")
                            .font(.caption)
                            .foregroundColor(.purple)
                    } else {
                        let keysNeeded = gameManager.keysNeededForChapter(chapter.id)
                        if keysNeeded > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                Text("Need \(keysNeeded) more keys")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        } else if gameManager.canUnlockChapter(chapter.id) {
                            Text("Tap to unlock!")
                                .font(.caption.bold())
                                .foregroundColor(.yellow)
                        } else {
                            Text("Complete previous chapter")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if chapter.isUnlocked && !chapter.isCompleted {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
        }
    }

    private var circleGradient: LinearGradient {
        if chapter.isCompleted {
            return LinearGradient(
                colors: [Color.green.opacity(0.8), Color.green.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if chapter.isUnlocked {
            return LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderColor: Color {
        if chapter.isCompleted {
            return .green
        } else if chapter.isUnlocked {
            return .purple
        } else if gameManager.canUnlockChapter(chapter.id) {
            return .yellow
        } else {
            return .gray.opacity(0.5)
        }
    }

    private var shadowColor: Color {
        if chapter.isCompleted {
            return .green.opacity(0.5)
        } else if chapter.isUnlocked {
            return .purple.opacity(0.5)
        } else {
            return .clear
        }
    }

    @ViewBuilder
    private var chapterIcon: some View {
        if chapter.isCompleted {
            Image(systemName: "checkmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
        } else if chapter.isUnlocked {
            Image(systemName: "play.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
        } else {
            Image(systemName: "lock.fill")
                .font(.system(size: 24))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Path Connector
struct PathConnector: View {
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(isUnlocked ? Color.green.opacity(0.6) : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .frame(height: 40)
    }
}

// MARK: - Mystery Chapter Node
struct MysteryChapterNode: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )

                Text("???")
                    .font(.title)
                    .foregroundColor(.gray)
            }

            Text("More chapters coming soon...")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(.vertical, 10)
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
