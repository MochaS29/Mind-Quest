import SwiftUI

// MARK: - SwiftUI VFX View
// Pure SwiftUI particle-based visual effects for all 15 effect types.
// Auto-plays on appear and disappears after the specified duration.

struct SwiftUIVFXView: View {
    let effectId: String
    let color: Color
    let duration: Double

    @State private var animate = false
    @State private var opacity: Double = 1.0

    private let particleCount = 12

    var body: some View {
        ZStack {
            effectContent
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: duration)) {
                animate = true
            }
            // Fade out near the end
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.7) {
                withAnimation(.easeOut(duration: duration * 0.3)) {
                    opacity = 0
                }
            }
        }
    }

    // MARK: - Effect Router

    @ViewBuilder
    private var effectContent: some View {
        switch effectId {
        case "fire":       fireEffect
        case "ice":        iceEffect
        case "shadow":     shadowEffect
        case "lightning":  lightningEffect
        case "nature":     natureEffect
        case "holy":       holyEffect
        case "heal":       healEffect
        case "shield":     shieldEffect
        case "slash":      slashEffect
        case "poison":     poisonEffect
        case "stun":       stunEffect
        case "bleed":      bleedEffect
        case "buff":       buffEffect
        case "debuff":     debuffEffect
        case "impact":     impactEffect
        default:           impactEffect
        }
    }

    // MARK: - Fire: orange/red particles rising

    private var fireEffect: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                let xOffset = CGFloat.random(in: -40...40)
                Image(systemName: "flame.fill")
                    .font(.system(size: CGFloat.random(in: 12...24)))
                    .foregroundColor(i % 2 == 0 ? .orange : .red)
                    .offset(
                        x: xOffset,
                        y: animate ? CGFloat.random(in: -80 ... -30) : 0
                    )
                    .opacity(animate ? 0.0 : 1.0)
                    .scaleEffect(animate ? 0.3 : 1.0)
                    .animation(
                        .easeOut(duration: duration).delay(Double(i) * 0.03),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Ice: blue shards scattering outward

    private var iceEffect: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                let angle = Double(i) / Double(particleCount) * .pi * 2
                Image(systemName: "rhombus.fill")
                    .font(.system(size: CGFloat.random(in: 8...16)))
                    .foregroundColor(i % 3 == 0 ? .white : color)
                    .rotationEffect(.degrees(Double(i * 30)))
                    .offset(
                        x: animate ? CGFloat(cos(angle)) * 60 : 0,
                        y: animate ? CGFloat(sin(angle)) * 60 : 0
                    )
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        .easeOut(duration: duration).delay(Double(i) * 0.02),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Shadow: purple particles imploding

    private var shadowEffect: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                let angle = Double(i) / Double(particleCount) * .pi * 2
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .offset(
                        x: animate ? 0 : CGFloat(cos(angle)) * 70,
                        y: animate ? 0 : CGFloat(sin(angle)) * 70
                    )
                    .opacity(animate ? 0.8 : 0.3)
                    .scaleEffect(animate ? 0.1 : 1.0)
                    .animation(
                        .easeIn(duration: duration).delay(Double(i) * 0.02),
                        value: animate
                    )
            }

            // Central dark pulse
            Circle()
                .fill(Color.black.opacity(0.6))
                .frame(width: animate ? 50 : 0, height: animate ? 50 : 0)
                .opacity(animate ? 0.0 : 0.8)
                .animation(.easeOut(duration: duration * 0.5).delay(duration * 0.3), value: animate)
        }
    }

    // MARK: - Lightning: yellow bolt flash

    private var lightningEffect: some View {
        ZStack {
            // Bright flash overlay
            Rectangle()
                .fill(color.opacity(animate ? 0.0 : 0.6))
                .animation(.easeOut(duration: duration * 0.3), value: animate)

            // Bolt symbol
            Image(systemName: "bolt.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .scaleEffect(animate ? 1.5 : 0.5)
                .opacity(animate ? 0.0 : 1.0)
                .animation(.easeOut(duration: duration), value: animate)

            // Spark particles
            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) / 6.0 * .pi * 2
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .offset(
                        x: animate ? CGFloat(cos(angle)) * 50 : 0,
                        y: animate ? CGFloat(sin(angle)) * 50 : 0
                    )
                    .opacity(animate ? 0.0 : 0.8)
                    .animation(
                        .easeOut(duration: duration * 0.6).delay(duration * 0.1),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Nature: green leaves floating up

    private var natureEffect: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                Image(systemName: "leaf.fill")
                    .font(.system(size: CGFloat.random(in: 10...20)))
                    .foregroundColor(i % 2 == 0 ? color : .green)
                    .rotationEffect(.degrees(animate ? Double(i * 60) : 0))
                    .offset(
                        x: CGFloat.random(in: -50...50),
                        y: animate ? CGFloat.random(in: -80 ... -40) : CGFloat.random(in: 0...20)
                    )
                    .opacity(animate ? 0.0 : 0.9)
                    .animation(
                        .easeOut(duration: duration).delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Holy: white/gold radial burst

    private var holyEffect: some View {
        ZStack {
            // Radial burst
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) / 8.0 * .pi * 2
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.white, color],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: animate ? 40 : 8)
                    .offset(
                        x: animate ? CGFloat(cos(angle)) * 50 : 0,
                        y: animate ? CGFloat(sin(angle)) * 50 : 0
                    )
                    .rotationEffect(.degrees(Double(i) * 45))
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(.easeOut(duration: duration), value: animate)
            }

            // Center glow
            Circle()
                .fill(Color.white)
                .frame(width: animate ? 80 : 10, height: animate ? 80 : 10)
                .opacity(animate ? 0.0 : 0.7)
                .animation(.easeOut(duration: duration * 0.6), value: animate)
        }
    }

    // MARK: - Heal: green sparkles floating up

    private var healEffect: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 10...18)))
                    .foregroundColor(i % 3 == 0 ? .white : color)
                    .offset(
                        x: CGFloat.random(in: -40...40),
                        y: animate ? CGFloat.random(in: -70 ... -30) : CGFloat.random(in: 10...30)
                    )
                    .opacity(animate ? 0.0 : 1.0)
                    .scaleEffect(animate ? 1.5 : 0.5)
                    .animation(
                        .easeOut(duration: duration).delay(Double(i) * 0.04),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Shield: blue circle expanding outward

    private var shieldEffect: some View {
        ZStack {
            Circle()
                .strokeBorder(color, lineWidth: animate ? 2 : 6)
                .frame(
                    width: animate ? 120 : 20,
                    height: animate ? 120 : 20
                )
                .opacity(animate ? 0.0 : 0.8)
                .animation(.easeOut(duration: duration), value: animate)

            Circle()
                .strokeBorder(color.opacity(0.5), lineWidth: animate ? 1 : 4)
                .frame(
                    width: animate ? 90 : 10,
                    height: animate ? 90 : 10
                )
                .opacity(animate ? 0.0 : 0.6)
                .animation(.easeOut(duration: duration).delay(0.1), value: animate)

            Image(systemName: "shield.fill")
                .font(.system(size: 30))
                .foregroundColor(color)
                .scaleEffect(animate ? 1.3 : 0.8)
                .opacity(animate ? 0.0 : 1.0)
                .animation(.easeOut(duration: duration * 0.8), value: animate)
        }
    }

    // MARK: - Slash: white arc sweeping across

    private var slashEffect: some View {
        ZStack {
            // Slash arc
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white, color, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: animate ? 160 : 20, height: 4)
                .rotationEffect(.degrees(animate ? -30 : 30))
                .opacity(animate ? 0.0 : 1.0)
                .animation(.easeOut(duration: duration), value: animate)

            // Secondary slash
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: animate ? 120 : 10, height: 2)
                .rotationEffect(.degrees(animate ? -15 : 45))
                .opacity(animate ? 0.0 : 0.7)
                .animation(.easeOut(duration: duration).delay(0.05), value: animate)
        }
    }

    // MARK: - Poison: green bubbles rising

    private var poisonEffect: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                let size = CGFloat.random(in: 6...16)
                Circle()
                    .fill(color.opacity(Double.random(in: 0.5...0.9)))
                    .frame(width: size, height: size)
                    .offset(
                        x: CGFloat.random(in: -35...35),
                        y: animate ? CGFloat.random(in: -60 ... -20) : CGFloat.random(in: 10...30)
                    )
                    .opacity(animate ? 0.0 : 1.0)
                    .scaleEffect(animate ? 1.5 : 0.8)
                    .animation(
                        .easeOut(duration: duration).delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Stun: yellow stars orbiting

    private var stunEffect: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                let baseAngle = Double(i) / 5.0 * .pi * 2
                Image(systemName: "star.fill")
                    .font(.system(size: CGFloat.random(in: 10...16)))
                    .foregroundColor(i % 2 == 0 ? color : .white)
                    .offset(
                        x: CGFloat(cos(baseAngle + (animate ? .pi : 0))) * 35,
                        y: CGFloat(sin(baseAngle + (animate ? .pi : 0))) * 35 - 10
                    )
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        .easeInOut(duration: duration).delay(Double(i) * 0.04),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Bleed: red drops falling

    private var bleedEffect: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                Image(systemName: "drop.fill")
                    .font(.system(size: CGFloat.random(in: 8...14)))
                    .foregroundColor(i % 3 == 0 ? Color(red: 0.6, green: 0.0, blue: 0.0) : color)
                    .offset(
                        x: CGFloat.random(in: -40...40),
                        y: animate ? CGFloat.random(in: 30...70) : CGFloat.random(in: -10...10)
                    )
                    .opacity(animate ? 0.0 : 0.9)
                    .animation(
                        .easeIn(duration: duration).delay(Double(i) * 0.04),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Buff: cyan upward arrows

    private var buffEffect: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Image(systemName: "arrow.up")
                    .font(.system(size: CGFloat.random(in: 12...20)).weight(.bold))
                    .foregroundColor(i % 2 == 0 ? color : .white)
                    .offset(
                        x: CGFloat.random(in: -30...30),
                        y: animate ? CGFloat.random(in: -70 ... -30) : 0
                    )
                    .opacity(animate ? 0.0 : 0.9)
                    .animation(
                        .easeOut(duration: duration).delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Debuff: gray downward arrows

    private var debuffEffect: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Image(systemName: "arrow.down")
                    .font(.system(size: CGFloat.random(in: 12...20)).weight(.bold))
                    .foregroundColor(i % 2 == 0 ? color : Color(white: 0.4))
                    .offset(
                        x: CGFloat.random(in: -30...30),
                        y: animate ? CGFloat.random(in: 30...70) : 0
                    )
                    .opacity(animate ? 0.0 : 0.9)
                    .animation(
                        .easeOut(duration: duration).delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Impact: orange burst expanding

    private var impactEffect: some View {
        ZStack {
            // Central burst
            Circle()
                .fill(color)
                .frame(
                    width: animate ? 100 : 5,
                    height: animate ? 100 : 5
                )
                .opacity(animate ? 0.0 : 0.7)
                .animation(.easeOut(duration: duration * 0.5), value: animate)

            // Shockwave ring
            Circle()
                .strokeBorder(color, lineWidth: animate ? 1 : 4)
                .frame(
                    width: animate ? 130 : 10,
                    height: animate ? 130 : 10
                )
                .opacity(animate ? 0.0 : 0.6)
                .animation(.easeOut(duration: duration), value: animate)

            // Debris particles
            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) / 6.0 * .pi * 2
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .offset(
                        x: animate ? CGFloat(cos(angle)) * 55 : 0,
                        y: animate ? CGFloat(sin(angle)) * 55 : 0
                    )
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        .easeOut(duration: duration * 0.8).delay(0.05),
                        value: animate
                    )
            }
        }
    }
}

// MARK: - Preview

struct SwiftUIVFXView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            SwiftUIVFXView(effectId: "fire", color: .orange, duration: 1.0)
                .frame(width: 200, height: 200)
        }
        .previewDisplayName("Fire Effect")
    }
}
