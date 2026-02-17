import XCTest
import SwiftUI
@testable import MindLabsQuest

class ThemeManagerTests: XCTestCase {
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        themeManager = ThemeManager.shared
        // Reset to default theme
        themeManager.resetToDefaults()
    }
    
    override func tearDown() {
        themeManager.resetToDefaults()
        super.tearDown()
    }
    
    // MARK: - Theme Selection Tests
    
    func testDefaultTheme() {
        // Then
        XCTAssertEqual(themeManager.currentTheme, .default)
        XCTAssertEqual(themeManager.fontStyle, .rounded)
        XCTAssertEqual(themeManager.sizePreference, .regular)
    }
    
    func testSelectTheme() {
        // When
        themeManager.selectTheme(.dark)
        
        // Then
        XCTAssertEqual(themeManager.currentTheme, .dark)
        
        // Test other themes
        themeManager.selectTheme(.midnight)
        XCTAssertEqual(themeManager.currentTheme, .midnight)
        
        themeManager.selectTheme(.nature)
        XCTAssertEqual(themeManager.currentTheme, .nature)
        
        themeManager.selectTheme(.ocean)
        XCTAssertEqual(themeManager.currentTheme, .ocean)
        
        themeManager.selectTheme(.sunset)
        XCTAssertEqual(themeManager.currentTheme, .sunset)
    }
    
    func testCustomTheme() {
        // Given
        let customColors = ColorSet(
            primary: Color.red,
            secondary: Color.orange,
            accent: Color.yellow,
            background: Color.black,
            card: Color.gray,
            text: Color.white,
            textSecondary: Color(white: 0.7),
            border: Color(white: 0.3),
            success: Color.green,
            warning: Color.orange,
            error: Color.red
        )
        
        // When
        themeManager.setCustomTheme(customColors)
        
        // Then
        XCTAssertEqual(themeManager.currentTheme, .custom)
        XCTAssertEqual(themeManager.customColors?.primary, Color.red)
        XCTAssertEqual(themeManager.customColors?.background, Color.black)
    }
    
    // MARK: - Font Style Tests
    
    func testFontStyleChange() {
        // When
        themeManager.setFontStyle(.system)
        
        // Then
        XCTAssertEqual(themeManager.fontStyle, .system)
        
        // Test other font styles
        themeManager.setFontStyle(.serif)
        XCTAssertEqual(themeManager.fontStyle, .serif)
        
        themeManager.setFontStyle(.monospaced)
        XCTAssertEqual(themeManager.fontStyle, .monospaced)
    }
    
    // MARK: - Size Preference Tests
    
    func testSizePreferenceChange() {
        // When
        themeManager.setSizePreference(.large)
        
        // Then
        XCTAssertEqual(themeManager.sizePreference, .large)
        
        // Test other sizes
        themeManager.setSizePreference(.small)
        XCTAssertEqual(themeManager.sizePreference, .small)
        
        themeManager.setSizePreference(.extraLarge)
        XCTAssertEqual(themeManager.sizePreference, .extraLarge)
    }
    
    // MARK: - Color Scheme Tests
    
    func testColorSchemeColors() {
        // Test default theme colors
        themeManager.selectTheme(.default)
        XCTAssertNotNil(themeManager.primaryColor)
        XCTAssertNotNil(themeManager.backgroundColor)
        XCTAssertNotNil(themeManager.cardColor)
        XCTAssertNotNil(themeManager.textColor)
        
        // Test dark theme colors
        themeManager.selectTheme(.dark)
        XCTAssertNotNil(themeManager.primaryColor)
        XCTAssertNotNil(themeManager.backgroundColor)
    }
    
    // MARK: - Typography Tests
    
    func testTypographyScaling() {
        // Test regular size
        themeManager.setSizePreference(.regular)
        let regularTitle = themeManager.titleFont
        
        // Test large size
        themeManager.setSizePreference(.large)
        let largeTitle = themeManager.titleFont
        
        // Typography should scale with size preference
        // Note: Direct font size comparison isn't possible in tests
        // but we can verify the fonts are created
        XCTAssertNotNil(regularTitle)
        XCTAssertNotNil(largeTitle)
    }
    
    func testFontStyleApplication() {
        // Test system font
        themeManager.setFontStyle(.system)
        XCTAssertNotNil(themeManager.bodyFont)
        
        // Test rounded font
        themeManager.setFontStyle(.rounded)
        XCTAssertNotNil(themeManager.bodyFont)
        
        // Test serif font
        themeManager.setFontStyle(.serif)
        XCTAssertNotNil(themeManager.bodyFont)
        
        // Test monospaced font
        themeManager.setFontStyle(.monospaced)
        XCTAssertNotNil(themeManager.bodyFont)
    }
    
    // MARK: - Persistence Tests
    
    func testThemePersistence() {
        // Given
        themeManager.selectTheme(.ocean)
        themeManager.setFontStyle(.serif)
        themeManager.setSizePreference(.large)
        
        // When - Create a new instance to test loading
        let newThemeManager = ThemeManager()
        
        // Then
        XCTAssertEqual(newThemeManager.currentTheme, .ocean)
        XCTAssertEqual(newThemeManager.fontStyle, .serif)
        XCTAssertEqual(newThemeManager.sizePreference, .large)
    }
    
    func testCustomThemePersistence() {
        // Given
        let customColors = ColorSet(
            primary: Color.purple,
            secondary: Color.pink,
            accent: Color.indigo,
            background: Color.black,
            card: Color.gray,
            text: Color.white,
            textSecondary: Color(white: 0.8),
            border: Color(white: 0.4),
            success: Color.green,
            warning: Color.yellow,
            error: Color.red
        )
        themeManager.setCustomTheme(customColors)
        
        // When - Create a new instance to test loading
        let newThemeManager = ThemeManager()
        
        // Then
        XCTAssertEqual(newThemeManager.currentTheme, .custom)
        XCTAssertNotNil(newThemeManager.customColors)
        // Note: Color comparison in tests is limited
    }
    
    // MARK: - Reset Tests
    
    func testResetToDefaults() {
        // Given - Change all settings
        themeManager.selectTheme(.midnight)
        themeManager.setFontStyle(.monospaced)
        themeManager.setSizePreference(.extraLarge)
        
        // When
        themeManager.resetToDefaults()
        
        // Then
        XCTAssertEqual(themeManager.currentTheme, .default)
        XCTAssertEqual(themeManager.fontStyle, .rounded)
        XCTAssertEqual(themeManager.sizePreference, .regular)
        XCTAssertNil(themeManager.customColors)
    }
    
    // MARK: - Gradient Tests
    
    func testGradientGeneration() {
        // Test that gradients are generated for each theme
        let themes: [Theme] = [.default, .dark, .midnight, .nature, .ocean, .sunset]
        
        for theme in themes {
            themeManager.selectTheme(theme)
            XCTAssertNotNil(themeManager.primaryGradient)
            XCTAssertNotNil(themeManager.backgroundGradient)
        }
    }
    
    // MARK: - Animation Tests
    
    func testAnimationSettings() {
        // Test default animation settings
        XCTAssertTrue(themeManager.animationsEnabled)
        XCTAssertEqual(themeManager.animationSpeed, 1.0)
        
        // Disable animations
        themeManager.setAnimationsEnabled(false)
        XCTAssertFalse(themeManager.animationsEnabled)
        
        // Change animation speed
        themeManager.setAnimationSpeed(0.5)
        XCTAssertEqual(themeManager.animationSpeed, 0.5)
        
        themeManager.setAnimationSpeed(2.0)
        XCTAssertEqual(themeManager.animationSpeed, 2.0)
    }
}

// MARK: - Theme Model Tests

extension ThemeManagerTests {
    func testThemeProperties() {
        // Test theme display names
        XCTAssertEqual(Theme.default.displayName, "Default")
        XCTAssertEqual(Theme.dark.displayName, "Dark")
        XCTAssertEqual(Theme.midnight.displayName, "Midnight")
        XCTAssertEqual(Theme.nature.displayName, "Nature")
        XCTAssertEqual(Theme.ocean.displayName, "Ocean")
        XCTAssertEqual(Theme.sunset.displayName, "Sunset")
        XCTAssertEqual(Theme.custom.displayName, "Custom")
    }
    
    func testFontStyleProperties() {
        // Test font style display names
        XCTAssertEqual(FontStyle.system.displayName, "System")
        XCTAssertEqual(FontStyle.rounded.displayName, "Rounded")
        XCTAssertEqual(FontStyle.serif.displayName, "Serif")
        XCTAssertEqual(FontStyle.monospaced.displayName, "Monospaced")
    }
    
    func testSizePreferenceProperties() {
        // Test size preference display names and scales
        XCTAssertEqual(SizePreference.small.displayName, "Small")
        XCTAssertEqual(SizePreference.small.scale, 0.85)
        
        XCTAssertEqual(SizePreference.regular.displayName, "Regular")
        XCTAssertEqual(SizePreference.regular.scale, 1.0)
        
        XCTAssertEqual(SizePreference.large.displayName, "Large")
        XCTAssertEqual(SizePreference.large.scale, 1.15)
        
        XCTAssertEqual(SizePreference.extraLarge.displayName, "Extra Large")
        XCTAssertEqual(SizePreference.extraLarge.scale, 1.3)
    }
}