import SwiftUI

struct SocialHubView: View {
    @EnvironmentObject var gameManager: GameManager
    @StateObject private var friendManager = FriendManager.shared
    @State private var selectedTab: SocialTab = .friends
    @State private var showingAddFriend = false
    @State private var showingFriendProfile: Friend?
    
    enum SocialTab: String, CaseIterable {
        case friends = "Friends"
        case activity = "Activity"
        case challenges = "Challenges"
        case leaderboard = "Leaderboard"
        
        var icon: String {
            switch self {
            case .friends: return "person.2.fill"
            case .activity: return "bell.fill"
            case .challenges: return "flag.fill"
            case .leaderboard: return "chart.bar.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(SocialTab.allCases, id: \.self) { tab in
                            TabButton(
                                title: tab.rawValue,
                                icon: tab.icon,
                                isSelected: selectedTab == tab,
                                badge: tab == .activity && friendManager.showNewActivityBadge ? 5 : nil
                            ) {
                                selectedTab = tab
                                if tab == .activity {
                                    friendManager.markActivitiesAsRead()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(Color.mindLabsCard)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .friends:
                            friendsContent
                        case .activity:
                            activityContent
                        case .challenges:
                            challengesContent
                        case .leaderboard:
                            leaderboardContent
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Social Hub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == .friends {
                        Button(action: { showingAddFriend = true }) {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.mindLabsPurple)
                        }
                    }
                }
            }
            .mindLabsBackground()
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView()
            }
            .sheet(item: $showingFriendProfile) { friend in
                FriendProfileView(friend: friend)
                    .environmentObject(gameManager)
            }
        }
    }
    
    // MARK: - Friends Content
    var friendsContent: some View {
        VStack(spacing: 20) {
            // Friend Requests
            if !friendManager.friendRequests.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    Label("Friend Requests", systemImage: "envelope.fill")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    ForEach(friendManager.friendRequests) { request in
                        FriendRequestCard(request: request) {
                            friendManager.acceptFriendRequest(request)
                        } onDecline: {
                            friendManager.declineFriendRequest(request)
                        }
                    }
                }
            }
            
            // Online Friends
            if !friendManager.getOnlineFriends().isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    Label("Online Now", systemImage: "circle.fill")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    ForEach(friendManager.getOnlineFriends()) { friend in
                        FriendCard(friend: friend) {
                            showingFriendProfile = friend
                        }
                    }
                }
            }
            
            // All Friends
            VStack(alignment: .leading, spacing: 15) {
                Label("All Friends", systemImage: "person.2.fill")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                if friendManager.friends.isEmpty {
                    EmptyStateCard(
                        icon: "person.2.slash",
                        title: "No Friends Yet",
                        description: "Add friends to share your journey and compete together!"
                    )
                } else {
                    ForEach(friendManager.friends.sorted { $0.displayName < $1.displayName }) { friend in
                        FriendCard(friend: friend) {
                            showingFriendProfile = friend
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Activity Content
    var activityContent: some View {
        VStack(spacing: 20) {
            if friendManager.recentActivities.isEmpty {
                EmptyStateCard(
                    icon: "bell.slash",
                    title: "No Recent Activity",
                    description: "Activities from your friends will appear here"
                )
            } else {
                ForEach(friendManager.recentActivities) { activity in
                    if let friend = friendManager.friends.first(where: { $0.id == activity.friendId }) {
                        ActivityCard(activity: activity, friend: friend)
                    }
                }
            }
        }
    }
    
    // MARK: - Challenges Content
    var challengesContent: some View {
        VStack(spacing: 20) {
            // Weekly Challenge
            ChallengeCard(
                title: "Weekly Focus Challenge",
                description: "Complete 20 quests this week",
                progress: 0.65,
                participants: 42,
                daysLeft: 3,
                reward: "500 XP + Special Badge"
            )
            
            // Daily Challenge
            ChallengeCard(
                title: "Daily Productivity Sprint",
                description: "Complete 5 quests today",
                progress: 0.4,
                participants: 128,
                daysLeft: 0,
                reward: "100 XP"
            )
            
            // Friend Challenge
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Label("Challenge a Friend", systemImage: "person.2.fill")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        Spacer()
                        Button("Create") {
                            // Create challenge
                        }
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsPurple)
                    }
                    
                    Text("Create custom challenges with your friends")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
        }
    }
    
    // MARK: - Leaderboard Content
    var leaderboardContent: some View {
        VStack(spacing: 20) {
            // Leaderboard Type Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    LeaderboardTypeButton(title: "Level", icon: "arrow.up.circle", isSelected: true)
                    LeaderboardTypeButton(title: "Streak", icon: "flame", isSelected: false)
                    LeaderboardTypeButton(title: "Quests", icon: "checkmark.circle", isSelected: false)
                    LeaderboardTypeButton(title: "This Week", icon: "calendar", isSelected: false)
                }
            }
            
            // Your Rank
            MindLabsCard {
                HStack {
                    Text("#12")
                        .font(MindLabsTypography.largeTitle())
                        .foregroundColor(.mindLabsPurple)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Rank")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        Text("Level \(gameManager.character.level)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                    
                    Text("\(gameManager.character.xp) XP")
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsPurple)
                }
            }
            
            // Top Players
            VStack(spacing: 15) {
                ForEach(Array(friendManager.getTopFriendsByLevel().prefix(10).enumerated()), id: \.element.id) { index, friend in
                    LeaderboardRow(
                        rank: index + 1,
                        friend: friend,
                        value: "\(friend.level)",
                        subtitle: "\(friend.totalQuestsCompleted) quests"
                    )
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let badge: Int?
    let action: () -> Void
    
    init(title: String, icon: String, isSelected: Bool, badge: Int? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.badge = badge
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(MindLabsTypography.subheadline())
                
                if let badge = badge {
                    Text("\(badge)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(isSelected ? .white : .mindLabsTextSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.mindLabsPurple : Color.clear
            )
            .cornerRadius(20)
        }
    }
}

struct FriendCard: View {
    let friend: Friend
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            MindLabsCard {
                HStack(spacing: 15) {
                    // Avatar
                    Text(friend.avatar)
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(Color.mindLabsPurple.opacity(0.1))
                        .clipShape(Circle())
                    
                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(friend.displayName)
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            // Status indicator
                            Image(systemName: friend.status.icon)
                                .font(.caption)
                                .foregroundColor(friend.status.color)
                        }
                        
                        HStack(spacing: 12) {
                            Label("Lvl \(friend.level)", systemImage: "arrow.up.circle")
                            Label("\(friend.currentStreak)🔥", systemImage: "flame")
                        }
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        
                        Text(friend.status.rawValue)
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(friend.status.color)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
        }
    }
}

struct FriendRequestCard: View {
    let request: FriendRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 15) {
                    Text(request.fromUser.avatar)
                        .font(.system(size: 40))
                        .frame(width: 50, height: 50)
                        .background(Color.mindLabsPurple.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.fromUser.displayName)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Text("Level \(request.fromUser.level)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                }
                
                if !request.message.isEmpty {
                    Text(request.message)
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                HStack(spacing: 15) {
                    Button(action: onDecline) {
                        Text("Decline")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsError)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.mindLabsError.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: onAccept) {
                        Text("Accept")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.mindLabsPurple)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}

struct ActivityCard: View {
    let activity: SharedActivity
    let friend: Friend
    
    var body: some View {
        MindLabsCard {
            HStack(spacing: 15) {
                // Activity Icon
                Image(systemName: activity.activityType.icon)
                    .font(.title2)
                    .foregroundColor(activity.activityType.color)
                    .frame(width: 40, height: 40)
                    .background(activity.activityType.color.opacity(0.1))
                    .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Text(activity.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Text(activity.timestamp.timeAgoDisplay())
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
            }
        }
    }
}

struct ChallengeCard: View {
    let title: String
    let description: String
    let progress: Double
    let participants: Int
    let daysLeft: Int
    let reward: String
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Text(description)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                    
                    if daysLeft == 0 {
                        Text("Ends Today")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsError)
                    } else {
                        Text("\(daysLeft) days left")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.mindLabsPurple.opacity(0.2))
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.mindLabsPurple)
                            .frame(width: geometry.size.width * progress, height: 10)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Label("\(participants) participants", systemImage: "person.2")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Spacer()
                    
                    Label(reward, systemImage: "gift")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsPurple)
                }
            }
        }
    }
}

struct LeaderboardTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
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

struct LeaderboardRow: View {
    let rank: Int
    let friend: Friend
    let value: String
    let subtitle: String
    
    var body: some View {
        MindLabsCard {
            HStack(spacing: 15) {
                // Rank
                Text("#\(rank)")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(rank <= 3 ? .mindLabsPurple : .mindLabsTextSecondary)
                    .frame(width: 40)
                
                // Avatar
                Text(friend.avatar)
                    .font(.title2)
                
                // Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.displayName)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    Text(subtitle)
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                // Value
                Text(value)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsPurple)
            }
        }
    }
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        MindLabsCard {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 50))
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
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Date Extension
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

struct SocialHubView_Previews: PreviewProvider {
    static var previews: some View {
        SocialHubView()
            .environmentObject(GameManager())
    }
}