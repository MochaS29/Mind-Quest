import SwiftUI

struct RegionNodeView: View {
    let region: MapRegion
    let isCurrentRegion: Bool
    let playerLevel: Int
    let dailyEnergy: Int
    let isParentModeEnabled: Bool
    let onTap: () -> Void

    @State private var isGlowing = false

    private var state: RegionState {
        if !region.isDiscovered { return .hidden }
        if region.isUnlocked && playerLevel >= region.unlockRequirements.minimumLevel {
            return isCurrentRegion ? .current : .unlocked
        }
        return .discovered
    }

    enum RegionState {
        case hidden, discovered, unlocked, current
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    // Glow effect for current/unlocked
                    if state == .current {
                        Circle()
                            .fill(region.biome.primaryColor.opacity(0.4))
                            .frame(width: 62, height: 62)
                            .blur(radius: 8)
                            .scaleEffect(isGlowing ? 1.2 : 1.0)
                    } else if state == .unlocked {
                        Circle()
                            .fill(region.biome.primaryColor.opacity(0.2))
                            .frame(width: 58, height: 58)
                            .blur(radius: 6)
                    }

                    // Main circle
                    Circle()
                        .fill(circleGradient)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(borderColor, lineWidth: state == .current ? 3 : 2)
                        )
                        .shadow(color: shadowColor, radius: state == .current ? 8 : 4)

                    // Icon
                    if state == .discovered {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    } else if state == .hidden {
                        Text("?")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.gray.opacity(0.5))
                    } else {
                        Image(systemName: region.icon)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }

                    // Energy badge
                    if isParentModeEnabled && dailyEnergy > 0 && state == .unlocked {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 8))
                            Text("\(dailyEnergy)")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.7))
                        )
                        .offset(x: 20, y: -20)
                    }
                }

                // Region name
                Text(region.name)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(state == .hidden ? .clear : (state == .discovered ? .gray.opacity(0.6) : .white.opacity(0.9)))
                    .lineLimit(1)
                    .frame(width: 80)

                // Level range
                if state != .hidden {
                    Text("Lv \(region.levelRange.lowerBound)-\(region.levelRange.upperBound)")
                        .font(.system(size: 7))
                        .foregroundColor(state == .discovered ? .gray.opacity(0.4) : .gray)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(state == .hidden ? 0.3 : (state == .discovered ? 0.6 : 1.0))
        .onAppear {
            if state == .current {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
        }
    }

    private var circleGradient: LinearGradient {
        switch state {
        case .current:
            return LinearGradient(
                colors: [region.biome.primaryColor, region.biome.accentColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .unlocked:
            return LinearGradient(
                colors: [region.biome.primaryColor.opacity(0.7), region.biome.accentColor.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .discovered:
            return LinearGradient(
                colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hidden:
            return LinearGradient(
                colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderColor: Color {
        switch state {
        case .current: return region.biome.accentColor
        case .unlocked: return region.biome.primaryColor.opacity(0.6)
        case .discovered: return .gray.opacity(0.3)
        case .hidden: return .gray.opacity(0.1)
        }
    }

    private var shadowColor: Color {
        switch state {
        case .current: return region.biome.primaryColor.opacity(0.6)
        case .unlocked: return region.biome.primaryColor.opacity(0.3)
        default: return .clear
        }
    }
}
