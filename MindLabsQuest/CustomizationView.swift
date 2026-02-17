import SwiftUI

// MARK: - Custom Category Model
struct CustomCategory: Codable, Identifiable {
    var id = UUID()
    var name: String
    var icon: String
    var color: String
    
    var swiftUIColor: Color {
        switch color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .gray
        }
    }
}

struct CustomizationView: View {
    @EnvironmentObject var gameManager: GameManager
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingAddCategory = false
    @State private var showingEditCategory = false
    @State private var selectedCategory: CustomCategory?
    @State private var customCategories: [CustomCategory] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Theme Customization
                    themeCustomizationSection
                    
                    // Quest Categories
                    questCategoriesSection
                    
                    // Character Customization
                    characterCustomizationSection
                    
                    // UI Preferences
                    uiPreferencesSection
                }
                .padding()
            }
            .navigationTitle("Customization")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(categories: $customCategories)
            }
            .sheet(item: $selectedCategory) { category in
                EditCategoryView(category: category, categories: $customCategories)
            }
        }
        .onAppear {
            loadCustomCategories()
        }
    }
    
    // MARK: - Sections
    
    var themeCustomizationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Theme & Colors", systemImage: "paintpalette.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 20) {
                    // Accent Color Showcase
                    VStack(spacing: 10) {
                        Text("Current Theme")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        HStack(spacing: 20) {
                            // Primary Color Sample
                            VStack {
                                Circle()
                                    .fill(themeManager.accentColor)
                                    .frame(width: 60, height: 60)
                                Text("Primary")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            
                            // Background Sample
                            VStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.mindLabsBackground)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.mindLabsBorder, lineWidth: 1)
                                    )
                                Text("Background")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            
                            // Card Sample
                            VStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.mindLabsCard)
                                    .frame(width: 60, height: 60)
                                Text("Card")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Text("Change Theme Settings")
                                .font(MindLabsTypography.body())
                                .foregroundColor(themeManager.accentColor)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                }
            }
        }
    }
    
    var questCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("Quest Categories", systemImage: "folder.fill")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
                
                Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            MindLabsCard {
                VStack(spacing: 15) {
                    // Default Categories
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Default Categories")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.icon)
                                    .font(.title3)
                                Text(category.rawValue)
                                    .font(MindLabsTypography.body())
                                    .foregroundColor(.mindLabsText)
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    
                    if !customCategories.isEmpty {
                        Divider()
                        
                        // Custom Categories
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Custom Categories")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            ForEach(customCategories) { category in
                                HStack {
                                    Text(category.icon)
                                        .font(.title3)
                                    Text(category.name)
                                        .font(MindLabsTypography.body())
                                        .foregroundColor(.mindLabsText)
                                    Spacer()
                                    
                                    Circle()
                                        .fill(category.swiftUIColor)
                                        .frame(width: 20, height: 20)
                                    
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.mindLabsTextSecondary)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var characterCustomizationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Character Options", systemImage: "person.crop.circle.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 15) {
                    // Avatar Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Character Avatar")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(["🧙‍♂️", "🦸‍♀️", "🧚‍♀️", "🏴‍☠️", "🤖", "🐉", "🦄", "🎮", "⚔️", "🛡️"], id: \.self) { avatar in
                                    Button(action: {
                                        gameManager.character.avatar = avatar
                                        gameManager.saveData()
                                    }) {
                                        Text(avatar)
                                            .font(.system(size: 40))
                                            .frame(width: 60, height: 60)
                                            .background(
                                                gameManager.character.avatar == avatar ?
                                                themeManager.accentColor.opacity(0.2) :
                                                Color.mindLabsCard
                                            )
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        gameManager.character.avatar == avatar ?
                                                        themeManager.accentColor :
                                                        Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Character Title
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Character Title")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        Text(characterTitle)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.mindLabsPurple.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    var uiPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("UI Preferences", systemImage: "square.grid.2x2.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 15) {
                    Toggle(isOn: .constant(true)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Compact Quest View")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                            Text("Show quests in a condensed format")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                    .tint(themeManager.accentColor)
                    
                    Toggle(isOn: .constant(false)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Show Quest Hints")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                            Text("Display helpful tips for completing quests")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                    .tint(themeManager.accentColor)
                    
                    Toggle(isOn: .constant(true)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Animated Transitions")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                            Text("Enable smooth animations throughout the app")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                    .tint(themeManager.accentColor)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var characterTitle: String {
        let level = gameManager.character.level
        switch level {
        case 1...5: return "Novice Adventurer"
        case 6...10: return "Skilled Hero"
        case 11...20: return "Master Champion"
        case 21...30: return "Epic Legend"
        case 31...40: return "Mythic Warrior"
        case 41...50: return "Divine Guardian"
        default: return "Legendary \(gameManager.character.characterClass?.rawValue ?? "Hero")"
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadCustomCategories() {
        if let data = UserDefaults.standard.data(forKey: "customCategories"),
           let categories = try? JSONDecoder().decode([CustomCategory].self, from: data) {
            customCategories = categories
        }
    }
    
    private func saveCustomCategories() {
        if let encoded = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(encoded, forKey: "customCategories")
        }
    }
}

// MARK: - Add Category View
struct AddCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var categories: [CustomCategory]
    
    @State private var categoryName = ""
    @State private var selectedIcon = "📁"
    @State private var selectedColor = "blue"
    
    let availableIcons = ["📁", "📚", "💡", "🎯", "🚀", "⭐", "🔥", "💎", "🎨", "🎪", "🎭", "🎸", "🎮", "🏆", "💪", "🧠", "❤️", "🌟", "🌈", "🔧"]
    let availableColors = ["blue", "green", "orange", "red", "purple", "pink", "yellow", "teal", "indigo"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $categoryName)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Text(icon)
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        selectedIcon == icon ?
                                        Color.mindLabsPurple.opacity(0.2) :
                                        Color.mindLabsCard
                                    )
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                selectedIcon == icon ?
                                                Color.mindLabsPurple :
                                                Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                        ForEach(availableColors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(colorForString(color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveCategory()
                }
                .disabled(categoryName.isEmpty)
            )
        }
    }
    
    private func colorForString(_ color: String) -> Color {
        switch color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .gray
        }
    }
    
    private func saveCategory() {
        let newCategory = CustomCategory(
            name: categoryName,
            icon: selectedIcon,
            color: selectedColor
        )
        categories.append(newCategory)
        
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "customCategories")
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Edit Category View
struct EditCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    let category: CustomCategory
    @Binding var categories: [CustomCategory]
    
    @State private var categoryName: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    
    init(category: CustomCategory, categories: Binding<[CustomCategory]>) {
        self.category = category
        self._categories = categories
        self._categoryName = State(initialValue: category.name)
        self._selectedIcon = State(initialValue: category.icon)
        self._selectedColor = State(initialValue: category.color)
    }
    
    let availableIcons = ["📁", "📚", "💡", "🎯", "🚀", "⭐", "🔥", "💎", "🎨", "🎪", "🎭", "🎸", "🎮", "🏆", "💪", "🧠", "❤️", "🌟", "🌈", "🔧"]
    let availableColors = ["blue", "green", "orange", "red", "purple", "pink", "yellow", "teal", "indigo"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $categoryName)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Text(icon)
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        selectedIcon == icon ?
                                        Color.mindLabsPurple.opacity(0.2) :
                                        Color.mindLabsCard
                                    )
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                selectedIcon == icon ?
                                                Color.mindLabsPurple :
                                                Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                        ForEach(availableColors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(colorForString(color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: deleteCategory) {
                        Text("Delete Category")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    updateCategory()
                }
                .disabled(categoryName.isEmpty)
            )
        }
    }
    
    private func colorForString(_ color: String) -> Color {
        switch color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .gray
        }
    }
    
    private func updateCategory() {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].name = categoryName
            categories[index].icon = selectedIcon
            categories[index].color = selectedColor
            
            if let encoded = try? JSONEncoder().encode(categories) {
                UserDefaults.standard.set(encoded, forKey: "customCategories")
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteCategory() {
        categories.removeAll { $0.id == category.id }
        
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "customCategories")
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct CustomizationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizationView()
            .environmentObject(GameManager())
    }
}