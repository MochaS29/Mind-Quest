import SwiftUI

struct FriendProfileView: View {
    let friend: Friend
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var friendManager = FriendManager.shared
    @State private var showingRemoveFriendAlert = false
    @State private var showingChallengeOptions = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Stats Overview
                    statsOverview
                    
                    // Action Buttons
                    actionButtons
                    
                    // Recent Activity
                    recentActivity
                    
                    // Shared Achievements
                    sharedAchievements
                    
                    // Quest Comparison
                    questComparison
                }
                .padding()
            }
            .navigationTitle(friend.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Menu {
                    Button(action: { showingChallengeOptions = true }) {
                        Label("Challenge Friend", systemImage: "flag.fill")
                    }
                    
                    Button(action: { /* Send message */ }) {
                        Label("Send Message", systemImage: "message.fill")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showingRemoveFriendAlert = true }) {
                        Label("Remove Friend", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.mindLabsPurple)
                }
            )
            .mindLabsBackground()
            .alert("Remove Friend?", isPresented: $showingRemoveFriendAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Remove", role: .destructive) {
                    friendManager.removeFriend(friend)
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Are you sure you want to remove \(friend.displayName) from your friends?")
            }
            .sheet(isPresented: $showingChallengeOptions) {
                ChallengeCreationView(friend: friend)
            }
        }
    }
    
    // MARK: - Profile Header
    var profileHeader: some View {
        MindLabsCard {
            VStack(spacing: 15) {
                // Avatar
                Text(friend.avatar)
                    .font(.system(size: 80))
                    .frame(width: 100, height: 100)
                    .background(Color.mindLabsPurple.opacity(0.1))
                    .clipShape(Circle())
                
                // Name and Status
                VStack(spacing: 8) {
                    Text(friend.displayName)
                        .font(MindLabsTypography.largeTitle())
                        .foregroundColor(.mindLabsText)
                    
                    Text("@\(friend.username)")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    HStack {
                        Image(systemName: friend.status.icon)
                            .font(.caption)
                        Text(friend.status.rawValue)
                            .font(MindLabsTypography.caption())
                    }
                    .foregroundColor(friend.status.color)
                }
                
                // Character Info
                if let characterClass = friend.characterClass {
                    HStack(spacing: 20) {
                        Label("Level \(friend.level)", systemImage: "arrow.up.circle")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsPurple)
                        
                        Text("•")
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        Text(characterClass.rawValue)
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Overview
    var statsOverview: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                FriendStatCard(
                    title: "Current Streak",
                    value: "\(friend.currentStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                FriendStatCard(
                    title: "Total Quests",
                    value: "\(friend.totalQuestsCompleted)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 15) {
                FriendStatCard(
                    title: "Joined",
                    value: friend.addedDate.formatted(date: .abbreviated, time: .omitted),
                    icon: "calendar",
                    color: .blue
                )
                
                FriendStatCard(
                    title: "Last Active",
                    value: friend.lastActive.timeAgoDisplay(),
                    icon: "clock.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Action Buttons
    var actionButtons: some View {
        HStack(spacing: 15) {
            Button(action: { showingChallengeOptions = true }) {
                HStack {
                    Image(systemName: "flag.fill")
                    Text("Challenge")
                }
                .font(MindLabsTypography.subheadline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.mindLabsPurple)
                .cornerRadius(10)
            }
            
            Button(action: { /* Send message */ }) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("Message")
                }
                .font(MindLabsTypography.subheadline())
                .foregroundColor(.mindLabsPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.mindLabsPurple.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Recent Activity
    var recentActivity: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Recent Activity", systemImage: "clock.arrow.circlepath")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            VStack(spacing: 10) {
                let friendActivities = friendManager.recentActivities
                    .filter { $0.friendId == friend.id }
                    .prefix(3)
                
                if friendActivities.isEmpty {
                    MindLabsCard {
                        Text("No recent activity")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                } else {
                    ForEach(Array(friendActivities), id: \.id) { activity in
                        MiniActivityCard(activity: activity)
                    }
                }
            }
        }
    }
    
    // MARK: - Shared Achievements
    var sharedAchievements: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Shared Achievements", systemImage: "star.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Demo shared achievements
                    SharedAchievementCard(
                        title: "Quest Buddies",
                        description: "Complete 10 quests on the same day",
                        progress: 0.7,
                        icon: "person.2.fill"
                    )
                    
                    SharedAchievementCard(
                        title: "Streak Warriors",
                        description: "Both maintain 7-day streaks",
                        progress: 1.0,
                        icon: "flame.fill"
                    )
                    
                    SharedAchievementCard(
                        title: "Challenge Champions",
                        description: "Complete 5 challenges together",
                        progress: 0.4,
                        icon: "flag.fill"
                    )
                }
            }
        }
    }
    
    // MARK: - Quest Comparison
    var questComparison: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Quest Comparison", systemImage: "chart.bar.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 20) {
                    ComparisonRow(
                        title: "Level",
                        yourValue: gameManager.character.level,
                        friendValue: friend.level
                    )
                    
                    ComparisonRow(
                        title: "Total Quests",
                        yourValue: gameManager.quests.filter { $0.isCompleted }.count,
                        friendValue: friend.totalQuestsCompleted
                    )
                    
                    ComparisonRow(
                        title: "Current Streak",
                        yourValue: gameManager.character.streak,
                        friendValue: friend.currentStreak
                    )
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct FriendStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Text(title)
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
        }
    }
}

struct MiniActivityCard: View {
    let activity: SharedActivity
    
    var body: some View {
        MindLabsCard {
            HStack(spacing: 12) {
                Image(systemName: activity.activityType.icon)
                    .font(.title3)
                    .foregroundColor(activity.activityType.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.title)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsText)
                    
                    Text(activity.timestamp.timeAgoDisplay())
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 5)
        }
    }
}

struct SharedAchievementCard: View {
    let title: String
    let description: String
    let progress: Double
    let icon: String
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 10) {
                // Icon with progress ring
                ZStack {
                    Circle()
                        .stroke(Color.mindLabsPurple.opacity(0.2), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.mindLabsPurple, lineWidth: 4)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.mindLabsPurple)
                }
                
                Text(title)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsText)
                    .multilineTextAlignment(.center)
                
                Text("\(Int(progress * 100))%")
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .frame(width: 120)
            .padding(.vertical, 10)
        }
    }
}

struct ComparisonRow: View {
    let title: String
    let yourValue: Int
    let friendValue: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Your value
            VStack(spacing: 4) {
                Text("\(yourValue)")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(yourValue >= friendValue ? .mindLabsPurple : .mindLabsText)
                Text("You")
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .frame(width: 60)
            
            Text("vs")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
            
            // Friend value
            VStack(spacing: 4) {
                Text("\(friendValue)")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(friendValue > yourValue ? .mindLabsPurple : .mindLabsText)
                Text("Friend")
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .frame(width: 60)
        }
    }
}

// MARK: - Challenge Creation View
struct ChallengeCreationView: View {
    let friend: Friend
    @Environment(\.presentationMode) var presentationMode
    @State private var challengeType: ChallengeType = .questCount
    @State private var duration: ChallengeDuration = .day
    @State private var targetValue = 5
    @State private var message = ""
    
    enum ChallengeType: String, CaseIterable {
        case questCount = "Quest Count"
        case focusTime = "Focus Time"
        case streakDays = "Streak Days"
        case levelGain = "Level Gain"
        
        var icon: String {
            switch self {
            case .questCount: return "checkmark.circle"
            case .focusTime: return "timer"
            case .streakDays: return "flame"
            case .levelGain: return "arrow.up.circle"
            }
        }
    }
    
    enum ChallengeDuration: String, CaseIterable {
        case day = "1 Day"
        case week = "1 Week"
        case month = "1 Month"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Challenge Type")) {
                    Picker("Type", selection: $challengeType) {
                        ForEach(ChallengeType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Duration")) {
                    Picker("Duration", selection: $duration) {
                        ForEach(ChallengeDuration.allCases, id: \.self) { duration in
                            Text(duration.rawValue).tag(duration)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Target")) {
                    HStack {
                        Text(challengeDescription)
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        Spacer()
                        
                        Stepper("\(targetValue)", value: $targetValue, in: 1...50)
                    }
                }
                
                Section(header: Text("Message (Optional)")) {
                    TextEditor(text: $message)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Challenge \(friend.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Send") {
                    sendChallenge()
                }
            )
        }
    }
    
    var challengeDescription: String {
        switch challengeType {
        case .questCount: return "Complete \(targetValue) quests"
        case .focusTime: return "Focus for \(targetValue) hours"
        case .streakDays: return "Maintain \(targetValue) day streak"
        case .levelGain: return "Gain \(targetValue) levels"
        }
    }
    
    private func sendChallenge() {
        // Send challenge logic
        presentationMode.wrappedValue.dismiss()
    }
}

struct FriendProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FriendProfileView(friend: Friend(
            username: "questmaster",
            displayName: "Quest Master",
            avatar: "🧙‍♂️",
            level: 25,
            currentStreak: 15,
            totalQuestsCompleted: 342,
            characterClass: .scholar,
            status: .online
        ))
        .environmentObject(GameManager())
    }
}