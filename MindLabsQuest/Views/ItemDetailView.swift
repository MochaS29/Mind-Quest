import SwiftUI

struct ItemDetailView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    let item: Item

    var isEquipped: Bool {
        gameManager.character.equipment.allEquipped.contains(where: { $0.id == item.id })
    }

    var canEquip: Bool {
        guard item.slot != nil else { return false }
        guard !isEquipped else { return false }
        guard gameManager.character.level >= item.levelRequirement else { return false }
        if let restrictions = item.classRestrictions, !restrictions.isEmpty {
            guard let charClass = gameManager.character.characterClass, restrictions.contains(charClass) else { return false }
        }
        return true
    }

    var isOwned: Bool {
        gameManager.character.inventory.contains(where: { $0.item.id == item.id }) || isEquipped
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Item header
                    itemHeader

                    // Stats section
                    if !item.statModifiers.isEmpty {
                        statsSection
                    }

                    // Consumable info
                    if item.type == .consumable {
                        consumableSection
                    }

                    // Description
                    descriptionSection

                    // Actions
                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.mindLabsPurple)
                }
            }
        }
    }

    private var itemHeader: some View {
        VStack(spacing: 12) {
            Text(item.icon)
                .font(.system(size: 60))

            Text(item.name)
                .font(MindLabsTypography.title())
                .foregroundColor(.mindLabsText)

            HStack(spacing: 8) {
                Text(item.rarity.rawValue)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(item.rarity.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(item.rarity.color.opacity(0.15))
                    .cornerRadius(8)

                Text(item.type.rawValue)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)

                if let slot = item.slot {
                    Text("(\(slot.rawValue))")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }

            if item.levelRequirement > 1 {
                HStack {
                    Image(systemName: gameManager.character.level >= item.levelRequirement ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(gameManager.character.level >= item.levelRequirement ? .mindLabsSuccess : .mindLabsError)
                    Text("Requires Level \(item.levelRequirement)")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(gameManager.character.level >= item.levelRequirement ? .mindLabsTextSecondary : .mindLabsError)
                }
            }

            if isEquipped {
                Text("EQUIPPED")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsSuccess)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.mindLabsSuccess.opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
    }

    private var statsSection: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Stat Bonuses")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)

                ForEach(item.statModifiers.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { stat, value in
                    HStack {
                        Text(stat.icon)
                        Text(stat.rawValue)
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        Spacer()
                        Text("+\(value)")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsSuccess)
                    }
                }
            }
        }
    }

    private var consumableSection: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Effect")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)

                if let heal = item.healAmount {
                    HStack {
                        Text("❤️")
                        Text("Restores \(heal) HP")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                    }
                }

                if let damage = item.battleDamage {
                    HStack {
                        Text("💥")
                        Text("Deals \(damage) damage")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                    }
                }

                if item.statusEffectCure != nil {
                    HStack {
                        Text("🧪")
                        Text("Cures status effects")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                    }
                }

                if let boost = item.tempStatBoost, let duration = item.tempBoostDuration {
                    ForEach(boost.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { stat, value in
                        HStack {
                            Text(stat.icon)
                            Text("+\(value) \(stat.rawValue) for \(duration) turns")
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)
                        }
                    }
                }
            }
        }
    }

    private var descriptionSection: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)

                Text(item.itemDescription)
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)

                Divider()

                HStack {
                    Text("Buy: \(item.buyPrice) 💰")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    Spacer()
                    Text("Sell: \(item.sellPrice) 💰")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }

                if let restrictions = item.classRestrictions, !restrictions.isEmpty {
                    HStack {
                        Text("Classes:")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        ForEach(restrictions, id: \.self) { cls in
                            Text("\(cls.icon)")
                        }
                    }
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if isOwned {
                if canEquip {
                    Button(action: {
                        _ = gameManager.equipItem(item)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "shield.fill")
                            Text("Equip")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mindLabsPurple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }

                if isEquipped, let slot = item.slot {
                    Button(action: {
                        _ = gameManager.unequipSlot(slot)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.square")
                            Text("Unequip")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mindLabsWarning)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }

                if item.type == .consumable && !isEquipped {
                    Button(action: {
                        _ = gameManager.useConsumable(item.id)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Use")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mindLabsSuccess)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }

                if !isEquipped && item.sellPrice > 0 {
                    Button(action: {
                        _ = gameManager.sellItem(item.id)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                            Text("Sell for \(item.sellPrice) Gold")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mindLabsError.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}
