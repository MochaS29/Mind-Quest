import Foundation
import SwiftUI

class SkillTreeManager: ObservableObject {

    // MARK: - Check if a skill can be unlocked
    func canUnlock(_ skill: Skill, character: Character) -> Bool {
        // Already unlocked
        guard !character.skillProgress.unlockedSkillIds.contains(skill.id) else { return false }

        // Enough skill points
        guard character.skillProgress.skillPoints >= skill.skillPointCost else { return false }

        // Prerequisite met
        if let prereqId = skill.prerequisiteSkillId {
            guard character.skillProgress.unlockedSkillIds.contains(prereqId) else { return false }
        }

        // Must be the correct class
        guard character.characterClass == skill.characterClass else { return false }

        return true
    }

    // MARK: - Unlock a skill
    func unlockSkill(_ skill: Skill, character: inout Character) -> Bool {
        guard canUnlock(skill, character: character) else { return false }

        character.skillProgress.skillPoints -= skill.skillPointCost
        character.skillProgress.unlockedSkillIds.insert(skill.id)
        return true
    }

    // MARK: - Get skills grouped by branch for a class
    func skillsByBranch(for characterClass: CharacterClass) -> [SkillBranch: [Skill]] {
        let allSkills = SkillTreeDatabase.skillTree(for: characterClass)
        var grouped: [SkillBranch: [Skill]] = [:]
        for branch in SkillBranch.allCases {
            grouped[branch] = allSkills
                .filter { $0.branch == branch }
                .sorted { $0.tier < $1.tier }
        }
        return grouped
    }

    // MARK: - Skill state for UI
    enum SkillState {
        case locked       // prerequisites not met
        case unlockable   // can be unlocked now
        case unlocked     // already unlocked
    }

    func skillState(_ skill: Skill, character: Character) -> SkillState {
        if character.skillProgress.unlockedSkillIds.contains(skill.id) {
            return .unlocked
        } else if canUnlock(skill, character: character) {
            return .unlockable
        } else {
            return .locked
        }
    }
}
