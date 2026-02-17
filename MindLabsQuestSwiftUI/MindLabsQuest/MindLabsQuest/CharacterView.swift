import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showEditSheet = false
    @State private var showAchievementsSheet = false
    @State private var showRewardsSheet = false
    @State private var showParentModeSheet = false
    @State private var showTimeAnalyticsSheet = false
    @State private var showNotificationSettings = false
    @State private var showADHDTools = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Character Card
                    CharacterCard()
                    
                    // Ability Scores
                    AbilityScoresCard()
                    
                    // Progress Stats
                    ProgressStatsCard(showTimeAnalyticsSheet: $showTimeAnalyticsSheet)
                    
                    // Equipment
                    EquipmentCard()
                    
                    // Class Abilities
                    ClassAbilitiesCard()
                    
                    // Achievements Preview
                    AchievementsPreviewCard()
                    
                    // Parent Rewards
                    ParentRewardsPreviewCard(showRewardsSheet: $showRewardsSheet)
                    
                    // ADHD Tools
                    ADHDToolsCard(showADHDTools: $showADHDTools)
                    
                    // Settings
                    SettingsCard(showNotificationSettings: $showNotificationSettings)
                }
                .padding()
            }
            .navigationTitle("Character")
            .mindLabsBackground()
            .navigationBarItems(
                leading: Button(action: {
                    showParentModeSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.shield")
                        Text("Parent")
                    }
                    .font(.caption)
                    .foregroundColor(.mindLabsPurple)
                },
                trailing: Button(action: {
                    showEditSheet = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                        .font(.title2)
                }
            )
            .sheet(isPresented: $showEditSheet) {
                CharacterEditView()
            }
            .sheet(isPresented: $showAchievementsSheet) {
                EnhancedAchievementsView()
            }
            .sheet(isPresented: $showRewardsSheet) {
                RewardsView()
            }
            .sheet(isPresented: $showParentModeSheet) {
                ParentModeView()
            }
            .sheet(isPresented: $showTimeAnalyticsSheet) {
                TimeAnalyticsView()
            }
            .sheet(isPresented: $showNotificationSettings) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showADHDTools) {
                ADHDToolsHub()
            }
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
}

struct AchievementsPreviewCard: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showAchievementsSheet = false
    
    var achievementManager: AchievementManager {
        gameManager.achievementManager
    }
    
    var recentAchievements: [Achievement] {
        achievementManager.achievements
            .filter { $0.isUnlocked }
            .sorted { (a, b) in
                (a.unlockedDate ?? Date.distantPast) > (b.unlockedDate ?? Date.distantPast)
            }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Achievements")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Spacer()
                    
                    Button(action: {
                        showAchievementsSheet = true
                    }) {
                        Text("View All")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsPurple)
                    }
                }
                
                // Progress
                HStack {
                    Text("\(achievementManager.unlockedCount)/\(achievementManager.totalCount) Unlocked")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Spacer()
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.mindLabsBorder.opacity(0.3))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(LinearGradient.mindLabsPrimary)
                                .frame(width: geometry.size.width * achievementManager.progressPercentage, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(width: 100, height: 6)
                }
                
                // Recent achievements
                if !recentAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent")
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        HStack(spacing: 15) {
                            ForEach(recentAchievements) { achievement in
                                VStack {
                                    Text(achievement.icon)
                                        .font(.system(size: 30))
                                    Text(achievement.title)
                                        .font(MindLabsTypography.caption2())
                                        .foregroundColor(.mindLabsText)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAchievementsSheet) {
            AchievementsView()
        }
    }
}

struct ParentRewardsPreviewCard: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showRewardsSheet: Bool
    
    var parentRewardManager: ParentRewardManager {
        gameManager.parentRewardManager
    }
    
    var eligibleCount: Int {
        parentRewardManager.getEligibleRewards(
            for: gameManager.character,
            achievements: gameManager.achievementManager.achievements
        ).count
    }
    
    var nextReward: ParentReward? {
        parentRewardManager.parentRewards
            .filter { $0.isActive && !$0.isClaimed && $0.requiredLevel > gameManager.character.level }
            .sorted { $0.requiredLevel < $1.requiredLevel }
            .first
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Parent Rewards")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Spacer()
                    
                    Button(action: {
                        showRewardsSheet = true
                    }) {
                        Text("View All")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsPurple)
                    }
                }
                
                if eligibleCount > 0 {
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.mindLabsPurple)
                        Text("\(eligibleCount) reward\(eligibleCount == 1 ? "" : "s") available!")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsPurple)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.mindLabsPurple.opacity(0.1))
                    .cornerRadius(8)
                }
                
                if let nextReward = nextReward {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Next Reward")
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(nextReward.title)
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsText)
                                Text("Level \(nextReward.requiredLevel)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            
                            Spacer()
                            
                            // Progress to next reward
                            let levelsToGo = nextReward.requiredLevel - gameManager.character.level
                            Text("\(levelsToGo) level\(levelsToGo == 1 ? "" : "s") away")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .onTapGesture {
            showRewardsSheet = true
        }
    }
}

struct CharacterEditView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var selectedAvatar: String = ""
    @State private var selectedClass: CharacterClass?
    @State private var selectedBackground: Background?
    @State private var showNameAlert = false
    @State private var showResetWarning = false
    
    let avatarOptions = ["🧙‍♂️", "🧙‍♀️", "⚔️", "🏹", "🛡️", "🗡️", "🎯", "🎭", "🦸‍♂️", "🦸‍♀️", "🧝‍♂️", "🧝‍♀️", "🧛‍♂️", "🧛‍♀️", "🧟‍♂️", "🧟‍♀️", "🤴", "👸", "🦹‍♂️", "🦹‍♀️"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Character Name") {
                    TextField("Character Name", text: $name)
                        .textFieldStyle(MindLabsTextFieldStyle())
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Avatar") {
                    let gridColumns = Array(repeating: GridItem(.flexible()), count: 5)
                    LazyVGrid(columns: gridColumns, spacing: 15) {
                        ForEach(avatarOptions, id: \.self) { avatar in
                            Button(action: {
                                selectedAvatar = avatar
                            }) {
                                Text(avatar)
                                    .font(.system(size: 40))
                                    .frame(width: 60, height: 60)
                                    .background(selectedAvatar == avatar ? Color.mindLabsPurple : Color.mindLabsBorder.opacity(0.2))
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(selectedAvatar == avatar ? Color.mindLabsPurple : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Character Class") {
                    ForEach(CharacterClass.allCases, id: \.self) { characterClass in
                        Button(action: {
                            selectedClass = characterClass
                        }) {
                            HStack {
                                Text(characterClass.icon)
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text(characterClass.rawValue)
                                        .font(MindLabsTypography.headline())
                                        .foregroundColor(.mindLabsText)
                                    Text(characterClass.description)
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                                Spacer()
                                if selectedClass == characterClass {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.mindLabsPurple)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Background") {
                    ForEach(Background.allCases, id: \.self) { background in
                        Button(action: {
                            selectedBackground = background
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(background.rawValue)
                                        .font(MindLabsTypography.headline())
                                        .foregroundColor(.mindLabsText)
                                    Text(background.description)
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.mindLabsTextSecondary)
                                }
                                Spacer()
                                if selectedBackground == background {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.mindLabsPurple)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Current Stats") {
                    HStack {
                        Text("Level")
                        Spacer()
                        Text("\(gameManager.character.level)")
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    HStack {
                        Text("XP")
                        Spacer()
                        Text("\(gameManager.character.xp)/\(gameManager.character.xpToNext)")
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    HStack {
                        Text("Gold")
                        Spacer()
                        Text("\(gameManager.character.gold)")
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                .listRowBackground(Color.mindLabsCard)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("Edit Character")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple),
                
                trailing: Button("Save") {
                    saveChanges()
                }
                .foregroundColor(.mindLabsPurple)
                .disabled(name.isEmpty || selectedClass == nil || selectedBackground == nil)
            )
            .onAppear {
                name = gameManager.character.name
                selectedAvatar = gameManager.character.avatar
                selectedClass = gameManager.character.characterClass
                selectedBackground = gameManager.character.background
            }
            .alert("Name Required", isPresented: $showNameAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a character name.")
            }
            .alert("Reset Character Stats?", isPresented: $showResetWarning) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    performFullCharacterUpdate()
                }
            } message: {
                Text("Changing your class or background will reset your stats. Your level, XP, and quests will be preserved.")
            }
        }
    }
    
    private func saveChanges() {
        guard !name.isEmpty else {
            showNameAlert = true
            return
        }
        
        // Check if class or background changed
        let classChanged = gameManager.character.characterClass != selectedClass
        let backgroundChanged = gameManager.character.background != selectedBackground
        
        if classChanged || backgroundChanged {
            showResetWarning = true
        } else {
            // Just update name and avatar
            gameManager.character.name = name
            gameManager.character.avatar = selectedAvatar
            gameManager.saveData()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func performFullCharacterUpdate() {
        // Update basic info
        gameManager.character.name = name
        gameManager.character.avatar = selectedAvatar
        
        if let newClass = selectedClass, let newBackground = selectedBackground {
            // Reset stats to base
            gameManager.character.stats = [
                .strength: 10,
                .dexterity: 10,
                .constitution: 10,
                .intelligence: 10,
                .wisdom: 10,
                .charisma: 10
            ]
            
            // Update class and background
            gameManager.character.characterClass = newClass
            gameManager.character.background = newBackground
            
            // Apply class bonuses
            let classBonuses = newClass.statBonuses
            for (stat, bonus) in classBonuses {
                gameManager.character.stats[stat, default: 10] += bonus
            }
            
            // Apply background bonuses
            for (stat, bonus) in newBackground.bonuses {
                gameManager.character.stats[stat, default: 10] += bonus
            }
            
            // Apply trait bonuses
            gameManager.character.applyTraitBonuses()
            
            // Recalculate health but keep current health ratio
            let healthRatio = Double(gameManager.character.health) / Double(gameManager.character.maxHealth)
            gameManager.character.maxHealth = 100 + (10 * gameManager.character.level)
            gameManager.character.health = Int(Double(gameManager.character.maxHealth) * healthRatio)
        }
        
        gameManager.saveData()
        presentationMode.wrappedValue.dismiss()
    }
}

struct ProgressStatsCard: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showTimeAnalyticsSheet: Bool
    
    var totalFocusHours: String {
        let totalMinutes = gameManager.character.totalFocusMinutes
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var timeAccuracy: String {
        let accuracy = gameManager.timeEstimateHistory.overallAccuracy
        if accuracy == 0 {
            return "--"
        }
        return "\(Int(accuracy * 100))%"
    }
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Progress Stats")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Spacer()
                    
                    Button(action: {
                        showTimeAnalyticsSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Analytics")
                        }
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsPurple)
                    }
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.mindLabsBlue)
                            Text("Focus Time")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        Text(totalFocusHours)
                            .font(MindLabsTypography.title2())
                            .foregroundColor(.mindLabsText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.mindLabsSuccess)
                            Text("Time Accuracy")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        Text(timeAccuracy)
                            .font(MindLabsTypography.title2())
                            .foregroundColor(.mindLabsText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.mindLabsPurple)
                            Text("Completed")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        Text("\(gameManager.character.totalQuestsCompleted)")
                            .font(MindLabsTypography.title2())
                            .foregroundColor(.mindLabsText)
                    }
                }
            }
        }
    }
}

struct SettingsCard: View {
    @Binding var showNotificationSettings: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.mindLabsPurple)
                
                Text("Settings")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "bell.badge.fill",
                    title: "Notifications",
                    subtitle: "Manage reminders and alerts",
                    action: {
                        showNotificationSettings = true
                    }
                )
                
                NavigationLink(destination: CalendarSyncView()) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.mindLabsPurple)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calendar Sync")
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)
                            Text("Connect iOS and Google calendars")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.mindLabsTextSecondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                }
                
                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Coming soon",
                    isDisabled: true,
                    action: {}
                )
            }
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDisabled ? .mindLabsTextSecondary : .mindLabsPurple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(isDisabled ? .mindLabsTextSecondary : .mindLabsText)
                    Text(subtitle)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.mindLabsTextSecondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .disabled(isDisabled)
    }
}

struct ADHDToolsCard: View {
    @Binding var showADHDTools: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.mindLabsPurple)
                
                Text("ADHD Tools")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
            }
            
            Button(action: { showADHDTools = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Focus Mode • Task Switching • Body Doubling")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        Text("Specialized tools to manage ADHD symptoms")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.mindLabsPurple)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.mindLabsPurple.opacity(0.1), Color.mindLabsPurple.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView()
            .environmentObject(GameManager())
    }
}