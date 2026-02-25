import SwiftUI

// MARK: - VFX Backend
// Defines which rendering system a VFX effect uses.
// Currently only .swiftUI is implemented; others are future-proofed.
enum VFXBackend: String, Codable {
    case swiftUI
    case spriteSheet
    case lottie
    case rive
}

// MARK: - VFX Effect
// Describes a single visual effect with its rendering configuration.
struct VFXEffect {
    let id: String
    let backend: VFXBackend
    let assetName: String
    let duration: Double
    let tintColor: Color?
    let fallbackIcon: String   // SF Symbol name
    let fallbackColor: Color
}

// MARK: - VFX Service
// Backend-agnostic VFX dispatcher. Defines 15 effect templates and resolves
// which backend to use based on available assets.
enum VFXService {

    // MARK: - Effect Registry

    /// All 15 built-in effect templates. Default to .swiftUI backend.
    static let effects: [String: VFXEffect] = [
        "fire": VFXEffect(
            id: "fire",
            backend: .swiftUI,
            assetName: "vfx_fire",
            duration: 0.8,
            tintColor: nil,
            fallbackIcon: "flame.fill",
            fallbackColor: Color(red: 1.0, green: 0.4, blue: 0.1)
        ),
        "ice": VFXEffect(
            id: "ice",
            backend: .swiftUI,
            assetName: "vfx_ice",
            duration: 0.7,
            tintColor: nil,
            fallbackIcon: "snowflake",
            fallbackColor: Color(red: 0.4, green: 0.7, blue: 1.0)
        ),
        "shadow": VFXEffect(
            id: "shadow",
            backend: .swiftUI,
            assetName: "vfx_shadow",
            duration: 0.9,
            tintColor: nil,
            fallbackIcon: "moon.fill",
            fallbackColor: Color(red: 0.5, green: 0.2, blue: 0.7)
        ),
        "lightning": VFXEffect(
            id: "lightning",
            backend: .swiftUI,
            assetName: "vfx_lightning",
            duration: 0.4,
            tintColor: nil,
            fallbackIcon: "bolt.fill",
            fallbackColor: Color(red: 1.0, green: 0.9, blue: 0.2)
        ),
        "nature": VFXEffect(
            id: "nature",
            backend: .swiftUI,
            assetName: "vfx_nature",
            duration: 1.0,
            tintColor: nil,
            fallbackIcon: "leaf.fill",
            fallbackColor: Color(red: 0.3, green: 0.8, blue: 0.3)
        ),
        "holy": VFXEffect(
            id: "holy",
            backend: .swiftUI,
            assetName: "vfx_holy",
            duration: 0.8,
            tintColor: nil,
            fallbackIcon: "sparkles",
            fallbackColor: Color(red: 1.0, green: 0.95, blue: 0.7)
        ),
        "heal": VFXEffect(
            id: "heal",
            backend: .swiftUI,
            assetName: "vfx_heal",
            duration: 1.0,
            tintColor: nil,
            fallbackIcon: "heart.fill",
            fallbackColor: Color(red: 0.3, green: 0.9, blue: 0.4)
        ),
        "shield": VFXEffect(
            id: "shield",
            backend: .swiftUI,
            assetName: "vfx_shield",
            duration: 0.6,
            tintColor: nil,
            fallbackIcon: "shield.fill",
            fallbackColor: Color(red: 0.3, green: 0.6, blue: 1.0)
        ),
        "slash": VFXEffect(
            id: "slash",
            backend: .swiftUI,
            assetName: "vfx_slash",
            duration: 0.4,
            tintColor: nil,
            fallbackIcon: "burst.fill",
            fallbackColor: Color(red: 0.9, green: 0.9, blue: 0.95)
        ),
        "poison": VFXEffect(
            id: "poison",
            backend: .swiftUI,
            assetName: "vfx_poison",
            duration: 1.0,
            tintColor: nil,
            fallbackIcon: "drop.fill",
            fallbackColor: Color(red: 0.2, green: 0.8, blue: 0.2)
        ),
        "stun": VFXEffect(
            id: "stun",
            backend: .swiftUI,
            assetName: "vfx_stun",
            duration: 0.8,
            tintColor: nil,
            fallbackIcon: "star.fill",
            fallbackColor: Color(red: 1.0, green: 0.85, blue: 0.1)
        ),
        "bleed": VFXEffect(
            id: "bleed",
            backend: .swiftUI,
            assetName: "vfx_bleed",
            duration: 0.9,
            tintColor: nil,
            fallbackIcon: "drop.fill",
            fallbackColor: Color(red: 0.9, green: 0.1, blue: 0.1)
        ),
        "buff": VFXEffect(
            id: "buff",
            backend: .swiftUI,
            assetName: "vfx_buff",
            duration: 0.7,
            tintColor: nil,
            fallbackIcon: "arrow.up.circle.fill",
            fallbackColor: Color(red: 0.0, green: 0.8, blue: 0.9)
        ),
        "debuff": VFXEffect(
            id: "debuff",
            backend: .swiftUI,
            assetName: "vfx_debuff",
            duration: 0.7,
            tintColor: nil,
            fallbackIcon: "arrow.down.circle.fill",
            fallbackColor: Color(red: 0.5, green: 0.5, blue: 0.5)
        ),
        "impact": VFXEffect(
            id: "impact",
            backend: .swiftUI,
            assetName: "vfx_impact",
            duration: 0.5,
            tintColor: nil,
            fallbackIcon: "burst.fill",
            fallbackColor: Color(red: 1.0, green: 0.6, blue: 0.1)
        )
    ]

    // MARK: - Resolve Effect

    /// Resolves the rendering backend for an effect. If a custom asset exists for the
    /// effect's configured backend (sprite sheet, Lottie, Rive), it returns as-is.
    /// Otherwise, falls back to a .swiftUI copy of the effect.
    static func resolve(_ effectId: String) -> VFXEffect {
        guard let effect = effects[effectId] else {
            // Unknown effect: return a generic impact
            return effects["impact"]!
        }

        switch effect.backend {
        case .swiftUI:
            return effect

        case .spriteSheet:
            // Check if sprite sheet frames exist
            if UIImage(named: "\(effect.assetName)_01") != nil {
                return effect
            }
            return swiftUIFallback(for: effect)

        case .lottie:
            // Check if Lottie JSON asset exists in the bundle
            if Bundle.main.path(forResource: effect.assetName, ofType: "json") != nil {
                return effect
            }
            return swiftUIFallback(for: effect)

        case .rive:
            // Check if Rive asset exists in the bundle
            if Bundle.main.path(forResource: effect.assetName, ofType: "riv") != nil {
                return effect
            }
            return swiftUIFallback(for: effect)
        }
    }

    // MARK: - Element Mapping

    /// Maps an ElementalType (from BattleModels) to the corresponding VFX effect ID.
    static func effectType(for element: ElementalType) -> String {
        switch element {
        case .physical:  return "impact"
        case .fire:      return "fire"
        case .ice:       return "ice"
        case .shadow:    return "shadow"
        case .lightning: return "lightning"
        case .nature:    return "nature"
        case .holy:      return "holy"
        }
    }

    // MARK: - Convenience

    /// Resolves the VFX effect for a given elemental type in one step.
    static func effectForElement(_ element: ElementalType) -> VFXEffect {
        return resolve(effectType(for: element))
    }

    /// Returns all available effect IDs, sorted alphabetically.
    static var allEffectIds: [String] {
        return effects.keys.sorted()
    }

    /// Maps a CombatAbility SF Symbol icon to the best VFX effect ID.
    static func effectIdForIcon(_ icon: String) -> String {
        switch icon {
        case "flame.fill", "flame":                         return "fire"
        case "snowflake":                                   return "ice"
        case "bolt.fill", "bolt":                           return "lightning"
        case "leaf.fill", "leaf":                           return "nature"
        case "sun.max.fill", "sun.max":                     return "holy"
        case "moon.fill", "moon":                           return "shadow"
        case "cross.fill", "heart.fill":                    return "heal"
        case "shield.fill", "shield":                       return "shield"
        case "drop.fill":                                   return "bleed"
        case "aqi.medium", "aqi.low":                       return "poison"
        case "star.fill":                                   return "stun"
        case "arrow.up.circle", "arrow.up.circle.fill":     return "buff"
        case "arrow.down.circle", "arrow.down.circle.fill": return "debuff"
        default:                                            return "slash"
        }
    }

    // MARK: - Private

    /// Creates a SwiftUI-backend copy of the given effect (for fallback).
    private static func swiftUIFallback(for effect: VFXEffect) -> VFXEffect {
        return VFXEffect(
            id: effect.id,
            backend: .swiftUI,
            assetName: effect.assetName,
            duration: effect.duration,
            tintColor: effect.tintColor,
            fallbackIcon: effect.fallbackIcon,
            fallbackColor: effect.fallbackColor
        )
    }
}
