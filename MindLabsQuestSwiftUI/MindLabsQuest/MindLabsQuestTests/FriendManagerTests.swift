import XCTest
@testable import MindLabsQuest

class FriendManagerTests: XCTestCase {
    var friendManager: FriendManager!
    
    override func setUp() {
        super.setUp()
        friendManager = FriendManager()
        // Clear any existing data
        friendManager.resetAll()
    }
    
    override func tearDown() {
        friendManager.resetAll()
        friendManager = nil
        super.tearDown()
    }
    
    // MARK: - Friend Management Tests
    
    func testAddFriend() {
        // Given
        let friend = Friend(
            username: "testuser",
            displayName: "Test User",
            avatar: "🧪",
            level: 10,
            currentStreak: 5,
            totalQuestsCompleted: 50,
            characterClass: .scholar,
            status: .online
        )
        
        // When
        friendManager.addFriend(friend)
        
        // Then
        XCTAssertEqual(friendManager.friends.count, 1)
        XCTAssertEqual(friendManager.friends.first?.username, "testuser")
        XCTAssertTrue(friendManager.recentActivities.count > 0)
    }
    
    func testRemoveFriend() {
        // Given
        let friend = Friend(
            username: "testuser",
            displayName: "Test User",
            avatar: "🧪",
            level: 10,
            currentStreak: 5,
            totalQuestsCompleted: 50
        )
        friendManager.addFriend(friend)
        
        // When
        friendManager.removeFriend(friend)
        
        // Then
        XCTAssertEqual(friendManager.friends.count, 0)
    }
    
    func testUpdateFriendStatus() {
        // Given
        let friend = Friend(
            username: "testuser",
            displayName: "Test User",
            avatar: "🧪",
            level: 10,
            currentStreak: 5,
            totalQuestsCompleted: 50,
            status: .offline
        )
        friendManager.addFriend(friend)
        
        // When
        friendManager.updateFriendStatus(friend.id, status: .online)
        
        // Then
        XCTAssertEqual(friendManager.friends.first?.status, .online)
    }
    
    // MARK: - Friend Request Tests
    
    func testSendFriendRequest() {
        // Given
        let initialRequestCount = friendManager.friendRequests.count
        
        // When
        friendManager.sendFriendRequest(to: "newuser", message: "Let's be friends!")
        
        // Then
        XCTAssertEqual(friendManager.friendRequests.count, initialRequestCount + 1)
        XCTAssertEqual(friendManager.friendRequests.last?.toUserId, "current_user")
    }
    
    func testAcceptFriendRequest() {
        // Given
        friendManager.sendFriendRequest(to: "newuser", message: "Let's be friends!")
        let request = friendManager.friendRequests.first!
        let initialFriendCount = friendManager.friends.count
        
        // When
        friendManager.acceptFriendRequest(request)
        
        // Then
        XCTAssertEqual(friendManager.friends.count, initialFriendCount + 1)
        XCTAssertEqual(friendManager.friendRequests.count, 0)
    }
    
    func testDeclineFriendRequest() {
        // Given
        friendManager.sendFriendRequest(to: "newuser", message: "Let's be friends!")
        let request = friendManager.friendRequests.first!
        
        // When
        friendManager.declineFriendRequest(request)
        
        // Then
        XCTAssertEqual(friendManager.friendRequests.count, 0)
        XCTAssertEqual(friendManager.friends.count, 0)
    }
    
    // MARK: - Activity Tests
    
    func testAddActivity() {
        // Given
        let activity = SharedActivity(
            friendId: UUID(),
            activityType: .questCompleted,
            title: "Test completed a quest",
            description: "Completed 'Study for exam'"
        )
        
        // When
        friendManager.addActivity(activity)
        
        // Then
        XCTAssertEqual(friendManager.recentActivities.first?.title, "Test completed a quest")
        XCTAssertTrue(friendManager.showNewActivityBadge)
    }
    
    func testActivityLimit() {
        // Given
        // Add 55 activities (more than the 50 limit)
        for i in 1...55 {
            let activity = SharedActivity(
                friendId: UUID(),
                activityType: .questCompleted,
                title: "Activity \(i)",
                description: "Description \(i)"
            )
            friendManager.addActivity(activity)
        }
        
        // Then
        XCTAssertEqual(friendManager.recentActivities.count, 50)
        XCTAssertEqual(friendManager.recentActivities.first?.title, "Activity 55")
    }
    
    // MARK: - Friend Stats Tests
    
    func testGetOnlineFriends() {
        // Given
        let onlineFriend = Friend(
            username: "online",
            displayName: "Online User",
            avatar: "🟢",
            level: 10,
            currentStreak: 5,
            totalQuestsCompleted: 50,
            status: .online
        )
        let offlineFriend = Friend(
            username: "offline",
            displayName: "Offline User",
            avatar: "⚫",
            level: 10,
            currentStreak: 5,
            totalQuestsCompleted: 50,
            status: .offline
        )
        
        friendManager.addFriend(onlineFriend)
        friendManager.addFriend(offlineFriend)
        
        // When
        let onlineFriends = friendManager.getOnlineFriends()
        
        // Then
        XCTAssertEqual(onlineFriends.count, 1)
        XCTAssertEqual(onlineFriends.first?.username, "online")
    }
    
    func testGetFriendsInQuest() {
        // Given
        let questFriend = Friend(
            username: "questing",
            displayName: "Questing User",
            avatar: "🎯",
            level: 10,
            currentStreak: 5,
            totalQuestsCompleted: 50,
            status: .inQuest
        )
        let idleFriend = Friend(
            username: "idle",
            displayName: "Idle User",
            avatar: "😴",
            level: 10,
            currentStreak: 5,
            totalQuestsCompleted: 50,
            status: .online
        )
        
        friendManager.addFriend(questFriend)
        friendManager.addFriend(idleFriend)
        
        // When
        let questingFriends = friendManager.getFriendsInQuest()
        
        // Then
        XCTAssertEqual(questingFriends.count, 1)
        XCTAssertEqual(questingFriends.first?.username, "questing")
    }
    
    func testGetTopFriendsByLevel() {
        // Given
        let highLevelFriend = Friend(
            username: "highlevel",
            displayName: "High Level",
            avatar: "🏆",
            level: 30,
            currentStreak: 5,
            totalQuestsCompleted: 50
        )
        let lowLevelFriend = Friend(
            username: "lowlevel",
            displayName: "Low Level",
            avatar: "🌱",
            level: 5,
            currentStreak: 5,
            totalQuestsCompleted: 50
        )
        
        friendManager.addFriend(lowLevelFriend)
        friendManager.addFriend(highLevelFriend)
        
        // When
        let topFriends = friendManager.getTopFriendsByLevel()
        
        // Then
        XCTAssertEqual(topFriends.first?.username, "highlevel")
        XCTAssertEqual(topFriends.last?.username, "lowlevel")
    }
    
    func testGetTopFriendsByStreak() {
        // Given
        let highStreakFriend = Friend(
            username: "highstreak",
            displayName: "High Streak",
            avatar: "🔥",
            level: 10,
            currentStreak: 30,
            totalQuestsCompleted: 50
        )
        let lowStreakFriend = Friend(
            username: "lowstreak",
            displayName: "Low Streak",
            avatar: "❄️",
            level: 10,
            currentStreak: 2,
            totalQuestsCompleted: 50
        )
        
        friendManager.addFriend(lowStreakFriend)
        friendManager.addFriend(highStreakFriend)
        
        // When
        let topFriends = friendManager.getTopFriendsByStreak()
        
        // Then
        XCTAssertEqual(topFriends.first?.username, "highstreak")
        XCTAssertEqual(topFriends.last?.username, "lowstreak")
    }
    
    // MARK: - Persistence Tests
    
    func testDataPersistence() {
        // Given
        let friend = Friend(
            username: "persistent",
            displayName: "Persistent User",
            avatar: "💾",
            level: 15,
            currentStreak: 10,
            totalQuestsCompleted: 100
        )
        friendManager.addFriend(friend)
        
        // When
        // Create a new instance to test loading
        let newFriendManager = FriendManager()
        
        // Then
        XCTAssertEqual(newFriendManager.friends.count, 1)
        XCTAssertEqual(newFriendManager.friends.first?.username, "persistent")
        
        // Cleanup
        newFriendManager.resetAll()
    }
}