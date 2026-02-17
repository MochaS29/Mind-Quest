import SwiftUI

struct LevelUpView: View {
    let newLevel: Int
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var particleScale = 0.0
    @State private var starRotation = 0.0
    @State private var glowOpacity = 0.0
    @State private var textScale = 0.1
    @State private var confettiOffset = -50.0
    @State private var showStats = false
    @State private var showRewards = false
    
    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    if showRewards {
                        onDismiss()
                    }
                }
            
            // Background particles
            ParticleSystemView()
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: showContent)
            
            VStack(spacing: 30) {
                // Level up badge with animations
                ZStack {
                    // Glowing background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.mindLabsPurple.opacity(0.6),
                                    Color.mindLabsPurple.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 20)
                        .opacity(glowOpacity)
                        .scaleEffect(particleScale)
                    
                    // Rotating stars
                    ForEach(0..<8) { index in
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .offset(x: 100)
                            .rotationEffect(.degrees(Double(index) * 45 + starRotation))
                            .opacity(showContent ? 1 : 0)
                            .animation(
                                .easeInOut(duration: 2)
                                .delay(Double(index) * 0.1),
                                value: showContent
                            )
                    }
                    .rotationEffect(.degrees(starRotation))
                    
                    // Level badge
                    ZStack {
                        Circle()
                            .fill(LinearGradient.mindLabsPrimary)
                            .frame(width: 150, height: 150)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                            )
                            .shadow(color: Color.mindLabsPurple.opacity(0.5), radius: 20)
                        
                        VStack(spacing: 5) {
                            Text("LEVEL")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(3)
                            
                            Text("\(newLevel)")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(textScale)
                }
                
                // Level up text with animation
                VStack(spacing: 10) {
                    Text("LEVEL UP!")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.mindLabsPurple)
                        .shadow(color: .mindLabsPurple.opacity(0.3), radius: 10)
                        .scaleEffect(showStats ? 1 : 0.8)
                        .opacity(showStats ? 1 : 0)
                    
                    Text("Congratulations, Hero!")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                        .opacity(showStats ? 1 : 0)
                }
                
                // Stats increase animation
                if showStats {
                    VStack(spacing: 15) {
                        StatIncreaseRow(
                            icon: "❤️",
                            stat: "Max Health",
                            value: "+10",
                            delay: 0.1
                        )
                        
                        StatIncreaseRow(
                            icon: "💰",
                            stat: "Gold Bonus",
                            value: "+\(newLevel * 10)",
                            delay: 0.2
                        )
                        
                        StatIncreaseRow(
                            icon: "⚡",
                            stat: "New Skills",
                            value: "Unlocked!",
                            delay: 0.3
                        )
                    }
                    .padding()
                    .background(Color.mindLabsCard)
                    .cornerRadius(15)
                    .mindLabsCardShadow()
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Continue button
                if showRewards {
                    Button(action: onDismiss) {
                        Text("Continue Adventure")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(LinearGradient.mindLabsPrimary)
                            .cornerRadius(25)
                            .mindLabsButtonShadow()
                            .scaleEffect(showRewards ? 1 : 0.8)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Confetti overlay
            ConfettiView()
                .offset(y: confettiOffset)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Initial delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
                textScale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.0)) {
                glowOpacity = 1.0
                particleScale = 1.2
            }
            
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                starRotation = 360
            }
            
            withAnimation(.easeOut(duration: 1.5)) {
                confettiOffset = UIScreen.main.bounds.height
            }
        }
        
        // Show stats
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showStats = true
            }
        }
        
        // Show continue button
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showRewards = true
            }
        }
    }
}

// MARK: - Stat Increase Row
struct StatIncreaseRow: View {
    let icon: String
    let stat: String
    let value: String
    let delay: Double
    
    @State private var show = false
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            Text(stat)
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsText)
            
            Spacer()
            
            Text(value)
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsPurple)
        }
        .padding(.horizontal)
        .opacity(show ? 1 : 0)
        .offset(x: show ? 0 : 50)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    show = true
                }
            }
        }
    }
}

// MARK: - Particle System
struct ParticleSystemView: View {
    @State private var particles: [Particle] = []
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Image(systemName: particle.symbol)
                        .font(.system(size: particle.size))
                        .foregroundColor(particle.color)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .onAppear {
                createInitialParticles(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateParticles()
                if particles.count < 30 {
                    addParticle(in: geometry.size)
                }
            }
        }
    }
    
    private func createInitialParticles(in size: CGSize) {
        for _ in 0..<20 {
            particles.append(Particle(in: size))
        }
    }
    
    private func updateParticles() {
        for index in particles.indices {
            particles[index].update()
            
            if particles[index].opacity <= 0 {
                particles[index] = Particle(in: UIScreen.main.bounds.size)
            }
        }
    }
    
    private func addParticle(in size: CGSize) {
        particles.append(Particle(in: size))
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    var rotation: Double = 0
    let symbol: String
    let color: Color
    let size: CGFloat
    let velocity: CGVector
    let rotationSpeed: Double
    
    init(in containerSize: CGSize) {
        position = CGPoint(
            x: CGFloat.random(in: 0...containerSize.width),
            y: CGFloat.random(in: 0...containerSize.height)
        )
        
        symbol = ["star.fill", "sparkle", "circle.fill"].randomElement()!
        color = [Color.mindLabsPurple, Color.mindLabsPink, Color.yellow, Color.blue].randomElement()!
        size = CGFloat.random(in: 10...25)
        
        velocity = CGVector(
            dx: CGFloat.random(in: -50...50),
            dy: CGFloat.random(in: -100...(-30))
        )
        
        rotationSpeed = Double.random(in: -180...180)
    }
    
    mutating func update() {
        position.x += velocity.dx * 0.02
        position.y += velocity.dy * 0.02
        opacity -= 0.01
        rotation += rotationSpeed * 0.02
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    let confettiColors: [Color] = [
        .mindLabsPurple,
        .mindLabsPink,
        .mindLabsBlue,
        .mindLabsSuccess,
        .yellow,
        .orange
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50) { index in
                    ConfettiPiece(
                        color: confettiColors.randomElement()!,
                        size: CGFloat.random(in: 5...15),
                        delay: Double(index) * 0.01
                    )
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: -50...0)
                    )
                }
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGFloat
    let delay: Double
    
    @State private var rotation = 0.0
    @State private var offsetY = 0.0
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(rotation))
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 2...4))
                    .delay(delay)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
                
                withAnimation(
                    .easeIn(duration: Double.random(in: 1.5...3))
                    .delay(delay)
                ) {
                    offsetY = UIScreen.main.bounds.height + 100
                }
            }
    }
}

struct LevelUpView_Previews: PreviewProvider {
    static var previews: some View {
        LevelUpView(newLevel: 5) { }
    }
}