import Foundation
import SwiftUI
import Combine

// MARK: - Battle State
class BattleState: ObservableObject {
    @Published var playerHP: Int
    @Published var playerMaxHP: Int
    @Published var playerAttack: Int
    @Published var playerDefense: Int
    @Published var playerIsDefending: Bool = false
    @Published var playerDamageReduction: Double = 0 // from shield abilities
    @Published var playerReflectPercent: Double = 0 // from reflect abilities

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

    // Combat tracking
    @Published var totalDamageDealt: Int = 0

    // Ability cooldowns: [abilityId: turnsRemaining]
    @Published var abilityCooldowns: [String: Int] = [:]

    // Last used ability (for UI effects)
    @Published var lastAbilityUsed: CombatAbility?

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

    func isAbilityReady(_ ability: CombatAbility) -> Bool {
        (abilityCooldowns[ability.id] ?? 0) <= 0
    }

    func cooldownRemaining(for ability: CombatAbility) -> Int {
        abilityCooldowns[ability.id] ?? 0
    }

    func decrementCooldowns() {
        for key in abilityCooldowns.keys {
            if abilityCooldowns[key]! > 0 {
                abilityCooldowns[key]! -= 1
            }
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
    case ability(String) // ability ID
    case useItem(UUID)
}

// MARK: - Combat Context (built from skill bonuses at battle start)
struct CombatContext {
    var critChance: Double = 0          // 0.0–1.0
    var dodgeChance: Double = 0         // 0.0–1.0
    var damageMultiplier: Double = 1.0  // 1.0 = no bonus
    var defenseMultiplier: Double = 1.0
    var lifestealPercent: Double = 0
    var counterattackChance: Double = 0
    var specialCooldownReduction: Int = 0
    var statusResistances: [StatusEffectType: Double] = [:]

    init() {}

    init(from character: Character) {
        let bonuses = character.skillBonuses
        critChance = Double(bonuses.critChance) / 100.0
        dodgeChance = Double(bonuses.dodgeChance) / 100.0
        damageMultiplier = 1.0 + Double(bonuses.damageMultiplier) / 100.0
        defenseMultiplier = 1.0 + Double(bonuses.defenseMultiplier) / 100.0
        lifestealPercent = Double(bonuses.lifestealPercent) / 100.0
        counterattackChance = Double(bonuses.counterattackPercent) / 100.0
        specialCooldownReduction = bonuses.specialCooldownReduction
        for (type, percent) in bonuses.statusResistances {
            statusResistances[type] = Double(percent) / 100.0
        }
    }
}

// MARK: - Battle Manager
class BattleManager: ObservableObject {
    @Published var battleState: BattleState?
    @Published var currentEncounter: BattleEncounter?
    @Published var isAnimating: Bool = false

    private var character: Character
    private var combatContext = CombatContext()
    private var stateCancellable: AnyCancellable?
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
        combatContext = CombatContext(from: character)
        let state = BattleState(player: character, encounter: encounter)
        // Forward BattleState changes so views update
        stateCancellable = state.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        battleState = state
    }

    // MARK: - Player Actions
    func performPlayerAction(_ action: PlayerAction) {
        guard let state = battleState, state.isPlayerTurn, state.battleResult == nil else { return }

        // Check if stunned
        if state.isPlayerStunned {
            state.addLogEntry("You are stunned and cannot act!", type: .system)
            state.isPlayerTurn = false
            state.processPlayerStatusEffects()
            state.decrementCooldowns()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.performEnemyTurn()
            }
            return
        }

        isAnimating = true

        switch action {
        case .ability(let abilityId):
            guard let ability = findAbility(abilityId) else {
                isAnimating = false
                return
            }
            guard state.isAbilityReady(ability) else {
                isAnimating = false
                return
            }
            performAbility(ability)
        case .useItem(let itemId):
            let result = useItemInBattle(itemId)
            if result == nil {
                isAnimating = false
                return
            }
        }

        // Process player status effects at end of turn
        state.processPlayerStatusEffects()

        // Decrement all ability cooldowns
        state.decrementCooldowns()

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

    private func findAbility(_ abilityId: String) -> CombatAbility? {
        guard let charClass = character.characterClass else { return nil }
        return CombatAbilityDatabase.abilities(for: charClass).first { $0.id == abilityId }
    }

    // MARK: - Perform Ability
    private func performAbility(_ ability: CombatAbility) {
        guard let state = battleState else { return }

        state.lastAbilityUsed = ability

        // Reset defense state from previous turn
        state.playerIsDefending = false
        state.playerDamageReduction = 0
        state.playerReflectPercent = 0

        if ability.isDefensive {
            performDefensiveAbility(ability)
        } else {
            performOffensiveAbility(ability)
        }

        // Set cooldown (if any)
        if ability.cooldown > 0 {
            state.abilityCooldowns[ability.id] = ability.cooldown
        }

        state.isPlayerTurn = false
    }

    private func performOffensiveAbility(_ ability: CombatAbility) {
        guard let state = battleState else { return }

        let baseDamage = Int(Double(state.playerAttack + state.playerAttackModifier) * ability.damageMultiplier)
        let defense = state.enemyIsEvading ? state.enemyDefense * 2 : state.enemyDefense
        var damage = calculateDamage(attack: baseDamage, defense: defense)

        // Apply damage multiplier from skills
        damage = Int(Double(damage) * combatContext.damageMultiplier)

        // Crit roll
        let isCrit = Double.random(in: 0...1) < combatContext.critChance
        if isCrit { damage = Int(Double(damage) * 1.5) }

        if state.enemyIsEvading && Double.random(in: 0...1) < 0.5 {
            state.addLogEntry("\(ability.name) missed the evading enemy!", type: .playerAction)
        } else {
            state.enemyHP = max(0, state.enemyHP - damage)
            state.lastDamageDealt = damage
            state.totalDamageDealt += damage
            state.showEnemyDamage = true

            if isCrit {
                state.addLogEntry("CRITICAL \(ability.name) for \(damage) damage!", type: .playerAction)
            } else {
                state.addLogEntry("\(ability.name) deals \(damage) damage!", type: .playerAction)
            }

            // Ability-specific lifesteal
            var totalLifesteal = combatContext.lifestealPercent
            if case .lifesteal(let percent) = ability.effect {
                totalLifesteal += percent
            }
            if totalLifesteal > 0 {
                let healAmount = max(1, Int(Double(damage) * totalLifesteal))
                let actualHeal = min(healAmount, state.playerMaxHP - state.playerHP)
                if actualHeal > 0 {
                    state.playerHP += actualHeal
                    state.addLogEntry("Drained \(actualHeal) HP!", type: .heal)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                state.showEnemyDamage = false
            }
        }

        // Apply ability effect to enemy (excluding lifesteal, handled above)
        if let effect = ability.effect {
            applyAbilityEffect(effect, toEnemy: true, abilityName: ability.name)
        }

        state.enemyIsEvading = false
    }

    private func performDefensiveAbility(_ ability: CombatAbility) {
        guard let state = battleState else { return }

        state.playerIsDefending = true

        if let effect = ability.effect {
            switch effect {
            case .shield(let reduction):
                state.playerDamageReduction = reduction
                state.addLogEntry("\(ability.name)! Damage reduced by \(Int(reduction * 100))%.", type: .playerAction)
            case .reflect(let percent):
                state.playerDamageReduction = 0.5
                state.playerReflectPercent = percent
                state.addLogEntry("\(ability.name)! Reflecting \(Int(percent * 100))% damage.", type: .playerAction)
            case .heal(let percent):
                let healAmount = Int(Double(state.playerMaxHP) * percent)
                let actualHeal = min(healAmount, state.playerMaxHP - state.playerHP)
                state.playerHP += actualHeal
                state.addLogEntry("\(ability.name) restores \(actualHeal) HP!", type: .heal)
            case .regenerate(let value, let turns):
                let regen = StatusEffect(type: .regenerate, duration: turns, value: value, sourceDescription: ability.name)
                state.playerStatusEffects.append(regen)
                state.addLogEntry("\(ability.name)! Regenerating \(value) HP per turn.", type: .heal)
            case .strengthen(let value, let turns):
                let buff = StatusEffect(type: .strengthen, duration: turns, value: value, sourceDescription: ability.name)
                state.playerStatusEffects.append(buff)
                state.addLogEntry("\(ability.name)! Attack boosted for \(turns) turns.", type: .playerAction)
            default:
                state.addLogEntry("You use \(ability.name)!", type: .playerAction)
            }
        } else {
            state.playerDamageReduction = 0.5
            state.addLogEntry("You use \(ability.name)!", type: .playerAction)
        }
    }

    private func applyAbilityEffect(_ effect: CombatAbilityEffect, toEnemy: Bool, abilityName: String) {
        guard let state = battleState else { return }

        switch effect {
        case .stun(let turns):
            if toEnemy {
                let stun = StatusEffect(type: .stun, duration: turns, value: 0, sourceDescription: abilityName)
                state.enemyStatusEffects.append(stun)
                state.addLogEntry("\(state.enemyName) is stunned!", type: .playerAction)
            }
        case .burn(let damage, let turns):
            if toEnemy {
                let burn = StatusEffect(type: .burn, duration: turns, value: damage, sourceDescription: abilityName)
                state.enemyStatusEffects.append(burn)
                state.addLogEntry("\(state.enemyName) is burning!", type: .playerAction)
            }
        case .poison(let damage, let turns):
            if toEnemy {
                let poison = StatusEffect(type: .poison, duration: turns, value: damage, sourceDescription: abilityName)
                state.enemyStatusEffects.append(poison)
                state.addLogEntry("\(state.enemyName) is poisoned!", type: .playerAction)
            }
        case .weaken(let value, let turns):
            if toEnemy {
                let debuff = StatusEffect(type: .weaken, duration: turns, value: value, sourceDescription: abilityName)
                state.enemyStatusEffects.append(debuff)
                state.addLogEntry("\(state.enemyName) is weakened!", type: .playerAction)
            }
        case .bleed(let damage, let turns):
            if toEnemy {
                let bleed = StatusEffect(type: .bleed, duration: turns, value: damage, sourceDescription: abilityName)
                state.enemyStatusEffects.append(bleed)
                state.addLogEntry("\(state.enemyName) is bleeding!", type: .playerAction)
            }
        case .strengthen(let value, let turns):
            // Self-buff on offensive ability
            let buff = StatusEffect(type: .strengthen, duration: turns, value: value, sourceDescription: abilityName)
            state.playerStatusEffects.append(buff)
            state.addLogEntry("You feel empowered!", type: .playerAction)
        case .lifesteal:
            break // handled in performOffensiveAbility
        case .heal, .shield, .reflect, .regenerate:
            break // handled in performDefensiveAbility
        }
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

        // Dodge roll from skills
        if Double.random(in: 0...1) < combatContext.dodgeChance {
            state.addLogEntry("You dodge the attack!", type: .playerAction)
            finishEnemyTurn()
            return
        }

        if let ability = ability {
            if ability.damage == 0 {
                state.enemyIsEvading = true
                state.addLogEntry("\(state.enemyName) uses \(ability.name)! \(ability.description)", type: .enemyAction)
            } else {
                var effectiveDefense = state.playerDefense
                // Apply defensive ability reduction
                if state.playerIsDefending {
                    let reduction = state.playerDamageReduction > 0 ? state.playerDamageReduction : 0.5
                    effectiveDefense = Int(Double(effectiveDefense) * (1.0 + reduction))
                }
                effectiveDefense = Int(Double(effectiveDefense) * combatContext.defenseMultiplier)
                let attackPower = ability.damage + state.enemyAttackModifier
                var damage = calculateDamage(attack: attackPower, defense: effectiveDefense)

                // Apply damage reduction from shield
                if state.playerIsDefending && state.playerDamageReduction > 0 {
                    damage = Int(Double(damage) * (1.0 - state.playerDamageReduction))
                    damage = max(1, damage)
                }

                state.playerHP = max(0, state.playerHP - damage)
                state.lastDamageReceived = damage
                state.showPlayerDamage = true
                state.addLogEntry("\(state.enemyName) uses \(ability.name) for \(damage) damage!", type: .enemyAction)

                // Reflect damage
                if state.playerReflectPercent > 0 {
                    let reflectDamage = max(1, Int(Double(damage) * state.playerReflectPercent))
                    state.enemyHP = max(0, state.enemyHP - reflectDamage)
                    state.addLogEntry("Reflected \(reflectDamage) damage!", type: .playerAction)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    state.showPlayerDamage = false
                }

                // Apply status effect from ability (check resistance)
                if let statusEffect = ability.statusEffect {
                    let resistance = combatContext.statusResistances[statusEffect.type] ?? 0
                    if Double.random(in: 0...1) >= resistance {
                        var effect = statusEffect
                        effect.id = UUID()
                        state.playerStatusEffects.append(effect)
                        state.addLogEntry("\(statusEffect.type.icon) You are afflicted with \(statusEffect.type.rawValue)!", type: .enemyAction)
                    } else {
                        state.addLogEntry("You resist \(statusEffect.type.rawValue)!", type: .playerAction)
                    }
                }
            }
        } else {
            var effectiveDefense = state.playerDefense
            if state.playerIsDefending {
                let reduction = state.playerDamageReduction > 0 ? state.playerDamageReduction : 0.5
                effectiveDefense = Int(Double(effectiveDefense) * (1.0 + reduction))
            }
            effectiveDefense = Int(Double(effectiveDefense) * combatContext.defenseMultiplier)
            let attackPower = state.enemyAttack + state.enemyAttackModifier
            var damage = calculateDamage(attack: attackPower, defense: effectiveDefense)

            if state.playerIsDefending && state.playerDamageReduction > 0 {
                damage = Int(Double(damage) * (1.0 - state.playerDamageReduction))
                damage = max(1, damage)
            }

            state.playerHP = max(0, state.playerHP - damage)
            state.lastDamageReceived = damage
            state.showPlayerDamage = true
            state.addLogEntry("\(state.enemyName) attacks for \(damage) damage!", type: .enemyAction)

            // Reflect damage
            if state.playerReflectPercent > 0 {
                let reflectDamage = max(1, Int(Double(damage) * state.playerReflectPercent))
                state.enemyHP = max(0, state.enemyHP - reflectDamage)
                state.addLogEntry("Reflected \(reflectDamage) damage!", type: .playerAction)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                state.showPlayerDamage = false
            }
        }

        if state.playerHP <= 0 {
            handleDefeat()
            return
        }

        if state.enemyHP <= 0 {
            handleVictory()
            return
        }

        finishEnemyTurn()
    }

    private func finishEnemyTurn() {
        guard let state = battleState else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            state.isPlayerTurn = true
            state.playerIsDefending = false
            state.playerDamageReduction = 0
            state.playerReflectPercent = 0
            self?.isAnimating = false
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

        // Temporary stat boost -> add as Strengthen effect
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
            state.totalDamageDealt += actualDamage
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
