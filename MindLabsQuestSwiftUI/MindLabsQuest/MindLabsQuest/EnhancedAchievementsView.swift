import SwiftUI
import UIKit

struct EnhancedAchievementsView: View {
    @StateObject private var achievementManager = AchievementManager()
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    @State private var showingAchievementDetail: Achievement? = nil
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Progress
                    OverallProgressCard(achievementManager: achievementManager)
                    
                    // Streak Card
                    CurrentStreakCard(streak: gameManager.character.streak)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            CategoryFilterButton(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    color: category.color,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Achievements Grid
                    let achievements = selectedCategory != nil
                        ? achievementManager.achievements.filter { $0.category == selectedCategory }
                        : achievementManager.achievements
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(achievements) { achievement in
                            EnhancedAchievementCard(achievement: achievement)
                                .onTapGesture {
                                    showingAchievementDetail = achievement
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Secret Achievements Section
                    if hasSecretAchievements {
                        SecretAchievementsSection()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
            .sheet(item: $showingAchievementDetail) { achievement in
                AchievementDetailView(achievement: achievement, onShare: { shareAchievement(achievement) })
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    AchievementShareSheet(items: [image])
                }
            }
        }
        .overlay(
            Group {
                if achievementManager.showAchievementUnlocked,
                   let achievement = achievementManager.unlockedAchievement {
                    AchievementUnlockedNotification(achievement: achievement)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(100)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    achievementManager.showAchievementUnlocked = false
                                }
                            }
                        }
                }
            }
        )
    }
    
    var hasSecretAchievements: Bool {
        // You can add secret achievements logic here
        false
    }
    
    func shareAchievement(_ achievement: Achievement) {
        // Create a shareable image of the achievement
        let view = AchievementShareView(achievement: achievement, character: gameManager.character)
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 400, height: 300)
        controller.view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300))
        shareImage = renderer.image { _ in
            controller.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        showShareSheet = true
    }
}

// MARK: - Supporting Views
struct OverallProgressCard: View {
    @ObservedObject var achievementManager: AchievementManager
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Achievement Progress")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Text("\(achievementManager.unlockedCount) of \(achievementManager.totalCount) unlocked")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.mindLabsPurple.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: achievementManager.progressPercentage)
                        .stroke(LinearGradient.mindLabsPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(achievementManager.progressPercentage * 100))%")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsPurple)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.mindLabsPurple.opacity(0.2))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient.mindLabsPrimary)
                        .frame(width: geometry.size.width * achievementManager.progressPercentage, height: 10)
                }
            }
            .frame(height: 10)
        }
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct CurrentStreakCard: View {
    let streak: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Streak")
                    .font(MindLabsTypography.subheadline())
                    .foregroundColor(.mindLabsTextSecondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text("\(streak)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.mindLabsText)
                    
                    Text("days")
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            Spacer()
            
            ZStack {
                ForEach(0..<min(streak, 5), id: \.self) { index in
                    Text("🔥")
                        .font(.system(size: 30))
                        .offset(x: CGFloat(index * 10), y: CGFloat(-index * 5))
                        .rotationEffect(.degrees(Double.random(in: -10...10)))
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.red.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct CategoryFilterButton: View {
    let title: String
    var color: Color = .mindLabsPurple
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MindLabsTypography.caption())
                .foregroundColor(isSelected ? .white : .mindLabsText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? color : Color.mindLabsCard
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.mindLabsPurple.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct EnhancedAchievementCard: View {
    let achievement: Achievement
    
    var progressPercentage: Double {
        guard achievement.requiredValue > 0 else { return 0 }
        return min(Double(achievement.progress) / Double(achievement.requiredValue), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.category.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                if achievement.isUnlocked {
                    Text(achievement.icon)
                        .font(.system(size: 40))
                } else {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .trim(from: 0, to: progressPercentage)
                            .stroke(achievement.category.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                        
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(achievement.isUnlocked ? .mindLabsText : .mindLabsTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if !achievement.isUnlocked {
                    Text("\(achievement.progress)/\(achievement.requiredValue)")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.mindLabsCard)
        .cornerRadius(15)
        .shadow(color: achievement.isUnlocked ? achievement.category.color.opacity(0.3) : Color.clear, radius: 5)
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    let onShare: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Achievement Icon
                ZStack {
                    Circle()
                        .fill(achievement.category.color.opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    if achievement.isUnlocked {
                        Text(achievement.icon)
                            .font(.system(size: 80))
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                
                // Achievement Info
                VStack(spacing: 15) {
                    Text(achievement.title)
                        .font(MindLabsTypography.title())
                        .foregroundColor(.mindLabsText)
                    
                    Text(achievement.description)
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if achievement.isUnlocked, let date = achievement.unlockedDate {
                        Label {
                            Text("Unlocked \(date, style: .date)")
                                .font(MindLabsTypography.caption())
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .foregroundColor(.mindLabsPurple)
                    } else {
                        ProgressView(value: Double(achievement.progress), total: Double(achievement.requiredValue))
                            .progressViewStyle(LinearProgressViewStyle(tint: achievement.category.color))
                            .frame(width: 200)
                        
                        Text("\(achievement.progress) / \(achievement.requiredValue)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                Spacer()
                
                if achievement.isUnlocked {
                    Button(action: onShare) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Achievement")
                        }
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.white)
                        .padding()
                        .background(achievement.category.color)
                        .cornerRadius(15)
                    }
                }
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
        }
        .mindLabsBackground()
    }
}

struct AchievementUnlockedNotification: View {
    let achievement: Achievement
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(achievement.category.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text(achievement.icon)
                        .font(.system(size: 30))
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievement Unlocked!")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.white)
                    
                    Text(achievement.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [achievement.category.color, achievement.category.color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding()
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct SecretAchievementsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Secret Achievements")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<3) { _ in
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Text("?")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                            
                            Text("???")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        .frame(width: 100)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct AchievementShareView: View {
    let achievement: Achievement
    let character: Character
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(achievement.icon)
                    .font(.system(size: 60))
                
                VStack(alignment: .leading) {
                    Text(achievement.title)
                        .font(.title)
                        .bold()
                    Text("Unlocked by \(character.name)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Text(achievement.description)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Text("Mind Labs Quest")
                .font(.caption)
                .foregroundColor(.purple)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct AchievementShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct EnhancedAchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedAchievementsView()
            .environmentObject(GameManager())
    }
}