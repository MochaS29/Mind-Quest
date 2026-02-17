import SwiftUI

// MARK: - Story Player View
/// Main view that orchestrates playing through a chapter's nodes
struct StoryPlayerView: View {
    let chapter: StoryChapter
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss

    @State private var currentNodeIndex = 0
    @State private var showBattle = false
    @State private var showChoice = false
    @State private var showChapterComplete = false
    @State private var selectedChoice: StoryChoice?

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            if currentNodeIndex < chapter.nodes.count {
                let node = chapter.nodes[currentNodeIndex]

                switch node.type {
                case .dialogue, .exploration:
                    StoryDialogueView(
                        node: node,
                        onComplete: {
                            advanceToNextNode()
                        }
                    )

                case .battle:
                    if let battle = node.battle {
                        BattleView(
                            encounter: battle,
                            onComplete: { victory in
                                if victory {
                                    gameManager.completeBattle(victory: true)
                                    advanceToNextNode()
                                } else {
                                    // Handle defeat - could retry or end chapter
                                    dismiss()
                                }
                            },
                            gameManager: gameManager
                        )
                    }

                case .choice:
                    StoryChoiceView(
                        node: node,
                        onChoiceMade: { choice in
                            selectedChoice = choice
                            handleChoice(choice)
                        }
                    )

                case .checkpoint, .reward:
                    ChapterCompleteView(
                        chapter: chapter,
                        onDismiss: {
                            gameManager.completeChapter(chapter.id, choiceMade: selectedChoice?.text)
                            dismiss()
                        }
                    )
                }
            } else {
                // Chapter complete
                ChapterCompleteView(
                    chapter: chapter,
                    onDismiss: {
                        gameManager.completeChapter(chapter.id, choiceMade: selectedChoice?.text)
                        dismiss()
                    }
                )
            }
        }
    }

    private func advanceToNextNode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentNodeIndex < chapter.nodes.count - 1 {
                currentNodeIndex += 1
            } else {
                // Show chapter complete
                showChapterComplete = true
            }
        }
    }

    private func handleChoice(_ choice: StoryChoice) {
        // Record the choice
        selectedChoice = choice

        // If choice leads to a different chapter, complete current and note the path
        if choice.leadsToChapterId != nil {
            gameManager.storyProgress.choicesMade[chapter.id] = choice.id.uuidString
            gameManager.saveStoryProgress()

            // Advance to checkpoint/reward node if there is one
            advanceToNextNode()
        } else if choice.leadsToNodeId != nil {
            // Find and go to that node (for internal branching)
            advanceToNextNode()
        } else {
            advanceToNextNode()
        }
    }
}

// MARK: - Story Dialogue View
/// Visual novel style dialogue presentation
struct StoryDialogueView: View {
    let node: StoryNode
    let onComplete: () -> Void

    @State private var currentLineIndex = 0
    @State private var displayedText = ""
    @State private var isTyping = false
    @State private var showContinueIndicator = false

    private let typingSpeed: Double = 0.03

    var body: some View {
        ZStack {
            // Background image or gradient
            backgroundView

            VStack {
                Spacer()

                // Dialogue box
                dialogueBox
            }
        }
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            startTyping()
        }
    }

    // MARK: - Background
    @ViewBuilder
    private var backgroundView: some View {
        if let bgImage = node.backgroundImage {
            // Try to load image, fall back to gradient
            Image(bgImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.3))
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.1, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Dialogue Box
    private var dialogueBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let dialogue = node.dialogue, currentLineIndex < dialogue.count {
                let line = dialogue[currentLineIndex]

                // Speaker avatar and name
                HStack(alignment: .bottom, spacing: 12) {
                    // Avatar
                    if let avatar = line.speakerAvatar {
                        avatarView(for: avatar)
                    } else if line.speaker != "Narrator" {
                        defaultAvatarView(for: line.speaker)
                    }

                    // Speaker name
                    if line.speaker != "Narrator" {
                        Text(line.speaker)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.purple.opacity(0.6))
                            )
                    }

                    Spacer()

                    // Node progress
                    if let dialogue = node.dialogue {
                        Text("\(currentLineIndex + 1)/\(dialogue.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                // Dialogue text
                VStack(alignment: .leading, spacing: 8) {
                    Text(displayedText)
                        .font(line.speaker == "Narrator" ? .body.italic() : .body)
                        .foregroundColor(line.speaker == "Narrator" ? .gray : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(4)

                    // Continue indicator
                    if showContinueIndicator {
                        HStack {
                            Spacer()
                            Text("Tap to continue")
                                .font(.caption)
                                .foregroundColor(.purple)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                        .transition(.opacity)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 30)
    }

    // MARK: - Avatar Views
    @ViewBuilder
    private func avatarView(for imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.purple, lineWidth: 2)
            )
    }

    private func defaultAvatarView(for speaker: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.purple.opacity(0.6))
                .frame(width: 60, height: 60)

            Text(String(speaker.prefix(1)))
                .font(.title2.bold())
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(Color.purple, lineWidth: 2)
        )
    }

    // MARK: - Typing Animation
    private func startTyping() {
        guard let dialogue = node.dialogue, currentLineIndex < dialogue.count else {
            onComplete()
            return
        }

        let fullText = dialogue[currentLineIndex].text
        displayedText = ""
        isTyping = true
        showContinueIndicator = false

        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if charIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                displayedText += String(fullText[index])
                charIndex += 1
            } else {
                timer.invalidate()
                isTyping = false
                withAnimation(.easeIn(duration: 0.3)) {
                    showContinueIndicator = true
                }
            }
        }
    }

    private func handleTap() {
        if isTyping {
            // Skip to full text
            if let dialogue = node.dialogue, currentLineIndex < dialogue.count {
                displayedText = dialogue[currentLineIndex].text
                isTyping = false
                showContinueIndicator = true
            }
        } else {
            // Advance to next line
            if let dialogue = node.dialogue, currentLineIndex < dialogue.count - 1 {
                currentLineIndex += 1
                startTyping()
            } else {
                // Node complete
                onComplete()
            }
        }
    }
}

// MARK: - Chapter Complete View
struct ChapterCompleteView: View {
    let chapter: StoryChapter
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var showRewards = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Celebration particles
            CelebrationParticles()

            VStack(spacing: 30) {
                Spacer()

                if showContent {
                    // Chapter complete banner
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)

                        Text("Chapter Complete!")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        Text(chapter.title)
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if showRewards {
                    // Rewards
                    VStack(spacing: 16) {
                        Text("Rewards Earned")
                            .font(.headline)
                            .foregroundColor(.gray)

                        HStack(spacing: 30) {
                            // XP
                            VStack {
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                Text("+\(chapter.rewards.xp) XP")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }

                            // Gold
                            VStack {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.orange)
                                Text("+\(chapter.rewards.gold) Gold")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }

                            // Story Key
                            VStack {
                                Image(systemName: "key.fill")
                                    .font(.title)
                                    .foregroundColor(.purple)
                                Text("+1 Key")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()

                if showButton {
                    Button(action: onDismiss) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.purple)
                            )
                    }
                    .transition(.opacity)
                }

                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            showContent = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8)) {
            showRewards = true
        }
        withAnimation(.easeIn(duration: 0.3).delay(1.3)) {
            showButton = true
        }
    }
}

// MARK: - Celebration Particles
struct CelebrationParticles: View {
    @State private var particles: [CelebrationParticle] = []

    struct CelebrationParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var rotation: Double
        var speed: Double
    }

    let colors: [Color] = [.yellow, .purple, .orange, .pink, .blue]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 2)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                // Create confetti
                for _ in 0..<40 {
                    particles.append(CelebrationParticle(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: -20,
                        size: CGFloat.random(in: 4...8),
                        color: colors.randomElement() ?? .yellow,
                        rotation: Double.random(in: 0...360),
                        speed: Double.random(in: 2...5)
                    ))
                }

                // Animate
                Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                    for i in 0..<particles.count {
                        particles[i].y += particles[i].speed
                        particles[i].rotation += 5
                        particles[i].x += CGFloat.random(in: -1...1)

                        if particles[i].y > geometry.size.height + 20 {
                            particles[i].y = -20
                            particles[i].x = CGFloat.random(in: 0...geometry.size.width)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct StoryDialogueView_Previews: PreviewProvider {
    static var previews: some View {
        StoryPlayerView(chapter: StoryContent.chapter1)
            .environmentObject(GameManager())
    }
}
