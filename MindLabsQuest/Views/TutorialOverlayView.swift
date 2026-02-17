import SwiftUI

struct TutorialOverlayView: View {
    @EnvironmentObject var gameManager: GameManager

    var tutorialManager: TutorialManager {
        gameManager.tutorialManager
    }

    var body: some View {
        if let step = tutorialManager.currentStep {
            ZStack {
                // Semi-transparent backdrop
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Dismiss on tap outside
                    }

                // Tutorial card
                VStack(spacing: 20) {
                    Spacer()

                    VStack(spacing: 16) {
                        // Step indicator dots
                        if let tutorial = tutorialManager.activeTutorial {
                            HStack(spacing: 6) {
                                ForEach(0..<tutorial.steps.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == tutorialManager.state.currentStepIndex ? Color.mindLabsPurple : Color.mindLabsBorder)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }

                        // Title
                        Text(step.title)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                            .multilineTextAlignment(.center)

                        // Message
                        Text(step.message)
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsTextSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        // Buttons
                        HStack(spacing: 15) {
                            Button(action: {
                                tutorialManager.skipTutorial()
                            }) {
                                Text("Skip")
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsTextSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.mindLabsBorder.opacity(0.2))
                                    .cornerRadius(10)
                            }

                            Button(action: {
                                HapticService.selection()
                                tutorialManager.advanceStep()
                            }) {
                                Text(step.action == .dismiss ? "Got it!" : "Next")
                                    .font(MindLabsTypography.subheadline())
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(LinearGradient.mindLabsPrimary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.mindLabsCard)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, y: 10)
                    .padding(.horizontal, 30)

                    Spacer()
                        .frame(height: 80) // space for tab bar
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: tutorialManager.activeTutorial?.id)
        }
    }
}
