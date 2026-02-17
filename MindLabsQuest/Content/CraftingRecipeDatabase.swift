import Foundation

struct CraftingRecipeDatabase {

    // MARK: - All Recipes

    static let allRecipes: [CraftingRecipe] = weaponsmithRecipes + armorsmithRecipes + alchemyRecipes + enchantingRecipes

    static func recipes(for category: CraftingCategory) -> [CraftingRecipe] {
        allRecipes.filter { $0.category == category }
    }

    // MARK: - Weaponsmith Recipes (2)

    static let weaponsmithRecipes: [CraftingRecipe] = [
        CraftingRecipe(
            id: "recipe_steel_sword",
            name: "Steel Sword",
            description: "A reliable blade forged from iron and tempered with crystal energy.",
            category: .weaponsmith,
            levelRequirement: 3,
            ingredients: [
                CraftingIngredient(templateId: "iron_ore", quantity: 5),
                CraftingIngredient(templateId: "crystal_shard", quantity: 1)
            ],
            resultTemplateId: "steel_sword",
            goldCost: 50
        ),
        CraftingRecipe(
            id: "recipe_shadow_blade",
            name: "Shadow Blade",
            description: "A sinister weapon infused with shadow essence, striking from the darkness.",
            category: .weaponsmith,
            levelRequirement: 8,
            ingredients: [
                CraftingIngredient(templateId: "iron_ore", quantity: 8),
                CraftingIngredient(templateId: "shadow_essence", quantity: 5)
            ],
            resultTemplateId: "shadow_blade",
            goldCost: 150
        )
    ]

    // MARK: - Armorsmith Recipes (3)

    static let armorsmithRecipes: [CraftingRecipe] = [
        CraftingRecipe(
            id: "recipe_chainmail",
            name: "Chainmail",
            description: "Interlocking iron rings woven with enchanted thread for added resilience.",
            category: .armorsmith,
            levelRequirement: 4,
            ingredients: [
                CraftingIngredient(templateId: "iron_ore", quantity: 6),
                CraftingIngredient(templateId: "enchanted_thread", quantity: 2)
            ],
            resultTemplateId: "chainmail",
            goldCost: 75
        ),
        CraftingRecipe(
            id: "recipe_plate_armor",
            name: "Plate Armor",
            description: "Heavy armor reinforced with dragon scales, offering supreme protection.",
            category: .armorsmith,
            levelRequirement: 10,
            ingredients: [
                CraftingIngredient(templateId: "iron_ore", quantity: 10),
                CraftingIngredient(templateId: "dragon_scale", quantity: 3)
            ],
            resultTemplateId: "plate_armor",
            goldCost: 200
        ),
        CraftingRecipe(
            id: "recipe_mage_robes",
            name: "Mage Robes",
            description: "Lightweight robes threaded with crystal energy, perfect for spellcasters.",
            category: .armorsmith,
            levelRequirement: 6,
            ingredients: [
                CraftingIngredient(templateId: "enchanted_thread", quantity: 4),
                CraftingIngredient(templateId: "crystal_shard", quantity: 3)
            ],
            resultTemplateId: "mage_robes",
            goldCost: 100
        )
    ]

    // MARK: - Alchemy Recipes (5)

    static let alchemyRecipes: [CraftingRecipe] = [
        CraftingRecipe(
            id: "recipe_health_potion",
            name: "Health Potion",
            description: "A basic restorative brew distilled from crystal shards.",
            category: .alchemy,
            levelRequirement: 1,
            ingredients: [
                CraftingIngredient(templateId: "crystal_shard", quantity: 2)
            ],
            resultTemplateId: "health_potion",
            goldCost: 10
        ),
        CraftingRecipe(
            id: "recipe_greater_health_potion",
            name: "Greater Health Potion",
            description: "A potent healing elixir enhanced with enchanted thread for lasting effect.",
            category: .alchemy,
            levelRequirement: 5,
            ingredients: [
                CraftingIngredient(templateId: "crystal_shard", quantity: 3),
                CraftingIngredient(templateId: "enchanted_thread", quantity: 2)
            ],
            resultTemplateId: "greater_health_potion",
            goldCost: 30
        ),
        CraftingRecipe(
            id: "recipe_antidote",
            name: "Antidote",
            description: "A cleansing tonic that neutralizes poisons and status ailments.",
            category: .alchemy,
            levelRequirement: 2,
            ingredients: [
                CraftingIngredient(templateId: "crystal_shard", quantity: 1),
                CraftingIngredient(templateId: "shadow_essence", quantity: 1)
            ],
            resultTemplateId: "antidote",
            goldCost: 15
        ),
        CraftingRecipe(
            id: "recipe_stat_potion",
            name: "Stat Potion",
            description: "A shimmering draught that temporarily boosts the drinker's abilities.",
            category: .alchemy,
            levelRequirement: 4,
            ingredients: [
                CraftingIngredient(templateId: "shadow_essence", quantity: 2),
                CraftingIngredient(templateId: "crystal_shard", quantity: 1)
            ],
            resultTemplateId: "stat_potion",
            goldCost: 25
        ),
        CraftingRecipe(
            id: "recipe_battle_scroll",
            name: "Battle Scroll",
            description: "A scroll inscribed with shadow-infused glyphs that unleash power in combat.",
            category: .alchemy,
            levelRequirement: 6,
            ingredients: [
                CraftingIngredient(templateId: "enchanted_thread", quantity: 2),
                CraftingIngredient(templateId: "shadow_essence", quantity: 2)
            ],
            resultTemplateId: "battle_scroll",
            goldCost: 40
        )
    ]

    // MARK: - Enchanting Recipes (5)

    static let enchantingRecipes: [CraftingRecipe] = [
        CraftingRecipe(
            id: "recipe_clarity_amulet",
            name: "Clarity Amulet",
            description: "A crystal-studded amulet that sharpens the mind and boosts focus.",
            category: .enchanting,
            levelRequirement: 5,
            ingredients: [
                CraftingIngredient(templateId: "crystal_shard", quantity: 3),
                CraftingIngredient(templateId: "enchanted_thread", quantity: 1)
            ],
            resultTemplateId: "clarity_amulet",
            goldCost: 80
        ),
        CraftingRecipe(
            id: "recipe_ring_of_might",
            name: "Ring of Might",
            description: "A sturdy ring imbued with shadow power to amplify raw strength.",
            category: .enchanting,
            levelRequirement: 5,
            ingredients: [
                CraftingIngredient(templateId: "iron_ore", quantity: 2),
                CraftingIngredient(templateId: "shadow_essence", quantity: 2)
            ],
            resultTemplateId: "ring_of_might",
            goldCost: 80
        ),
        CraftingRecipe(
            id: "recipe_wisdom_pendant",
            name: "Wisdom Pendant",
            description: "A pendant radiating crystalline light, granting deep insight to its wearer.",
            category: .enchanting,
            levelRequirement: 7,
            ingredients: [
                CraftingIngredient(templateId: "crystal_shard", quantity: 3),
                CraftingIngredient(templateId: "enchanted_thread", quantity: 2)
            ],
            resultTemplateId: "wisdom_pendant",
            goldCost: 120
        ),
        CraftingRecipe(
            id: "recipe_swiftfoot_boots",
            name: "Swiftfoot Boots",
            description: "Enchanted boots woven with iron buckles and crystal agility charms.",
            category: .enchanting,
            levelRequirement: 6,
            ingredients: [
                CraftingIngredient(templateId: "enchanted_thread", quantity: 2),
                CraftingIngredient(templateId: "iron_ore", quantity: 2),
                CraftingIngredient(templateId: "crystal_shard", quantity: 1)
            ],
            resultTemplateId: "dexterity_boots",
            goldCost: 100
        ),
        CraftingRecipe(
            id: "recipe_dragon_shield",
            name: "Dragon Scale Shield",
            description: "A legendary shield forged from dragon scales, nearly impervious to damage.",
            category: .enchanting,
            levelRequirement: 12,
            ingredients: [
                CraftingIngredient(templateId: "dragon_scale", quantity: 5),
                CraftingIngredient(templateId: "iron_ore", quantity: 3)
            ],
            resultTemplateId: "dragon_shield",
            goldCost: 300
        )
    ]
}
