import SwiftUI

struct SeasonalEventView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode

    var eventManager: SeasonalEventManager {
        gameManager.seasonalEventManager
    }

    var body: some View {
        NavigationView {
            ScrollView {
                if let event = eventManager.activeEvent {
                    VStack(spacing: 20) {
                        // Event Banner
                        eventBanner(event)

                        // Challenges
                        challengesSection(event)

                        // Exclusive Items Preview
                        exclusiveItemsSection(event)

                        // Battle Seasonal Enemy
                        if gameManager.energyManager.currentEnergy >= 1 {
                            Button(action: startSeasonalBattle) {
                                HStack {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.yellow)
                                    Text("Battle Seasonal Enemy")
                                    Text("(1 Energy)")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [event.themeColor, event.themeColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.mindLabsTextSecondary)
                        Text("No Active Event")
                            .font(MindLabsTypography.title())
                            .foregroundColor(.mindLabsText)
                        Text("Check back soon for seasonal events!")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding(.top, 80)
                }
            }
            .navigationTitle("Seasonal Event")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.mindLabsPurple))
        }
    }

    // MARK: - Event Banner
    func eventBanner(_ event: SeasonalEvent) -> some View {
        VStack(spacing: 12) {
            Text(event.icon)
                .font(.system(size: 50))

            Text(event.name)
                .font(MindLabsTypography.title())
                .foregroundColor(.white)

            Text(event.description)
                .font(MindLabsTypography.caption())
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            HStack {
                Image(systemName: "clock.fill")
                Text("\(event.daysRemaining) days remaining")
            }
            .font(MindLabsTypography.caption())
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(colors: [event.themeColor, event.themeColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(15)
    }

    // MARK: - Challenges Section
    func challengesSection(_ event: SeasonalEvent) -> some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Challenges")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    Spacer()
                    Text("\(eventManager.completedChallengeCount)/\(eventManager.totalChallengeCount)")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }

                ForEach(event.challenges) { challenge in
                    VStack(spacing: 8) {
                        HStack {
                            Text(challenge.icon)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(challenge.title)
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(.mindLabsText)
                                Text(challenge.description)
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            Spacer()

                            if challenge.isClaimed {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.mindLabsSuccess)
                            } else if challenge.isCompleted {
                                Button("Claim") {
                                    claimReward(challengeId: challenge.id, rewards: challenge.rewards)
                                }
                                .font(MindLabsTypography.caption())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.mindLabsSuccess)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            } else {
                                Text("\(challenge.progress)/\(challenge.target)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.mindLabsBorder.opacity(0.3))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                Rectangle()
                                    .fill(challenge.isClaimed ? Color.gray : (challenge.isCompleted ? Color.mindLabsSuccess : event.themeColor))
                                    .frame(width: geometry.size.width * min(1.0, CGFloat(challenge.progress) / CGFloat(max(1, challenge.target))), height: 6)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(height: 6)

                        // Rewards preview
                        HStack(spacing: 8) {
                            if challenge.rewards.xp > 0 {
                                Label("\(challenge.rewards.xp) XP", systemImage: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.blue)
                            }
                            if challenge.rewards.gold > 0 {
                                Label("\(challenge.rewards.gold) Gold", systemImage: "bitcoinsign.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.mindLabsBorder.opacity(challenge.isClaimed ? 0.05 : 0.1))
                    .cornerRadius(8)
                    .opacity(challenge.isClaimed ? 0.6 : 1.0)
                }
            }
        }
    }

    // MARK: - Exclusive Items
    func exclusiveItemsSection(_ event: SeasonalEvent) -> some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Exclusive Items")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)

                ForEach(event.exclusiveItems) { item in
                    HStack {
                        Text(item.icon)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)
                            Text(item.itemDescription)
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        Spacer()
                        Text(item.rarity.rawValue)
                            .font(.system(size: 10))
                            .foregroundColor(item.rarity.color)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Actions
    private func startSeasonalBattle() {
        guard let encounter = eventManager.getSeasonalEncounter(playerLevel: gameManager.character.level) else { return }
        guard gameManager.energyManager.spendEnergy(1) else { return }
        let bm = gameManager.getBattleManager()
        bm.startBattle(encounter: encounter)
    }

    private func claimReward(challengeId: String, rewards: SeasonalRewardSet) {
        if let claimed = eventManager.claimReward(challengeId: challengeId) {
            gameManager.character.xp += claimed.xp
            gameManager.character.gold += claimed.gold
            for item in claimed.items {
                var uniqueItem = item
                uniqueItem.id = UUID()
                _ = gameManager.character.addItem(uniqueItem)
            }
            while gameManager.character.xp >= gameManager.character.xpToNext {
                gameManager.character.xp -= gameManager.character.xpToNext
                gameManager.character.level += 1
                gameManager.character.xpToNext = gameManager.character.level * 100
            }
            gameManager.saveData()
        }
    }
}
