import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showNewQuestSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Character Header
                    CharacterHeaderView()
                    
                    // Daily Progress
                    DailyProgressCard()
                    
                    // Quick Adventures
                    QuickAdventuresCard(showNewQuestSheet: $showNewQuestSheet)
                    
                    // Character Status
                    CharacterStatusCard()
                }
                .padding()
            }
            .navigationTitle("Mind Labs Quest")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewQuestSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                    }
                }
            }
        }
        .sheet(isPresented: $showNewQuestSheet) {
            NewQuestView()
        }
    }
}

struct CharacterHeaderView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 15) {
            HStack {
                Text(gameManager.character.avatar)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading) {
                    Text(gameManager.character.name)
                        .font(MindLabsTypography.title2())
                        .bold()
                        .foregroundColor(.mindLabsText)
                    
                    if let characterClass = gameManager.character.characterClass {
                        Text("Level \(gameManager.character.level) \(characterClass.rawValue)")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(gameManager.character.gold)")
                            .bold()
                            .foregroundColor(.mindLabsText)
                    }
                    
                    Text("\(gameManager.character.xp)/\(gameManager.character.xpToNext) XP")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            // Health Bar
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(gameManager.character.health)/\(gameManager.character.maxHealth)")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsText)
                    Spacer()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.mindLabsBorder.opacity(0.5))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(LinearGradient(colors: [Color.mindLabsError.opacity(0.8), Color.mindLabsError], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geometry.size.width * CGFloat(gameManager.character.health) / CGFloat(gameManager.character.maxHealth), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            
            // XP Bar
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.blue)
                    Text("Level \(gameManager.character.level)")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsText)
                    Spacer()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.mindLabsBorder.opacity(0.5))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(LinearGradient.mindLabsPrimary)
                            .frame(width: geometry.size.width * CGFloat(gameManager.character.xp) / CGFloat(gameManager.character.xpToNext), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            }
        }
    }
}

struct DailyProgressCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var progress: Double {
        guard gameManager.todayQuests.count > 0 else { return 0 }
        return Double(gameManager.completedTodayCount) / Double(gameManager.todayQuests.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Today's Adventures")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.white)
                Spacer()
                Text("\(gameManager.completedTodayCount)/\(gameManager.todayQuests.count) completed")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.white.opacity(0.8))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 12)
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(LinearGradient.mindLabsAccent)
                        .frame(width: geometry.size.width * progress, height: 12)
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
            
            Text(gameManager.completedTodayCount == gameManager.todayQuests.count && gameManager.todayQuests.count > 0 
                 ? "🎉 All adventures completed! Epic!" 
                 : "\(gameManager.todayQuests.count - gameManager.completedTodayCount) adventures remaining")
                .font(MindLabsTypography.caption())
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(LinearGradient.mindLabsPrimary)
        .foregroundColor(.white)
        .cornerRadius(15)
        .mindLabsCardShadow()
    }
}

struct QuickAdventuresCard: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var showNewQuestSheet: Bool
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Quick Adventures")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                Spacer()
                Button(action: {
                    showNewQuestSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    Button(action: {
                        // Quick create quest for this category
                        showNewQuestSheet = true
                    }) {
                        VStack(spacing: 8) {
                            Text(category.icon)
                                .font(.system(size: 30))
                            Text(category.rawValue)
                                .font(MindLabsTypography.caption())
                                .bold()
                            Text("+\(category.primaryStat.rawValue.prefix(3).uppercased())")
                                .font(MindLabsTypography.caption2())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [category.color.opacity(0.8), category.color], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .mindLabsButtonShadow()
                    }
                }
            }
        }
    }
}

struct CharacterStatusCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Character Status")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
            
            HStack {
                Text(gameManager.character.avatar)
                    .font(.system(size: 60))
                
                VStack(alignment: .leading) {
                    Text(gameManager.character.name)
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    if let characterClass = gameManager.character.characterClass {
                        Text("Level \(gameManager.character.level) \(characterClass.rawValue)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Text("Next Level: \(gameManager.character.xpToNext - gameManager.character.xp) XP")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsPurple)
                }
                
                Spacer()
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(GameManager())
    }
}