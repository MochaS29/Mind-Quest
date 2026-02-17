import Foundation
import SwiftUI

// MARK: - Friend Model
struct Friend: Codable, Identifiable {
    var id = UUID()
    var username: String
    var displayName: String
    var avatar: String
    var level: Int
    var currentStreak: Int
    var totalQuestsCompleted: Int
    var characterClass: CharacterClass?
    var status: FriendStatus = .offline
    var lastActive: Date = Date()
    var addedDate: Date = Date()
    
    enum FriendStatus: String, Codable {
        case online = "Online"
        case inQuest = "In Quest"
        case inFocus = "Focus Mode"
        case offline = "Offline"
        
        var color: Color {
            switch self {
            case .online: return .green
            case .inQuest: return .orange
            case .inFocus: return .purple
            case .offline: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .online: return "circle.fill"
            case .inQuest: return "target"
            case .inFocus: return "moon.fill"
            case .offline: return "circle"
            }
        }
    }
}

// MARK: - Friend Request Model
struct FriendRequest: Codable, Identifiable {
    var id = UUID()
    var fromUser: Friend
    var toUserId: String
    var message: String
    var sentDate: Date = Date()
    var status: RequestStatus = .pending
    
    enum RequestStatus: String, Codable {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
    }
}

// MARK: - Shared Activity Model
struct SharedActivity: Codable, Identifiable {
    var id = UUID()
    var friendId: UUID
    var activityType: ActivityType
    var title: String
    var description: String
    var timestamp: Date = Date()
    
    enum ActivityType: String, Codable {
        case questCompleted = "Quest Completed"
        case levelUp = "Level Up"
        case achievementUnlocked = "Achievement Unlocked"
        case streakMilestone = "Streak Milestone"
        case challengeCompleted = "Challenge Completed"
        
        var icon: String {
            switch self {
            case .questCompleted: return "checkmark.circle.fill"
            case .levelUp: return "arrow.up.circle.fill"
            case .achievementUnlocked: return "star.fill"
            case .streakMilestone: return "flame.fill"
            case .challengeCompleted: return "trophy.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .questCompleted: return .green
            case .levelUp: return .purple
            case .achievementUnlocked: return .yellow
            case .streakMilestone: return .orange
            case .challengeCompleted: return .blue
            }
        }
    }
}

// MARK: - Friend Manager
class FriendManager: ObservableObject {
    static let shared = FriendManager()
    
    @Published var friends: [Friend] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var recentActivities: [SharedActivity] = []
    @Published var showNewActivityBadge = false
    
    private let friendsKey = "mindlabs_friends"
    private let requestsKey = "mindlabs_friend_requests"
    private let activitiesKey = "mindlabs_friend_activities"
    
    init() {
        loadData()
        setupMockData() // For demo purposes
    }
    
    // MARK: - Friend Management
    func addFriend(_ friend: Friend) {
        friends.append(friend)
        saveData()
        
        // Add activity
        let activity = SharedActivity(
            friendId: friend.id,
            activityType: .questCompleted,
            title: "\(friend.displayName) is now your friend!",
            description: "Start your adventure together"
        )
        addActivity(activity)
    }
    
    func removeFriend(_ friend: Friend) {
        friends.removeAll { $0.id == friend.id }
        saveData()
    }
    
    func updateFriendStatus(_ friendId: UUID, status: Friend.FriendStatus) {
        if let index = friends.firstIndex(where: { $0.id == friendId }) {
            friends[index].status = status
            friends[index].lastActive = Date()
            saveData()
        }
    }
    
    // MARK: - Friend Requests
    func sendFriendRequest(to username: String, message: String) {
        // In a real app, this would send to a server
        // For demo, we'll just show it locally
        let demoFriend = Friend(
            username: username,
            displayName: username.capitalized,
            avatar: ["🧙‍♂️", "🦸‍♀️", "🧚‍♀️", "🏴‍☠️", "🤖"].randomElement()!,
            level: Int.random(in: 1...20),
            currentStreak: Int.random(in: 0...30),
            totalQuestsCompleted: Int.random(in: 10...200)
        )
        
        let request = FriendRequest(
            fromUser: demoFriend,
            toUserId: "current_user",
            message: message
        )
        
        friendRequests.append(request)
        saveData()
    }
    
    func acceptFriendRequest(_ request: FriendRequest) {
        if let index = friendRequests.firstIndex(where: { $0.id == request.id }) {
            friendRequests[index].status = .accepted
            addFriend(request.fromUser)
            friendRequests.remove(at: index)
            saveData()
        }
    }
    
    func declineFriendRequest(_ request: FriendRequest) {
        friendRequests.removeAll { $0.id == request.id }
        saveData()
    }
    
    // MARK: - Activities
    func addActivity(_ activity: SharedActivity) {
        recentActivities.insert(activity, at: 0)
        
        // Keep only last 50 activities
        if recentActivities.count > 50 {
            recentActivities = Array(recentActivities.prefix(50))
        }
        
        showNewActivityBadge = true
        saveData()
    }
    
    func markActivitiesAsRead() {
        showNewActivityBadge = false
    }
    
    // MARK: - Friend Stats
    func getOnlineFriends() -> [Friend] {
        friends.filter { $0.status != .offline }
    }
    
    func getFriendsInQuest() -> [Friend] {
        friends.filter { $0.status == .inQuest }
    }
    
    func getTopFriendsByLevel() -> [Friend] {
        friends.sorted { $0.level > $1.level }
    }
    
    func getTopFriendsByStreak() -> [Friend] {
        friends.sorted { $0.currentStreak > $1.currentStreak }
    }
    
    // MARK: - Mock Data
    private func setupMockData() {
        if friends.isEmpty {
            // Add some demo friends
            let demoFriends = [
                Friend(
                    username: "questmaster",
                    displayName: "Quest Master",
                    avatar: "🧙‍♂️",
                    level: 25,
                    currentStreak: 15,
                    totalQuestsCompleted: 342,
                    characterClass: .scholar,
                    status: .online
                ),
                Friend(
                    username: "focusninja",
                    displayName: "Focus Ninja",
                    avatar: "🥷",
                    level: 18,
                    currentStreak: 7,
                    totalQuestsCompleted: 256,
                    characterClass: .ranger,
                    status: .inFocus
                ),
                Friend(
                    username: "productivityhero",
                    displayName: "Productivity Hero",
                    avatar: "🦸‍♀️",
                    level: 22,
                    currentStreak: 23,
                    totalQuestsCompleted: 489,
                    characterClass: .warrior,
                    status: .inQuest
                )
            ]
            
            friends = demoFriends
            
            // Add some demo activities
            let activities = [
                SharedActivity(
                    friendId: demoFriends[0].id,
                    activityType: .levelUp,
                    title: "Quest Master reached level 25!",
                    description: "Your friend is making great progress"
                ),
                SharedActivity(
                    friendId: demoFriends[1].id,
                    activityType: .streakMilestone,
                    title: "Focus Ninja achieved a 7-day streak!",
                    description: "Consistency is key to success"
                ),
                SharedActivity(
                    friendId: demoFriends[2].id,
                    activityType: .achievementUnlocked,
                    title: "Productivity Hero unlocked 'Quest Marathon'",
                    description: "Completed 10 quests in one day"
                )
            ]
            
            recentActivities = activities
            saveData()
        }
    }
    
    // MARK: - Persistence
    private func saveData() {
        // Save friends
        if let encoded = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(encoded, forKey: friendsKey)
        }
        
        // Save requests
        if let encoded = try? JSONEncoder().encode(friendRequests) {
            UserDefaults.standard.set(encoded, forKey: requestsKey)
        }
        
        // Save activities
        if let encoded = try? JSONEncoder().encode(recentActivities) {
            UserDefaults.standard.set(encoded, forKey: activitiesKey)
        }
    }
    
    private func loadData() {
        // Load friends
        if let data = UserDefaults.standard.data(forKey: friendsKey),
           let decoded = try? JSONDecoder().decode([Friend].self, from: data) {
            friends = decoded
        }
        
        // Load requests
        if let data = UserDefaults.standard.data(forKey: requestsKey),
           let decoded = try? JSONDecoder().decode([FriendRequest].self, from: data) {
            friendRequests = decoded
        }
        
        // Load activities
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([SharedActivity].self, from: data) {
            recentActivities = decoded
        }
    }
    
    // MARK: - Reset
    func resetAll() {
        friends = []
        friendRequests = []
        recentActivities = []
        showNewActivityBadge = false
        
        UserDefaults.standard.removeObject(forKey: friendsKey)
        UserDefaults.standard.removeObject(forKey: requestsKey)
        UserDefaults.standard.removeObject(forKey: activitiesKey)
    }
}