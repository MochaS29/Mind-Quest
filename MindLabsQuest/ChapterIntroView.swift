import SwiftUI

struct ChapterIntroView: View {
    let chapter: StoryChapter
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss

    @State private var showBackground = false
    @State private var showChapterNumber = false
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showButton = false
    @State private var titleScale: CGFloat = 0.5
    @State private var navigateToStory = false

    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
                .opacity(showBackground ? 1 : 0)

            // Particles/stars effect
            if showBackground {
                ParticleEffect()
            }

            // Content
            VStack(spacing: 30) {
                Spacer()

                // Chapter number
                if showChapterNumber {
                    Text(chapterNumber)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .tracking(4)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }

                // Chapter title
                if showTitle {
                    Text(chapter.title)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .scaleEffect(titleScale)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                }

                // Description
                if showDescription {
                    Text(chapter.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity)
                }

                Spacer()

                // Begin button
                if showButton {
                    Button(action: {
                        navigateToStory = true
                    }) {
                        HStack(spacing: 12) {
                            Text("Begin Chapter")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .pulsingAnimation()
                }

                // Skip button
                if showButton {
                    Button("Back to Map") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                }

                Spacer()
                    .frame(height: 50)
            }
        }
        .fullScreenCover(isPresented: $navigateToStory) {
            StoryPlayerView(chapter: chapter)
                .environmentObject(gameManager)
        }
        .onAppear {
            startAnimation()
        }
    }

    private var chapterNumber: String {
        let id = chapter.id
        if id.contains("1") {
            return "CHAPTER ONE"
        } else if id.contains("2a") {
            return "CHAPTER TWO - PATH A"
        } else if id.contains("2b") {
            return "CHAPTER TWO - PATH B"
        } else if id.contains("2") {
            return "CHAPTER TWO"
        } else if id.contains("3") {
            return "CHAPTER THREE"
        }
        return "CHAPTER"
    }

    private func startAnimation() {
        // Background fade in
        withAnimation(.easeIn(duration: 0.8)) {
            showBackground = true
        }

        // Chapter number
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                showChapterNumber = true
            }
        }

        // Title with scale
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showTitle = true
                titleScale = 1.0
            }
        }

        // Description
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeIn(duration: 0.5)) {
                showDescription = true
            }
        }

        // Button
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showButton = true
            }
        }
    }
}

// MARK: - Particle Effect
struct ParticleEffect: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: Double
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.purple.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                // Create initial particles
                for _ in 0..<30 {
                    particles.append(Particle(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height),
                        size: CGFloat.random(in: 2...6),
                        opacity: Double.random(in: 0.2...0.6),
                        speed: Double.random(in: 0.5...2)
                    ))
                }

                // Animate particles
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    for i in 0..<particles.count {
                        particles[i].y -= particles[i].speed
                        if particles[i].y < -10 {
                            particles[i].y = geometry.size.height + 10
                            particles[i].x = CGFloat.random(in: 0...geometry.size.width)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Pulsing Animation Modifier
struct PulsingModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.02 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func pulsingAnimation() -> some View {
        modifier(PulsingModifier())
    }
}

// MARK: - Preview
struct ChapterIntroView_Previews: PreviewProvider {
    static var previews: some View {
        ChapterIntroView(chapter: StoryContent.chapter1)
            .environmentObject(GameManager())
    }
}
