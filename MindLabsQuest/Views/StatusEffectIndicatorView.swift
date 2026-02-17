import SwiftUI

// MARK: - Status Effect Row
struct StatusEffectRow: View {
    let effects: [StatusEffect]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(effects) { effect in
                StatusEffectBadge(effect: effect)
            }
        }
    }
}

// MARK: - Status Effect Badge
struct StatusEffectBadge: View {
    let effect: StatusEffect
    @State private var showTooltip = false

    var body: some View {
        Button {
            showTooltip.toggle()
        } label: {
            ZStack(alignment: .topTrailing) {
                // Icon circle
                Text(effect.type.icon)
                    .font(.system(size: 14))
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(effect.type.color.opacity(0.3))
                            .overlay(
                                Circle()
                                    .stroke(effect.type.color, lineWidth: 1.5)
                            )
                    )

                // Duration counter
                if effect.duration > 0 {
                    Text("\(effect.duration)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 14, height: 14)
                        .background(Circle().fill(Color.black.opacity(0.7)))
                        .offset(x: 3, y: -3)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showTooltip) {
            StatusEffectTooltip(effect: effect)
        }
    }
}

// MARK: - Status Effect Tooltip
struct StatusEffectTooltip: View {
    let effect: StatusEffect

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(effect.type.icon)
                    .font(.title3)
                Text(effect.type.rawValue)
                    .font(.headline)
                    .foregroundColor(effect.type.color)
            }

            if !effect.sourceDescription.isEmpty {
                Text(effect.sourceDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack {
                if effect.value > 0 {
                    Label {
                        Text(effectValueDescription)
                            .font(.caption)
                    } icon: {
                        Image(systemName: effect.type.isDebuff ? "arrow.down.circle" : "arrow.up.circle")
                            .foregroundColor(effect.type.isDebuff ? .red : .green)
                    }
                }

                Spacer()

                Label {
                    Text("\(effect.duration) turn\(effect.duration == 1 ? "" : "s")")
                        .font(.caption)
                } icon: {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .frame(width: 200)
    }

    private var effectValueDescription: String {
        switch effect.type {
        case .poison, .burn, .bleed:
            return "\(effect.value) dmg/turn"
        case .regenerate:
            return "+\(effect.value) HP/turn"
        case .strengthen:
            return "+\(effect.value) ATK"
        case .weaken:
            return "-\(effect.value) ATK"
        case .shield:
            return "+\(effect.value) DEF"
        case .stun:
            return "Skips turn"
        }
    }
}
