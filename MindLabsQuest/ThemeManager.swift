import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("appTheme") var appTheme: SettingsView.AppTheme = .system {
        didSet {
            updateAppearance()
        }
    }
    
    @AppStorage("selectedAccentColor") var selectedAccentColorString: String = "purple" {
        didSet {
            if let color = SettingsView.AccentColor(rawValue: selectedAccentColorString) {
                selectedAccentColor = color
            }
        }
    }
    
    @Published var selectedAccentColor: SettingsView.AccentColor = .purple
    
    private init() {
        if let color = SettingsView.AccentColor(rawValue: selectedAccentColorString) {
            selectedAccentColor = color
        }
        updateAppearance()
    }
    
    func updateAppearance() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        switch appTheme {
        case .system:
            window?.overrideUserInterfaceStyle = .unspecified
        case .light:
            window?.overrideUserInterfaceStyle = .light
        case .dark:
            window?.overrideUserInterfaceStyle = .dark
        }
    }
    
    var accentColor: Color {
        selectedAccentColor.color
    }
}

// MARK: - Theme Extensions
extension Color {
    static var themeAccent: Color {
        ThemeManager.shared.accentColor
    }
}