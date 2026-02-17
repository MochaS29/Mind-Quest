import XCTest
@testable import MindLabsQuest

class FocusManagerTests: XCTestCase {
    var focusManager: FocusManager!
    
    override func setUp() {
        super.setUp()
        focusManager = FocusManager.shared
        // Reset to clean state
        focusManager.reset()
    }
    
    override func tearDown() {
        focusManager.endSession()
        focusManager.reset()
        super.tearDown()
    }
    
    // MARK: - Session Management Tests
    
    func testStartSession() {
        // Given
        let quest = Quest(
            title: "Test Quest",
            description: "Test Description",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        
        // When
        focusManager.startSession(for: quest, duration: 25)
        
        // Then
        XCTAssertTrue(focusManager.isActive)
        XCTAssertEqual(focusManager.currentQuest?.id, quest.id)
        XCTAssertEqual(focusManager.sessionDuration, 25)
        XCTAssertEqual(focusManager.timeRemaining, 25 * 60) // 25 minutes in seconds
        XCTAssertEqual(focusManager.sessionType, .focus)
        XCTAssertNotNil(focusManager.startTime)
    }
    
    func testEndSession() {
        // Given
        let quest = Quest(
            title: "Test Quest",
            description: "Test Description",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        focusManager.startSession(for: quest, duration: 25)
        
        // When
        let summary = focusManager.endSession()
        
        // Then
        XCTAssertFalse(focusManager.isActive)
        XCTAssertNil(focusManager.currentQuest)
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.questTitle, "Test Quest")
        XCTAssertTrue(summary?.actualDuration ?? 0 >= 0)
    }
    
    func testPauseResume() {
        // Given
        let quest = Quest(
            title: "Test Quest",
            description: "Test Description",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        focusManager.startSession(for: quest, duration: 25)
        
        // When - Pause
        focusManager.pauseSession()
        
        // Then
        XCTAssertTrue(focusManager.isPaused)
        XCTAssertTrue(focusManager.isActive) // Still active, just paused
        
        // When - Resume
        focusManager.resumeSession()
        
        // Then
        XCTAssertFalse(focusManager.isPaused)
        XCTAssertTrue(focusManager.isActive)
    }
    
    // MARK: - Timer Tests
    
    func testTimerCountdown() {
        // Given
        let quest = Quest(
            title: "Test Quest",
            description: "Test Description",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        focusManager.startSession(for: quest, duration: 1) // 1 minute for testing
        
        let expectation = self.expectation(description: "Timer counts down")
        
        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Wait 2 seconds
            // Then
            XCTAssertLessThan(self.focusManager.timeRemaining, 60) // Should be less than 60 seconds
            XCTAssertGreaterThan(self.focusManager.timeRemaining, 55) // But more than 55 seconds
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testTimerPausedDoesNotCountDown() {
        // Given
        let quest = Quest(
            title: "Test Quest",
            description: "Test Description",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        focusManager.startSession(for: quest, duration: 25)
        focusManager.pauseSession()
        let initialTime = focusManager.timeRemaining
        
        let expectation = self.expectation(description: "Timer doesn't count when paused")
        
        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Wait 2 seconds
            // Then
            XCTAssertEqual(self.focusManager.timeRemaining, initialTime) // Time should not have changed
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    // MARK: - Break Session Tests
    
    func testStartBreakSession() {
        // When
        focusManager.startBreakSession(duration: 5)
        
        // Then
        XCTAssertTrue(focusManager.isActive)
        XCTAssertNil(focusManager.currentQuest)
        XCTAssertEqual(focusManager.sessionType, .break)
        XCTAssertEqual(focusManager.sessionDuration, 5)
        XCTAssertEqual(focusManager.timeRemaining, 5 * 60)
    }
    
    // MARK: - Pomodoro Tests
    
    func testPomodoroSettings() {
        // Test default settings
        XCTAssertEqual(focusManager.pomodoroSettings.focusDuration, 25)
        XCTAssertEqual(focusManager.pomodoroSettings.shortBreakDuration, 5)
        XCTAssertEqual(focusManager.pomodoroSettings.longBreakDuration, 15)
        XCTAssertEqual(focusManager.pomodoroSettings.sessionsUntilLongBreak, 4)
        
        // Update settings
        var newSettings = focusManager.pomodoroSettings
        newSettings.focusDuration = 30
        newSettings.shortBreakDuration = 10
        focusManager.updatePomodoroSettings(newSettings)
        
        // Verify update
        XCTAssertEqual(focusManager.pomodoroSettings.focusDuration, 30)
        XCTAssertEqual(focusManager.pomodoroSettings.shortBreakDuration, 10)
    }
    
    func testPomodoroSessionTracking() {
        // Given
        let quest = Quest(
            title: "Test Quest",
            description: "Test Description",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        
        // Complete multiple sessions
        for i in 1...4 {
            focusManager.startSession(for: quest, duration: 25)
            _ = focusManager.endSession()
            XCTAssertEqual(focusManager.completedPomodoroSessions, i)
        }
        
        // After 4 sessions, should suggest long break
        XCTAssertTrue(focusManager.shouldTakeLongBreak)
        
        // Start break
        focusManager.startBreakSession(duration: 15)
        _ = focusManager.endSession()
        
        // Counter should reset
        XCTAssertEqual(focusManager.completedPomodoroSessions, 0)
    }
    
    // MARK: - Focus Mode Tests
    
    func testFocusModeActivation() {
        // Given
        XCTAssertFalse(focusManager.isFocusModeActive)
        
        // When
        focusManager.activateFocusMode()
        
        // Then
        XCTAssertTrue(focusManager.isFocusModeActive)
        
        // When
        focusManager.deactivateFocusMode()
        
        // Then
        XCTAssertFalse(focusManager.isFocusModeActive)
    }
    
    func testFocusModeSettings() {
        // Test default settings
        XCTAssertTrue(focusManager.focusModeSettings.blockNotifications)
        XCTAssertTrue(focusManager.focusModeSettings.hideStatusBar)
        XCTAssertFalse(focusManager.focusModeSettings.playWhiteNoise)
        XCTAssertEqual(focusManager.focusModeSettings.whiteNoiseVolume, 0.5)
        
        // Update settings
        var newSettings = focusManager.focusModeSettings
        newSettings.playWhiteNoise = true
        newSettings.whiteNoiseVolume = 0.8
        focusManager.updateFocusModeSettings(newSettings)
        
        // Verify update
        XCTAssertTrue(focusManager.focusModeSettings.playWhiteNoise)
        XCTAssertEqual(focusManager.focusModeSettings.whiteNoiseVolume, 0.8)
    }
    
    // MARK: - Statistics Tests
    
    func testSessionStatistics() {
        // Given
        let quest = Quest(
            title: "Test Quest",
            description: "Test Description",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        
        // Complete a session
        focusManager.startSession(for: quest, duration: 25)
        
        // Simulate some time passing
        let expectation = self.expectation(description: "Session completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let summary = self.focusManager.endSession()
            
            // Then
            XCTAssertNotNil(summary)
            XCTAssertGreaterThan(summary?.actualDuration ?? 0, 0)
            XCTAssertEqual(summary?.plannedDuration, 25)
            XCTAssertNotNil(summary?.startTime)
            XCTAssertNotNil(summary?.endTime)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTotalFocusTime() {
        // Given
        let initialTotal = focusManager.totalFocusTime
        
        let quest = Quest(
            title: "Test Quest",
            description: "Test Description",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        
        // Complete a session
        focusManager.startSession(for: quest, duration: 25)
        
        let expectation = self.expectation(description: "Focus time updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = self.focusManager.endSession()
            
            // Then
            XCTAssertGreaterThan(self.focusManager.totalFocusTime, initialTotal)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    // MARK: - Preset Tests
    
    func testFocusPresets() {
        // Test default presets
        let presets = focusManager.focusPresets
        XCTAssertTrue(presets.count > 0)
        
        // Verify common presets exist
        XCTAssertNotNil(presets.first(where: { $0.name == "Quick Focus" }))
        XCTAssertNotNil(presets.first(where: { $0.name == "Pomodoro" }))
        XCTAssertNotNil(presets.first(where: { $0.name == "Deep Work" }))
        
        // Test adding custom preset
        let customPreset = FocusPreset(
            name: "Custom",
            duration: 45,
            breakDuration: 10,
            icon: "⭐"
        )
        focusManager.addCustomPreset(customPreset)
        
        XCTAssertTrue(focusManager.focusPresets.contains(where: { $0.name == "Custom" }))
    }
    
    // MARK: - Persistence Tests
    
    func testSettingsPersistence() {
        // Given
        var pomodoroSettings = focusManager.pomodoroSettings
        pomodoroSettings.focusDuration = 30
        focusManager.updatePomodoroSettings(pomodoroSettings)
        
        var focusModeSettings = focusManager.focusModeSettings
        focusModeSettings.playWhiteNoise = true
        focusManager.updateFocusModeSettings(focusModeSettings)
        
        // When - Create new instance
        let newFocusManager = FocusManager()
        
        // Then
        XCTAssertEqual(newFocusManager.pomodoroSettings.focusDuration, 30)
        XCTAssertTrue(newFocusManager.focusModeSettings.playWhiteNoise)
    }
    
    // MARK: - Edge Cases
    
    func testStartSessionWhileActive() {
        // Given
        let quest1 = Quest(
            title: "Quest 1",
            description: "Test",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        
        let quest2 = Quest(
            title: "Quest 2",
            description: "Test",
            category: .personal,
            difficulty: .easy,
            estimatedMinutes: 15,
            xpReward: 50
        )
        
        focusManager.startSession(for: quest1, duration: 25)
        
        // When - Try to start another session
        focusManager.startSession(for: quest2, duration: 15)
        
        // Then - Should end first session and start new one
        XCTAssertEqual(focusManager.currentQuest?.id, quest2.id)
        XCTAssertEqual(focusManager.sessionDuration, 15)
    }
    
    func testEndSessionWhenNotActive() {
        // When
        let summary = focusManager.endSession()
        
        // Then
        XCTAssertNil(summary)
    }
}

// MARK: - Focus Models Tests

extension FocusManagerTests {
    func testFocusSessionSummary() {
        // Given
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(1500) // 25 minutes
        
        let summary = FocusSessionSummary(
            questId: UUID(),
            questTitle: "Test Quest",
            plannedDuration: 25,
            actualDuration: 25,
            startTime: startTime,
            endTime: endTime,
            wasCompleted: true,
            sessionType: .focus
        )
        
        // Then
        XCTAssertEqual(summary.questTitle, "Test Quest")
        XCTAssertEqual(summary.plannedDuration, 25)
        XCTAssertEqual(summary.actualDuration, 25)
        XCTAssertTrue(summary.wasCompleted)
        XCTAssertEqual(summary.sessionType, .focus)
    }
    
    func testFocusPreset() {
        // Given
        let preset = FocusPreset(
            name: "Test Preset",
            duration: 50,
            breakDuration: 10,
            icon: "🎯"
        )
        
        // Then
        XCTAssertEqual(preset.name, "Test Preset")
        XCTAssertEqual(preset.duration, 50)
        XCTAssertEqual(preset.breakDuration, 10)
        XCTAssertEqual(preset.icon, "🎯")
    }
    
    func testPomodoroSettings() {
        // Given
        let settings = PomodoroSettings(
            focusDuration: 25,
            shortBreakDuration: 5,
            longBreakDuration: 15,
            sessionsUntilLongBreak: 4
        )
        
        // Then
        XCTAssertEqual(settings.focusDuration, 25)
        XCTAssertEqual(settings.shortBreakDuration, 5)
        XCTAssertEqual(settings.longBreakDuration, 15)
        XCTAssertEqual(settings.sessionsUntilLongBreak, 4)
    }
    
    func testFocusModeSettingsModel() {
        // Given
        let settings = FocusModeSettings(
            blockNotifications: true,
            hideStatusBar: false,
            playWhiteNoise: true,
            whiteNoiseVolume: 0.7
        )
        
        // Then
        XCTAssertTrue(settings.blockNotifications)
        XCTAssertFalse(settings.hideStatusBar)
        XCTAssertTrue(settings.playWhiteNoise)
        XCTAssertEqual(settings.whiteNoiseVolume, 0.7)
    }
}