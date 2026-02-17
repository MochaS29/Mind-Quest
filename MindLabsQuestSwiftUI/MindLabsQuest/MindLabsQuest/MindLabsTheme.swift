import SwiftUI

// MARK: - Mind Labs Color Palette
extension Color {
    // Primary Colors
    static let mindLabsPurple = Color(hex: "7C3AED")
    static let mindLabsDeepPurple = Color(hex: "6B46C1")
    static let mindLabsDarkPurple = Color(hex: "4C1D95")
    
    // Accent Colors
    static let mindLabsPink = Color(hex: "EC4899")
    static let mindLabsBlue = Color(hex: "3B82F6")
    static let mindLabsTeal = Color(hex: "14B8A6")
    
    // Semantic Colors
    static let mindLabsSuccess = Color(hex: "10B981")
    static let mindLabsWarning = Color(hex: "F59E0B")
    static let mindLabsError = Color(hex: "EF4444")
    static let mindLabsInfo = Color(hex: "3B82F6")
    
    // Neutral Colors
    static let mindLabsBackground = Color(hex: "F9FAFB")
    static let mindLabsCard = Color.white
    static let mindLabsText = Color(hex: "111827")
    static let mindLabsTextSecondary = Color(hex: "6B7280")
    static let mindLabsTextLight = Color(hex: "9CA3AF")
    static let mindLabsBorder = Color(hex: "E5E7EB")
    
    // Gradient Colors
    static let mindLabsGradientStart = Color(hex: "7C3AED")
    static let mindLabsGradientEnd = Color(hex: "EC4899")
    
    // Dark Mode Colors
    static let mindLabsDarkBackground = Color(hex: "1F2937")
    static let mindLabsDarkCard = Color(hex: "374151")
    
    // Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Mind Labs Typography
struct MindLabsTypography {
    // Font Names
    static let primaryFont = "SF Pro Display"
    static let secondaryFont = "SF Pro Text"
    static let monoFont = "SF Mono"
    
    // Title Styles
    static func largeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }
    
    static func title() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static func title2() -> Font {
        .system(size: 22, weight: .semibold, design: .rounded)
    }
    
    static func title3() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    // Body Styles
    static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .rounded)
    }
    
    static func body() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }
    
    static func callout() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }
    
    static func subheadline() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }
    
    static func footnote() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }
    
    static func caption() -> Font {
        .system(size: 12, weight: .regular, design: .default)
    }
    
    static func caption2() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }
}

// MARK: - Mind Labs Gradients
extension LinearGradient {
    static let mindLabsPrimary = LinearGradient(
        colors: [.mindLabsGradientStart, .mindLabsGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let mindLabsSecondary = LinearGradient(
        colors: [.mindLabsDeepPurple, .mindLabsDarkPurple],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let mindLabsAccent = LinearGradient(
        colors: [.mindLabsPink, .mindLabsPurple],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let mindLabsSuccess = LinearGradient(
        colors: [.mindLabsSuccess.opacity(0.8), .mindLabsSuccess],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Mind Labs Shadows
extension View {
    func mindLabsShadow() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    func mindLabsCardShadow() -> some View {
        self.shadow(color: .mindLabsPurple.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    func mindLabsButtonShadow() -> some View {
        self.shadow(color: .mindLabsPurple.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Mind Labs Button Styles
struct MindLabsPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MindLabsTypography.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(LinearGradient.mindLabsPrimary)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .mindLabsButtonShadow()
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct MindLabsSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MindLabsTypography.headline())
            .foregroundColor(.mindLabsPurple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.mindLabsPurple.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.mindLabsPurple, lineWidth: 2)
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Mind Labs Card Style
struct MindLabsCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 20
    
    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(Color.mindLabsCard)
            .cornerRadius(16)
            .mindLabsCardShadow()
    }
}

// MARK: - Mind Labs Input Field Style
struct MindLabsTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.mindLabsBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.mindLabsBorder, lineWidth: 1)
            )
            .font(MindLabsTypography.body())
    }
}

// MARK: - Mind Labs Navigation Bar Appearance
struct MindLabsNavigationBarModifier: ViewModifier {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.mindLabsBackground)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.mindLabsText),
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.mindLabsText),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    func body(content: Content) -> some View {
        content
    }
}

// MARK: - Mind Labs Tab Bar Appearance
struct MindLabsTabBarModifier: ViewModifier {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.mindLabsCard)
        
        UITabBar.appearance().standardAppearance = appearance
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func body(content: Content) -> some View {
        content
            .accentColor(.mindLabsPurple)
    }
}

// MARK: - Convenience Extensions
extension View {
    func mindLabsNavigationBar() -> some View {
        self.modifier(MindLabsNavigationBarModifier())
    }
    
    func mindLabsTabBar() -> some View {
        self.modifier(MindLabsTabBarModifier())
    }
    
    func mindLabsBackground() -> some View {
        self.background(Color.mindLabsBackground.ignoresSafeArea())
    }
}