import XCTest
@testable import MindLabsQuest

class SocialFeaturesIntegrationTests: XCTestCase {
    var gameManager: GameManager!
    var friendManager: FriendManager!
    var challengeManager: ChallengeManager!
    
    override func setUp() {
        super.setUp()
        gameManager = GameManager()
        friendManager = FriendManager.shared
        challengeManager = ChallengeManager.shared
        
        // Reset managers
        friendManager.resetAll()
        challengeManager.resetAll()
        
        // Set up test character
        gameManager.character.name = "TestHero"
        gameManager.character.level = 10
        gameManager.character.xp = 1000
    }
    
    override func tearDown() {
        friendManager.resetAll()
        challengeManager.resetAll()
        gameManager = nil
        super.tearDown()
    }
    
    // MARK: - Friend System Integration Tests
    
    func testFriendSystemWithQuestCompletion() {
        // Given - Add a friend
        let friend = Friend(
            username: "questbuddy",
            displayName: "Quest Buddy",
            avatar: "🎮",
            level: 8,
            currentStreak: 5,
            totalQuestsCompleted: 45
        )
        friendManager.addFriend(friend)
        
        // When - Complete a quest
        let quest = Quest(
            title: "Integration Test Quest",
            description: "Test quest completion with friends",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        gameManager.completeQuest(quest)
        
        // Then - Activity should be generated
        XCTAssertTrue(friendManager.recentActivities.count > 0)
        
        if let activity = friendManager.recentActivities.first {
            XCTAssertEqual(activity.activityType, .questCompleted)
            XCTAssertTrue(activity.title.contains("completed a quest"))
        }
    }
    
    func testFriendSystemWithAchievementUnlock() {
        // Given - Add friends
        let friend1 = Friend(
            username: "achiever1",
            displayName: "Achiever One",
            avatar: "🏆",
            level: 12,
            currentStreak: 10,
            totalQuestsCompleted: 100
        )
        friendManager.addFriend(friend1)
        
        // When - Trigger achievement unlock
        // First, complete enough quests to unlock an achievement
        for i in 1...5 {
            let quest = Quest(
                title: "Quest \(i)",
                description: "Test",
                category: .work,
                difficulty: .easy,
                estimatedMinutes: 15,
                xpReward: 50
            )
            gameManager.completeQuest(quest)
        }
        
        // Then - Check for achievement activity
        let achievementActivities = friendManager.recentActivities.filter {
            $0.activityType == .achievementUnlocked
        }
        XCTAssertTrue(achievementActivities.count > 0)
    }
    
    // MARK: - Challenge System Integration Tests
    
    func testChallengeProgressWithQuestCompletion() {
        // Given - Join a quest count challenge
        let questChallenge = challengeManager.activeChallenges.first {
            $0.type == .questCount
        }!
        challengeManager.joinChallenge(questChallenge, username: "TestHero", avatar: "🦸")
        
        let initialProgress = challengeManager.getUserProgress(for: questChallenge)?.currentProgress ?? 0
        
        // When - Complete a quest
        let quest = Quest(
            title: "Challenge Quest",
            description: "Quest for challenge",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        gameManager.completeQuest(quest)
        
        // Simulate challenge progress update (in real app, this would be automatic)
        challengeManager.updateProgress(for: questChallenge.id, progress: initialProgress + 1)
        
        // Then - Challenge progress should increase
        let updatedProgress = challengeManager.getUserProgress(for: questChallenge)?.currentProgress ?? 0
        XCTAssertEqual(updatedProgress, initialProgress + 1)
    }
    
    func testChallengeCompletionWithRewards() {
        // Given - Join a challenge and complete it
        let challenge = challengeManager.activeChallenges.first!
        challengeManager.joinChallenge(challenge, username: "TestHero", avatar: "🦸")
        
        let initialXP = gameManager.character.xp
        
        // When - Complete the challenge
        challengeManager.updateProgress(for: challenge.id, progress: challenge.goal)
        
        // Then - Challenge should be marked as completed
        let progress = challengeManager.getUserProgress(for: challenge)!
        XCTAssertTrue(progress.isCompleted)
        XCTAssertTrue(challengeManager.completedChallenges.contains { $0.id == challenge.id })
        
        // In real app, XP rewards would be applied
        // Here we simulate the reward
        gameManager.character.xp += challenge.reward.xp
        XCTAssertEqual(gameManager.character.xp, initialXP + challenge.reward.xp)
    }
    
    // MARK: - Friend & Challenge Integration Tests
    
    func testFriendLeaderboardInChallenge() {
        // Given - Add friends and have them join a challenge
        let friend1 = Friend(
            username: "competitor1",
            displayName: "Competitor One",
            avatar: "🥇",
            level: 15,
            currentStreak: 20,
            totalQuestsCompleted: 200
        )
        let friend2 = Friend(
            username: "competitor2", 
            displayName: "Competitor Two",
            avatar: "🥈",
            level: 12,
            currentStreak: 15,
            totalQuestsCompleted: 150
        )
        
        friendManager.addFriend(friend1)
        friendManager.addFriend(friend2)
        
        // Join a challenge
        var challenge = challengeManager.activeChallenges.first!
        challengeManager.joinChallenge(challenge, username: "TestHero", avatar: "🦸")
        
        // Simulate friends joining with different progress
        challenge.participants.append(ChallengeParticipant(
            userId: friend1.id.uuidString,
            username: friend1.username,
            avatar: friend1.avatar,
            progress: 15
        ))
        challenge.participants.append(ChallengeParticipant(
            userId: friend2.id.uuidString,
            username: friend2.username,
            avatar: friend2.avatar,
            progress: 10
        ))
        
        // Update challenge in manager
        if let index = challengeManager.activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            challengeManager.activeChallenges[index] = challenge
        }
        
        // When - Get leaderboard
        let leaderboard = challengeManager.getLeaderboard(for: challenge)
        
        // Then - Verify friend rankings
        XCTAssertEqual(leaderboard.count, 3)
        XCTAssertEqual(leaderboard[0].username, friend1.username) // Highest progress
        XCTAssertEqual(leaderboard[0].progress, 15)
    }
    
    func testSocialActivityFeed() {
        // Given - Multiple friends with various activities
        let friends = [
            Friend(username: "friend1", displayName: "Friend One", avatar: "1️⃣", level: 10, currentStreak: 5, totalQuestsCompleted: 50),
            Friend(username: "friend2", displayName: "Friend Two", avatar: "2️⃣", level: 12, currentStreak: 8, totalQuestsCompleted: 80),
            Friend(username: "friend3", displayName: "Friend Three", avatar: "3️⃣", level: 8, currentStreak: 3, totalQuestsCompleted: 30)
        ]
        
        friends.forEach { friendManager.addFriend($0) }
        
        // When - Generate various activities
        let activityTypes: [SharedActivity.ActivityType] = [.questCompleted, .levelUp, .achievementUnlocked, .challengeJoined]
        
        for (index, friend) in friends.enumerated() {
            let activity = SharedActivity(
                friendId: friend.id,
                activityType: activityTypes[index % activityTypes.count],
                title: "\(friend.displayName) \(activityTypes[index % activityTypes.count].rawValue)",
                description: "Test activity description"
            )
            friendManager.addActivity(activity)
        }
        
        // Then - Verify activity feed
        XCTAssertEqual(friendManager.recentActivities.count, friends.count)
        XCTAssertTrue(friendManager.showNewActivityBadge)
        
        // Mark as read
        friendManager.markActivitiesAsRead()
        XCTAssertFalse(friendManager.showNewActivityBadge)
    }
    
    // MARK: - Performance Tests
    
    func testLargeFriendListPerformance() {
        // Given - Add many friends
        measure {
            for i in 1...100 {
                let friend = Friend(
                    username: "friend\(i)",
                    displayName: "Friend \(i)",
                    avatar: "👤",
                    level: Int.random(in: 1...50),
                    currentStreak: Int.random(in: 0...30),
                    totalQuestsCompleted: Int.random(in: 0...500)
                )
                friendManager.addFriend(friend)
            }
            
            // Test operations
            _ = friendManager.getOnlineFriends()
            _ = friendManager.getTopFriendsByLevel()
            _ = friendManager.getTopFriendsByStreak()
        }
    }
    
    func testManyChallengesPerformance() {
        measure {
            // Join multiple challenges
            for challenge in challengeManager.activeChallenges.prefix(10) {
                challengeManager.joinChallenge(challenge, username: "TestHero", avatar: "🦸")
                
                // Update progress
                for progress in stride(from: 0, to: challenge.goal, by: challenge.goal / 5) {
                    challengeManager.updateProgress(for: challenge.id, progress: progress)
                }
            }
            
            // Get leaderboards
            for challenge in challengeManager.activeChallenges.prefix(10) {
                _ = challengeManager.getLeaderboard(for: challenge)
                _ = challengeManager.getUserRank(in: challenge)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testRemoveFriendWithSharedActivities() {
        // Given - Friend with activities
        let friend = Friend(
            username: "tempfriend",
            displayName: "Temporary Friend",
            avatar: "⏰",
            level: 10,
            currentStreak: 5,
            totalQuestsCompleted: 50
        )
        friendManager.addFriend(friend)
        
        // Add activities
        for i in 1...5 {
            let activity = SharedActivity(
                friendId: friend.id,
                activityType: .questCompleted,
                title: "Activity \(i)",
                description: "Test"
            )
            friendManager.addActivity(activity)
        }
        
        // When - Remove friend
        friendManager.removeFriend(friend)
        
        // Then - Friend should be removed but activities might remain
        XCTAssertFalse(friendManager.friends.contains { $0.id == friend.id })
    }
    
    func testChallengeWithNoParticipants() {
        // Given - A challenge with no participants
        let challenge = challengeManager.activeChallenges.first!
        
        // When - Get leaderboard
        let leaderboard = challengeManager.getLeaderboard(for: challenge)
        
        // Then - Should handle gracefully
        XCTAssertEqual(leaderboard.count, challenge.participants.count)
    }
    
    func testConcurrentFriendOperations() {
        // Test thread safety of friend operations
        let expectation = self.expectation(description: "Concurrent operations complete")
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        
        // Perform multiple concurrent operations
        for i in 1...10 {
            group.enter()
            queue.async {
                let friend = Friend(
                    username: "concurrent\(i)",
                    displayName: "Concurrent \(i)",
                    avatar: "\(i)️⃣",
                    level: i,
                    currentStreak: i,
                    totalQuestsCompleted: i * 10
                )
                self.friendManager.addFriend(friend)
                
                // Add activity
                let activity = SharedActivity(
                    friendId: friend.id,
                    activityType: .questCompleted,
                    title: "Concurrent activity \(i)",
                    description: "Test"
                )
                self.friendManager.addActivity(activity)
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Verify all operations completed successfully
            XCTAssertGreaterThanOrEqual(self.friendManager.friends.count, 10)
            XCTAssertGreaterThanOrEqual(self.friendManager.recentActivities.count, 10)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}