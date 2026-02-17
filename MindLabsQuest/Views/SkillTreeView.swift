import SwiftUI

struct SkillTreeView: View {
    @EnvironmentObject var gameManager: GameManager
    @StateObject private var skillTreeManager = SkillTreeManager()
    @State private var confirmSkill: Skill?
    @State private var showConfirmation = false

    var characterClass: CharacterClass {
        gameManager.character.characterClass ?? .warrior
    }

    var skillsByBranch: [SkillBranch: [Skill]] {
        skillTreeManager.skillsByBranch(for: characterClass)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Skill points header
                    skillPointsHeader

                    // 3 branch columns
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(SkillBranch.allCases, id: \.self) { branch in
                            branchColumn(branch)
                        }
                    }
                    .padding(.horizontal, 4)

                    // Bonus summary
                    bonusSummary
                }
                .padding()
            }
            .navigationTitle("Skill Tree")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .alert("Unlock Skill", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Unlock") {
                    if let skill = confirmSkill {
                        if skillTreeManager.unlockSkill(skill, character: &gameManager.character) {
                            gameManager.saveData()
                        }
                    }
                }
            } message: {
                if let skill = confirmSkill {
                    Text("Spend \(skill.skillPointCost) skill point\(skill.skillPointCost > 1 ? "s" : "") to unlock \(skill.name)?")
                }
            }
        }
    }

    // MARK: - Skill Points Header
    private var skillPointsHeader: some View {
        MindLabsCard {
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundColor(.mindLabsWarning)
                VStack(alignment: .leading) {
                    Text("Available Skill Points")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    Text("\(gameManager.character.skillProgress.skillPoints)")
                        .font(MindLabsTypography.title())
                        .foregroundColor(.mindLabsText)
                }
                Spacer()
                Text("\(gameManager.character.skillProgress.unlockedSkillIds.count) skills unlocked")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
            }
        }
    }

    // MARK: - Branch Column
    private func branchColumn(_ branch: SkillBranch) -> some View {
        VStack(spacing: 8) {
            // Branch header
            VStack(spacing: 4) {
                Image(systemName: branch.icon)
                    .font(.title3)
                    .foregroundColor(branchColor(branch))
                Text(branch.displayName)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(branchColor(branch))
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(branchColor(branch).opacity(0.1))
            .cornerRadius(8)

            // Skills in tiers
            let skills = skillsByBranch[branch] ?? []
            ForEach(skills) { skill in
                skillNode(skill)
            }
        }
    }

    // MARK: - Skill Node
    private func skillNode(_ skill: Skill) -> some View {
        let state = skillTreeManager.skillState(skill, character: gameManager.character)

        return Button {
            if state == .unlockable {
                confirmSkill = skill
                showConfirmation = true
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: skill.icon)
                    .font(.system(size: 20))
                    .foregroundColor(nodeIconColor(state))

                Text(skill.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(nodeTextColor(state))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text("T\(skill.tier) · \(skill.skillPointCost)pt")
                    .font(.system(size: 8))
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(6)
            .background(nodeBackground(state, branch: skill.branch))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(nodeBorderColor(state, branch: skill.branch), lineWidth: state == .unlockable ? 2 : 1)
            )
            .cornerRadius(8)
        }
        .disabled(state == .locked)
    }

    // MARK: - Bonus Summary
    private var bonusSummary: some View {
        let bonuses = gameManager.character.skillBonuses
        let hasAnyBonus = bonuses.critChance > 0 || bonuses.dodgeChance > 0 ||
            bonuses.damageMultiplier > 0 || bonuses.lifestealPercent > 0 ||
            !bonuses.statBoosts.isEmpty || bonuses.maxHealthBonus > 0

        return Group {
            if hasAnyBonus {
                MindLabsCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active Bonuses")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)

                        if bonuses.critChance > 0 {
                            bonusRow(icon: "bolt.fill", text: "+\(bonuses.critChance)% Crit Chance", color: .orange)
                        }
                        if bonuses.dodgeChance > 0 {
                            bonusRow(icon: "figure.walk", text: "+\(bonuses.dodgeChance)% Dodge", color: .blue)
                        }
                        if bonuses.damageMultiplier > 0 {
                            bonusRow(icon: "flame.fill", text: "+\(bonuses.damageMultiplier)% Damage", color: .red)
                        }
                        if bonuses.defenseMultiplier > 0 {
                            bonusRow(icon: "shield.fill", text: "+\(bonuses.defenseMultiplier)% Defense", color: .blue)
                        }
                        if bonuses.lifestealPercent > 0 {
                            bonusRow(icon: "heart.fill", text: "+\(bonuses.lifestealPercent)% Lifesteal", color: .red)
                        }
                        if bonuses.maxHealthBonus > 0 {
                            bonusRow(icon: "heart.circle.fill", text: "+\(bonuses.maxHealthBonus) Max HP", color: .green)
                        }
                        if bonuses.goldMultiplier > 0 {
                            bonusRow(icon: "dollarsign.circle.fill", text: "+\(bonuses.goldMultiplier)% Gold", color: .yellow)
                        }
                        if bonuses.xpMultiplier > 0 {
                            bonusRow(icon: "star.fill", text: "+\(bonuses.xpMultiplier)% XP", color: .purple)
                        }
                        ForEach(Array(bonuses.statBoosts.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { stat in
                            if let value = bonuses.statBoosts[stat] {
                                bonusRow(icon: "arrow.up.circle.fill", text: "+\(value) \(stat.rawValue)", color: stat.color)
                            }
                        }
                    }
                }
            }
        }
    }

    private func bonusRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(text)
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsText)
        }
    }

    // MARK: - Styling Helpers
    private func branchColor(_ branch: SkillBranch) -> Color {
        switch branch {
        case .offense: return .red
        case .defense: return .blue
        case .utility: return .green
        }
    }

    private func nodeIconColor(_ state: SkillTreeManager.SkillState) -> Color {
        switch state {
        case .locked: return .gray
        case .unlockable: return .mindLabsWarning
        case .unlocked: return .white
        }
    }

    private func nodeTextColor(_ state: SkillTreeManager.SkillState) -> Color {
        switch state {
        case .locked: return .gray
        case .unlockable: return .mindLabsText
        case .unlocked: return .white
        }
    }

    private func nodeBackground(_ state: SkillTreeManager.SkillState, branch: SkillBranch) -> Color {
        switch state {
        case .locked: return Color.mindLabsCard.opacity(0.5)
        case .unlockable: return Color.mindLabsCard
        case .unlocked: return branchColor(branch).opacity(0.6)
        }
    }

    private func nodeBorderColor(_ state: SkillTreeManager.SkillState, branch: SkillBranch) -> Color {
        switch state {
        case .locked: return Color.gray.opacity(0.3)
        case .unlockable: return Color.mindLabsWarning
        case .unlocked: return branchColor(branch)
        }
    }
}
