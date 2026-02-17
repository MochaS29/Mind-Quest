import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameManager: GameManager
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("autoStartTimer") private var autoStartTimer = false
    @AppStorage("defaultTimerDuration") private var defaultTimerDuration = 25
    @AppStorage("showStreakInWidget") private var showStreakInWidget = true
    @AppStorage("enableDailyReminder") private var enableDailyReminder = true
    @AppStorage("dailyReminderTime") private var dailyReminderTimeString = "09:00"
    
    @State private var showingResetAlert = false
    @State private var showingExportData = false
    
    enum AppTheme: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        
        var icon: String {
            switch self {
            case .system: return "circle.lefthalf.fill"
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            }
        }
    }
    
    enum AccentColor: String, CaseIterable {
        case purple = "Purple"
        case blue = "Blue"
        case green = "Green"
        case orange = "Orange"
        case pink = "Pink"
        case red = "Red"
        
        var color: Color {
            switch self {
            case .purple: return .mindLabsPurple
            case .blue: return .blue
            case .green: return .green
            case .orange: return .orange
            case .pink: return .pink
            case .red: return .red
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Customization Link
                    NavigationLink(destination: CustomizationView()) {
                        MindLabsCard {
                            HStack {
                                Label("Advanced Customization", systemImage: "paintbrush.pointed.fill")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(themeManager.accentColor)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                    
                    // Appearance Section
                    appearanceSection
                    
                    // Sound & Haptics Section
                    soundHapticsSection
                    
                    // Timer Preferences
                    timerPreferencesSection
                    
                    // Notification Preferences
                    notificationPreferencesSection
                    
                    // Widget Settings
                    widgetSettingsSection
                    
                    // Data Management
                    dataManagementSection
                    
                    // About Section
                    aboutSection
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .sheet(isPresented: $showingExportData) {
                DataExportView()
                    .environmentObject(gameManager)
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all your progress, quests, and character data. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Sections
    
    var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Appearance", systemImage: "paintbrush.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 15) {
                    // Theme Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Theme")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        HStack(spacing: 15) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                ThemeButton(
                                    theme: theme,
                                    isSelected: themeManager.appTheme == theme,
                                    action: { themeManager.appTheme = theme }
                                )
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Accent Color
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Accent Color")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 15) {
                            ForEach(AccentColor.allCases, id: \.self) { color in
                                AccentColorButton(
                                    accentColor: color,
                                    isSelected: themeManager.selectedAccentColor == color,
                                    action: { 
                                        themeManager.selectedAccentColor = color
                                        themeManager.selectedAccentColorString = color.rawValue
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    var soundHapticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Sound & Haptics", systemImage: "speaker.wave.2.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 15) {
                    Toggle(isOn: $soundEnabled) {
                        HStack {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.mindLabsPurple)
                            Text("Sound Effects")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                        }
                    }
                    .tint(.mindLabsPurple)
                    
                    Toggle(isOn: $hapticEnabled) {
                        HStack {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.mindLabsPurple)
                            Text("Haptic Feedback")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                        }
                    }
                    .tint(.mindLabsPurple)
                }
            }
        }
    }
    
    var timerPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Timer Preferences", systemImage: "timer")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 15) {
                    Toggle(isOn: $autoStartTimer) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Auto-start Timer")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                            Text("Automatically start timer when selecting a quest")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                    .tint(.mindLabsPurple)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Default Timer Duration")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsText)
                        
                        HStack {
                            Text("\(defaultTimerDuration) minutes")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Slider(value: Binding(
                                get: { Double(defaultTimerDuration) },
                                set: { defaultTimerDuration = Int($0) }
                            ), in: 5...60, step: 5)
                            .tint(.mindLabsPurple)
                        }
                    }
                }
            }
        }
    }
    
    var notificationPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Notifications", systemImage: "bell.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 15) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notification Settings")
                                    .font(MindLabsTypography.body())
                                    .foregroundColor(.mindLabsText)
                                Text("Configure reminders and alerts")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                    
                    Divider()
                    
                    Toggle(isOn: $enableDailyReminder) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Check-in Reminder")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                            Text("Get reminded to check your quests")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                    .tint(.mindLabsPurple)
                    
                    if enableDailyReminder {
                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: { dailyReminderTime },
                                set: { 
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm"
                                    dailyReminderTimeString = formatter.string(from: $0)
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsText)
                        .tint(.mindLabsPurple)
                    }
                }
            }
        }
    }
    
    var widgetSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Widget", systemImage: "square.stack.3d.up.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                Toggle(isOn: $showStreakInWidget) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show Streak in Widget")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsText)
                        Text("Display your current streak on the home screen")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                .tint(.mindLabsPurple)
            }
        }
    }
    
    var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Data Management", systemImage: "externaldrive.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(spacing: 15) {
                    Button(action: { showingExportData = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.mindLabsPurple)
                            Text("Export Data")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                    
                    Divider()
                    
                    Button(action: { showingResetAlert = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.mindLabsError)
                            Text("Reset All Data")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsError)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("About", systemImage: "info.circle.fill")
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Version")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsText)
                        Spacer()
                        Text("1.0.0")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Developer")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsText)
                        Spacer()
                        Text("Mind Labs")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Divider()
                    
                    Button(action: openPrivacyPolicy) {
                        HStack {
                            Text("Privacy Policy")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsPurple)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.mindLabsPurple)
                        }
                    }
                    
                    Divider()
                    
                    Button(action: openTermsOfService) {
                        HStack {
                            Text("Terms of Service")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsPurple)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.mindLabsPurple)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    var dailyReminderTime: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: dailyReminderTimeString) ?? Date()
    }
    
    // MARK: - Actions
    
    private func resetAllData() {
        // Clear all UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Reset GameManager
        gameManager.resetAllData()
        
        // Reset character to default
        gameManager.character = Character(name: "Adventurer")
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://mindlabs.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://mindlabs.com/terms") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Views

struct ThemeButton: View {
    let theme: SettingsView.AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: theme.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .mindLabsPurple)
                
                Text(theme.rawValue)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(isSelected ? .white : .mindLabsText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.mindLabsPurple : Color.mindLabsPurple.opacity(0.1))
            )
        }
    }
}

struct AccentColorButton: View {
    let accentColor: SettingsView.AccentColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(accentColor.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .opacity(isSelected ? 1 : 0)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.caption)
                        .opacity(isSelected ? 1 : 0)
                )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(GameManager())
    }
}