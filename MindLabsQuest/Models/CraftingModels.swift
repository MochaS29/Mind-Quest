import Foundation

// MARK: - Crafting Category
enum CraftingCategory: String, CaseIterable, Codable {
    case weaponsmith = "Weaponsmith"
    case armorsmith = "Armorsmith"
    case alchemy = "Alchemy"
    case enchanting = "Enchanting"

    var icon: String {
        switch self {
        case .weaponsmith: return "hammer.fill"
        case .armorsmith: return "shield.lefthalf.filled"
        case .alchemy: return "flask.fill"
        case .enchanting: return "sparkles"
        }
    }
}

// MARK: - Crafting Ingredient
struct CraftingIngredient: Codable, Equatable {
    var templateId: String   // matches Item.templateId
    var quantity: Int
}

// MARK: - Crafting Recipe
struct CraftingRecipe: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var category: CraftingCategory
    var levelRequirement: Int
    var ingredients: [CraftingIngredient]
    var resultTemplateId: String    // matches Item.templateId
    var goldCost: Int = 0
}

// MARK: - Crafting Progress (persisted)
struct CraftingProgress: Codable {
    var discoveredRecipeIds: Set<String> = []
    var craftCounts: [String: Int] = [:]   // recipeId -> count
    var totalItemsCrafted: Int = 0
}
