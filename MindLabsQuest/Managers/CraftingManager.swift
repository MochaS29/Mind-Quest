import Foundation

class CraftingManager: ObservableObject {
    @Published var craftingProgress = CraftingProgress()

    private let persistenceKey = "craftingProgress"

    init() {
        loadProgress()
    }

    // MARK: - Can Craft

    func canCraft(_ recipe: CraftingRecipe, character: Character) -> Bool {
        // Level check
        guard character.level >= recipe.levelRequirement else { return false }

        // Gold check
        guard character.gold >= recipe.goldCost else { return false }

        // Inventory space check
        guard !character.isInventoryFull else { return false }

        // Ingredient check
        for ingredient in recipe.ingredients {
            let owned = character.inventory
                .filter { $0.item.templateId == ingredient.templateId }
                .reduce(0) { $0 + $1.quantity }
            guard owned >= ingredient.quantity else { return false }
        }

        return true
    }

    // MARK: - Ingredient Count

    func ownedCount(of templateId: String, character: Character) -> Int {
        character.inventory
            .filter { $0.item.templateId == templateId }
            .reduce(0) { $0 + $1.quantity }
    }

    // MARK: - Craft Item

    func craft(_ recipe: CraftingRecipe, character: inout Character) -> Item? {
        guard canCraft(recipe, character: character) else { return nil }

        // Consume gold
        character.gold -= recipe.goldCost

        // Consume ingredients
        for ingredient in recipe.ingredients {
            var remaining = ingredient.quantity
            while remaining > 0 {
                guard let entryIndex = character.inventory.firstIndex(where: { $0.item.templateId == ingredient.templateId }) else { break }
                let available = character.inventory[entryIndex].quantity
                let toRemove = min(available, remaining)
                _ = character.removeItem(character.inventory[entryIndex].item.id, quantity: toRemove)
                remaining -= toRemove
            }
        }

        // Create result item
        guard let template = findItem(byTemplateId: recipe.resultTemplateId) else { return nil }
        var newItem = template
        newItem.id = UUID()
        _ = character.addItem(newItem)

        // Update progress
        craftingProgress.discoveredRecipeIds.insert(recipe.id)
        craftingProgress.craftCounts[recipe.id, default: 0] += 1
        craftingProgress.totalItemsCrafted += 1
        saveProgress()

        return newItem
    }

    // MARK: - Item Lookup

    func findItem(byTemplateId templateId: String) -> Item? {
        ItemDatabase.allShopItems.first { $0.templateId == templateId }
    }

    func ingredientName(for templateId: String) -> String {
        findItem(byTemplateId: templateId)?.name ?? templateId
    }

    func ingredientIcon(for templateId: String) -> String {
        findItem(byTemplateId: templateId)?.icon ?? "❓"
    }

    // MARK: - Persistence

    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(craftingProgress) {
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        }
    }

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey),
              let decoded = try? JSONDecoder().decode(CraftingProgress.self, from: data) else {
            return
        }
        craftingProgress = decoded
    }
}
