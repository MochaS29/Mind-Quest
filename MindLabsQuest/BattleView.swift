import SwiftUI

struct BattleView: View {
    let encounter: BattleEncounter
    let onComplete: (Bool) -> Void
    @ObservedObject var gameManager: GameManager

    @State private var playerShake = false
    @State private var enemyShake = false
    @State private var showPreBattleText = true
    @State private var showVictory = false
    @State private var showDefeat = false
    @State private var showItemPicker = false

    init(encounter: BattleEncounter, onComplete: @escaping (Bool) -> Void, gameManager: GameManager) {
        self.encounter = encounter
        self.onComplete = onComplete
        self.gameManager = gameManager
    }

    var body: some View {
        ZStack {
            // Background
            backgroundView

            if showPreBattleText {
                preBattleView
            } else if showVictory {
                victoryView
            } else if showDefeat {
                defeatView
            } else {
                battleContentView
            }
        }
        .onAppear {
            setupBattle()
        }
    }

    // MARK: - Setup
    private func setupBattle() {
        gameManager.getBattleManager().startBattle(encounter: encounter)

        // Show pre-battle text for a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showPreBattleText = false
            }
        }
    }

    // MARK: - Background
    @ViewBuilder
    private var backgroundView: some View {
        if let bgImage = encounter.backgroundImage {
            Image(bgImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.4))
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.05, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Pre-Battle Text
    private var preBattleView: some View {
        VStack(spacing: 20) {
            Spacer()

            if let text = encounter.preBattleText {
                Text(text)
                    .font(.body.italic())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Text("Battle Start!")
                .font(.title.bold())
                .foregroundColor(.red)
                .shadow(color: .red.opacity(0.5), radius: 10)

            Spacer()
        }
        .transition(.opacity)
    }

    // MARK: - Battle Content
    private var battleContentView: some View {
        VStack(spacing: 20) {
            // Enemy section
            enemySection

            Spacer()

            // VS indicator
            Text("VS")
                .font(.title.bold())
                .foregroundColor(.white.opacity(0.5))

            Spacer()

            // Player section
            playerSection

            // Battle log
            battleLogView

            // Action buttons
            actionButtons
        }
        .padding()
    }

    // MARK: - Enemy Section
    private var enemySection: some View {
        VStack(spacing: 12) {
            // Enemy name and level
            HStack {
                Text(encounter.enemyName)
                    .font(.headline)
                    .foregroundColor(.white)

                if encounter.isBoss {
                    Text("BOSS")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                }

                Spacer()

                Text("Lv.\(encounter.enemyLevel)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Enemy HP bar
            if let state = gameManager.battleManager?.battleState {
                HPBar(
                    current: state.enemyHP,
                    max: state.enemyMaxHP,
                    color: .red,
                    showDamage: state.showEnemyDamage,
                    damageAmount: state.lastDamageDealt
                )

                if !state.enemyStatusEffects.isEmpty {
                    StatusEffectRow(effects: state.enemyStatusEffects)
                }
            }

            // Enemy avatar
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 100, height: 100)

                if let state = gameManager.battleManager?.battleState, state.enemyIsEvading {
                    Text("Evading")
                        .font(.caption)
                        .foregroundColor(.cyan)
                        .padding(.top, 110)
                }

                Image(encounter.enemyAvatar)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.red, lineWidth: 2))
                    .offset(x: enemyShake ? -5 : 0)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.5))
        )
    }

    // MARK: - Player Section
    private var playerSection: some View {
        VStack(spacing: 12) {
            // Player avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 80, height: 80)

                if let state = gameManager.battleManager?.battleState, state.playerIsDefending {
                    Image(systemName: "shield.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .offset(x: 40, y: -20)
                }

                Text(gameManager.character.avatar)
                    .font(.system(size: 40))
                    .offset(x: playerShake ? 5 : 0)
            }

            // Player HP bar
            if let state = gameManager.battleManager?.battleState {
                HPBar(
                    current: state.playerHP,
                    max: state.playerMaxHP,
                    color: .green,
                    showDamage: state.showPlayerDamage,
                    damageAmount: state.lastDamageReceived
                )

                if !state.playerStatusEffects.isEmpty {
                    StatusEffectRow(effects: state.playerStatusEffects)
                }
            }

            // Player name
            Text(gameManager.character.name)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.5))
        )
    }

    // MARK: - Battle Log
    private var battleLogView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let state = gameManager.battleManager?.battleState {
                ForEach(state.battleLog.suffix(3)) { entry in
                    Text(entry.message)
                        .font(.caption)
                        .foregroundColor(entry.type.color)
                        .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.6))
        )
        .frame(height: 80)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Attack button
            ActionButton(
                title: "Attack",
                icon: "burst.fill",
                color: .red,
                isEnabled: gameManager.battleManager?.battleState?.isPlayerTurn ?? false
            ) {
                performAction(.attack)
            }

            // Defend button
            ActionButton(
                title: "Defend",
                icon: "shield.fill",
                color: .blue,
                isEnabled: gameManager.battleManager?.battleState?.isPlayerTurn ?? false
            ) {
                performAction(.defend)
            }

            // Special button
            ActionButton(
                title: "Special",
                icon: "sparkles",
                color: .purple,
                isEnabled: (gameManager.battleManager?.battleState?.isPlayerTurn ?? false) &&
                          (gameManager.battleManager?.battleState?.playerSpecialReady ?? false)
            ) {
                performAction(.special)
            }

            // Items button
            ActionButton(
                title: "Items",
                icon: "bag.fill",
                color: .orange,
                isEnabled: gameManager.battleManager?.battleState?.isPlayerTurn ?? false
            ) {
                showItemPicker = true
            }
        }
        .padding(.bottom, 20)
        .sheet(isPresented: $showItemPicker) {
            BattleItemPickerView(
                inventory: gameManager.character.inventory
            ) { itemId in
                performAction(.useItem(itemId))
            }
        }
    }

    // MARK: - Perform Action
    private func performAction(_ action: PlayerAction) {
        gameManager.battleManager?.performPlayerAction(action)

        // Trigger enemy shake on attack
        if action == .attack || action == .special {
            withAnimation(.default.repeatCount(3, autoreverses: true).speed(4)) {
                enemyShake = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                enemyShake = false
            }
        }

        // Check for battle end after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            checkBattleResult()
        }
    }

    private func checkBattleResult() {
        guard let state = gameManager.battleManager?.battleState else { return }

        if state.battleResult == .victory {
            withAnimation {
                showVictory = true
            }
        } else if state.battleResult == .defeat {
            withAnimation {
                showDefeat = true
            }
        }
    }

    // MARK: - Victory View
    private var victoryView: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)

            Text("Victory!")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            if let text = encounter.victoryText {
                Text(text)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Rewards
            VStack(spacing: 12) {
                Text("Rewards")
                    .font(.headline)
                    .foregroundColor(.gray)

                HStack(spacing: 30) {
                    VStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("+\(encounter.rewards.xp) XP")
                            .foregroundColor(.white)
                    }

                    VStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.orange)
                        Text("+\(encounter.rewards.gold) Gold")
                            .foregroundColor(.white)
                    }
                }

                // Loot drops
                if let lootResult = gameManager.lastLootResult, !lootResult.itemsReceived.isEmpty {
                    Divider().background(Color.white.opacity(0.3))

                    Text("Loot")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    ForEach(Array(lootResult.itemsReceived.enumerated()), id: \.offset) { _, itemPair in
                        HStack {
                            Text(itemPair.0.icon)
                            Text(itemPair.0.name)
                                .foregroundColor(.white)
                                .font(.subheadline)
                            if itemPair.1 > 1 {
                                Text("x\(itemPair.1)")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            Spacer()
                            Text(itemPair.0.rarity.rawValue)
                                .font(.caption)
                                .foregroundColor(itemPair.0.rarity.color)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.5))
            )

            Spacer()

            Button("Continue") {
                onComplete(true)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 50)
            .padding(.vertical, 16)
            .background(Capsule().fill(Color.green))

            Spacer()
                .frame(height: 50)
        }
        .transition(.opacity)
    }

    // MARK: - Defeat View
    private var defeatView: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)

            Text("Defeated")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("The shadows proved too strong this time...")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            Button("Return") {
                onComplete(false)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 50)
            .padding(.vertical, 16)
            .background(Capsule().fill(Color.red))

            Spacer()
                .frame(height: 50)
        }
        .transition(.opacity)
    }
}

// MARK: - HP Bar
struct HPBar: View {
    let current: Int
    let max: Int
    let color: Color
    let showDamage: Bool
    let damageAmount: Int

    var body: some View {
        VStack(spacing: 4) {
            // HP text
            HStack {
                Text("HP")
                    .font(.caption.bold())
                    .foregroundColor(.white)

                Spacer()

                Text("\(current)/\(max)")
                    .font(.caption)
                    .foregroundColor(.white)

                // Damage indicator
                if showDamage && damageAmount > 0 {
                    Text("-\(damageAmount)")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }

            // Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))

                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(current) / CGFloat(max))
                        .animation(.easeInOut(duration: 0.3), value: current)
                }
            }
            .frame(height: 12)
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption.bold())
            }
            .foregroundColor(isEnabled ? .white : .gray)
            .frame(width: 72, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? color : Color.gray.opacity(0.3))
            )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Battle State Wrapper
/// Wrapper to make BattleState work with @StateObject
class BattleStateWrapper: ObservableObject {
    @Published var isReady = false
}

// MARK: - Preview
struct BattleView_Previews: PreviewProvider {
    static var sampleEncounter = BattleEncounter(
        id: UUID(),
        enemyName: "Shadow Scout",
        enemyAvatar: "shadow_scout",
        enemyDescription: "A creature of darkness",
        enemyLevel: 1,
        enemyHP: 50,
        enemyMaxHP: 50,
        enemyAttack: 12,
        enemyDefense: 5,
        abilities: [
            EnemyAbility(name: "Shadow Strike", damage: 15, description: "Dark attack")
        ],
        rewards: BattleRewards(xp: 50, gold: 25),
        preBattleText: "The shadow creature emerges!",
        victoryText: "Victory!"
    )

    static var previews: some View {
        BattleView(encounter: sampleEncounter, onComplete: { _ in }, gameManager: GameManager())
    }
}
