import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedReward: ParentReward?
    @State private var showClaimAlert = false
    @State private var showNotEligibleAlert = false
    @State private var notEligibleMessage = ""
    
    var parentRewardManager: ParentRewardManager {
        gameManager.parentRewardManager
    }
    
    var eligibleRewards: [ParentReward] {
        parentRewardManager.getEligibleRewards(
            for: gameManager.character,
            achievements: gameManager.achievementManager.achievements
        )
    }
    
    var upcomingRewards: [ParentReward] {
        parentRewardManager.parentRewards
            .filter { reward in
                reward.isActive && !reward.isClaimed && !eligibleRewards.contains(where: { eligible in eligible.id == reward.id })
            }
            .sorted { $0.requiredLevel < $1.requiredLevel }
    }
    
    var claimedRewards: [ParentReward] {
        parentRewardManager.parentRewards
            .filter { $0.isClaimed }
            .sorted { (a, b) in
                (a.claimedDate ?? Date.distantPast) > (b.claimedDate ?? Date.distantPast)
            }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    MindLabsCard {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Parent Rewards")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                                Text("Earn real-world rewards for your progress!")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            
                            Spacer()
                            
                            Text("🎁")
                                .font(.system(size: 50))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Available to Claim
                    if !eligibleRewards.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Available to Claim")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                                .padding(.horizontal)
                            
                            ForEach(eligibleRewards) { reward in
                                RewardCard(reward: reward, isEligible: true) {
                                    selectedReward = reward
                                    showClaimAlert = true
                                }
                            }
                        }
                    }
                    
                    // Upcoming Rewards
                    if !upcomingRewards.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Upcoming Rewards")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                                .padding(.horizontal)
                            
                            ForEach(upcomingRewards) { reward in
                                RewardCard(
                                    reward: reward,
                                    currentLevel: gameManager.character.level,
                                    character: gameManager.character,
                                    achievements: gameManager.achievementManager.achievements
                                ) {
                                    // Show requirements
                                    checkRequirements(for: reward)
                                }
                            }
                        }
                    }
                    
                    // Claimed Rewards
                    if !claimedRewards.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Claimed Rewards")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                                .padding(.horizontal)
                            
                            ForEach(claimedRewards) { reward in
                                RewardCard(reward: reward, isClaimed: true) {
                                    // No action for claimed
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Rewards")
            .mindLabsBackground()
        }
        .alert("Claim Reward?", isPresented: $showClaimAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Claim") {
                if let reward = selectedReward {
                    claimReward(reward)
                }
            }
        } message: {
            if let reward = selectedReward {
                Text("Claim '\(reward.title)'? Your parent will be notified for approval.")
            }
        }
        .alert("Not Yet Eligible", isPresented: $showNotEligibleAlert) {
            Button("OK") { }
        } message: {
            Text(notEligibleMessage)
        }
    }
    
    private func claimReward(_ reward: ParentReward) {
        let success = parentRewardManager.claimReward(
            reward,
            character: gameManager.character,
            achievements: gameManager.achievementManager.achievements
        )
        
        if !success {
            notEligibleMessage = "You don't meet all requirements for this reward yet."
            showNotEligibleAlert = true
        }
    }
    
    private func checkRequirements(for reward: ParentReward) {
        var missingRequirements: [String] = []
        
        if gameManager.character.level < reward.requiredLevel {
            missingRequirements.append("Reach level \(reward.requiredLevel) (current: \(gameManager.character.level))")
        }
        
        for requirement in reward.additionalRequirements {
            if !requirement.isMet(character: gameManager.character, achievements: gameManager.achievementManager.achievements) {
                missingRequirements.append(requirement.description)
            }
        }
        
        if missingRequirements.isEmpty {
            notEligibleMessage = "You meet all requirements!"
        } else {
            notEligibleMessage = "Requirements needed:\n" + missingRequirements.joined(separator: "\n")
        }
        showNotEligibleAlert = true
    }
}

struct RewardCard: View {
    let reward: ParentReward
    var isEligible: Bool = false
    var isClaimed: Bool = false
    var currentLevel: Int = 0
    var character: Character? = nil
    var achievements: [Achievement]? = nil
    let action: () -> Void
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(reward.title)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Text(reward.description)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                    
                    if isEligible {
                        Button("Claim") {
                            action()
                        }
                        .buttonStyle(MindLabsPrimaryButtonStyle())
                        .frame(width: 80)
                    } else if !isClaimed {
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("Level \(reward.requiredLevel)")
                                .font(MindLabsTypography.caption())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    currentLevel >= reward.requiredLevel
                                        ? Color.mindLabsSuccess.opacity(0.2)
                                        : Color.mindLabsBorder.opacity(0.2)
                                )
                                .foregroundColor(
                                    currentLevel >= reward.requiredLevel
                                        ? .mindLabsSuccess
                                        : .mindLabsTextSecondary
                                )
                                .cornerRadius(15)
                            
                            if currentLevel < reward.requiredLevel {
                                Text("\(reward.requiredLevel - currentLevel) levels to go")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                }
                
                // Requirements
                if !reward.additionalRequirements.isEmpty && !isClaimed {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(reward.additionalRequirements.indices, id: \.self) { index in
                            let requirement = reward.additionalRequirements[index]
                            let isMet = character != nil && achievements != nil
                                ? requirement.isMet(character: character!, achievements: achievements!)
                                : false
                            
                            HStack(spacing: 5) {
                                Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isMet ? .mindLabsSuccess : .mindLabsTextSecondary)
                                    .font(.caption)
                                
                                Text(requirement.description)
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(isMet ? .mindLabsText : .mindLabsTextSecondary)
                            }
                        }
                    }
                    .padding(.top, 5)
                }
                
                // Status
                if isClaimed {
                    HStack {
                        if reward.isApproved {
                            Label("Approved", systemImage: "checkmark.circle.fill")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsSuccess)
                        } else {
                            Label("Pending Approval", systemImage: "clock.fill")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsWarning)
                        }
                        
                        Spacer()
                        
                        if let date = reward.claimedDate {
                            Text(date, style: .date)
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            if !isEligible && !isClaimed {
                action()
            }
        }
        .opacity(isClaimed && reward.isApproved ? 0.7 : 1.0)
    }
}