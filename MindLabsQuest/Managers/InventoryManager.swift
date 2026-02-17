import Foundation
import SwiftUI

class InventoryManager: ObservableObject {
    @Published var character: Character

    init(character: Character) {
        self.character = character
    }

    // MARK: - Add Item
    @discardableResult
    func addItem(_ item: Item, quantity: Int = 1) -> Bool {
        return character.addItem(item, quantity: quantity)
    }

    // MARK: - Remove Item
    @discardableResult
    func removeItem(_ itemId: UUID, quantity: Int = 1) -> Bool {
        return character.removeItem(itemId, quantity: quantity)
    }

    // MARK: - Equip Item
    /// Equips an item from inventory, returns the previously equipped item (if any)
    @discardableResult
    func equipItem(_ item: Item) -> Item? {
        return character.equip(item)
    }

    // MARK: - Unequip Item
    @discardableResult
    func unequipSlot(_ slot: EquipmentSlot) -> Bool {
        return character.unequip(slot: slot)
    }

    // MARK: - Sell Item
    func sellItem(_ itemId: UUID, quantity: Int = 1) -> Int {
        guard let entry = character.inventory.first(where: { $0.item.id == itemId }) else { return 0 }

        let sellPrice = entry.item.sellPrice * quantity
        guard character.removeItem(itemId, quantity: quantity) else { return 0 }

        character.gold += sellPrice
        return sellPrice
    }

    // MARK: - Buy Item
    func buyItem(_ item: Item, quantity: Int = 1) -> Bool {
        let totalCost = item.buyPrice * quantity
        guard character.gold >= totalCost else { return false }
        guard character.addItem(item, quantity: quantity) else { return false }

        character.gold -= totalCost
        return true
    }

    // MARK: - Use Consumable
    func useConsumable(_ itemId: UUID) -> ConsumableResult? {
        guard let entry = character.inventory.first(where: { $0.item.id == itemId }) else { return nil }
        let item = entry.item
        guard item.type == .consumable else { return nil }

        var result = ConsumableResult()

        // Heal
        if let healAmount = item.healAmount {
            let actualHeal = min(healAmount, character.maxHealth - character.health)
            character.health += actualHeal
            result.healedAmount = actualHeal
        }

        // Cure status effects
        if let cureString = item.statusEffectCure {
            let cureNames = cureString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            result.curedEffects = cureNames
        }

        // Temporary stat boost
        if let boosts = item.tempStatBoost, let duration = item.tempBoostDuration {
            result.tempBoosts = boosts
            result.boostDuration = duration
        }

        // Battle damage
        if let damage = item.battleDamage {
            result.battleDamage = damage
        }

        // Remove from inventory
        _ = character.removeItem(itemId)

        return result
    }

    // MARK: - Award Loot
    func awardLoot(from lootTable: LootTable) -> LootResult {
        let roll = lootTable.roll()
        var result = LootResult()
        result.goldEarned = roll.gold
        character.gold += roll.gold

        for (item, quantity) in roll.items {
            if character.addItem(item, quantity: quantity) {
                result.itemsReceived.append((item, quantity))
            } else {
                result.itemsDropped.append((item, quantity))
            }
        }

        return result
    }

    // MARK: - Award Starter Items
    func awardStarterItems(for characterClass: CharacterClass) {
        let starterWeapon = ItemDatabase.starterWeapon(for: characterClass)
        _ = addItem(starterWeapon)
        _ = character.equip(starterWeapon)

        let basicArmor = ItemDatabase.basicArmor
        _ = addItem(basicArmor)
        _ = character.equip(basicArmor)
    }

    // MARK: - Inventory Queries
    func items(ofType type: ItemType) -> [InventoryEntry] {
        character.inventory.filter { $0.item.type == type }
    }

    func consumables() -> [InventoryEntry] {
        items(ofType: .consumable)
    }

    func equipment() -> [InventoryEntry] {
        character.inventory.filter { $0.item.slot != nil }
    }

    func materials() -> [InventoryEntry] {
        items(ofType: .material)
    }

    var sortedInventory: [InventoryEntry] {
        character.inventory.sorted { a, b in
            if a.item.type.rawValue != b.item.type.rawValue {
                return a.item.type.rawValue < b.item.type.rawValue
            }
            if a.item.rarity != b.item.rarity {
                return a.item.rarity > b.item.rarity
            }
            return a.item.name < b.item.name
        }
    }
}

// MARK: - Result Types
struct ConsumableResult {
    var healedAmount: Int = 0
    var curedEffects: [String] = []
    var tempBoosts: [StatType: Int] = [:]
    var boostDuration: Int = 0
    var battleDamage: Int = 0
}

struct LootResult {
    var goldEarned: Int = 0
    var itemsReceived: [(Item, Int)] = []
    var itemsDropped: [(Item, Int)] = [] // items that didn't fit in inventory
}
