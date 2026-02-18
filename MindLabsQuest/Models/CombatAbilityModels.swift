import Foundation
import SwiftUI

// MARK: - Combat Ability Effect
enum CombatAbilityEffect: Equatable {
    case heal(percent: Double)
    case stun(turns: Int)
    case burn(damage: Int, turns: Int)
    case poison(damage: Int, turns: Int)
    case shield(damageReduction: Double)
    case lifesteal(percent: Double)
    case strengthen(value: Int, turns: Int)
    case weaken(value: Int, turns: Int)
    case reflect(percent: Double)
    case bleed(damage: Int, turns: Int)
    case regenerate(value: Int, turns: Int)
}

// MARK: - Combat Ability
struct CombatAbility: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String // SF Symbol
    let description: String
    let damageMultiplier: Double // 1.0 = base, 0.0 = no damage (pure defensive)
    let effect: CombatAbilityEffect?
    let cooldown: Int // turns between uses, 0 = no cooldown
    let unlockTier: Int // 0 = always available, 1/2/3 = requires skill tree tier
    let branch: SkillBranch
    let isDefensive: Bool

    var isOffensive: Bool { !isDefensive && damageMultiplier > 0 }

    var effectTag: String {
        guard let effect = effect else {
            if isDefensive { return "Defend" }
            return "\(String(format: "%.0f", damageMultiplier * 100))%"
        }
        switch effect {
        case .heal: return "Heal"
        case .stun: return "Stun"
        case .burn: return "Burn"
        case .poison: return "Poison"
        case .shield: return "Shield"
        case .lifesteal: return "Drain"
        case .strengthen: return "Buff"
        case .weaken: return "Debuff"
        case .reflect: return "Reflect"
        case .bleed: return "Bleed"
        case .regenerate: return "Regen"
        }
    }

    var effectColor: Color {
        guard let effect = effect else {
            return isDefensive ? .blue : .red
        }
        switch effect {
        case .heal, .regenerate: return .green
        case .stun: return .yellow
        case .burn: return .orange
        case .poison: return .green
        case .shield, .reflect: return .blue
        case .lifesteal: return .purple
        case .strengthen: return .cyan
        case .weaken: return .gray
        case .bleed: return .red
        }
    }
}
