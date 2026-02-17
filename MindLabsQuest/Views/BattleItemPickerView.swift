import SwiftUI

struct BattleItemPickerView: View {
    let inventory: [InventoryEntry]
    let onSelectItem: (UUID) -> Void
    @Environment(\.dismiss) var dismiss

    var consumables: [InventoryEntry] {
        inventory.filter { $0.item.type == .consumable }
    }

    var body: some View {
        NavigationView {
            Group {
                if consumables.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bag")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No consumable items")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Find items by defeating enemies or visit the shop.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(consumables) { entry in
                            Button {
                                onSelectItem(entry.item.id)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    // Item icon
                                    Text(entry.item.icon)
                                        .font(.title2)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(entry.item.rarity.color.opacity(0.15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(entry.item.rarity.color.opacity(0.4), lineWidth: 1)
                                                )
                                        )

                                    // Item details
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(entry.item.name)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)

                                        Text(entry.item.itemDescription)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    // Quantity badge
                                    if entry.quantity > 1 {
                                        Text("x\(entry.quantity)")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Capsule().fill(Color.gray.opacity(0.6)))
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Use Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
