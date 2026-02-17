import SwiftUI

struct PrestigeView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPerkId: String?
    @State private var showConfirmation = false

    var canPrestige: Bool {
        gameManager.character.level >= 20
    }

    var currentPrestige: Int {
        gameManager.character.prestigeData.prestigeLevel
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Prestige Level Header
                    prestigeHeader

                    if canPrestige {
                        // What You Keep / Reset
                        keepResetSection

                        // Perk Selection
                        perkSelectionSection

                        // Prestige Button
                        Button(action: { showConfirmation = true }) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Prestige Now")
                            }
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                selectedPerkId != nil
                                    ? LinearGradient(colors: [.purple, .orange], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                        }
                        .disabled(selectedPerkId == nil)
                        .padding(.horizontal)
                    } else {
                        // Requirements not met
                        MindLabsCard {
                            VStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.mindLabsTextSecondary)
                                Text("Reach Level 20 to Prestige")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                                Text("Current Level: \(gameManager.character.level)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)

                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.mindLabsBorder.opacity(0.3))
                                            .frame(height: 8)
                                            .cornerRadius(4)
                                        Rectangle()
                                            .fill(LinearGradient(colors: [.purple, .orange], startPoint: .leading, endPoint: .trailing))
                                            .frame(width: geometry.size.width * CGFloat(gameManager.character.level) / 20.0, height: 8)
                                            .cornerRadius(4)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding()
                        }
                    }

                    // Prestige History
                    if !gameManager.character.prestigeData.prestigeHistory.isEmpty {
                        prestigeHistorySection
                    }
                }
                .padding()
            }
            .navigationTitle("Prestige")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.mindLabsPurple))
            .alert("Confirm Prestige", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Prestige!", role: .destructive) {
                    if let perkId = selectedPerkId {
                        gameManager.performPrestige(perkId: perkId)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text("Your level and stats will reset to 1. You keep your inventory, equipment, cosmetics, achievements, and story progress. You'll earn permanent bonuses!")
            }
        }
    }

    // MARK: - Prestige Header
    var prestigeHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(0..<max(1, currentPrestige), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                }
            }
            .font(.title2)

            Text("Prestige Level \(currentPrestige)")
                .font(MindLabsTypography.title())
                .foregroundColor(.white)

            if currentPrestige > 0 {
                let rewards = PrestigeRewards.rewards(for: currentPrestige)
                HStack(spacing: 15) {
                    Label("+\(rewards.bonusXPPercent)% XP", systemImage: "star.fill")
                    Label("+\(rewards.bonusGoldPercent)% Gold", systemImage: "bitcoinsign.circle.fill")
                    Label("+\(rewards.extraSkillPoints) SP", systemImage: "arrow.triangle.branch")
                }
                .font(MindLabsTypography.caption())
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(colors: [.purple, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(15)
    }

    // MARK: - Keep / Reset Section
    var keepResetSection: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("What Happens")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Level resets to 1", systemImage: "arrow.counterclockwise")
                        .foregroundColor(.mindLabsError)
                    Label("Stats reset to base", systemImage: "arrow.counterclockwise")
                        .foregroundColor(.mindLabsError)
                    Label("Gold set to \(100 * (currentPrestige + 2))", systemImage: "arrow.counterclockwise")
                        .foregroundColor(.orange)
                }
                .font(MindLabsTypography.caption())

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Label("Inventory & Equipment kept", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.mindLabsSuccess)
                    Label("Cosmetics & Achievements kept", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.mindLabsSuccess)
                    Label("Story progress kept", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.mindLabsSuccess)
                    Label("Skill tree unlocks kept", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.mindLabsSuccess)
                    Label("Permanent perk earned", systemImage: "star.circle.fill")
                        .foregroundColor(.orange)
                }
                .font(MindLabsTypography.caption())
            }
        }
    }

    // MARK: - Perk Selection
    var perkSelectionSection: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose a Perk")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)

                Text("Select one permanent bonus (cannot be changed)")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)

                ForEach(PrestigePerk.allPerks) { perk in
                    let isAlreadyChosen = gameManager.character.prestigeData.activePerkIds.contains(perk.id)
                    let isSelected = selectedPerkId == perk.id

                    Button(action: {
                        if !isAlreadyChosen {
                            selectedPerkId = perk.id
                            HapticService.selection()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: perk.icon)
                                .font(.title3)
                                .foregroundColor(isAlreadyChosen ? .gray : (isSelected ? .white : .mindLabsPurple))
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(perk.name)
                                    .font(MindLabsTypography.subheadline())
                                    .foregroundColor(isAlreadyChosen ? .gray : (isSelected ? .white : .mindLabsText))
                                Text(perk.description)
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(isAlreadyChosen ? .gray : (isSelected ? .white.opacity(0.8) : .mindLabsTextSecondary))
                            }

                            Spacer()

                            if isAlreadyChosen {
                                Text("Owned")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.gray)
                            } else if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? Color.mindLabsPurple : Color.mindLabsBorder.opacity(0.1))
                        )
                    }
                    .disabled(isAlreadyChosen)
                }
            }
        }
    }

    // MARK: - Prestige History
    var prestigeHistorySection: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Prestige History")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)

                ForEach(gameManager.character.prestigeData.prestigeHistory) { record in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Prestige at Level \(record.levelAtPrestige)")
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)

                            if let perk = PrestigePerk.perk(for: record.perkChosen) {
                                Text("Perk: \(perk.name)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsPurple)
                            }
                        }

                        Spacer()

                        Text(record.date, style: .date)
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
