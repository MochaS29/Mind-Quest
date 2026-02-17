import SwiftUI

struct QuestCompletionView: View {
    let quest: Quest
    let xpEarned: Int
    let goldEarned: Int
    let onDismiss: () -> Void
    
    @State private var showCheckmark = false
    @State private var showTitle = false
    @State private var showRewards = false
    @State private var checkmarkScale = 0.1
    @State private var sparkleRotation = 0.0
    @State private var rewardScale = 0.1
    @State private var glowPulse = 0.8
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    if showRewards {
                        onDismiss()
                    }
                }
            
            VStack(spacing: 30) {
                // Animated checkmark with sparkles
                ZStack {
                    // Glowing background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.mindLabsSuccess.opacity(0.5),
                                    Color.mindLabsSuccess.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(glowPulse)
                        .blur(radius: 10)
                    
                    // Rotating sparkles
                    ForEach(0..<6) { index in
                        Image(systemName: "sparkle")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .offset(x: 70)
                            .rotationEffect(.degrees(Double(index) * 60 + sparkleRotation))
                            .opacity(showCheckmark ? 1 : 0)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .delay(Double(index) * 0.1),
                                value: showCheckmark
                            )
                    }
                    .rotationEffect(.degrees(sparkleRotation))
                    
                    // Checkmark circle
                    ZStack {
                        Circle()
                            .fill(Color.mindLabsSuccess)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                            )
                            .shadow(color: Color.mindLabsSuccess.opacity(0.5), radius: 15)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(checkmarkScale)
                }
                
                // Quest completion text
                if showTitle {
                    VStack(spacing: 10) {
                        Text("QUEST COMPLETE!")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.mindLabsPurple)
                            .shadow(color: .mindLabsPurple.opacity(0.3), radius: 10)
                        
                        Text(quest.title)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Rewards
                if showRewards {
                    VStack(spacing: 20) {
                        // XP Reward
                        RewardRow(
                            icon: "star.fill",
                            iconColor: .mindLabsBlue,
                            label: "Experience",
                            value: "+\(xpEarned) XP",
                            scale: rewardScale,
                            delay: 0.1
                        )
                        
                        // Gold Reward
                        RewardRow(
                            icon: "bitcoinsign.circle.fill",
                            iconColor: .yellow,
                            label: "Gold",
                            value: "+\(goldEarned)",
                            scale: rewardScale,
                            delay: 0.2
                        )
                        
                        // Stats increased (if applicable)
                        if let questTemplate = quest.questTemplate {
                            RewardRow(
                                icon: questTemplate.category.primaryStat.icon,
                                iconColor: questTemplate.category.color,
                                label: questTemplate.category.primaryStat.rawValue,
                                value: "+1",
                                scale: rewardScale,
                                delay: 0.3
                            )
                        }
                    }
                    .padding()
                    .background(Color.mindLabsCard)
                    .cornerRadius(15)
                    .mindLabsCardShadow()
                    .scaleEffect(rewardScale)
                }
                
                // Continue button
                if showRewards {
                    Button(action: onDismiss) {
                        Text("Continue")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(LinearGradient.mindLabsPrimary)
                            .cornerRadius(25)
                            .mindLabsButtonShadow()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Checkmark animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showCheckmark = true
            checkmarkScale = 1.0
        }
        
        // Glow pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowPulse = 1.2
        }
        
        // Sparkle rotation
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }
        
        // Show title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        // Show rewards
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showRewards = true
                rewardScale = 1.0
            }
        }
    }
}

struct RewardRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let scale: CGFloat
    let delay: Double
    
    @State private var show = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
                
                Text(value)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
            }
            
            Spacer()
            
            // Animated plus sign
            Text("+")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(iconColor)
                .opacity(show ? 1 : 0)
                .scaleEffect(show ? 1 : 2)
                .animation(.spring(response: 0.4).delay(delay + 0.3), value: show)
        }
        .padding(.horizontal)
        .opacity(show ? 1 : 0)
        .offset(y: show ? 0 : 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    show = true
                }
            }
        }
    }
}

// MARK: - Mini Quest Completion Toast
struct QuestCompletionToast: View {
    let quest: Quest
    @State private var show = false
    @State private var offset: CGFloat = -100
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundColor(.mindLabsSuccess)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Quest Complete!")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Text(quest.title)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(quest.xpReward) XP")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsBlue)
                
                Text("+\(quest.goldReward) Gold")
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
        .mindLabsCardShadow()
        .offset(y: offset)
        .opacity(show ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                show = true
                offset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    show = false
                    offset = -100
                }
            }
        }
    }
}

struct QuestCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestCompletionView(
            quest: Quest(
                title: "Complete Math Homework",
                category: .academic,
                difficulty: .medium
            ),
            xpEarned: 50,
            goldEarned: 25,
            onDismiss: { }
        )
    }
}