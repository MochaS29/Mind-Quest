import SwiftUI

struct StoryChoiceView: View {
    let node: StoryNode
    let onChoiceMade: (StoryChoice) -> Void

    @State private var showDialogue = true
    @State private var showChoices = false
    @State private var selectedChoice: StoryChoice?
    @State private var currentDialogueIndex = 0
    @State private var displayedText = ""
    @State private var isTyping = false

    private let typingSpeed: Double = 0.03

    var body: some View {
        ZStack {
            // Background
            backgroundView

            VStack {
                Spacer()

                if showDialogue {
                    dialogueSection
                }

                if showChoices {
                    choicesSection
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            startDialogue()
        }
        .onTapGesture {
            if showDialogue && !showChoices {
                handleDialogueTap()
            }
        }
    }

    // MARK: - Background
    @ViewBuilder
    private var backgroundView: some View {
        if let bgImage = node.backgroundImage {
            Image(bgImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.5))
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.25),
                    Color(red: 0.1, green: 0.05, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Dialogue Section
    private var dialogueSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let dialogue = node.dialogue, currentDialogueIndex < dialogue.count {
                let line = dialogue[currentDialogueIndex]

                // Speaker info
                if line.speaker != "Narrator" {
                    HStack(spacing: 12) {
                        // Avatar placeholder
                        if let avatar = line.speakerAvatar {
                            Image(avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.purple, lineWidth: 2))
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.6))
                                    .frame(width: 50, height: 50)
                                Text(String(line.speaker.prefix(1)))
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                            }
                        }

                        Text(line.speaker)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }

                // Dialogue text
                Text(displayedText)
                    .font(line.speaker == "Narrator" ? .body.italic() : .body)
                    .foregroundColor(line.speaker == "Narrator" ? .gray : .white)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Continue indicator
            if !isTyping && !showChoices {
                HStack {
                    Spacer()
                    Text("Tap to continue")
                        .font(.caption)
                        .foregroundColor(.purple.opacity(0.8))
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.purple.opacity(0.8))
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, showChoices ? 16 : 40)
    }

    // MARK: - Choices Section
    private var choicesSection: some View {
        VStack(spacing: 16) {
            Text("What will you do?")
                .font(.headline)
                .foregroundColor(.gray)

            if let choices = node.choices {
                ForEach(choices) { choice in
                    ChoiceButton(
                        choice: choice,
                        isSelected: selectedChoice?.id == choice.id
                    ) {
                        selectChoice(choice)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.9))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    // MARK: - Dialogue Logic
    private func startDialogue() {
        guard let dialogue = node.dialogue, !dialogue.isEmpty else {
            showChoicesWithAnimation()
            return
        }

        typeCurrentLine()
    }

    private func typeCurrentLine() {
        guard let dialogue = node.dialogue, currentDialogueIndex < dialogue.count else {
            showChoicesWithAnimation()
            return
        }

        let fullText = dialogue[currentDialogueIndex].text
        displayedText = ""
        isTyping = true

        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if charIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                displayedText += String(fullText[index])
                charIndex += 1
            } else {
                timer.invalidate()
                isTyping = false
            }
        }
    }

    private func handleDialogueTap() {
        if isTyping {
            // Skip to end of current line
            if let dialogue = node.dialogue, currentDialogueIndex < dialogue.count {
                displayedText = dialogue[currentDialogueIndex].text
                isTyping = false
            }
        } else {
            // Advance to next line
            if let dialogue = node.dialogue, currentDialogueIndex < dialogue.count - 1 {
                currentDialogueIndex += 1
                typeCurrentLine()
            } else {
                // Show choices
                showChoicesWithAnimation()
            }
        }
    }

    private func showChoicesWithAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showChoices = true
        }
    }

    private func selectChoice(_ choice: StoryChoice) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedChoice = choice
        }

        // Delay before transitioning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onChoiceMade(choice)
        }
    }
}

// MARK: - Choice Button
struct ChoiceButton: View {
    let choice: StoryChoice
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    // Icon
                    if let iconName = choice.icon {
                        Image(systemName: iconName)
                            .font(.title2)
                            .foregroundColor(isSelected ? .white : .purple)
                            .frame(width: 40)
                    }

                    // Choice text
                    VStack(alignment: .leading, spacing: 4) {
                        Text(choice.text)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

                        Text(choice.consequence)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(isSelected ? .white : .purple.opacity(0.6))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.purple : Color.purple.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.purple : Color.purple.opacity(0.4), lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Preview
struct StoryChoiceView_Previews: PreviewProvider {
    static var sampleNode = StoryNode(
        id: UUID(),
        type: .choice,
        title: "The Decision",
        dialogue: [
            DialogueLine(speaker: "Elder Maren", speakerAvatar: nil, text: "What will you do?", emotion: nil)
        ],
        battle: nil,
        choices: [
            StoryChoice(
                text: "Defend the Village",
                consequence: "The villagers will become your allies.",
                icon: "shield.fill",
                leadsToChapterId: "chapter_2a"
            ),
            StoryChoice(
                text: "Pursue the Source",
                consequence: "You may find answers alone.",
                icon: "magnifyingglass",
                leadsToChapterId: "chapter_2b"
            )
        ],
        backgroundImage: nil,
        nextNodeId: nil
    )

    static var previews: some View {
        StoryChoiceView(node: sampleNode, onChoiceMade: { _ in })
    }
}
