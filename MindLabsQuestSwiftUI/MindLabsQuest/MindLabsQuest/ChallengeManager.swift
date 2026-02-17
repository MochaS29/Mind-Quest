import Foundation
import SwiftUI

// MARK: - Challenge Models
struct CommunityChallenge: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var category: ChallengeCategory
    var difficulty: Difficulty
    var type: ChallengeType
    var startDate: Date
    var endDate: Date
    var goal: Int
    var unit: String
    var reward: ChallengeReward
    var participants: [ChallengeParticipant] = []
    var isActive: Bool = true
    var bannerImage: String?
    var rules: [String] = []
    var createdBy: String = "MindLabs Team"
    
    enum ChallengeCategory: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case special = "Special Event"
        
        var color: Color {
            switch self {
            case .daily: return .blue
            case .weekly: return .green
            case .monthly: return .orange
            case .special: return .purple
            }
        }
    }
    
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case extreme = "Extreme"
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .orange
            case .hard: return .red
            case .extreme: return .purple
            }
        }
        
        var xpMultiplier: Double {
            switch self {
            case .easy: return 1.0
            case .medium: return 1.5
            case .hard: return 2.0
            case .extreme: return 3.0
            }
        }
    }
    
    enum ChallengeType: String, Codable {
        case questCount = "Quest Count"
        case focusTime = "Focus Time"
        case streakDays = "Streak Days"
        case xpEarned = "XP Earned"
        case specificCategory = "Category Specific"
    }
    
    var timeRemaining: String {
        let interval = endDate.timeIntervalSince(Date())
        if interval <= 0 {
            return "Ended"
        }
        
        let days = Int(interval) / 86400
        let hours = Int(interval) % 86400 / 3600
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h \(Int(interval) % 3600 / 60)m"
        }
    }
}

struct ChallengeReward: Codable {
    var xp: Int
    var badge: String?
    var title: String?
    var bonusRewards: [String] = []
}

struct ChallengeParticipant: Codable, Identifiable {
    var id = UUID()
    var userId: String
    var username: String
    var avatar: String
    var progress: Int = 0
    var joinedDate: Date = Date()
    var lastUpdate: Date = Date()
    var rank: Int?
}

struct UserChallengeProgress: Codable, Identifiable {
    var id = UUID()
    var challengeId: UUID
    var userId: String
    var currentProgress: Int = 0
    var milestones: [ChallengeMilestone] = []
    var isCompleted: Bool = false
    var completedDate: Date?
}

struct ChallengeMilestone: Codable, Identifiable {
    var id = UUID()
    var threshold: Int
    var reward: String
    var isAchieved: Bool = false
    var achievedDate: Date?
}

// MARK: - Challenge Manager
class ChallengeManager: ObservableObject {
    static let shared = ChallengeManager()
    
    @Published var activeChallenges: [CommunityChallenge] = []
    @Published var userProgress: [UserChallengeProgress] = []
    @Published var completedChallenges: [CommunityChallenge] = []
    @Published var showChallengeComplete = false
    @Published var completedChallenge: CommunityChallenge?
    
    private let challengesKey = "mindlabs_community_challenges"
    private let progressKey = "mindlabs_challenge_progress"
    private let completedKey = "mindlabs_completed_challenges"
    
    init() {
        loadData()
        setupDefaultChallenges()
        updateChallengeStatuses()
    }
    
    // MARK: - Challenge Management
    func joinChallenge(_ challenge: CommunityChallenge, username: String, avatar: String) {
        guard let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) else { return }
        
        let participant = ChallengeParticipant(
            userId: "current_user",
            username: username,
            avatar: avatar
        )
        
        activeChallenges[index].participants.append(participant)
        
        // Create progress tracking
        let progress = UserChallengeProgress(
            challengeId: challenge.id,
            userId: "current_user",
            milestones: createMilestones(for: challenge)
        )
        
        userProgress.append(progress)
        saveData()
    }
    
    func leaveChallenge(_ challenge: CommunityChallenge) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallenges[index].participants.removeAll { $0.userId == "current_user" }
        }
        
        userProgress.removeAll { $0.challengeId == challenge.id }
        saveData()
    }
    
    func updateProgress(for challengeId: UUID, progress: Int) {
        guard let index = userProgress.firstIndex(where: { $0.challengeId == challengeId }) else { return }
        
        userProgress[index].currentProgress = progress
        userProgress[index].milestones = updateMilestones(
            userProgress[index].milestones,
            progress: progress
        )
        
        // Check if challenge is completed
        if let challenge = activeChallenges.first(where: { $0.id == challengeId }) {
            if progress >= challenge.goal {
                completeChallenge(challenge)
            }
        }
        
        // Update participant progress
        if let challengeIndex = activeChallenges.firstIndex(where: { $0.id == challengeId }),
           let participantIndex = activeChallenges[challengeIndex].participants.firstIndex(where: { $0.userId == "current_user" }) {
            activeChallenges[challengeIndex].participants[participantIndex].progress = progress
            activeChallenges[challengeIndex].participants[participantIndex].lastUpdate = Date()
        }
        
        saveData()
    }
    
    private func completeChallenge(_ challenge: CommunityChallenge) {
        if let progressIndex = userProgress.firstIndex(where: { $0.challengeId == challenge.id }) {
            userProgress[progressIndex].isCompleted = true
            userProgress[progressIndex].completedDate = Date()
        }
        
        completedChallenge = challenge
        showChallengeComplete = true
        
        // Move to completed challenges
        var completedChallenge = challenge
        completedChallenge.isActive = false
        completedChallenges.append(completedChallenge)
        
        saveData()
    }
    
    // MARK: - Helper Methods
    func isUserParticipating(in challenge: CommunityChallenge) -> Bool {
        challenge.participants.contains { $0.userId == "current_user" }
    }
    
    func getUserProgress(for challenge: CommunityChallenge) -> UserChallengeProgress? {
        userProgress.first { $0.challengeId == challenge.id }
    }
    
    func getLeaderboard(for challenge: CommunityChallenge) -> [ChallengeParticipant] {
        challenge.participants.sorted { $0.progress > $1.progress }
    }
    
    func getUserRank(in challenge: CommunityChallenge) -> Int? {
        let sorted = getLeaderboard(for: challenge)
        return sorted.firstIndex { $0.userId == "current_user" }.map { $0 + 1 }
    }
    
    private func createMilestones(for challenge: CommunityChallenge) -> [ChallengeMilestone] {
        let milestoneCount = 4
        var milestones: [ChallengeMilestone] = []
        
        for i in 1...milestoneCount {
            let threshold = (challenge.goal * i) / milestoneCount
            let milestone = ChallengeMilestone(
                threshold: threshold,
                reward: "Bonus \(50 * i) XP"
            )
            milestones.append(milestone)
        }
        
        return milestones
    }
    
    private func updateMilestones(_ milestones: [ChallengeMilestone], progress: Int) -> [ChallengeMilestone] {
        return milestones.map { milestone in
            var updated = milestone
            if progress >= milestone.threshold && !milestone.isAchieved {
                updated.isAchieved = true
                updated.achievedDate = Date()
            }
            return updated
        }
    }
    
    private func updateChallengeStatuses() {
        let now = Date()
        
        // Check for expired challenges
        for i in 0..<activeChallenges.count {
            if activeChallenges[i].endDate < now {
                activeChallenges[i].isActive = false
                
                // Move to completed if user was participating
                if isUserParticipating(in: activeChallenges[i]) {
                    completedChallenges.append(activeChallenges[i])
                }
            }
        }
        
        // Remove inactive challenges
        activeChallenges.removeAll { !$0.isActive }
        saveData()
    }
    
    // MARK: - Default Challenges
    private func setupDefaultChallenges() {
        if activeChallenges.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            
            // Daily Challenge
            let dailyChallenge = CommunityChallenge(
                title: "Daily Productivity Sprint",
                description: "Complete 5 quests today and earn bonus XP!",
                category: .daily,
                difficulty: .easy,
                type: .questCount,
                startDate: calendar.startOfDay(for: today),
                endDate: calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))!,
                goal: 5,
                unit: "quests",
                reward: ChallengeReward(
                    xp: 200,
                    badge: "daily_warrior",
                    title: "Daily Warrior"
                ),
                rules: [
                    "Complete any 5 quests today",
                    "Quests must be marked complete before midnight",
                    "All difficulty levels count"
                ]
            )
            
            // Weekly Challenge
            let weeklyChallenge = CommunityChallenge(
                title: "Focus Week Marathon",
                description: "Accumulate 20 hours of focus time this week",
                category: .weekly,
                difficulty: .medium,
                type: .focusTime,
                startDate: calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today,
                endDate: calendar.date(byAdding: .day, value: 7, to: calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today)!,
                goal: 20,
                unit: "hours",
                reward: ChallengeReward(
                    xp: 500,
                    badge: "focus_master",
                    title: "Focus Master",
                    bonusRewards: ["Unlock special focus theme"]
                ),
                rules: [
                    "Use the Focus Timer to track time",
                    "Breaks don't count toward the goal",
                    "All timer modes are eligible"
                ]
            )
            
            // Monthly Challenge
            let monthlyChallenge = CommunityChallenge(
                title: "Streak Survivor",
                description: "Maintain a 30-day streak this month",
                category: .monthly,
                difficulty: .hard,
                type: .streakDays,
                startDate: calendar.dateInterval(of: .month, for: today)?.start ?? today,
                endDate: calendar.date(byAdding: .month, value: 1, to: calendar.dateInterval(of: .month, for: today)?.start ?? today)!,
                goal: 30,
                unit: "days",
                reward: ChallengeReward(
                    xp: 1000,
                    badge: "streak_legend",
                    title: "Streak Legend",
                    bonusRewards: ["Exclusive avatar frame", "Double XP weekend"]
                ),
                rules: [
                    "Complete at least one quest each day",
                    "Streak resets if you miss a day",
                    "No skip days allowed"
                ]
            )
            
            // Add demo participants
            var challenges = [dailyChallenge, weeklyChallenge, monthlyChallenge]
            for i in 0..<challenges.count {
                challenges[i].participants = generateDemoParticipants()
            }
            
            activeChallenges = challenges
            saveData()
        }
    }
    
    private func generateDemoParticipants() -> [ChallengeParticipant] {
        [
            ChallengeParticipant(
                userId: "demo1",
                username: "QuestMaster",
                avatar: "🧙‍♂️",
                progress: Int.random(in: 40...90)
            ),
            ChallengeParticipant(
                userId: "demo2",
                username: "FocusNinja",
                avatar: "🥷",
                progress: Int.random(in: 30...80)
            ),
            ChallengeParticipant(
                userId: "demo3",
                username: "TaskHero",
                avatar: "🦸‍♀️",
                progress: Int.random(in: 20...70)
            )
        ]
    }
    
    // MARK: - Persistence
    private func saveData() {
        // Save active challenges
        if let encoded = try? JSONEncoder().encode(activeChallenges) {
            UserDefaults.standard.set(encoded, forKey: challengesKey)
        }
        
        // Save user progress
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
        
        // Save completed challenges
        if let encoded = try? JSONEncoder().encode(completedChallenges) {
            UserDefaults.standard.set(encoded, forKey: completedKey)
        }
    }
    
    private func loadData() {
        // Load active challenges
        if let data = UserDefaults.standard.data(forKey: challengesKey),
           let decoded = try? JSONDecoder().decode([CommunityChallenge].self, from: data) {
            activeChallenges = decoded
        }
        
        // Load user progress
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode([UserChallengeProgress].self, from: data) {
            userProgress = decoded
        }
        
        // Load completed challenges
        if let data = UserDefaults.standard.data(forKey: completedKey),
           let decoded = try? JSONDecoder().decode([CommunityChallenge].self, from: data) {
            completedChallenges = decoded
        }
    }
    
    // MARK: - Reset
    func resetAll() {
        activeChallenges = []
        userProgress = []
        completedChallenges = []
        showChallengeComplete = false
        completedChallenge = nil
        
        UserDefaults.standard.removeObject(forKey: challengesKey)
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: completedKey)
    }
}