import SwiftUI

struct ChallengeDetailView: View {
    let challenge: CommunityChallenge
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var challengeManager = ChallengeManager.shared
    @State private var showingJoinConfirmation = false
    @State private var showingLeaveConfirmation = false
    @State private var selectedTab: DetailTab = .overview
    
    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case leaderboard = "Leaderboard"
        case milestones = "Milestones"
        case rules = "Rules"
        
        var icon: String {
            switch self {
            case .overview: return "info.circle"
            case .leaderboard: return "chart.bar"
            case .milestones: return "flag.checkered"
            case .rules: return "list.bullet.rectangle"
            }
        }
    }
    
    var isParticipating: Bool {
        challengeManager.isUserParticipating(in: challenge)
    }
    
    var userProgress: UserChallengeProgress? {
        challengeManager.getUserProgress(for: challenge)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Challenge Header
                    challengeHeader
                    
                    // Tab Selector
                    tabSelector
                    
                    // Tab Content
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .overview:
                            overviewContent
                        case .leaderboard:
                            leaderboardContent
                        case .milestones:
                            milestonesContent
                        case .rules:
                            rulesContent
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .mindLabsBackground()
            .alert("Join Challenge?", isPresented: $showingJoinConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Join") {
                    joinChallenge()
                }
            } message: {
                Text("Ready to take on \(challenge.title)?")
            }
            .alert("Leave Challenge?", isPresented: $showingLeaveConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Leave", role: .destructive) {
                    leaveChallenge()
                }
            } message: {
                Text("Are you sure you want to leave this challenge? Your progress will be lost.")
            }
        }
    }
    
    // MARK: - Challenge Header
    var challengeHeader: some View {
        VStack(spacing: 20) {
            // Banner or Icon
            if let bannerImage = challenge.bannerImage {
                Image(systemName: bannerImage)
                    .font(.system(size: 60))
                    .foregroundColor(.mindLabsPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(
                        LinearGradient(
                            colors: [
                                challenge.category.color.opacity(0.3),
                                challenge.category.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 15) {
                // Title and Category
                VStack(spacing: 8) {
                    Text(challenge.title)
                        .font(MindLabsTypography.largeTitle())
                        .foregroundColor(.mindLabsText)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 10) {
                        CategoryBadge(
                            text: challenge.category.rawValue,
                            color: challenge.category.color
                        )
                        
                        CategoryBadge(
                            text: challenge.difficulty.rawValue,
                            color: challenge.difficulty.color
                        )
                    }
                }
                
                // Time and Participants
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text(challenge.timeRemaining)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(challenge.timeRemaining == "Ended" ? .red : .mindLabsPurple)
                        Text("Time Left")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(challenge.participants.count)")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsPurple)
                        Text("Participants")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    if let rank = challengeManager.getUserRank(in: challenge) {
                        VStack(spacing: 4) {
                            Text("#\(rank)")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsPurple)
                            Text("Your Rank")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                }
                
                // Action Button
                if challenge.timeRemaining != "Ended" {
                    if isParticipating {
                        HStack(spacing: 15) {
                            Button(action: { showingLeaveConfirmation = true }) {
                                Text("Leave Challenge")
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsError)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.mindLabsError.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: updateProgress) {
                                Text("Update Progress")
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.mindLabsPurple)
                                    .cornerRadius(10)
                            }
                        }
                    } else {
                        Button(action: { showingJoinConfirmation = true }) {
                            Text("Join Challenge")
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.mindLabsPurple)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.mindLabsCard)
    }
    
    // MARK: - Tab Selector
    var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    ChallengeTabButton(
                        title: tab.rawValue,
                        icon: tab.icon,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.mindLabsCard)
    }
    
    // MARK: - Overview Content
    var overviewContent: some View {
        VStack(spacing: 20) {
            // Description
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Label("About", systemImage: "info.circle")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Text(challenge.description)
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            // Goal
            MindLabsCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Goal")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        Text("\(challenge.goal) \(challenge.unit)")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                    }
                    
                    Spacer()
                    
                    if let progress = userProgress {
                        CircularProgressView(
                            progress: Double(progress.currentProgress) / Double(challenge.goal),
                            lineWidth: 8,
                            size: 60
                        ) {
                            Text("\(Int((Double(progress.currentProgress) / Double(challenge.goal)) * 100))%")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsPurple)
                        }
                    }
                }
            }
            
            // Rewards
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Label("Rewards", systemImage: "gift")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ChallengeRewardRow(
                            icon: "star.fill",
                            text: "\(challenge.reward.xp) XP",
                            color: .orange
                        )
                        
                        if let badge = challenge.reward.badge {
                            ChallengeRewardRow(
                                icon: "rosette",
                                text: "Badge: \(badge)",
                                color: .purple
                            )
                        }
                        
                        if let title = challenge.reward.title {
                            ChallengeRewardRow(
                                icon: "crown.fill",
                                text: "Title: \(title)",
                                color: .yellow
                            )
                        }
                        
                        ForEach(challenge.reward.bonusRewards, id: \.self) { bonus in
                            ChallengeRewardRow(
                                icon: "sparkles",
                                text: bonus,
                                color: .blue
                            )
                        }
                    }
                }
            }
            
            // Created By
            HStack {
                Text("Created by \(challenge.createdBy)")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
                Spacer()
            }
        }
    }
    
    // MARK: - Leaderboard Content
    var leaderboardContent: some View {
        VStack(spacing: 15) {
            // Top 3
            if challenge.participants.count >= 3 {
                HStack(alignment: .bottom, spacing: 20) {
                    // 2nd Place
                    if challenge.participants.count > 1 {
                        PodiumView(
                            participant: challengeManager.getLeaderboard(for: challenge)[1],
                            rank: 2,
                            height: 80
                        )
                    }
                    
                    // 1st Place
                    PodiumView(
                        participant: challengeManager.getLeaderboard(for: challenge)[0],
                        rank: 1,
                        height: 100
                    )
                    
                    // 3rd Place
                    if challenge.participants.count > 2 {
                        PodiumView(
                            participant: challengeManager.getLeaderboard(for: challenge)[2],
                            rank: 3,
                            height: 60
                        )
                    }
                }
                .padding(.bottom, 20)
            }
            
            // Full Leaderboard
            ForEach(Array(challengeManager.getLeaderboard(for: challenge).enumerated()), id: \.element.id) { index, participant in
                LeaderboardRowView(
                    participant: participant,
                    rank: index + 1,
                    challenge: challenge,
                    isCurrentUser: participant.userId == "current_user"
                )
            }
        }
    }
    
    // MARK: - Milestones Content
    var milestonesContent: some View {
        VStack(spacing: 15) {
            if let progress = userProgress {
                ForEach(progress.milestones) { milestone in
                    MilestoneCard(
                        milestone: milestone,
                        currentProgress: progress.currentProgress
                    )
                }
            } else {
                ChallengeEmptyStateCard(
                    icon: "flag.slash",
                    title: "Join to See Milestones",
                    description: "Milestones help you track your progress and earn bonus rewards"
                )
            }
        }
    }
    
    // MARK: - Rules Content
    var rulesContent: some View {
        VStack(spacing: 15) {
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Label("Challenge Rules", systemImage: "list.bullet")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    if challenge.rules.isEmpty {
                        Text("Standard challenge rules apply")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsTextSecondary)
                    } else {
                        ForEach(Array(challenge.rules.enumerated()), id: \.offset) { index, rule in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1).")
                                    .font(MindLabsTypography.body())
                                    .foregroundColor(.mindLabsPurple)
                                
                                Text(rule)
                                    .font(MindLabsTypography.body())
                                    .foregroundColor(.mindLabsTextSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
            
            // General Guidelines
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Label("General Guidelines", systemImage: "info.circle")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        GuidelineRow(text: "Progress updates automatically based on your activity")
                        GuidelineRow(text: "Cheating or exploits will result in disqualification")
                        GuidelineRow(text: "Be supportive and encouraging to other participants")
                        GuidelineRow(text: "Have fun and challenge yourself!")
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    private func joinChallenge() {
        challengeManager.joinChallenge(
            challenge,
            username: gameManager.character.name,
            avatar: gameManager.character.avatar
        )
    }
    
    private func leaveChallenge() {
        challengeManager.leaveChallenge(challenge)
    }
    
    private func updateProgress() {
        // In a real app, this would calculate progress based on actual data
        let simulatedProgress = Int.random(in: 1...5)
        if let currentProgress = userProgress {
            let newProgress = min(currentProgress.currentProgress + simulatedProgress, challenge.goal)
            challengeManager.updateProgress(for: challenge.id, progress: newProgress)
        }
    }
}

// MARK: - Supporting Views

struct CategoryBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(MindLabsTypography.caption())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(12)
    }
}

struct ChallengeTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(MindLabsTypography.caption())
            }
            .foregroundColor(isSelected ? .mindLabsPurple : .mindLabsTextSecondary)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.mindLabsPurple.opacity(0.1) : Color.clear
            )
            .cornerRadius(10)
        }
    }
}

struct CircularProgressView<Content: View>: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.mindLabsPurple.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(Color.mindLabsPurple, lineWidth: lineWidth)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            content()
        }
    }
}

struct ChallengeRewardRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(text)
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsText)
        }
    }
}

struct PodiumView: View {
    let participant: ChallengeParticipant
    let rank: Int
    let height: CGFloat
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.75)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            // Avatar
            Text(participant.avatar)
                .font(.system(size: rank == 1 ? 40 : 30))
            
            // Username
            Text(participant.username)
                .font(MindLabsTypography.caption2())
                .foregroundColor(.mindLabsText)
                .lineLimit(1)
            
            // Progress
            Text("\(participant.progress)")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsPurple)
            
            // Podium
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(rankColor)
                    .frame(width: 80, height: height)
                
                Text("\(rank)")
                    .font(MindLabsTypography.largeTitle())
                    .foregroundColor(.white)
            }
        }
    }
}

struct LeaderboardRowView: View {
    let participant: ChallengeParticipant
    let rank: Int
    let challenge: CommunityChallenge
    let isCurrentUser: Bool
    
    var body: some View {
        MindLabsCard {
            HStack(spacing: 15) {
                // Rank
                Text("#\(rank)")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(rank <= 3 ? .mindLabsPurple : .mindLabsTextSecondary)
                    .frame(width: 40)
                
                // Avatar
                Text(participant.avatar)
                    .font(.title2)
                
                // Name and Progress
                VStack(alignment: .leading, spacing: 2) {
                    Text(participant.username)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Text("\(participant.progress) \(challenge.unit)")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                // Progress Percentage
                Text("\(Int((Double(participant.progress) / Double(challenge.goal)) * 100))%")
                    .font(MindLabsTypography.subheadline())
                    .foregroundColor(.mindLabsPurple)
                
                if isCurrentUser {
                    Image(systemName: "person.fill")
                        .foregroundColor(.mindLabsPurple)
                }
            }
        }
        .overlay(
            isCurrentUser ?
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.mindLabsPurple, lineWidth: 2) : nil
        )
    }
}

struct MilestoneCard: View {
    let milestone: ChallengeMilestone
    let currentProgress: Int
    
    var isUnlocked: Bool {
        currentProgress >= milestone.threshold
    }
    
    var body: some View {
        MindLabsCard {
            HStack {
                // Status Icon
                Image(systemName: milestone.isAchieved ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(milestone.isAchieved ? .green : .mindLabsTextSecondary)
                
                // Milestone Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reach \(milestone.threshold)")
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(isUnlocked ? .mindLabsText : .mindLabsTextSecondary)
                    
                    Text(milestone.reward)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsPurple)
                }
                
                Spacer()
                
                if milestone.isAchieved, let date = milestone.achievedDate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
            }
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
    }
}

struct GuidelineRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
                .padding(.top, 2)
            
            Text(text)
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ChallengeEmptyStateCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.mindLabsTextSecondary)
                
                Text(title)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Text(description)
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

// MARK: - Create Challenge View (Placeholder)
struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create Custom Challenge")
                    .font(MindLabsTypography.largeTitle())
                    .foregroundColor(.mindLabsText)
                
                Text("Coming Soon!")
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .mindLabsBackground()
        }
    }
}

struct ChallengeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeDetailView(challenge: CommunityChallenge(
            title: "Daily Productivity Sprint",
            description: "Complete 5 quests today",
            category: .daily,
            difficulty: .easy,
            type: .questCount,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            goal: 5,
            unit: "quests",
            reward: ChallengeReward(xp: 200, badge: "daily_warrior")
        ))
        .environmentObject(GameManager())
    }
}