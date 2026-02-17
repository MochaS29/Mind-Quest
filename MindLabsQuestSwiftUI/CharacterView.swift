import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Character Card
                    CharacterCard()
                    
                    // Ability Scores
                    AbilityScoresCard()
                    
                    // Equipment
                    EquipmentCard()
                    
                    // Class Abilities
                    ClassAbilitiesCard()
                }
                .padding()
            }
            .navigationTitle("Character")
            .mindLabsBackground()
        }
    }
}

struct CharacterCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text(gameManager.character.avatar)
                .font(.system(size: 80))
            
            Text(gameManager.character.name)
                .font(.title)
                .bold()
            
            if let characterClass = gameManager.character.characterClass {
                Text("Level \(gameManager.character.level) \(characterClass.rawValue)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            if let background = gameManager.character.background {
                Text("\(background.rawValue) Background")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient.mindLabsPrimary
        )
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}

struct AbilityScoresCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Ability Scores")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(StatType.allCases, id: \.self) { stat in
                    VStack(spacing: 8) {
                        HStack {
                            Text(stat.icon)
                                .font(.title2)
                            Text(stat.rawValue)
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        
                        Text("\(gameManager.character.stats[stat] ?? 10)")
                            .font(MindLabsTypography.title())
                            .bold()
                            .foregroundColor(.mindLabsText)
                        
                        Text("Modifier: \(gameManager.character.modifier(stat) >= 0 ? "+" : "")\(gameManager.character.modifier(stat))")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mindLabsBorder.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct EquipmentCard: View {
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Equipment")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
            
            VStack(spacing: 10) {
                EquipmentRow(type: "Weapon", name: "Basic Focus Blade", icon: "⚔️")
                EquipmentRow(type: "Armor", name: "Student Robes", icon: "🛡️")
                EquipmentRow(type: "Accessory", name: "Clarity Amulet", icon: "💎")
            }
        }
    }
}

struct EquipmentRow: View {
    let type: String
    let name: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(type)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
                Text(name)
                    .font(MindLabsTypography.subheadline())
                    .bold()
                    .foregroundColor(.mindLabsText)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.mindLabsBorder.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ClassAbilitiesCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var abilities: [String] {
        switch gameManager.character.characterClass {
        case .scholar:
            return ["Double XP from academic tasks", "Unlock advanced study techniques", "Research mastery"]
        case .warrior:
            return ["Double XP from fitness tasks", "Endurance boost", "Athletic excellence"]
        case .diplomat:
            return ["Double XP from social tasks", "Leadership skills", "Communication mastery"]
        case .ranger:
            return ["Balanced XP from all activities", "Adaptability", "Nature connection"]
        case .artificer:
            return ["Double XP from creative tasks", "Innovation bonus", "Problem-solving mastery"]
        case .cleric:
            return ["Double XP from health tasks", "Mental wellness boost", "Healing abilities"]
        case .none:
            return []
        }
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Class Abilities")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(abilities, id: \.self) { ability in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(ability)
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView()
            .environmentObject(GameManager())
    }
}