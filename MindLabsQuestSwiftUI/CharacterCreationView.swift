import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var currentStep = 0
    @State private var characterName = ""
    @State private var selectedAvatar = "🧙‍♂️"
    @State private var selectedClass: CharacterClass?
    @State private var selectedBackground: Background?
    
    let avatars = ["🧙‍♂️", "🧙‍♀️", "⚔️", "🏹", "🛡️", "✨", "🎨", "📚"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Indicator
                HStack {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index <= currentStep ? Color.mindLabsPurple : Color.mindLabsBorder)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding()
                
                // Content based on step
                Group {
                    switch currentStep {
                    case 0:
                        nameAndAvatarStep
                    case 1:
                        classSelectionStep
                    case 2:
                        backgroundSelectionStep
                    case 3:
                        reviewStep
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut, value: currentStep)
                
                Spacer()
                
                // Navigation Buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            currentStep -= 1
                        }
                        .foregroundColor(.mindLabsPurple)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == 3 ? "Begin Adventure!" : "Next") {
                        if currentStep == 3 {
                            createCharacter()
                        } else {
                            if canProceed {
                                currentStep += 1
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(canProceed ? LinearGradient.mindLabsPrimary : LinearGradient(colors: [Color.mindLabsTextLight], startPoint: .top, endPoint: .bottom))
                    .cornerRadius(25)
                    .mindLabsButtonShadow()
                    .disabled(!canProceed)
                }
                .padding()
            }
            .navigationTitle("Create Your Character")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
        }
    }
    
    // MARK: - Step Views
    
    var nameAndAvatarStep: some View {
        VStack(spacing: 30) {
            Text("🎭")
                .font(.system(size: 80))
            
            Text("Choose your identity")
                .font(MindLabsTypography.title2())
                .foregroundColor(.mindLabsTextSecondary)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Character Name")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                TextField("Enter your hero's name", text: $characterName)
                    .textFieldStyle(MindLabsTextFieldStyle())
                    .autocapitalization(.words)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Choose Avatar")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                    ForEach(avatars, id: \.self) { avatar in
                        Button(action: {
                            selectedAvatar = avatar
                        }) {
                            Text(avatar)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(selectedAvatar == avatar ? Color.mindLabsPurple.opacity(0.2) : Color.mindLabsBorder.opacity(0.3))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedAvatar == avatar ? Color.mindLabsPurple : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var classSelectionStep: some View {
        VStack(spacing: 20) {
            Text(selectedAvatar)
                .font(.system(size: 60))
            
            Text(characterName)
                .font(MindLabsTypography.title2())
                .bold()
                .foregroundColor(.mindLabsText)
            
            Text("Choose your class")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsTextSecondary)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(CharacterClass.allCases, id: \.self) { characterClass in
                        Button(action: {
                            selectedClass = characterClass
                        }) {
                            HStack {
                                Text(characterClass.icon)
                                    .font(.system(size: 30))
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(characterClass.rawValue)
                                        .font(MindLabsTypography.headline())
                                        .foregroundColor(.mindLabsText)
                                    
                                    Text(characterClass.description)
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                    
                                    Text("Primary: \(characterClass.primaryStat.rawValue)")
                                        .font(MindLabsTypography.caption2())
                                        .foregroundColor(.mindLabsPurple)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(selectedClass == characterClass ? Color.mindLabsPurple.opacity(0.1) : Color.mindLabsBorder.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedClass == characterClass ? Color.mindLabsPurple : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var backgroundSelectionStep: some View {
        VStack(spacing: 20) {
            Text(selectedAvatar)
                .font(.system(size: 60))
            
            Text(characterName)
                .font(MindLabsTypography.title2())
                .bold()
                .foregroundColor(.mindLabsText)
            
            if let selectedClass = selectedClass {
                Text(selectedClass.rawValue)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsPurple)
            }
            
            Text("Choose your background")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsTextSecondary)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(Background.allCases, id: \.self) { background in
                        Button(action: {
                            selectedBackground = background
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(background.rawValue)
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                                
                                Text(background.description)
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                                
                                HStack {
                                    ForEach(background.bonuses.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { stat in
                                        Label("+\(background.bonuses[stat] ?? 0)", systemImage: "plus.circle.fill")
                                            .font(MindLabsTypography.caption2())
                                            .foregroundColor(stat.color)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(selectedBackground == background ? Color.mindLabsPurple.opacity(0.1) : Color.mindLabsBorder.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedBackground == background ? Color.mindLabsPurple : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var reviewStep: some View {
        VStack(spacing: 30) {
            Text("Review Your Character")
                .font(MindLabsTypography.title2())
                .bold()
                .foregroundColor(.mindLabsText)
            
            VStack(spacing: 20) {
                Text(selectedAvatar)
                    .font(.system(size: 100))
                
                Text(characterName)
                    .font(MindLabsTypography.title())
                    .bold()
                    .foregroundColor(.mindLabsText)
                
                if let selectedClass = selectedClass {
                    HStack {
                        Text(selectedClass.icon)
                        Text(selectedClass.rawValue)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                    }
                }
                
                if let selectedBackground = selectedBackground {
                    Text("\(selectedBackground.rawValue) Background")
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                // Starting Stats Preview
                VStack(spacing: 10) {
                    Text("Starting Stats")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                        ForEach(StatType.allCases, id: \.self) { stat in
                            VStack {
                                Text(stat.icon)
                                    .font(.title2)
                                Text(stat.rawValue.prefix(3))
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                                Text("\(calculateStartingStat(for: stat))")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.mindLabsBorder.opacity(0.3))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    var canProceed: Bool {
        switch currentStep {
        case 0:
            return !characterName.isEmpty
        case 1:
            return selectedClass != nil
        case 2:
            return selectedBackground != nil
        case 3:
            return true
        default:
            return false
        }
    }
    
    func calculateStartingStat(for stat: StatType) -> Int {
        var value = 10
        
        if let selectedClass = selectedClass,
           let bonus = selectedClass.statBonuses[stat] {
            value += bonus
        }
        
        if let selectedBackground = selectedBackground,
           let bonus = selectedBackground.bonuses[stat] {
            value += bonus
        }
        
        return value
    }
    
    func createCharacter() {
        guard let selectedClass = selectedClass,
              let selectedBackground = selectedBackground else { return }
        
        gameManager.createCharacter(
            name: characterName,
            characterClass: selectedClass,
            background: selectedBackground,
            avatar: selectedAvatar
        )
    }
}

struct CharacterCreationView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCreationView()
            .environmentObject(GameManager())
    }
}