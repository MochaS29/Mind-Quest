import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var currentStep = 0
    @State private var characterName = ""
    @State private var selectedAvatar = "🧙‍♂️"
    @State private var selectedClass: CharacterClass?
    @State private var selectedBackground: Background?
    @State private var selectedTraits: Set<CharacterTrait> = []
    @State private var selectedMotivation: CharacterMotivation?
    @State private var selectedDailyQuests: Set<String> = []
    
    let avatars = ["🧙‍♂️", "🧙‍♀️", "🦸", "🦹‍♀️", "🧑‍🎓", "👩‍🎓", "🧑‍💻", "👩‍💻", "🧑‍🎨", "👩‍🎨", "🏃", "🏃‍♀️"]
    let maxTraits = 2
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Indicator
                HStack {
                    ForEach(0..<7) { index in
                        Circle()
                            .fill(index <= currentStep ? Color.mindLabsPurple : Color.mindLabsBorder)
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentStep ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentStep)
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
                        traitsSelectionStep
                    case 4:
                        motivationSelectionStep
                    case 5:
                        dailyQuestsStep
                    case 6:
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
                    
                    Button(currentStep == 6 ? "Begin Adventure!" : "Next") {
                        if currentStep == 6 {
                            createCharacter()
                        } else {
                            if canProceed {
                                currentStep += 1
                            }
                        }
                    }
                    .buttonStyle(MindLabsPrimaryButtonStyle())
                    .frame(width: 180)
                    .disabled(!canProceed)
                    .opacity(canProceed ? 1.0 : 0.6)
                }
                .padding()
            }
            .navigationTitle("Create Your Hero")
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
                Text("Hero Name")
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
                                .scaleEffect(selectedAvatar == avatar ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3), value: selectedAvatar)
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
                            .scaleEffect(selectedClass == characterClass ? 1.02 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedClass)
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
    
    var traitsSelectionStep: some View {
        VStack(spacing: 20) {
            Text("🌟")
                .font(.system(size: 60))
            
            Text("Select Your Traits")
                .font(MindLabsTypography.title())
                .bold()
                .foregroundColor(.mindLabsText)
            
            Text("Choose up to \(maxTraits) traits that define you")
                .font(MindLabsTypography.subheadline())
                .foregroundColor(.mindLabsTextSecondary)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(CharacterTrait.allCases, id: \.self) { trait in
                        Button(action: {
                            if selectedTraits.contains(trait) {
                                selectedTraits.remove(trait)
                            } else if selectedTraits.count < maxTraits {
                                selectedTraits.insert(trait)
                            }
                        }) {
                            HStack {
                                Text(trait.icon)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(trait.rawValue)
                                        .font(MindLabsTypography.headline())
                                        .foregroundColor(.mindLabsText)
                                    
                                    Text(trait.description)
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                                
                                Spacer()
                                
                                if selectedTraits.contains(trait) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.mindLabsPurple)
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(selectedTraits.contains(trait) ? Color.mindLabsPurple.opacity(0.1) : Color.mindLabsBorder.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedTraits.contains(trait) ? Color.mindLabsPurple : Color.clear, lineWidth: 2)
                            )
                        }
                        .disabled(!selectedTraits.contains(trait) && selectedTraits.count >= maxTraits)
                        .opacity((!selectedTraits.contains(trait) && selectedTraits.count >= maxTraits) ? 0.5 : 1.0)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var motivationSelectionStep: some View {
        VStack(spacing: 20) {
            Text("🎯")
                .font(.system(size: 60))
            
            Text("What Drives You?")
                .font(MindLabsTypography.title())
                .bold()
                .foregroundColor(.mindLabsText)
            
            Text("Choose your primary motivation")
                .font(MindLabsTypography.subheadline())
                .foregroundColor(.mindLabsTextSecondary)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(CharacterMotivation.allCases, id: \.self) { motivation in
                        MotivationCard(
                            motivation: motivation,
                            isSelected: selectedMotivation == motivation,
                            onSelect: { selectedMotivation = motivation }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var dailyQuestsStep: some View {
        VStack(spacing: 20) {
            Text("📋")
                .font(.system(size: 60))
            
            Text("Daily Quest Setup")
                .font(MindLabsTypography.title())
                .bold()
                .foregroundColor(.mindLabsText)
            
            Text("Select your daily quests")
                .font(MindLabsTypography.subheadline())
                .foregroundColor(.mindLabsTextSecondary)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(["Morning", "Afternoon", "Evening"], id: \.self) { timeOfDay in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(timeOfDay) Routines")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(getTemplatesForTime(timeOfDay), id: \.id) { template in
                                        DailyQuestTemplateCard(
                                            template: template,
                                            isSelected: selectedDailyQuests.contains(template.id),
                                            onToggle: {
                                                if selectedDailyQuests.contains(template.id) {
                                                    selectedDailyQuests.remove(template.id)
                                                } else {
                                                    selectedDailyQuests.insert(template.id)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            
            Text("\(selectedDailyQuests.count) daily quests selected")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
        }
    }
    
    var reviewStep: some View {
        VStack(spacing: 30) {
            Text("Review Your Hero")
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
                
                if !selectedTraits.isEmpty {
                    HStack {
                        ForEach(Array(selectedTraits), id: \.self) { trait in
                            HStack(spacing: 4) {
                                Text(trait.icon)
                                Text(trait.rawValue)
                            }
                            .font(MindLabsTypography.caption())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.mindLabsPurple.opacity(0.2))
                            .cornerRadius(15)
                        }
                    }
                }
                
                if let motivation = selectedMotivation {
                    Text(motivation.rawValue)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsPurple)
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
                
                Text("\(selectedDailyQuests.count) daily quests selected")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
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
            return !selectedTraits.isEmpty
        case 4:
            return selectedMotivation != nil
        case 5:
            return true // Daily quests are optional
        case 6:
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
              let selectedBackground = selectedBackground,
              let selectedMotivation = selectedMotivation else { return }
        
        gameManager.createCharacter(
            name: characterName,
            characterClass: selectedClass,
            background: selectedBackground,
            avatar: selectedAvatar,
            traits: Array(selectedTraits),
            motivation: selectedMotivation,
            dailyQuestIds: selectedDailyQuests
        )
    }
    
    func getTemplatesForTime(_ timeOfDay: String) -> [DailyQuestTemplate] {
        return DailyQuestTemplate.allTemplates.filter { template in
            template.timeOfDay.rawValue == timeOfDay || template.timeOfDay == .anytime
        }
    }
}

// MARK: - Daily Quest Template Card
struct DailyQuestTemplateCard: View {
    let template: DailyQuestTemplate
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 8) {
                Text(template.icon)
                    .font(.title)
                
                Text(template.normalTitle)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text("\(template.baseXP)")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsBlue)
                    Text("XP")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            .frame(width: 100, height: 120)
            .background(backgroundView)
            .cornerRadius(10)
            .overlay(borderView)
        }
    }
    
    private var backgroundView: some View {
        Group {
            if isSelected {
                LinearGradient.mindLabsPrimary.opacity(0.2)
            } else {
                Color.mindLabsBorder.opacity(0.1)
            }
        }
    }
    
    private var borderView: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(
                isSelected ? Color.mindLabsPurple : Color.clear,
                lineWidth: 2
            )
    }
}

// MARK: - Motivation Card
struct MotivationCard: View {
    let motivation: CharacterMotivation
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 10) {
                Text(motivation.rawValue)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Text(motivation.description)
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)
                    .multilineTextAlignment(.center)
                
                if let bonus = motivation.questBonus {
                    bonusView(for: bonus)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundView)
            .cornerRadius(15)
            .overlay(borderView)
        }
    }
    
    private func bonusView(for bonus: TaskCategory) -> some View {
        HStack {
            Text(bonus.icon)
            Text("Bonus to \(bonus.rawValue) quests")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsPurple)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .background(Color.mindLabsPurple.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var backgroundView: some View {
        Group {
            if isSelected {
                LinearGradient.mindLabsPrimary.opacity(0.1)
            } else {
                Color.mindLabsBorder.opacity(0.05)
            }
        }
    }
    
    private var borderView: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(
                isSelected ? Color.mindLabsPurple : Color.clear,
                lineWidth: 2
            )
    }
}

struct CharacterCreationView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCreationView()
            .environmentObject(GameManager())
    }
}