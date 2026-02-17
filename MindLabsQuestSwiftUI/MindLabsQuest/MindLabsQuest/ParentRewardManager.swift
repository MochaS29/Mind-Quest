import Foundation
import SwiftUI

class ParentRewardManager: ObservableObject {
    @Published var parentRewards: [ParentReward] = []
    @Published var isParentModeEnabled = false
    @Published var showRewardClaimed = false
    @Published var claimedReward: ParentReward?
    
    private let pinKey = "parentModePIN"
    private let rewardsKey = "parentRewards"
    
    init() {
        loadRewards()
    }
    
    // MARK: - PIN Management
    func setPIN(_ pin: String) {
        UserDefaults.standard.set(pin, forKey: pinKey)
    }
    
    func verifyPIN(_ pin: String) -> Bool {
        guard let savedPIN = UserDefaults.standard.string(forKey: pinKey) else {
            return false
        }
        return pin == savedPIN
    }
    
    func hasPINSet() -> Bool {
        return UserDefaults.standard.string(forKey: pinKey) != nil
    }
    
    func removePIN() {
        UserDefaults.standard.removeObject(forKey: pinKey)
    }
    
    // MARK: - Reward Management
    func addReward(_ reward: ParentReward) {
        parentRewards.append(reward)
        saveRewards()
    }
    
    func updateReward(_ reward: ParentReward) {
        if let index = parentRewards.firstIndex(where: { $0.id == reward.id }) {
            parentRewards[index] = reward
            saveRewards()
        }
    }
    
    func deleteReward(_ reward: ParentReward) {
        parentRewards.removeAll { $0.id == reward.id }
        saveRewards()
    }
    
    func claimReward(_ reward: ParentReward, character: Character, achievements: [Achievement]) -> Bool {
        guard let index = parentRewards.firstIndex(where: { $0.id == reward.id }) else {
            return false
        }
        
        // Check if eligible
        guard character.level >= reward.requiredLevel else {
            return false
        }
        
        // Check additional requirements
        for requirement in reward.additionalRequirements {
            if !requirement.isMet(character: character, achievements: achievements) {
                return false
            }
        }
        
        // Mark as claimed
        parentRewards[index].isClaimed = true
        parentRewards[index].claimedDate = Date()
        
        claimedReward = parentRewards[index]
        showRewardClaimed = true
        
        saveRewards()
        
        // Send notification to parent
        scheduleParentNotification(for: parentRewards[index])
        
        return true
    }
    
    func approveReward(_ reward: ParentReward) {
        if let index = parentRewards.firstIndex(where: { $0.id == reward.id }) {
            parentRewards[index].isApproved = true
            parentRewards[index].approvedDate = Date()
            saveRewards()
        }
    }
    
    func resetReward(_ reward: ParentReward) {
        if let index = parentRewards.firstIndex(where: { $0.id == reward.id }) {
            parentRewards[index].isClaimed = false
            parentRewards[index].isApproved = false
            parentRewards[index].claimedDate = nil
            parentRewards[index].approvedDate = nil
            saveRewards()
        }
    }
    
    // MARK: - Reward Eligibility
    func getEligibleRewards(for character: Character, achievements: [Achievement]) -> [ParentReward] {
        return parentRewards.filter { reward in
            guard reward.isActive && !reward.isClaimed else { return false }
            guard character.level >= reward.requiredLevel else { return false }
            
            for requirement in reward.additionalRequirements {
                if !requirement.isMet(character: character, achievements: achievements) {
                    return false
                }
            }
            
            return true
        }
    }
    
    func getClaimedRewards() -> [ParentReward] {
        return parentRewards.filter { $0.isClaimed && !$0.isApproved }
    }
    
    func getApprovedRewards() -> [ParentReward] {
        return parentRewards.filter { $0.isApproved }
    }
    
    // MARK: - Notifications
    private func scheduleParentNotification(for reward: ParentReward) {
        let content = UNMutableNotificationContent()
        content.title = "Reward Claimed! 🎁"
        content.body = "\(reward.title) has been claimed and is awaiting your approval."
        content.sound = .default
        content.categoryIdentifier = "PARENT_REWARD_CLAIM"
        content.userInfo = ["rewardId": reward.id.uuidString]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "parent_reward_\(reward.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling parent notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Persistence
    private func saveRewards() {
        if let encoded = try? JSONEncoder().encode(parentRewards) {
            UserDefaults.standard.set(encoded, forKey: rewardsKey)
        }
    }
    
    private func loadRewards() {
        if let data = UserDefaults.standard.data(forKey: rewardsKey),
           let decoded = try? JSONDecoder().decode([ParentReward].self, from: data) {
            parentRewards = decoded
        } else {
            // Initialize with default rewards
            parentRewards = ParentReward.defaultRewards
            saveRewards()
        }
    }
    
    // MARK: - Default Rewards Setup
    func setupDefaultRewards() {
        parentRewards = ParentReward.defaultRewards
        saveRewards()
    }
    
    // MARK: - Reset
    func resetAll() {
        parentRewards = []
        isParentModeEnabled = false
        showRewardClaimed = false
        claimedReward = nil
        UserDefaults.standard.removeObject(forKey: rewardsKey)
        UserDefaults.standard.removeObject(forKey: pinKey)
    }
}