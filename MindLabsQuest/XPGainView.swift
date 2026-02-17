import SwiftUI

struct XPGainView: View {
    let xpAmount: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.mindLabsBlue)
            
            Text("+\(xpAmount) XP")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsBlue)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.mindLabsBlue.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color.mindLabsBlue.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offset)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                offset = -80
                opacity = 0
                scale = 1.2
            }
        }
    }
}

struct GoldGainView: View {
    let goldAmount: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            
            Text("+\(goldAmount)")
                .font(MindLabsTypography.caption())
                .foregroundColor(.yellow)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offset)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).delay(0.1)) {
                offset = -80
                opacity = 0
                scale = 1.2
            }
        }
    }
}

// MARK: - Floating Rewards Container
struct FloatingRewardsView: View {
    let xpGain: Int
    let goldGain: Int
    let position: CGPoint
    
    var body: some View {
        VStack(spacing: 8) {
            XPGainView(xpAmount: xpGain)
            GoldGainView(goldAmount: goldGain)
        }
        .position(position)
    }
}

// MARK: - Quick XP Bar Animation
struct XPBarView: View {
    let currentXP: Int
    let xpToNext: Int
    let level: Int
    @State private var animatedXP: Double = 0
    
    private var progress: Double {
        Double(currentXP) / Double(xpToNext)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Level \(level)")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
                
                Text("\(currentXP) / \(xpToNext) XP")
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.mindLabsBorder.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient.mindLabsPrimary)
                        .frame(width: geometry.size.width * animatedXP, height: 8)
                        .overlay(
                            // Shine effect
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.clear,
                                            Color.white.opacity(0.3)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        )
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            animateXP()
        }
        .onChange(of: currentXP) { _ in
            animateXP()
        }
    }
    
    private func animateXP() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animatedXP = progress
        }
    }
}

// MARK: - Stat Increase Animation
struct StatIncreaseView: View {
    let stat: StatType
    let increase: Int
    @State private var show = false
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        HStack(spacing: 5) {
            Text(stat.icon)
                .font(.caption)
            
            Text("+\(increase)")
                .font(MindLabsTypography.caption())
                .foregroundColor(stat.color)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(stat.color.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(stat.color.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(opacity)
        .offset(y: offset)
        .scaleEffect(show ? 1 : 0.1)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                show = true
            }
            
            withAnimation(.easeOut(duration: 2).delay(1)) {
                offset = -60
                opacity = 0
            }
        }
    }
}

// MARK: - Health Restoration Animation
struct HealthRestoreView: View {
    let healthRestored: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "heart.fill")
                .font(.caption)
                .foregroundColor(.mindLabsError)
            
            Text("+\(healthRestored)")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsError)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.mindLabsError.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color.mindLabsError.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offset)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).delay(0.2)) {
                offset = -80
                opacity = 0
                scale = 1.2
            }
        }
    }
}

struct XPGainView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            XPGainView(xpAmount: 50)
            GoldGainView(goldAmount: 25)
            StatIncreaseView(stat: .intelligence, increase: 1)
            HealthRestoreView(healthRestored: 5)
            
            XPBarView(currentXP: 150, xpToNext: 200, level: 3)
                .padding()
        }
        .padding()
        .background(Color.mindLabsBackground)
    }
}