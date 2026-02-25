import SwiftUI

// MARK: - Asset Service
// Checks for custom art assets in the asset catalog, falling back to emoji/SF Symbols.
// When custom art is added later, it will be picked up automatically by name convention:
//   enemy_{templateId}, item_{icon}, region_{regionId}, story_{name}, npc_{name}

enum AssetService {

    // MARK: - Enemy Image

    /// Returns a view for the enemy. Checks for "enemy_{templateId}" in the asset catalog,
    /// falls back to the emoji scaled up as a large centered label.
    static func enemyImage(templateId: String, fallbackEmoji: String) -> AnyView {
        let assetName = "enemy_\(templateId)"
        if let uiImage = UIImage(named: assetName) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            )
        }
        return AnyView(
            Text(fallbackEmoji)
                .font(.system(size: 80))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.3),
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
    }

    // MARK: - Item Image

    /// Returns a view for an item. Checks for "item_{icon}" in the asset catalog,
    /// falls back to rendering the icon string (emoji) as text.
    static func itemImage(icon: String) -> AnyView {
        let assetName = "item_\(icon)"
        if let uiImage = UIImage(named: assetName) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            )
        }
        return AnyView(
            Text(icon)
                .font(.system(size: 36))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }

    // MARK: - Region Background

    /// Returns a background view for a map region. Checks for "region_{regionId}" in the
    /// asset catalog, falls back to a gradient derived from the biome colors.
    static func regionBackground(regionId: String, biome: RegionBiome) -> AnyView {
        let assetName = "region_\(regionId)"
        if let uiImage = UIImage(named: assetName) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            )
        }
        return AnyView(
            ZStack {
                LinearGradient(
                    colors: [
                        biome.primaryColor,
                        biome.accentColor,
                        biome.primaryColor.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Overlay pattern using the biome SF Symbol
                VStack(spacing: 30) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 40) {
                            ForEach(0..<4, id: \.self) { col in
                                Image(systemName: biome.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.08))
                                    .rotationEffect(.degrees(Double((row + col) * 15)))
                            }
                        }
                    }
                }
            }
        )
    }

    // MARK: - Story Background

    /// Returns a background view for story scenes. Checks for "story_{name}" in the
    /// asset catalog, falls back to a dark atmospheric gradient.
    static func storyBackground(name: String) -> AnyView {
        let assetName = "story_\(name)"
        if let uiImage = UIImage(named: assetName) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            )
        }

        let gradient = storyGradient(for: name)
        return AnyView(
            ZStack {
                LinearGradient(
                    colors: gradient,
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Subtle vignette overlay
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.4)
                    ],
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
            }
        )
    }

    // MARK: - NPC Portrait

    /// Returns a portrait view for NPCs. Checks for "npc_{name}" in the asset catalog,
    /// falls back to the emoji in a styled circle frame.
    static func npcPortrait(name: String, fallbackEmoji: String) -> AnyView {
        let assetName = "npc_\(name)"
        if let uiImage = UIImage(named: assetName) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            )
        }
        return AnyView(
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.25),
                                Color(white: 0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )

                Text(fallbackEmoji)
                    .font(.system(size: 40))
            }
        )
    }

    // MARK: - Private Helpers

    /// Maps story background names to thematic gradient colors.
    private static func storyGradient(for name: String) -> [Color] {
        let lowered = name.lowercased()
        if lowered.contains("forest") || lowered.contains("nature") {
            return [
                Color(red: 0.05, green: 0.15, blue: 0.05),
                Color(red: 0.1, green: 0.3, blue: 0.1),
                Color(red: 0.05, green: 0.1, blue: 0.05)
            ]
        } else if lowered.contains("cave") || lowered.contains("dungeon") || lowered.contains("hollow") {
            return [
                Color(red: 0.08, green: 0.05, blue: 0.12),
                Color(red: 0.15, green: 0.1, blue: 0.2),
                Color(red: 0.05, green: 0.03, blue: 0.08)
            ]
        } else if lowered.contains("village") || lowered.contains("town") {
            return [
                Color(red: 0.15, green: 0.12, blue: 0.08),
                Color(red: 0.25, green: 0.2, blue: 0.12),
                Color(red: 0.1, green: 0.08, blue: 0.05)
            ]
        } else if lowered.contains("battle") || lowered.contains("arena") {
            return [
                Color(red: 0.2, green: 0.05, blue: 0.05),
                Color(red: 0.35, green: 0.1, blue: 0.1),
                Color(red: 0.15, green: 0.03, blue: 0.03)
            ]
        } else if lowered.contains("ice") || lowered.contains("frozen") {
            return [
                Color(red: 0.1, green: 0.15, blue: 0.25),
                Color(red: 0.2, green: 0.3, blue: 0.45),
                Color(red: 0.08, green: 0.1, blue: 0.2)
            ]
        } else {
            // Default dark atmosphere
            return [
                Color(red: 0.08, green: 0.08, blue: 0.12),
                Color(red: 0.15, green: 0.12, blue: 0.2),
                Color(red: 0.05, green: 0.05, blue: 0.08)
            ]
        }
    }
}
