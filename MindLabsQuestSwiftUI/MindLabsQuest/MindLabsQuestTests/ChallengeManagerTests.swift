import XCTest
@testable import MindLabsQuest

class ChallengeManagerTests: XCTestCase {
    var challengeManager: ChallengeManager!
    
    override func setUp() {
        super.setUp()
        challengeManager = ChallengeManager()
        // Clear any existing data
        challengeManager.resetAll()
    }
    
    override func tearDown() {
        challengeManager.resetAll()
        challengeManager = nil
        super.tearDown()
    }
    
    // MARK: - Challenge Management Tests
    
    func testDefaultChallengesCreated() {
        // Given
        // ChallengeManager creates default challenges on init
        
        // Then
        XCTAssertTrue(challengeManager.activeChallenges.count > 0)
        
        // Check for different challenge types
        let hasDaily = challengeManager.activeChallenges.contains { $0.category == .daily }
        let hasWeekly = challengeManager.activeChallenges.contains { $0.category == .weekly }
        let hasMonthly = challengeManager.activeChallenges.contains { $0.category == .monthly }
        
        XCTAssertTrue(hasDaily)
        XCTAssertTrue(hasWeekly)
        XCTAssertTrue(hasMonthly)
    }
    
    func testJoinChallenge() {
        // Given
        let challenge = challengeManager.activeChallenges.first!
        let initialParticipantCount = challenge.participants.count
        
        // When
        challengeManager.joinChallenge(challenge, username: "TestUser", avatar: "🧪")
        
        // Then
        let updatedChallenge = challengeManager.activeChallenges.first { $0.id == challenge.id }!
        XCTAssertEqual(updatedChallenge.participants.count, initialParticipantCount + 1)
        XCTAssertTrue(challengeManager.isUserParticipating(in: updatedChallenge))
        XCTAssertNotNil(challengeManager.getUserProgress(for: updatedChallenge))
    }
    
    func testLeaveChallenge() {
        // Given
        let challenge = challengeManager.activeChallenges.first!
        challengeManager.joinChallenge(challenge, username: "TestUser", avatar: "🧪")
        
        // When
        challengeManager.leaveChallenge(challenge)
        
        // Then
        XCTAssertFalse(challengeManager.isUserParticipating(in: challenge))
        XCTAssertNil(challengeManager.getUserProgress(for: challenge))
    }
    
    func testUpdateProgress() {
        // Given
        let challenge = challengeManager.activeChallenges.first!
        challengeManager.joinChallenge(challenge, username: "TestUser", avatar: "🧪")
        
        // When
        challengeManager.updateProgress(for: challenge.id, progress: 3)
        
        // Then
        let progress = challengeManager.getUserProgress(for: challenge)
        XCTAssertEqual(progress?.currentProgress, 3)
        
        // Check participant progress is updated
        let updatedChallenge = challengeManager.activeChallenges.first { $0.id == challenge.id }!
        let participant = updatedChallenge.participants.first { $0.userId == "current_user" }
        XCTAssertEqual(participant?.progress, 3)
    }
    
    func testCompleteChallenge() {
        // Given
        let challenge = challengeManager.activeChallenges.first!
        challengeManager.joinChallenge(challenge, username: "TestUser", avatar: "🧪")
        
        // When
        challengeManager.updateProgress(for: challenge.id, progress: challenge.goal)
        
        // Then
        let progress = challengeManager.getUserProgress(for: challenge)
        XCTAssertTrue(progress?.isCompleted ?? false)
        XCTAssertNotNil(progress?.completedDate)
        XCTAssertTrue(challengeManager.completedChallenges.contains { $0.id == challenge.id })
    }
    
    // MARK: - Milestone Tests
    
    func testMilestoneCreation() {
        // Given
        let challenge = challengeManager.activeChallenges.first!
        challengeManager.joinChallenge(challenge, username: "TestUser", avatar: "🧪")
        
        // When
        let progress = challengeManager.getUserProgress(for: challenge)!
        
        // Then
        XCTAssertEqual(progress.milestones.count, 4) // Default is 4 milestones
        
        // Check milestone thresholds
        let expectedThresholds = [
            challenge.goal / 4,
            challenge.goal / 2,
            (challenge.goal * 3) / 4,
            challenge.goal
        ]
        
        for (index, milestone) in progress.milestones.enumerated() {
            XCTAssertEqual(milestone.threshold, expectedThresholds[index])
        }
    }
    
    func testMilestoneAchievement() {
        // Given
        let challenge = challengeManager.activeChallenges.first!
        challengeManager.joinChallenge(challenge, username: "TestUser", avatar: "🧪")
        let firstMilestoneThreshold = challenge.goal / 4
        
        // When
        challengeManager.updateProgress(for: challenge.id, progress: firstMilestoneThreshold)
        
        // Then
        let progress = challengeManager.getUserProgress(for: challenge)!
        let firstMilestone = progress.milestones.first!
        XCTAssertTrue(firstMilestone.isAchieved)
        XCTAssertNotNil(firstMilestone.achievedDate)
    }
    
    // MARK: - Leaderboard Tests
    
    func testGetLeaderboard() {
        // Given
        var challenge = challengeManager.activeChallenges.first!
        
        // Add test participants with different progress
        let participant1 = ChallengeParticipant(
            userId: "user1",
            username: "User1",
            avatar: "1️⃣",
            progress: 10
        )
        let participant2 = ChallengeParticipant(
            userId: "user2",
            username: "User2",
            avatar: "2️⃣",
            progress: 20
        )
        let participant3 = ChallengeParticipant(
            userId: "user3",
            username: "User3",
            avatar: "3️⃣",
            progress: 15
        )
        
        challenge.participants = [participant1, participant2, participant3]
        
        // Update challenge in manager
        if let index = challengeManager.activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            challengeManager.activeChallenges[index] = challenge
        }
        
        // When
        let leaderboard = challengeManager.getLeaderboard(for: challenge)
        
        // Then
        XCTAssertEqual(leaderboard.count, 3)
        XCTAssertEqual(leaderboard[0].progress, 20) // Highest first
        XCTAssertEqual(leaderboard[1].progress, 15)
        XCTAssertEqual(leaderboard[2].progress, 10) // Lowest last
    }
    
    func testGetUserRank() {
        // Given
        var challenge = challengeManager.activeChallenges.first!
        
        // Add current user and other participants
        let currentUser = ChallengeParticipant(
            userId: "current_user",
            username: "TestUser",
            avatar: "🧪",
            progress: 15
        )
        let otherUser1 = ChallengeParticipant(
            userId: "user1",
            username: "User1",
            avatar: "1️⃣",
            progress: 20
        )
        let otherUser2 = ChallengeParticipant(
            userId: "user2",
            username: "User2",
            avatar: "2️⃣",
            progress: 10
        )
        
        challenge.participants = [currentUser, otherUser1, otherUser2]
        
        // Update challenge in manager
        if let index = challengeManager.activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            challengeManager.activeChallenges[index] = challenge
        }
        
        // When
        let rank = challengeManager.getUserRank(in: challenge)
        
        // Then
        XCTAssertEqual(rank, 2) // Second place (20, 15, 10)
    }
    
    // MARK: - Challenge Types Tests
    
    func testDifferentChallengeTypes() {
        // Test that different challenge types are properly configured
        let challenges = challengeManager.activeChallenges
        
        // Quest Count Challenge
        if let questChallenge = challenges.first(where: { $0.type == .questCount }) {
            XCTAssertEqual(questChallenge.unit, "quests")
        }
        
        // Focus Time Challenge
        if let focusChallenge = challenges.first(where: { $0.type == .focusTime }) {
            XCTAssertEqual(focusChallenge.unit, "hours")
        }
        
        // Streak Days Challenge
        if let streakChallenge = challenges.first(where: { $0.type == .streakDays }) {
            XCTAssertEqual(streakChallenge.unit, "days")
        }
    }
    
    func testChallengeDifficulty() {
        // Test XP multipliers for different difficulties
        XCTAssertEqual(CommunityChallenge.Difficulty.easy.xpMultiplier, 1.0)
        XCTAssertEqual(CommunityChallenge.Difficulty.medium.xpMultiplier, 1.5)
        XCTAssertEqual(CommunityChallenge.Difficulty.hard.xpMultiplier, 2.0)
        XCTAssertEqual(CommunityChallenge.Difficulty.extreme.xpMultiplier, 3.0)
    }
    
    // MARK: - Persistence Tests
    
    func testDataPersistence() {
        // Given
        let challenge = challengeManager.activeChallenges.first!
        challengeManager.joinChallenge(challenge, username: "TestUser", avatar: "🧪")
        challengeManager.updateProgress(for: challenge.id, progress: 3)
        
        // When
        // Create a new instance to test loading
        let newChallengeManager = ChallengeManager()
        
        // Then
        let progress = newChallengeManager.getUserProgress(for: challenge)
        XCTAssertNotNil(progress)
        XCTAssertEqual(progress?.currentProgress, 3)
        
        // Cleanup
        newChallengeManager.resetAll()
    }
}

// MARK: - Challenge Model Tests

extension ChallengeManagerTests {
    func testChallengeTimeRemaining() {
        // Given
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        
        let activeChallenge = CommunityChallenge(
            title: "Active Challenge",
            description: "Test",
            category: .daily,
            difficulty: .easy,
            type: .questCount,
            startDate: Date(),
            endDate: futureDate,
            goal: 5,
            unit: "quests",
            reward: ChallengeReward(xp: 100)
        )
        
        let endedChallenge = CommunityChallenge(
            title: "Ended Challenge",
            description: "Test",
            category: .daily,
            difficulty: .easy,
            type: .questCount,
            startDate: pastDate.addingTimeInterval(-3600),
            endDate: pastDate,
            goal: 5,
            unit: "quests",
            reward: ChallengeReward(xp: 100)
        )
        
        // Then
        XCTAssertNotEqual(activeChallenge.timeRemaining, "Ended")
        XCTAssertEqual(endedChallenge.timeRemaining, "Ended")
    }
    
    func testChallengeRewards() {
        // Given
        let reward = ChallengeReward(
            xp: 500,
            badge: "champion_badge",
            title: "Challenge Champion",
            bonusRewards: ["Extra life", "Double XP weekend"]
        )
        
        // Then
        XCTAssertEqual(reward.xp, 500)
        XCTAssertEqual(reward.badge, "champion_badge")
        XCTAssertEqual(reward.title, "Challenge Champion")
        XCTAssertEqual(reward.bonusRewards.count, 2)
    }
}