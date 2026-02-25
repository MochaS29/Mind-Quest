import SwiftUI

// MARK: - Particle Model
struct BattleParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var scale: CGFloat
    let icon: String
}

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

    // Visual effects
    @State private var floatingDamage: Int?
    @State private var floatingDamageIsPlayer = false
    @State private var floatingDamageOffset: CGFloat = 0
    @State private var floatingDamageOpacity: Double = 1
    @State private var floatingDamageScale: CGFloat = 0

    @State private var screenFlashColor: Color?
    @State private var screenFlashOpacity: Double = 0

    @State private var attackEffectIcon: String?
    @State private var attackEffectScale: CGFloat = 0
    @State private var attackEffectRotation: Double = 0
    @State private var attackEffectOpacity: Double = 1
    @State private var activeVFXEffect: VFXEffect?

    @State private var showTurnBanner = false
    @State private var turnBannerText = ""
    @State private var turnBannerOffset: CGFloat = -100

    @State private var particles: [BattleParticle] = []

    @State private var lowHPPulse = false

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

            // Screen flash overlay
            if screenFlashColor != nil {
                screenFlashColor
                    .opacity(screenFlashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            // Floating damage number
            if let dmg = floatingDamage {
                Text("-\(dmg)")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(floatingDamageIsPlayer ? .red : .yellow)
                    .shadow(color: .black, radius: 2)
                    .scaleEffect(floatingDamageScale)
                    .opacity(floatingDamageOpacity)
                    .offset(y: floatingDamageOffset + (floatingDamageIsPlayer ? 100 : -60))
                    .allowsHitTesting(false)
            }

            // Attack effect icon + VFX
            if let effect = activeVFXEffect {
                VFXView(effect: effect) {
                    activeVFXEffect = nil
                }
                .allowsHitTesting(false)
            } else if let icon = attackEffectIcon {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .orange, radius: 10)
                    .scaleEffect(attackEffectScale)
                    .rotationEffect(.degrees(attackEffectRotation))
                    .opacity(attackEffectOpacity)
                    .allowsHitTesting(false)
            }

            // Turn banner
            if showTurnBanner {
                VStack {
                    Text(turnBannerText)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(turnBannerText == "YOUR TURN" ?
                                      Color.blue.opacity(0.8) : Color.red.opacity(0.8))
                        )
                        .offset(y: turnBannerOffset)
                    Spacer()
                }
                .padding(.top, 60)
                .allowsHitTesting(false)
            }

            // Particles
            ForEach(particles) { particle in
                Image(systemName: particle.icon)
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onAppear {
            setupBattle()
        }
    }

    // MARK: - Setup
    private func setupBattle() {
        gameManager.getBattleManager().startBattle(encounter: encounter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showPreBattleText = false
            }
            // Show initial turn banner
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showBanner("YOUR TURN")
            }
        }
    }

    // MARK: - Background
    @ViewBuilder
    private var backgroundView: some View {
        GeometryReader { geo in
            if let bgImage = encounter.backgroundImage,
               UIImage(named: bgImage) != nil {
                Image(bgImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
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
            }
        }
        .ignoresSafeArea()
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
        VStack(spacing: 12) {
            // Enemy section
            enemySection

            Spacer()

            // Player section
            playerSection

            // Battle log
            battleLogView

            // Move grid
            moveGrid
        }
        .padding()
    }

    // MARK: - Enemy Section
    private var enemySection: some View {
        VStack(spacing: 10) {
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

            // Enemy HP bar with color gradient
            if let state = gameManager.battleManager?.battleState {
                AnimatedHPBar(
                    current: state.enemyHP,
                    max: state.enemyMaxHP,
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

                AssetService.enemyImage(
                    templateId: encounter.enemyName.lowercased().replacingOccurrences(of: " ", with: "_"),
                    fallbackEmoji: encounter.enemyAvatar
                )
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.red, lineWidth: 2))
                .offset(x: enemyShake ? -15 : 0)
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
        VStack(spacing: 10) {
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

                Group {
                    if gameManager.character.avatar.count > 3 {
                        Image(gameManager.character.avatar)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text(gameManager.character.avatar)
                            .font(.system(size: 40))
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .offset(x: playerShake ? 15 : 0)
            }

            // Player HP bar
            if let state = gameManager.battleManager?.battleState {
                AnimatedHPBar(
                    current: state.playerHP,
                    max: state.playerMaxHP,
                    showDamage: state.showPlayerDamage,
                    damageAmount: state.lastDamageReceived,
                    showLowHPGlow: true
                )

                if !state.playerStatusEffects.isEmpty {
                    StatusEffectRow(effects: state.playerStatusEffects)
                }
            }

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
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
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
        .frame(height: 70)
    }

    // MARK: - Move Grid (replaces old action buttons)
    private var moveGrid: some View {
        VStack(spacing: 8) {
            let abilities = gameManager.character.availableCombatAbilities
            let columns = [GridItem(.flexible()), GridItem(.flexible())]

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(abilities) { ability in
                    let isReady = gameManager.battleManager?.battleState?.isAbilityReady(ability) ?? false
                    let isPlayerTurn = gameManager.battleManager?.battleState?.isPlayerTurn ?? false
                    let cooldown = gameManager.battleManager?.battleState?.cooldownRemaining(for: ability) ?? 0

                    MoveCard(
                        ability: ability,
                        isEnabled: isPlayerTurn && isReady,
                        cooldownRemaining: cooldown
                    ) {
                        performAction(.ability(ability.id))
                    }
                }

                // Items button
                let isPlayerTurn = gameManager.battleManager?.battleState?.isPlayerTurn ?? false
                Button {
                    HapticService.selection()
                    showItemPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bag.fill")
                            .font(.caption)
                        Text("Items")
                            .font(.caption.bold())
                    }
                    .foregroundColor(isPlayerTurn ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isPlayerTurn ? Color.orange.opacity(0.8) : Color.gray.opacity(0.3))
                    )
                }
                .disabled(!isPlayerTurn)
            }
        }
        .padding(.bottom, 16)
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
        // Haptic on move selection
        HapticService.selection()

        // Get ability info for effects
        var abilityIcon: String?
        if case .ability(let id) = action,
           let ability = gameManager.character.availableCombatAbilities.first(where: { $0.id == id }) {
            abilityIcon = ability.icon
        }

        gameManager.battleManager?.performPlayerAction(action)

        // Trigger visual effects for offensive actions
        if case .ability(let id) = action,
           let ability = gameManager.character.availableCombatAbilities.first(where: { $0.id == id }),
           !ability.isDefensive {

            // Enemy shake with spring
            withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                enemyShake = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring()) { enemyShake = false }
            }

            // Floating damage number
            if let state = gameManager.battleManager?.battleState, state.lastDamageDealt > 0 {
                showFloatingDamage(state.lastDamageDealt, isPlayer: false)
            }

            // Screen flash
            triggerScreenFlash(.red)

            // VFX effect based on ability, with fallback to icon animation
            if case .ability(let abilityId) = action,
               let abil = gameManager.character.availableCombatAbilities.first(where: { $0.id == abilityId }) {
                let vfxId = VFXService.effectIdForIcon(abil.icon)
                activeVFXEffect = VFXService.resolve(vfxId)
            } else if let icon = abilityIcon {
                showAttackEffect(icon)
            }

            // Particles
            spawnHitParticles()

            // Haptic: heavy impact on hit
            HapticService.impact(.heavy)
        }

        // Monitor enemy's turn for player damage effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            checkPlayerDamage()
        }

        // Check for battle end
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            checkBattleResult()
        }

        // Show turn banner after enemy acts
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            if gameManager.battleManager?.battleState?.isPlayerTurn == true &&
               gameManager.battleManager?.battleState?.battleResult == nil {
                showBanner("YOUR TURN")
            }
        }
    }

    private func checkPlayerDamage() {
        guard let state = gameManager.battleManager?.battleState else { return }
        if state.lastDamageReceived > 0 && state.showPlayerDamage {
            // Player took damage
            showFloatingDamage(state.lastDamageReceived, isPlayer: true)
            triggerScreenFlash(.orange)

            withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                playerShake = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring()) { playerShake = false }
            }

            HapticService.notification(.warning)
        }
    }

    private func checkBattleResult() {
        guard let state = gameManager.battleManager?.battleState else { return }

        if state.battleResult == .victory {
            HapticService.notification(.success)
            withAnimation {
                showVictory = true
            }
        } else if state.battleResult == .defeat {
            HapticService.notification(.error)
            withAnimation {
                showDefeat = true
            }
        }
    }

    // MARK: - Visual Effect Helpers

    private func showFloatingDamage(_ amount: Int, isPlayer: Bool) {
        floatingDamage = amount
        floatingDamageIsPlayer = isPlayer
        floatingDamageOffset = 0
        floatingDamageOpacity = 1
        floatingDamageScale = 0

        // Pop in
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            floatingDamageScale = 1.3
        }
        // Settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.1)) {
                floatingDamageScale = 1.0
            }
        }
        // Float up and fade
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.7)) {
                floatingDamageOffset = -60
                floatingDamageOpacity = 0
            }
        }
        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            floatingDamage = nil
        }
    }

    private func triggerScreenFlash(_ color: Color) {
        screenFlashColor = color
        screenFlashOpacity = 0.3
        withAnimation(.easeOut(duration: 0.3)) {
            screenFlashOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            screenFlashColor = nil
        }
    }

    private func showAttackEffect(_ icon: String) {
        attackEffectIcon = icon
        attackEffectScale = 0
        attackEffectRotation = -30
        attackEffectOpacity = 1

        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            attackEffectScale = 1.5
            attackEffectRotation = 15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                attackEffectScale = 0
                attackEffectOpacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            attackEffectIcon = nil
        }
    }

    private func showBanner(_ text: String) {
        turnBannerText = text
        showTurnBanner = true
        turnBannerOffset = -100

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            turnBannerOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                turnBannerOffset = -100
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            showTurnBanner = false
        }
    }

    private func spawnHitParticles() {
        let centerX: CGFloat = UIScreen.main.bounds.width / 2
        let centerY: CGFloat = 200
        let icons = ["star.fill", "sparkle", "circle.fill"]

        var newParticles: [BattleParticle] = []
        for _ in 0..<8 {
            newParticles.append(BattleParticle(
                x: centerX + CGFloat.random(in: -20...20),
                y: centerY + CGFloat.random(in: -20...20),
                opacity: 1.0,
                scale: CGFloat.random(in: 0.5...1.2),
                icon: icons.randomElement()!
            ))
        }
        particles = newParticles

        // Animate outward and fade
        withAnimation(.easeOut(duration: 0.6)) {
            for i in 0..<particles.count {
                particles[i].x += CGFloat.random(in: -60...60)
                particles[i].y += CGFloat.random(in: -60...60)
                particles[i].opacity = 0
                particles[i].scale = 0.1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            particles = []
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

// MARK: - Animated HP Bar (green -> yellow -> red)
struct AnimatedHPBar: View {
    let current: Int
    let max: Int
    let showDamage: Bool
    let damageAmount: Int
    var showLowHPGlow: Bool = false

    @State private var lowHPPulse = false

    private var hpPercent: Double {
        guard max > 0 else { return 0 }
        return Double(current) / Double(max)
    }

    private var barColor: Color {
        if hpPercent > 0.5 { return .green }
        if hpPercent > 0.25 { return .yellow }
        return .red
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("HP")
                    .font(.caption.bold())
                    .foregroundColor(.white)

                Spacer()

                Text("\(current)/\(max)")
                    .font(.caption)
                    .foregroundColor(.white)

                if showDamage && damageAmount > 0 {
                    Text("-\(damageAmount)")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [barColor, barColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max > 0 ? geometry.size.width * CGFloat(current) / CGFloat(self.max) : 0)
                        .animation(.easeInOut(duration: 0.3), value: current)
                }
                .overlay(
                    // Low HP pulsing glow
                    Group {
                        if showLowHPGlow && hpPercent <= 0.25 && hpPercent > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.red, lineWidth: 2)
                                .opacity(lowHPPulse ? 0.8 : 0.2)
                                .animation(
                                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                    value: lowHPPulse
                                )
                                .onAppear { lowHPPulse = true }
                        }
                    }
                )
            }
            .frame(height: 12)
        }
    }
}

// MARK: - Move Card
struct MoveCard: View {
    let ability: CombatAbility
    let isEnabled: Bool
    let cooldownRemaining: Int
    let action: () -> Void

    private var isOnCooldown: Bool { cooldownRemaining > 0 }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // Icon
                Image(systemName: ability.icon)
                    .font(.system(size: 14))
                    .foregroundColor(isEnabled ? .white : .gray)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ability.name)
                        .font(.caption.bold())
                        .foregroundColor(isEnabled ? .white : .gray)
                        .lineLimit(1)

                    Text(ability.effectTag)
                        .font(.system(size: 9))
                        .foregroundColor(isEnabled ? ability.effectColor : .gray)
                }

                Spacer()

                // Cooldown indicator
                if isOnCooldown {
                    Text("\(cooldownRemaining)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.gray.opacity(0.6)))
                } else if ability.cooldown > 0 {
                    // Ready indicator for abilities with cooldowns
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .disabled(!isEnabled || isOnCooldown)
    }

    private var backgroundColor: Color {
        if isOnCooldown { return Color.gray.opacity(0.2) }
        if !isEnabled { return Color.gray.opacity(0.3) }
        if ability.isDefensive { return Color.blue.opacity(0.6) }
        return Color.red.opacity(0.6)
    }

    private var borderColor: Color {
        if isOnCooldown { return Color.gray.opacity(0.3) }
        if !isEnabled { return Color.clear }
        if ability.isDefensive { return Color.blue.opacity(0.4) }
        return Color.red.opacity(0.4)
    }
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
