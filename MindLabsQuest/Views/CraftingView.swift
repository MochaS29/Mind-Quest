import SwiftUI

struct CraftingView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCategory: CraftingCategory = .alchemy
    @State private var craftedItem: Item?
    @State private var showCraftedAlert = false

    var recipes: [CraftingRecipe] {
        CraftingRecipeDatabase.recipes(for: selectedCategory)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Category tabs
                    categoryTabs

                    // Recipes list
                    ForEach(recipes) { recipe in
                        recipeCard(recipe)
                    }
                }
                .padding()
            }
            .navigationTitle("Crafting")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .alert("Item Crafted!", isPresented: $showCraftedAlert) {
                Button("OK") {}
            } message: {
                if let item = craftedItem {
                    Text("You crafted \(item.name)! Check your inventory.")
                }
            }
        }
    }

    // MARK: - Category Tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CraftingCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption)
                            Text(category.rawValue)
                                .font(MindLabsTypography.caption())
                        }
                        .foregroundColor(selectedCategory == category ? .white : .mindLabsText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? Color.mindLabsPurple : Color.mindLabsCard)
                        .cornerRadius(16)
                    }
                }
            }
        }
    }

    // MARK: - Recipe Card

    private func recipeCard(_ recipe: CraftingRecipe) -> some View {
        let canCraft = gameManager.craftingManager.canCraft(recipe, character: gameManager.character)
        let resultItem = gameManager.craftingManager.findItem(byTemplateId: recipe.resultTemplateId)
        let meetsLevel = gameManager.character.level >= recipe.levelRequirement

        return MindLabsCard {
            VStack(alignment: .leading, spacing: 10) {
                // Header: result item
                HStack {
                    Text(resultItem?.icon ?? "❓")
                        .font(.system(size: 30))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(recipe.name)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        Text(recipe.description)
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    if let rarity = resultItem?.rarity {
                        Text(rarity.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(rarity.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(rarity.color.opacity(0.15))
                            .cornerRadius(4)
                    }
                }

                // Level requirement
                if !meetsLevel {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                        Text("Requires Level \(recipe.levelRequirement)")
                            .font(MindLabsTypography.caption2())
                    }
                    .foregroundColor(.mindLabsError)
                }

                // Ingredients
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ingredients")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .bold()

                    ForEach(recipe.ingredients, id: \.templateId) { ingredient in
                        let owned = gameManager.craftingManager.ownedCount(of: ingredient.templateId, character: gameManager.character)
                        let hasEnough = owned >= ingredient.quantity
                        HStack(spacing: 6) {
                            Text(gameManager.craftingManager.ingredientIcon(for: ingredient.templateId))
                                .font(.caption)
                            Text(gameManager.craftingManager.ingredientName(for: ingredient.templateId))
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsText)
                            Spacer()
                            Text("\(owned)/\(ingredient.quantity)")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(hasEnough ? .mindLabsSuccess : .mindLabsError)
                                .bold()
                        }
                    }
                }

                // Gold cost + Craft button
                HStack {
                    if recipe.goldCost > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text("\(recipe.goldCost)")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(gameManager.character.gold >= recipe.goldCost ? .mindLabsText : .mindLabsError)
                        }
                    }

                    Spacer()

                    Button {
                        if let item = gameManager.craftingManager.craft(recipe, character: &gameManager.character) {
                            craftedItem = item
                            showCraftedAlert = true
                            gameManager.saveData()
                        }
                    } label: {
                        Text("Craft")
                            .font(MindLabsTypography.caption())
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(canCraft ? Color.mindLabsSuccess : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!canCraft)
                }
            }
        }
        .opacity(meetsLevel ? 1.0 : 0.6)
    }
}
