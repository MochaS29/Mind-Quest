import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedFilter: ItemType? = nil
    @State private var selectedItem: Item? = nil
    @State private var showItemDetail = false
    @State private var sortByRarity = true
    @State private var showCrafting = false

    var filteredInventory: [InventoryEntry] {
        var entries = gameManager.character.inventory
        if let filter = selectedFilter {
            entries = entries.filter { $0.item.type == filter }
        }
        if sortByRarity {
            entries.sort { $0.item.rarity > $1.item.rarity }
        } else {
            entries.sort { $0.item.name < $1.item.name }
        }
        return entries
    }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Capacity bar
                    capacityBar

                    // Equipment summary
                    equippedSection

                    // Filter chips
                    filterChips

                    // Item grid
                    if filteredInventory.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredInventory) { entry in
                                ItemGridCell(entry: entry)
                                    .onTapGesture {
                                        selectedItem = entry.item
                                        showItemDetail = true
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Inventory")
            .mindLabsBackground()
            .sheet(isPresented: $showItemDetail) {
                if let item = selectedItem {
                    ItemDetailView(item: item)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showCrafting = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "hammer.fill")
                            Text("Craft")
                                .font(MindLabsTypography.caption())
                        }
                        .foregroundColor(.mindLabsPurple)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { sortByRarity.toggle() }) {
                        Image(systemName: sortByRarity ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle")
                            .foregroundColor(.mindLabsPurple)
                    }
                }
            }
            .sheet(isPresented: $showCrafting) {
                CraftingView()
            }
        }
    }

    private var capacityBar: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Inventory")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    Spacer()
                    Text("\(gameManager.character.inventoryCount)/\(gameManager.character.inventoryCapacity)")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.mindLabsBorder.opacity(0.3))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(LinearGradient(
                                colors: gameManager.character.isInventoryFull ? [.red, .red] : [.mindLabsPurple, .mindLabsBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(
                                width: geometry.size.width * CGFloat(gameManager.character.inventoryCount) / CGFloat(gameManager.character.inventoryCapacity),
                                height: 8
                            )
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("💰 \(gameManager.character.gold) Gold")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsWarning)
                    Spacer()
                }
            }
        }
    }

    private var equippedSection: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Equipped")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)

                HStack(spacing: 12) {
                    EquippedSlotView(
                        slot: .weapon,
                        item: gameManager.character.equipment.weapon,
                        onTap: { if let item = gameManager.character.equipment.weapon { selectedItem = item; showItemDetail = true } }
                    )
                    EquippedSlotView(
                        slot: .armor,
                        item: gameManager.character.equipment.armor,
                        onTap: { if let item = gameManager.character.equipment.armor { selectedItem = item; showItemDetail = true } }
                    )
                    EquippedSlotView(
                        slot: .accessory,
                        item: gameManager.character.equipment.accessory,
                        onTap: { if let item = gameManager.character.equipment.accessory { selectedItem = item; showItemDetail = true } }
                    )
                }

                // Equipment stat bonuses
                let mods = gameManager.character.equipment.totalStatModifiers()
                if !mods.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(mods.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { stat, value in
                            Text("\(stat.icon)+\(value)")
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsSuccess)
                        }
                    }
                }
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                InventoryFilterChip(title: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                ForEach(ItemType.allCases, id: \.self) { type in
                    InventoryFilterChip(title: "\(type.icon) \(type.rawValue)", isSelected: selectedFilter == type) {
                        selectedFilter = type
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🎒")
                .font(.system(size: 50))
            Text("No items yet")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            Text("Complete battles and quests to earn loot!")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Supporting Views

struct ItemGridCell: View {
    let entry: InventoryEntry

    var body: some View {
        VStack(spacing: 4) {
            Text(entry.item.icon)
                .font(.system(size: 30))

            Text(entry.item.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.mindLabsText)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if entry.quantity > 1 {
                Text("x\(entry.quantity)")
                    .font(.system(size: 9))
                    .foregroundColor(.mindLabsTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.mindLabsCard)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(entry.item.rarity.color.opacity(0.5), lineWidth: 2)
        )
        .cornerRadius(10)
    }
}

struct EquippedSlotView: View {
    let slot: EquipmentSlot
    let item: Item?
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            if let item = item {
                Text(item.icon)
                    .font(.system(size: 24))
                Text(item.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.mindLabsText)
                    .lineLimit(1)
            } else {
                Text(slot.icon)
                    .font(.system(size: 24))
                    .opacity(0.3)
                Text("Empty")
                    .font(.system(size: 9))
                    .foregroundColor(.mindLabsTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.mindLabsBorder.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(item != nil ? item!.rarity.color.opacity(0.4) : Color.mindLabsBorder.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
        .onTapGesture(perform: onTap)
    }
}

struct InventoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .mindLabsText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.mindLabsPurple : Color.mindLabsCard)
                .cornerRadius(16)
        }
    }
}
