import SwiftUI

struct CosmeticsView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedType: CosmeticType = .title

    var cosmeticsManager: CosmeticsManager {
        gameManager.cosmeticsManager
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary
                    MindLabsCard {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.mindLabsPurple)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Cosmetics Collection")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                                Text("\(cosmeticsManager.unlockedCount)/\(cosmeticsManager.totalCount) unlocked")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            Spacer()
                        }
                    }

                    // Type Picker
                    Picker("Type", selection: $selectedType) {
                        ForEach(CosmeticType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Cosmetic Items
                    let items = CosmeticDatabase.cosmetics(of: selectedType)
                    ForEach(items) { cosmetic in
                        CosmeticItemCard(cosmetic: cosmetic)
                    }
                }
                .padding()
            }
            .navigationTitle("Cosmetics")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.mindLabsPurple))
        }
    }
}

// MARK: - Cosmetic Item Card
struct CosmeticItemCard: View {
    @EnvironmentObject var gameManager: GameManager
    let cosmetic: CosmeticItem

    var isUnlocked: Bool {
        gameManager.cosmeticsManager.unlockedCosmeticIds.contains(cosmetic.id)
    }

    var isEquipped: Bool {
        switch cosmetic.type {
        case .title:
            return gameManager.cosmeticsManager.loadout.equippedTitle == cosmetic.id
        case .border:
            return gameManager.cosmeticsManager.loadout.equippedBorder == cosmetic.id
        case .battleEffect:
            return gameManager.cosmeticsManager.loadout.equippedBattleEffect == cosmetic.id
        }
    }

    var body: some View {
        MindLabsCard {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isUnlocked ? cosmetic.rarity.color.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)

                    if isUnlocked {
                        Image(systemName: cosmetic.icon)
                            .font(.title2)
                            .foregroundColor(cosmetic.rarity.color)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(cosmetic.name)
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(isUnlocked ? .mindLabsText : .mindLabsTextSecondary)

                        Text(cosmetic.rarity.rawValue)
                            .font(.system(size: 10))
                            .foregroundColor(cosmetic.rarity.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(cosmetic.rarity.color.opacity(0.15))
                            .cornerRadius(4)
                    }

                    Text(isUnlocked ? cosmetic.description : cosmetic.unlockRequirement.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)

                    if let displayText = cosmetic.displayText, isUnlocked {
                        Text("\"\(displayText)\"")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsPurple)
                    }
                }

                Spacer()

                // Action
                if isUnlocked {
                    if isEquipped {
                        Button("Unequip") {
                            gameManager.cosmeticsManager.unequip(type: cosmetic.type)
                        }
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray)
                        .cornerRadius(8)
                    } else {
                        Button("Equip") {
                            gameManager.cosmeticsManager.equip(cosmetic.id)
                        }
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.mindLabsPurple)
                        .cornerRadius(8)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
        }
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}
