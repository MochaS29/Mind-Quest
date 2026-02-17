import XCTest
@testable import MindLabsQuest

class DataExportManagerTests: XCTestCase {
    var exportManager: DataExportManager!
    var gameManager: GameManager!
    
    override func setUp() {
        super.setUp()
        gameManager = GameManager()
        exportManager = DataExportManager()
        
        // Set up test data
        setupTestData()
    }
    
    override func tearDown() {
        exportManager = nil
        gameManager = nil
        super.tearDown()
    }
    
    private func setupTestData() {
        // Add test quests
        let quest1 = Quest(
            title: "Test Quest 1",
            description: "Description 1",
            category: .work,
            difficulty: .easy,
            estimatedMinutes: 30,
            xpReward: 50,
            isCompleted: true,
            completedDate: Date().addingTimeInterval(-86400) // 1 day ago
        )
        
        let quest2 = Quest(
            title: "Test Quest 2",
            description: "Description 2",  
            category: .personal,
            difficulty: .medium,
            estimatedMinutes: 45,
            xpReward: 100,
            isCompleted: false
        )
        
        gameManager.quests = [quest1, quest2]
        
        // Add test character data
        gameManager.character.name = "Test Hero"
        gameManager.character.xp = 500
        gameManager.character.level = 5
        gameManager.character.streak = 7
    }
    
    // MARK: - CSV Export Tests
    
    func testGenerateQuestCSV() {
        // When
        let csvData = exportManager.generateQuestCSV(from: gameManager.quests)
        let csvString = String(data: csvData, encoding: .utf8)!
        
        // Then
        XCTAssertTrue(csvString.contains("Title,Category,Difficulty,Status,XP Reward,Estimated Time,Completed Date"))
        XCTAssertTrue(csvString.contains("Test Quest 1"))
        XCTAssertTrue(csvString.contains("Test Quest 2"))
        XCTAssertTrue(csvString.contains("Work"))
        XCTAssertTrue(csvString.contains("Personal"))
        XCTAssertTrue(csvString.contains("Easy"))
        XCTAssertTrue(csvString.contains("Medium"))
        XCTAssertTrue(csvString.contains("Completed"))
        XCTAssertTrue(csvString.contains("Pending"))
        XCTAssertTrue(csvString.contains("50"))
        XCTAssertTrue(csvString.contains("100"))
    }
    
    func testGenerateQuestCSVEmpty() {
        // Given
        let emptyQuests: [Quest] = []
        
        // When
        let csvData = exportManager.generateQuestCSV(from: emptyQuests)
        let csvString = String(data: csvData, encoding: .utf8)!
        
        // Then
        XCTAssertTrue(csvString.contains("Title,Category,Difficulty,Status,XP Reward,Estimated Time,Completed Date"))
        let lines = csvString.components(separatedBy: .newlines)
        XCTAssertEqual(lines.count, 2) // Header + empty line
    }
    
    func testGenerateAnalyticsCSV() {
        // Given
        let analytics = AnalyticsData(
            totalQuests: 100,
            completedQuests: 75,
            totalXP: 5000,
            totalFocusTime: 3600, // 60 hours
            averageQuestTime: 45,
            currentStreak: 7,
            longestStreak: 14,
            categoryBreakdown: [
                "Work": 40,
                "Personal": 35,
                "Health": 15,
                "Creative": 10
            ],
            completionRate: 0.75,
            weeklyProgress: [10, 12, 8, 15, 9, 11, 13]
        )
        
        // When
        let csvData = exportManager.generateAnalyticsCSV(from: analytics)
        let csvString = String(data: csvData, encoding: .utf8)!
        
        // Then
        XCTAssertTrue(csvString.contains("Metric,Value"))
        XCTAssertTrue(csvString.contains("Total Quests,100"))
        XCTAssertTrue(csvString.contains("Completed Quests,75"))
        XCTAssertTrue(csvString.contains("Total XP,5000"))
        XCTAssertTrue(csvString.contains("Total Focus Time,60.0 hours"))
        XCTAssertTrue(csvString.contains("Average Quest Time,45 minutes"))
        XCTAssertTrue(csvString.contains("Current Streak,7 days"))
        XCTAssertTrue(csvString.contains("Longest Streak,14 days"))
        XCTAssertTrue(csvString.contains("Completion Rate,75.0%"))
        XCTAssertTrue(csvString.contains("Work,40"))
        XCTAssertTrue(csvString.contains("Personal,35"))
    }
    
    // MARK: - JSON Export Tests
    
    func testGenerateFullExportJSON() {
        // Given
        let character = gameManager.character
        let quests = gameManager.quests
        let achievements = gameManager.achievementManager.achievements
        
        // When
        let jsonData = exportManager.generateFullExportJSON(
            character: character,
            quests: quests,
            achievements: achievements
        )
        
        // Then
        XCTAssertNotNil(jsonData)
        
        // Decode and verify
        let decoder = JSONDecoder()
        do {
            let exportData = try decoder.decode(ExportData.self, from: jsonData)
            
            XCTAssertEqual(exportData.character.name, "Test Hero")
            XCTAssertEqual(exportData.character.level, 5)
            XCTAssertEqual(exportData.character.xp, 500)
            XCTAssertEqual(exportData.quests.count, 2)
            XCTAssertTrue(exportData.achievements.count > 0)
            XCTAssertNotNil(exportData.exportDate)
        } catch {
            XCTFail("Failed to decode export data: \(error)")
        }
    }
    
    func testGenerateQuestJSON() {
        // When
        let jsonData = exportManager.generateQuestJSON(from: gameManager.quests)
        
        // Then
        XCTAssertNotNil(jsonData)
        
        // Decode and verify
        let decoder = JSONDecoder()
        do {
            let quests = try decoder.decode([Quest].self, from: jsonData)
            XCTAssertEqual(quests.count, 2)
            XCTAssertEqual(quests[0].title, "Test Quest 1")
            XCTAssertEqual(quests[1].title, "Test Quest 2")
        } catch {
            XCTFail("Failed to decode quests: \(error)")
        }
    }
    
    // MARK: - PDF Export Tests
    
    func testGenerateReportPDF() {
        // Given
        let character = gameManager.character
        let quests = gameManager.quests
        let analytics = AnalyticsData(
            totalQuests: 100,
            completedQuests: 75,
            totalXP: 5000,
            totalFocusTime: 3600,
            averageQuestTime: 45,
            currentStreak: 7,
            longestStreak: 14,
            categoryBreakdown: ["Work": 40, "Personal": 35],
            completionRate: 0.75,
            weeklyProgress: [10, 12, 8, 15, 9, 11, 13]
        )
        
        // When
        let pdfData = exportManager.generateReportPDF(
            character: character,
            quests: quests,
            analytics: analytics
        )
        
        // Then
        XCTAssertNotNil(pdfData)
        XCTAssertTrue(pdfData.count > 0)
        
        // Verify PDF header (PDF files start with %PDF)
        let pdfHeader = String(data: pdfData.prefix(4), encoding: .ascii)
        XCTAssertEqual(pdfHeader, "%PDF")
    }
    
    // MARK: - File Name Generation Tests
    
    func testGenerateFileName() {
        // Test different export types
        let csvFileName = exportManager.generateFileName(for: .csv, prefix: "quests")
        XCTAssertTrue(csvFileName.hasPrefix("quests_"))
        XCTAssertTrue(csvFileName.hasSuffix(".csv"))
        
        let jsonFileName = exportManager.generateFileName(for: .json, prefix: "data")
        XCTAssertTrue(jsonFileName.hasPrefix("data_"))
        XCTAssertTrue(jsonFileName.hasSuffix(".json"))
        
        let pdfFileName = exportManager.generateFileName(for: .pdf, prefix: "report")
        XCTAssertTrue(pdfFileName.hasPrefix("report_"))
        XCTAssertTrue(pdfFileName.hasSuffix(".pdf"))
    }
    
    func testDateFormatInFileName() {
        // Given
        let fileName = exportManager.generateFileName(for: .csv, prefix: "test")
        
        // Then
        // Check date format: test_YYYY-MM-DD.csv
        let components = fileName.components(separatedBy: "_")
        XCTAssertEqual(components.count, 2)
        
        let datePart = components[1].replacingOccurrences(of: ".csv", with: "")
        let dateComponents = datePart.components(separatedBy: "-")
        XCTAssertEqual(dateComponents.count, 3) // Year, month, day
    }
    
    // MARK: - Data Filtering Tests
    
    func testFilterQuestsByDateRange() {
        // Given
        let now = Date()
        let quest1 = Quest(
            title: "Recent Quest",
            description: "Test",
            category: .work,
            difficulty: .easy,
            estimatedMinutes: 30,
            xpReward: 50,
            isCompleted: true,
            completedDate: now.addingTimeInterval(-86400) // 1 day ago
        )
        
        let quest2 = Quest(
            title: "Old Quest", 
            description: "Test",
            category: .work,
            difficulty: .easy,
            estimatedMinutes: 30,
            xpReward: 50,
            isCompleted: true,
            completedDate: now.addingTimeInterval(-864000) // 10 days ago
        )
        
        let quests = [quest1, quest2]
        
        // When - Filter last 7 days
        let startDate = now.addingTimeInterval(-604800) // 7 days ago
        let filteredQuests = exportManager.filterQuests(
            quests,
            from: startDate,
            to: now
        )
        
        // Then
        XCTAssertEqual(filteredQuests.count, 1)
        XCTAssertEqual(filteredQuests[0].title, "Recent Quest")
    }
    
    func testFilterQuestsByCategory() {
        // When
        let workQuests = exportManager.filterQuests(
            gameManager.quests,
            byCategory: .work
        )
        
        // Then
        XCTAssertEqual(workQuests.count, 1)
        XCTAssertEqual(workQuests[0].category, .work)
    }
    
    // MARK: - Export Options Tests
    
    func testExportOptions() {
        // Test default options
        let defaultOptions = ExportOptions()
        XCTAssertTrue(defaultOptions.includeCharacter)
        XCTAssertTrue(defaultOptions.includeQuests)
        XCTAssertTrue(defaultOptions.includeAchievements)
        XCTAssertTrue(defaultOptions.includeAnalytics)
        XCTAssertNil(defaultOptions.dateRange)
        XCTAssertNil(defaultOptions.questFilter)
        
        // Test custom options
        let customOptions = ExportOptions(
            includeCharacter: false,
            includeQuests: true,
            includeAchievements: false,
            includeAnalytics: true,
            dateRange: (Date(), Date()),
            questFilter: { $0.category == .work }
        )
        
        XCTAssertFalse(customOptions.includeCharacter)
        XCTAssertTrue(customOptions.includeQuests)
        XCTAssertFalse(customOptions.includeAchievements)
        XCTAssertTrue(customOptions.includeAnalytics)
        XCTAssertNotNil(customOptions.dateRange)
        XCTAssertNotNil(customOptions.questFilter)
    }
}

// MARK: - Export Data Model Tests

extension DataExportManagerTests {
    func testExportDataModel() {
        // Given
        let character = Character()
        character.name = "Test Hero"
        character.level = 10
        
        let quest = Quest(
            title: "Test Quest",
            description: "Test",
            category: .work,
            difficulty: .medium,
            estimatedMinutes: 30,
            xpReward: 100
        )
        
        let achievement = Achievement(
            id: "test_achievement",
            title: "Test Achievement",
            description: "Test",
            icon: "🏆",
            category: .quest,
            requiredValue: 10
        )
        
        // When
        let exportData = ExportData(
            character: character,
            quests: [quest],
            achievements: [achievement],
            exportDate: Date()
        )
        
        // Then
        XCTAssertEqual(exportData.character.name, "Test Hero")
        XCTAssertEqual(exportData.quests.count, 1)
        XCTAssertEqual(exportData.achievements.count, 1)
        XCTAssertNotNil(exportData.exportDate)
        
        // Test encoding/decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let encoded = try encoder.encode(exportData)
            let decoded = try decoder.decode(ExportData.self, from: encoded)
            
            XCTAssertEqual(decoded.character.name, exportData.character.name)
            XCTAssertEqual(decoded.quests.count, exportData.quests.count)
            XCTAssertEqual(decoded.achievements.count, exportData.achievements.count)
        } catch {
            XCTFail("Failed to encode/decode export data: \(error)")
        }
    }
}