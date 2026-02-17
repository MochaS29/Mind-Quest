import Foundation
import SwiftUI

// MARK: - Battle State
class BattleState: ObservableObject {
    @Published var playerHP: Int
    @Published var playerMaxHP: Int
    @Published var playerAttack: Int
    @Published var playerDefense: Int
    @Published var playerIsDefending: Bool = false
    @Published var playerSpecialReady: Bool = true

    @Published var enemyHP: Int
    @Published var enemyMaxHP: Int
    @Published var enemyAttack: Int
    @Published var enemyDefense: Int
    @Published var enemyName: String
    @Published var enemyAvatar: String
    @Published var enemyAbilities: [EnemyAbility]
    @Published var enemyIsEvading: Bool = false

    @Published var isPlayerTurn: Bool = true
    @Published var battleLog: [BattleLogEntry] = []
    @Published var battleResult: BattleResult?
    @Published var rewards: BattleRewards?

    @Published var lastDamageDealt: Int = 0
    @Published var lastDamageReceived: Int = 0
    @Published var showPlayerDamage: Bool = false
    @Published var showEnemyDamage: Bool = false

    // Status effects
    @Published var playerStatusEffects: [StatusEffect] = []
    @Published var enemyStatusEffects: [StatusEffect] = []

    init(player: Character, encounter: BattleEncounter) {
        self.playerHP = player.health
        self.playerMaxHP = player.maxHealth

        // Use effective stats (base + equipment bonuses)
        self.playerAttack = player.attackPower
        self.playerDefense = player.defensePower

        self.enemyHP = encounter.enemyHP
        self.enemyMaxHP = encounter.enemyMaxHP
        self.enemyAttack = encounter.enemyAttack
        self.enemyDefense = encounter.enemyDefense
        self.enemyName = encounter.enemyName
        self.enemyAvatar = encounter.enemyAvatar
        self.enemyAbilities = encounter.abilities
        self.rewards = encounter.rewards

        addLogEntry("Battle begins against \(encounter.enemyName)!", type: .system)
    }

    func addLogEntry(_ message: String, type: BattleLogEntry.EntryType) {
        let entry = BattleLogEntry(message: message, type: type)
        battleLog.append(entry)
        if battleLog.count > 5 {
            battleLog.removeFirst()
        }
    }

    // MARK: - Status Effect Processing
    func processPlayerStatusEffects() {
        var expiredEffects: [UUID] = []

        for i in 0..<playerStatusEffects.count {
            let effect = playerStatusEffects[i]

            switch effect.type {
            case .poison, .burn, .bleed:
                playerHP = max(0, playerHP - effect.value)
                addLogEntry("\(effect.type.icon) You take \(effect.value) \(effect.type.rawValue.lowercased()) damage!", type: .damage)
            case .regenerate:
                let heal = min(effect.value, playerMaxHP - playerHP)
                playerHP += heal
                if heal > 0 {
                    addLogEntry("\(effect.type.icon) You regenerate \(heal) HP!", type: .heal)
                }
            default:
                break
            }

            playerStatusEffects[i].tick()
            if playerStatusEffects[i].isExpired {
                expiredEffects.append(effect.id)
            }
        }

        playerStatusEffects.removeAll { expiredEffects.contains($0.id) }
    }

    func processEnemyStatusEffects() {
        var expiredEffects: [UUID] = []

        for i in 0..<enemyStatusEffects.count {
            let effect = enemyStatusEffects[i]

            switch effect.type {
            case .poison, .burn, .bleed:
                enemyHP = max(0, enemyHP - effect.value)
                addLogEntry("\(effect.type.icon) \(enemyName) takes \(effect.value) \(effect.type.rawValue.lowercased()) damage!", type: .damage)
            case .regenerate:
                let heal = min(effect.value, enemyMaxHP - enemyHP)
                enemyHP += heal
                if heal > 0 {
                    addLogEntry("\(effect.type.icon) \(enemyName) regenerates \(heal) HP!", type: .heal)
                }
            default:
                break
            }

            enemyStatusEffects[i].tick()
            if enemyStatusEffects[i].isExpired {
                expiredEffects.append(effect.id)
            }
        }

        enemyStatusEffects.removeAll { expiredEffects.contains($0.id) }
    }

    var isPlayerStunned: Bool {
        playerStatusEffects.contains { $0.type == .stun }
    }

    var isEnemyStunned: Bool {
        enemyStatusEffects.contains { $0.type == .stun }
    }

    var playerAttackModifier: Int {
        var mod = 0
        for effect in playerStatusEffects {
            switch effect.type {
            case .strengthen: mod += effect.value
            case .weaken: mod -= effect.value
            default: break
            }
        }
        return mod
    }

    var enemyAttackModifier: Int {
        var mod = 0
        for effect in enemyStatusEffects {
            switch effect.type {
            case .strengthen: mod += effect.value
            case .weaken: mod -= effect.value
            default: break
            }
        }
        return mod
    }
}

// MARK: - Battle Log Entry
struct BattleLogEntry: Identifiable {
    let id = UUID()
    let message: String
    let type: EntryType
    let timestamp = Date()

    enum EntryType {
        case playerAction
        case enemyAction
        case damage
        case heal
        case system
        case victory
        case defeat

        var color: Color {
            switch self {
            case .playerAction: return .blue
            case .enemyAction: return .red
            case .damage: return .orange
            case .heal: return .green
            case .system: return .gray
            case .victory: return .yellow
            case .defeat: return .purple
            }
        }
    }
}

// MARK: - Battle Result
enum BattleResult {
    case victory
    case defeat
    case fled
}

// MARK: - Player Action
enum PlayerAction: Equatable {
    case attack
    case defend
    case special
    case useItem(UUID)
}

// MARK: - Battle Manager
class BattleManager: ObservableObject {
    @Published var battleState: BattleState?
    @Published var currentEncounter: BattleEncounter?
    @Published var isAnimating: Bool = false

    private var character: Character
    var onItemUsed: ((UUID) -> Void)?

    init(character: Character) {
        self.character = character
    }

    func updateCharacter(_ character: Character) {
        self.character = character
    }

    // MARK: - Start Battle
    func startBattle(encounter: BattleEncounter) {
        currentEncounter = encounter
        battleState = BattleState(player: character, encounter: encounter)
    }

    // MARK: - Player Actions
    func performPlayerAction(_ action: PlayerAction) {
        guard let state = battleState, state.isPlayerTurn, state.battleResult == nil else { return }

        // Check if stunned
        if state.isPlayerStunned {
            state.addLogEntry("You are stunned and cannot act!", type: .system)
            state.isPlayerTurn = false
            // Process status effects
            state.processPlayerStatusEffects()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.performEnemyTurn()
            }
            return
        }

        isAnimating = true
        state.playerIsDefending = false

        switch action {
        case .attack:
            performPlayerAttack()
        case .defend:
            performPlayerDefend()
        case .special:
            performPlayerSpecial()
        case .useItem(let itemId):
            let result = useItemInBattle(itemId)
            if result == nil {
                // Item use failed, don't end turn
                isAnimating = false
                return
            }
        }

        // Process player status effects at end of turn
        state.processPlayerStatusEffects()

        if let state = battleState, state.enemyHP <= 0 {
            handleVictory()
            return
        }

        if let state = battleState, state.playerHP <= 0 {
            handleDefeat()
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.performEnemyTurn()
        }
    }

    private func performPlayerAttack() {
        guard let state = battleState else { return }

        let baseDamage = state.playerAttack + state.playerAttackModifier
        let defense = state.enemyIsEvading ? state.enemyDefense * 2 : state.enemyDefense
        let damage = calculateDamage(attack: baseDamage, defense: defense)

        if state.enemyIsEvading && Double.random(in: 0...1) < 0.5 {
            state.addLogEntry("Your attack missed the evading enemy!", type: .playerAction)
        } else {
            state.enemyHP = max(0, state.enemyHP - damage)
            state.lastDamageDealt = damage
            state.showEnemyDamage = true
            state.addLogEntry("You attack for \(damage) damage!", type: .playerAction)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                state.showEnemyDamage = false
            }
        }

        state.enemyIsEvading = false
        state.isPlayerTurn = false
    }

    private func performPlayerDefend() {
        guard let state = battleState else { return }

        state.playerIsDefending = true
        state.addLogEntry("You take a defensive stance!", type: .playerAction)
        state.isPlayerTurn = false
    }

    private func performPlayerSpecial() {
        guard let state = battleState, state.playerSpecialReady else { return }

        let baseDamage = (state.playerAttack + state.playerAttackModifier) * 2
        let defense = state.enemyIsEvading ? state.enemyDefense * 2 : state.enemyDefense
        let damage = calculateDamage(attack: baseDamage, defense: defense)

        state.enemyHP = max(0, state.enemyHP - damage)
        state.lastDamageDealt = damage
        state.showEnemyDamage = true
        state.playerSpecialReady = false
        state.addLogEntry("You unleash a powerful special attack for \(damage) damage!", type: .playerAction)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            state.showEnemyDamage = false
        }

        state.enemyIsEvading = false
        state.isPlayerTurn = false
    }

    // MARK: - Enemy Turn
    private func performEnemyTurn() {
        guard let state = battleState, state.battleResult == nil else {
            isAnimating = false
            return
        }

        // Process enemy status effects first
        state.processEnemyStatusEffects()

        if state.enemyHP <= 0 {
            handleVictory()
            return
        }

        // Check if enemy is stunned
        if state.isEnemyStunned {
            state.addLogEntry("\(state.enemyName) is stunned and cannot act!", type: .system)
            finishEnemyTurn()
            return
        }

        let ability = chooseEnemyAbility()

        if let ability = ability {
            if ability.damage == 0 {
                state.enemyIsEvading = true
                state.addLogEntry("\(state.enemyName) uses \(ability.name)! \(ability.description)", type: .enemyAction)
            } else {
                let effectiveDefense = state.playerIsDefending ? state.playerDefense * 2 : state.playerDefense
                let attackPower = ability.damage + state.enemyAttackModifier
                let damage = calculateDamage(attack: attackPower, defense: effectiveDefense)

                state.playerHP = max(0, state.playerHP - damage)
                state.lastDamageReceived = damage
                state.showPlayerDamage = true
                state.addLogEntry("\(state.enemyName) uses \(ability.name) for \(damage) damage!", type: .enemyAction)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    state.showPlayerDamage = false
                }

                // Apply status effect from ability
                if let statusEffect = ability.statusEffect {
                    var effect = statusEffect
                    effect.id = UUID()
                    state.playerStatusEffects.append(effect)
                    state.addLogEntry("\(statusEffect.type.icon) You are afflicted with \(statusEffect.type.rawValue)!", type: .enemyAction)
                }
            }
        } else {
            let effectiveDefense = state.playerIsDefending ? state.playerDefense * 2 : state.playerDefense
            let attackPower = state.enemyAttack + state.enemyAttackModifier
            let damage = calculateDamage(attack: attackPower, defense: effectiveDefense)

            state.playerHP = max(0, state.playerHP - damage)
            state.lastDamageReceived = damage
            state.showPlayerDamage = true
            state.addLogEntry("\(state.enemyName) attacks for \(damage) damage!", type: .enemyAction)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                state.showPlayerDamage = false
            }
        }

        if state.playerHP <= 0 {
            handleDefeat()
            return
        }

        finishEnemyTurn()
    }

    private func finishEnemyTurn() {
        guard let state = battleState else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            state.isPlayerTurn = true
            state.playerIsDefending = false
            self?.isAnimating = false

            if !state.playerSpecialReady && state.battleLog.count % 6 == 0 {
                state.playerSpecialReady = true
                state.addLogEntry("Special attack is ready!", type: .system)
            }
        }
    }

    private func chooseEnemyAbility() -> EnemyAbility? {
        guard let state = battleState else { return nil }

        for ability in state.enemyAbilities {
            if Double.random(in: 0...1) < ability.chance {
                return ability
            }
        }
        return nil
    }

    // MARK: - Damage Calculation
    func calculateDamage(attack: Int, defense: Int) -> Int {
        let baseDamage = max(1, attack - defense / 2)
        let variance = Int.random(in: -2...2)
        return max(1, baseDamage + variance)
    }

    // MARK: - Battle Resolution
    private func handleVictory() {
        guard let state = battleState else { return }

        state.battleResult = .victory
        state.addLogEntry("Victory! You defeated \(state.enemyName)!", type: .victory)
        isAnimating = false
    }

    private func handleDefeat() {
        guard let state = battleState else { return }

        state.battleResult = .defeat
        state.addLogEntry("Defeated! You have fallen in battle...", type: .defeat)
        isAnimating = false
    }

    // MARK: - Reset
    func endBattle() {
        battleState = nil
        currentEncounter = nil
        isAnimating = false
    }

    // MARK: - Use Item in Battle
    func useItemInBattle(_ itemId: UUID) -> ConsumableResult? {
        guard let state = battleState else { return nil }
        guard let entry = character.inventory.first(where: { $0.item.id == itemId }) else { return nil }
        let item = entry.item
        guard item.type == .consumable else { return nil }

        var result = ConsumableResult()

        // Heal
        if let healAmount = item.healAmount {
            let actualHeal = min(healAmount, state.playerMaxHP - state.playerHP)
            state.playerHP += actualHeal
            result.healedAmount = actualHeal
            if actualHeal > 0 {
                state.addLogEntry("Used \(item.name): restored \(actualHeal) HP!", type: .heal)
            }
        }

        // Cure status effects
        if let cureString = item.statusEffectCure {
            let cureNames = cureString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            result.curedEffects = cureNames
            let curedCount = state.playerStatusEffects.filter { effect in
                cureNames.contains(effect.type.rawValue.lowercased())
            }.count
            state.playerStatusEffects.removeAll { effect in
                cureNames.contains(effect.type.rawValue.lowercased())
            }
            if curedCount > 0 {
                state.addLogEntry("Used \(item.name): cured \(cureNames.joined(separator: ", "))!", type: .heal)
            }
        }

        // Temporary stat boost → add as Strengthen effect
        if let boosts = item.tempStatBoost, let duration = item.tempBoostDuration {
            result.tempBoosts = boosts
            result.boostDuration = duration
            let totalBoost = boosts.values.reduce(0, +)
            let effect = StatusEffect(type: .strengthen, duration: duration, value: totalBoost, sourceDescription: item.name)
            state.playerStatusEffects.append(effect)
            state.addLogEntry("Used \(item.name): boosted stats for \(duration) turns!", type: .playerAction)
        }

        // Battle damage to enemy
        if let damage = item.battleDamage {
            // Partially ignores defense (only 25% of defense applies)
            let effectiveDefense = state.enemyDefense / 4
            let actualDamage = max(1, damage - effectiveDefense)
            state.enemyHP = max(0, state.enemyHP - actualDamage)
            state.lastDamageDealt = actualDamage
            state.showEnemyDamage = true
            result.battleDamage = actualDamage
            state.addLogEntry("Used \(item.name): dealt \(actualDamage) damage!", type: .playerAction)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                state.showEnemyDamage = false
            }
        }

        // Remove item from character inventory
        _ = character.removeItem(itemId)
        onItemUsed?(itemId)

        // Uses the player's turn
        state.isPlayerTurn = false

        return result
    }

    // MARK: - Get Rewards
    func collectRewards() -> BattleRewards? {
        guard let state = battleState, state.battleResult == .victory else { return nil }
        return state.rewards
    }
}
