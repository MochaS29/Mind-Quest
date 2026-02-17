//
//  MindLabsQuestUITests.swift
//  MindLabsQuestUITests
//
//  Created by Mocha Shmigelsky on 2025-07-29.
//

import XCTest

final class MindLabsQuestUITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Clean up
    }

    @MainActor
    func testCharacterCreationFlow() throws {
        // Check if we're on character creation screen
        let characterCreationTitle = app.staticTexts["Create Your Character"]
        XCTAssertTrue(characterCreationTitle.waitForExistence(timeout: 5))
        
        // Enter character name
        let nameField = app.textFields["Character name"]
        nameField.tap()
        nameField.typeText("Test Hero")
        
        // Select avatar
        let avatarButton = app.buttons.containing(NSPredicate(format: "label CONTAINS '🦸'")).firstMatch
        if avatarButton.exists {
            avatarButton.tap()
        }
        
        // Select class
        let warriorButton = app.buttons["Warrior"]
        if warriorButton.exists {
            warriorButton.tap()
        }
        
        // Continue to next step
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.exists)
        continueButton.tap()
        
        // Select background
        let freshmanButton = app.buttons["Freshman"]
        if freshmanButton.waitForExistence(timeout: 3) {
            freshmanButton.tap()
        }
        
        // Select primary goal
        let academicButton = app.buttons["Academic Excellence"]
        if academicButton.waitForExistence(timeout: 3) {
            academicButton.tap()
        }
        
        // Complete character creation
        let beginButton = app.buttons["Begin Adventure"]
        if beginButton.waitForExistence(timeout: 3) {
            beginButton.tap()
        }
        
        // Verify we're now on the main dashboard
        let questTab = app.tabBars.buttons["Quest"]
        XCTAssertTrue(questTab.waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testQuestCreation() throws {
        skipCharacterCreationIfNeeded()
        
        // Navigate to Adventures tab
        app.tabBars.buttons["Adventures"].tap()
        
        // Tap add quest button
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // Fill in quest details
        let titleField = app.textFields.firstMatch
        titleField.tap()
        titleField.typeText("Test Quest")
        
        // Select difficulty
        let mediumButton = app.buttons["Medium"]
        if mediumButton.exists {
            mediumButton.tap()
        }
        
        // Create quest
        let createButton = app.buttons["Create Quest"]
        if createButton.exists {
            createButton.tap()
        }
        
        // Verify quest appears in list
        let questCell = app.staticTexts["Test Quest"]
        XCTAssertTrue(questCell.waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testTimerFunctionality() throws {
        skipCharacterCreationIfNeeded()
        
        // Navigate to Focus tab
        app.tabBars.buttons["Focus"].tap()
        
        // Select a preset time
        let preset25Button = app.buttons["25"]
        XCTAssertTrue(preset25Button.waitForExistence(timeout: 5))
        preset25Button.tap()
        
        // Start timer
        let startButton = app.buttons["Start Timer"]
        XCTAssertTrue(startButton.exists)
        startButton.tap()
        
        // Verify timer is running
        let playPauseButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'pause'")).firstMatch
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
        
        // Pause timer
        playPauseButton.tap()
        
        // Verify timer is paused
        let playButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'play'")).firstMatch
        XCTAssertTrue(playButton.exists)
    }
    
    @MainActor
    func testNavigationBetweenTabs() throws {
        skipCharacterCreationIfNeeded()
        
        let tabBar = app.tabBars.firstMatch
        
        // Test each tab
        let tabs = ["Quest", "Adventures", "Routines", "Analytics", "Focus", "Character"]
        
        for tabName in tabs {
            let tabButton = tabBar.buttons[tabName]
            XCTAssertTrue(tabButton.exists, "Tab \(tabName) should exist")
            tabButton.tap()
            
            // Give the view time to load
            Thread.sleep(forTimeInterval: 0.5)
            
            // Verify we're on the correct tab by checking for unique elements
            switch tabName {
            case "Quest":
                XCTAssertTrue(app.staticTexts["Daily Quests"].exists || app.staticTexts["Active Quests"].exists)
            case "Adventures":
                XCTAssertTrue(app.navigationBars["Quests"].exists)
            case "Routines":
                XCTAssertTrue(app.navigationBars["Routines"].exists)
            case "Analytics":
                XCTAssertTrue(app.navigationBars["Analytics"].exists)
            case "Focus":
                XCTAssertTrue(app.staticTexts["Focus Timer"].exists || app.staticTexts["Pomodoro Timer"].exists)
            case "Character":
                XCTAssertTrue(app.navigationBars["Character"].exists)
            default:
                break
            }
        }
    }
    
    @MainActor
    func testAchievementView() throws {
        skipCharacterCreationIfNeeded()
        
        // Navigate to Character tab
        app.tabBars.buttons["Character"].tap()
        
        // Look for achievements section
        let achievementsButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Achievements'")).firstMatch
        if achievementsButton.waitForExistence(timeout: 5) {
            achievementsButton.tap()
            
            // Verify achievements view opened
            let achievementsTitle = app.navigationBars["Achievements"]
            XCTAssertTrue(achievementsTitle.waitForExistence(timeout: 5))
            
            // Check for achievement categories
            let questsCategory = app.buttons["Quests"]
            XCTAssertTrue(questsCategory.exists)
        }
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    // MARK: - Helper Methods
    
    private func skipCharacterCreationIfNeeded() {
        // If character creation screen appears, quickly create a character
        let characterCreationTitle = app.staticTexts["Create Your Character"]
        if characterCreationTitle.waitForExistence(timeout: 2) {
            // Quick character creation
            let nameField = app.textFields["Character name"]
            nameField.tap()
            nameField.typeText("UI Test Hero")
            
            // Select first available options
            app.buttons.containing(NSPredicate(format: "label CONTAINS '🦸'")).firstMatch.tap()
            app.buttons["Continue"].tap()
            
            // Wait and select background/goal
            Thread.sleep(forTimeInterval: 0.5)
            app.buttons.element(boundBy: 0).tap()
            app.buttons.element(boundBy: 0).tap()
            
            // Begin adventure
            let beginButton = app.buttons["Begin Adventure"]
            if beginButton.waitForExistence(timeout: 3) {
                beginButton.tap()
            }
        }
    }
}