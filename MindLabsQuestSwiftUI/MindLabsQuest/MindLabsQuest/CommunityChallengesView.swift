import SwiftUI

struct CommunityChallengesView: View {
    @EnvironmentObject var gameManager: GameManager
    @StateObject private var challengeManager = ChallengeManager.shared
    @State private var selectedFilter: ChallengeFilter = .all
    @State private var showingChallengeDetail: CommunityChallenge?
    @State private var showingCreateChallenge = false
    
    enum ChallengeFilter: String, CaseIterable {
        case all = "All"
        case participating = "My Challenges"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .participating: return "person.fill"
            case .daily: return "sun.max"
            case .weekly: return "calendar"
            case .monthly: return "calendar.badge.clock"
            }
        }
    }
    
    var filteredChallenges: [CommunityChallenge] {
        switch selectedFilter {
        case .all:
            return challengeManager.activeChallenges
        case .participating:
            return challengeManager.activeChallenges.filter { challengeManager.isUserParticipating(in: $0) }
        case .daily:
            return challengeManager.activeChallenges.filter { $0.category == .daily }
        case .weekly:
            return challengeManager.activeChallenges.filter { $0.category == .weekly }
        case .monthly:
            return challengeManager.activeChallenges.filter { $0.category == .monthly }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Overview
                    statsOverview
                    
                    // Filter Tabs
                    filterTabs
                    
                    // Active Challenges
                    if filteredChallenges.isEmpty {
                        EmptyStateView(
                            icon: "flag.slash",
                            title: "No Challenges Found",
                            description: selectedFilter == .participating ?
                                "Join a challenge to start competing!" :
                                "Check back later for new challenges"
                        )
                        .padding(.top, 50)
                    } else {
                        ForEach(filteredChallenges) { challenge in
                            ChallengeCardView(
                                challenge: challenge,
                                isParticipating: challengeManager.isUserParticipating(in: challenge),
                                userProgress: challengeManager.getUserProgress(for: challenge)
                            ) {
                                showingChallengeDetail = challenge
                            }
                        }
                    }
                    
                    // Completed Challenges Section
                    if !challengeManager.completedChallenges.isEmpty {
                        completedChallengesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Community Challenges")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateChallenge = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                    }
                }
            }
            .mindLabsBackground()
            .sheet(item: $showingChallengeDetail) { challenge in
                ChallengeDetailView(challenge: challenge)
                    .environmentObject(gameManager)
            }
            .sheet(isPresented: $showingCreateChallenge) {
                CreateChallengeView()
                    .environmentObject(gameManager)
            }
            .alert("Challenge Complete! 🎉", isPresented: $challengeManager.showChallengeComplete) {
                Button("Awesome!") {
                    challengeManager.showChallengeComplete = false
                }
            } message: {
                if let challenge = challengeManager.completedChallenge {
                    Text("You've completed \(challenge.title) and earned \(challenge.reward.xp) XP!")
                }
            }
        }
    }
    
    // MARK: - Stats Overview
    var statsOverview: some View {
        HStack(spacing: 15) {
            ChallengeStatCard(
                value: "\(challengeManager.activeChallenges.filter { challengeManager.isUserParticipating(in: $0) }.count)",
                label: "Active",
                icon: "flag.fill",
                color: .green
            )
            
            ChallengeStatCard(
                value: "\(challengeManager.completedChallenges.count)",
                label: "Completed",
                icon: "checkmark.circle.fill",
                color: .blue
            )
            
            ChallengeStatCard(
                value: calculateTotalXPEarned(),
                label: "XP Earned",
                icon: "star.fill",
                color: .orange
            )
        }
    }
    
    // MARK: - Filter Tabs
    var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ChallengeFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
        }
    }
    
    // MARK: - Completed Challenges
    var completedChallengesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Completed Challenges", systemImage: "trophy.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            ForEach(challengeManager.completedChallenges.prefix(3)) { challenge in
                CompletedChallengeRow(challenge: challenge)
            }
            
            if challengeManager.completedChallenges.count > 3 {
                Button(action: {}) {
                    Text("View All (\(challengeManager.completedChallenges.count))")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsPurple)
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Methods
    private func calculateTotalXPEarned() -> String {
        let totalXP = challengeManager.completedChallenges.reduce(0) { $0 + $1.reward.xp }
        return "\(totalXP)"
    }
}

// MARK: - Challenge Card View
struct ChallengeCardView: View {
    let challenge: CommunityChallenge
    let isParticipating: Bool
    let userProgress: UserChallengeProgress?
    let onTap: () -> Void
    
    var progressPercentage: Double {
        guard let progress = userProgress else { return 0 }
        return Double(progress.currentProgress) / Double(challenge.goal)
    }
    
    var body: some View {
        Button(action: onTap) {
            MindLabsCard {
                VStack(spacing: 15) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(challenge.category.rawValue)
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(challenge.category.color)
                                    .cornerRadius(12)
                                
                                Text(challenge.difficulty.rawValue)
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(challenge.difficulty.color)
                                    .cornerRadius(12)
                                
                                if isParticipating {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Text(challenge.title)
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(challenge.timeRemaining)
                                .font(MindLabsTypography.caption())
                                .foregroundColor(challenge.timeRemaining == "Ended" ? .red : .mindLabsTextSecondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption2)
                                Text("\(challenge.participants.count)")
                                    .font(MindLabsTypography.caption2())
                            }
                            .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                    
                    // Description
                    Text(challenge.description)
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Progress (if participating)
                    if isParticipating, let progress = userProgress {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Your Progress")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                                
                                Spacer()
                                
                                Text("\(progress.currentProgress)/\(challenge.goal) \(challenge.unit)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsPurple)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.mindLabsPurple.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.mindLabsPurple)
                                        .frame(width: geometry.size.width * min(progressPercentage, 1.0), height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                    
                    // Reward
                    HStack {
                        Label("\(challenge.reward.xp) XP", systemImage: "star.fill")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.orange)
                        
                        if let badge = challenge.reward.badge {
                            Label(badge, systemImage: "rosette")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.purple)
                        }
                        
                        Spacer()
                        
                        if !isParticipating {
                            Text("Tap to join")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsPurple)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct ChallengeStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(MindLabsTypography.largeTitle())
                    .foregroundColor(.mindLabsText)
                
                Text(label)
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(MindLabsTypography.caption())
            }
            .foregroundColor(isSelected ? .white : .mindLabsTextSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.mindLabsPurple : Color.mindLabsPurple.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct CompletedChallengeRow: View {
    let challenge: CommunityChallenge
    
    var body: some View {
        MindLabsCard {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(challenge.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Text("Earned \(challenge.reward.xp) XP")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                if let badge = challenge.reward.badge {
                    Image(systemName: "rosette")
                        .foregroundColor(.purple)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 60))
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
        .padding(40)
    }
}

struct CommunityChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityChallengesView()
            .environmentObject(GameManager())
    }
}