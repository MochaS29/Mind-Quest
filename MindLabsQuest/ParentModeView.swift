import SwiftUI

struct ParentModeView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showPINEntry = true
    @State private var enteredPIN = ""
    @State private var showIncorrectPIN = false
    @State private var isSettingNewPIN = false
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    
    var parentRewardManager: ParentRewardManager {
        gameManager.parentRewardManager
    }
    
    var body: some View {
        NavigationView {
            if showPINEntry {
                PINEntryView(
                    enteredPIN: $enteredPIN,
                    showIncorrectPIN: $showIncorrectPIN,
                    isSettingNewPIN: $isSettingNewPIN,
                    newPIN: $newPIN,
                    confirmPIN: $confirmPIN,
                    onSuccess: {
                        showPINEntry = false
                    }
                )
            } else {
                ParentDashboardView()
            }
        }
    }
}

struct PINEntryView: View {
    @EnvironmentObject var gameManager: GameManager
    @Binding var enteredPIN: String
    @Binding var showIncorrectPIN: Bool
    @Binding var isSettingNewPIN: Bool
    @Binding var newPIN: String
    @Binding var confirmPIN: String
    let onSuccess: () -> Void
    
    var parentRewardManager: ParentRewardManager {
        gameManager.parentRewardManager
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Parent Mode")
                .font(MindLabsTypography.title())
                .foregroundColor(.mindLabsText)
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.mindLabsPurple)
            
            if !parentRewardManager.hasPINSet() || isSettingNewPIN {
                // Set new PIN
                VStack(spacing: 20) {
                    Text("Set Parent PIN")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    SecureField("Enter 4-digit PIN", text: $newPIN)
                        .textFieldStyle(MindLabsTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 200)
                    
                    SecureField("Confirm PIN", text: $confirmPIN)
                        .textFieldStyle(MindLabsTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 200)
                    
                    Button("Set PIN") {
                        if newPIN == confirmPIN && newPIN.count == 4 {
                            parentRewardManager.setPIN(newPIN)
                            onSuccess()
                        }
                    }
                    .buttonStyle(MindLabsPrimaryButtonStyle())
                    .frame(width: 200)
                    .disabled(newPIN != confirmPIN || newPIN.count != 4)
                }
            } else {
                // Enter existing PIN
                VStack(spacing: 20) {
                    Text("Enter Parent PIN")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    SecureField("4-digit PIN", text: $enteredPIN)
                        .textFieldStyle(MindLabsTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 200)
                    
                    if showIncorrectPIN {
                        Text("Incorrect PIN")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsError)
                    }
                    
                    Button("Enter") {
                        if parentRewardManager.verifyPIN(enteredPIN) {
                            onSuccess()
                        } else {
                            showIncorrectPIN = true
                            enteredPIN = ""
                        }
                    }
                    .buttonStyle(MindLabsPrimaryButtonStyle())
                    .frame(width: 200)
                    .disabled(enteredPIN.count != 4)
                }
            }
        }
        .padding()
        .navigationBarItems(
            leading: Button("Cancel") {
                // Dismiss
            }
            .foregroundColor(.mindLabsPurple)
        )
        .mindLabsBackground()
    }
}

struct ParentDashboardView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Tab selector
            Picker("", selection: $selectedTab) {
                Text("Rewards").tag(0)
                Text("Progress").tag(1)
                Text("Settings").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            switch selectedTab {
            case 0:
                ParentRewardsView()
            case 1:
                ParentProgressView()
            case 2:
                ParentSettingsView()
            default:
                EmptyView()
            }
        }
        .navigationTitle("Parent Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .mindLabsBackground()
    }
}

struct ParentRewardsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showAddReward = false
    @State private var selectedReward: ParentReward?
    
    var parentRewardManager: ParentRewardManager {
        gameManager.parentRewardManager
    }
    
    var pendingRewards: [ParentReward] {
        parentRewardManager.getClaimedRewards()
    }
    
    var activeRewards: [ParentReward] {
        parentRewardManager.parentRewards.filter { $0.isActive && !$0.isClaimed }
    }
    
    var approvedRewards: [ParentReward] {
        parentRewardManager.getApprovedRewards()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Pending Approval
                if !pendingRewards.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pending Approval")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                            .padding(.horizontal)
                        
                        ForEach(pendingRewards) { reward in
                            ParentRewardCard(reward: reward, isPending: true) {
                                parentRewardManager.approveReward(reward)
                            }
                        }
                    }
                }
                
                // Active Rewards
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Active Rewards")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Spacer()
                        
                        Button(action: {
                            showAddReward = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.mindLabsPurple)
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(activeRewards) { reward in
                        ParentRewardCard(reward: reward) {
                            selectedReward = reward
                        }
                    }
                }
                
                // Approved History
                if !approvedRewards.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Approved Rewards")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                            .padding(.horizontal)
                        
                        ForEach(approvedRewards) { reward in
                            ParentRewardCard(reward: reward, isHistory: true) {
                                // No action for history
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showAddReward) {
            AddRewardView()
        }
        .sheet(item: $selectedReward) { reward in
            EditRewardView(reward: reward)
        }
    }
}

struct ParentRewardCard: View {
    let reward: ParentReward
    var isPending: Bool = false
    var isHistory: Bool = false
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
                    
                    if isPending {
                        Button("Approve") {
                            action()
                        }
                        .buttonStyle(MindLabsPrimaryButtonStyle())
                        .frame(width: 100)
                    } else if !isHistory {
                        Text("Level \(reward.requiredLevel)")
                            .font(MindLabsTypography.caption())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.mindLabsPurple.opacity(0.2))
                            .foregroundColor(.mindLabsPurple)
                            .cornerRadius(15)
                    }
                }
                
                if !reward.additionalRequirements.isEmpty {
                    HStack {
                        ForEach(reward.additionalRequirements.indices, id: \.self) { index in
                            Text(reward.additionalRequirements[index].description)
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            if index < reward.additionalRequirements.count - 1 {
                                Text("•")
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                }
                
                if let claimedDate = reward.claimedDate {
                    Text("Claimed: \(claimedDate, style: .date)")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsPurple)
                }
                
                if let approvedDate = reward.approvedDate {
                    Text("Approved: \(approvedDate, style: .date)")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsSuccess)
                }
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            if !isPending && !isHistory {
                action()
            }
        }
    }
}