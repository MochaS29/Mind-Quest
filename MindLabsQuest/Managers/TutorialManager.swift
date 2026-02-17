import Foundation

class TutorialManager: ObservableObject {
    @Published var state: TutorialState = TutorialState()
    @Published var activeTutorial: TutorialSequence?

    private let stateKey = "tutorialState"

    init() {
        loadData()
    }

    // MARK: - Trigger Checks
    func checkTriggers(character: Character, hasBattled: Bool = false, hasUsedArena: Bool = false, hasCrafted: Bool = false) {
        guard activeTutorial == nil else { return }

        for sequence in TutorialDatabase.allSequences {
            guard !state.completedSequenceIds.contains(sequence.id) else { continue }

            if isTriggerMet(sequence.triggerCondition, character: character, hasBattled: hasBattled, hasUsedArena: hasUsedArena, hasCrafted: hasCrafted) {
                startSequence(sequence)
                return
            }
        }
    }

    private func isTriggerMet(_ trigger: TutorialTrigger, character: Character, hasBattled: Bool, hasUsedArena: Bool, hasCrafted: Bool) -> Bool {
        switch trigger {
        case .firstLaunch:
            return true
        case .firstBattle:
            return hasBattled
        case .levelUp(let level):
            return character.level >= level
        case .firstArena:
            return hasUsedArena
        case .reachLevel(let level):
            return character.level >= level
        case .firstCraft:
            return hasCrafted
        case .firstDungeon:
            return false // triggered externally
        }
    }

    // MARK: - Sequence Control
    func startSequence(_ sequence: TutorialSequence) {
        activeTutorial = sequence
        state.currentSequenceId = sequence.id
        state.currentStepIndex = 0
        saveData()
    }

    var currentStep: TutorialStep? {
        guard let tutorial = activeTutorial,
              state.currentStepIndex < tutorial.steps.count else { return nil }
        return tutorial.steps[state.currentStepIndex]
    }

    func advanceStep() {
        guard let tutorial = activeTutorial else { return }
        state.currentStepIndex += 1

        if state.currentStepIndex >= tutorial.steps.count {
            completeTutorial()
        } else {
            saveData()
        }
    }

    func skipTutorial() {
        completeTutorial()
    }

    func completeTutorial() {
        if let sequenceId = state.currentSequenceId {
            state.completedSequenceIds.insert(sequenceId)
        }
        state.currentSequenceId = nil
        state.currentStepIndex = 0
        activeTutorial = nil
        saveData()
    }

    // MARK: - Reset
    func resetAll() {
        state = TutorialState()
        activeTutorial = nil
        UserDefaults.standard.removeObject(forKey: stateKey)
    }

    // MARK: - Persistence
    func saveData() {
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: stateKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: stateKey),
           let decoded = try? JSONDecoder().decode(TutorialState.self, from: data) {
            state = decoded
        }
    }
}
