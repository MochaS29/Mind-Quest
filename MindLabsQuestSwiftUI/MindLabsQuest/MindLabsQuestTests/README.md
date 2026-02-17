# Mind Labs Quest Testing Guide

## Overview
This directory contains the test suite for Mind Labs Quest, including unit tests, integration tests, and UI tests.

## Test Structure

```
MindLabsQuestTests/
├── GameManagerTests.swift      # Core game logic tests
├── NotificationManagerTests.swift # Notification system tests
├── AchievementManagerTests.swift # Achievement system tests
├── CalendarManagerTests.swift   # Calendar integration tests
├── ModelsTests.swift           # Data model tests
├── TestPlan.md                 # Comprehensive test plan
└── README.md                   # This file

MindLabsQuestUITests/
└── MindLabsQuestUITests.swift  # UI automation tests
```

## Running Tests

### In Xcode
1. Open `MindLabsQuest.xcodeproj`
2. Select the target device/simulator
3. Run tests:
   - All tests: `⌘+U`
   - Single test: Click the diamond next to the test method
   - Test file: Click the diamond next to the struct/class name

### Command Line

```bash
# Run all unit tests
swift test

# Run specific test
swift test --filter GameManagerTests

# Run with coverage
swift test --enable-code-coverage

# Generate coverage report
xcrun llvm-cov export -format="lcov" \
  .build/debug/MindLabsQuestPackageTests.xctest/Contents/MacOS/MindLabsQuestPackageTests \
  -instr-profile .build/debug/codecov/default.profdata > coverage.lcov
```

### Using xcodebuild

```bash
# Run all tests
xcodebuild test \
  -scheme MindLabsQuest \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'

# Run with specific configuration
xcodebuild test \
  -scheme MindLabsQuest \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES
```

## Test Categories

### Unit Tests
Fast, isolated tests for individual components:
- **GameManager**: Character, quest, and streak management
- **NotificationManager**: Notification scheduling and configuration
- **AchievementManager**: Achievement unlocking and progress
- **CalendarManager**: Event conversion and sync settings
- **Models**: Data structure validation

### UI Tests
End-to-end tests simulating user interactions:
- Character creation flow
- Quest management
- Timer functionality
- Navigation between tabs
- Achievement viewing

## Writing New Tests

### Test Template
```swift
import Testing
@testable import MindLabsQuest

struct NewFeatureTests {
    @Test func testNewFeature() async throws {
        // Arrange
        let manager = NewFeatureManager()
        
        // Act
        let result = manager.performAction()
        
        // Assert
        #expect(result == expectedValue)
    }
}
```

### Best Practices
1. **Isolation**: Each test should be independent
2. **Clarity**: Use descriptive test names
3. **Speed**: Keep tests fast (< 1 second each)
4. **Coverage**: Test both success and failure cases
5. **Assertions**: Use clear, specific assertions

## Continuous Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Run tests
      run: |
        xcodebuild test \
          -scheme MindLabsQuest \
          -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Debugging Tests

### Common Issues

1. **Test Timing Out**
   ```swift
   // Use waitForExistence with appropriate timeout
   XCTAssertTrue(element.waitForExistence(timeout: 10))
   ```

2. **Flaky Tests**
   - Add explicit waits for UI elements
   - Clear state between tests
   - Use unique identifiers

3. **Notification Tests**
   - Mock UNUserNotificationCenter for unit tests
   - Test scheduling logic, not delivery

## Test Data

### Factories
```swift
extension Quest {
    static func testQuest() -> Quest {
        Quest(
            title: "Test Quest",
            category: .academic,
            difficulty: .medium,
            estimatedTime: 30
        )
    }
}
```

### Cleanup
```swift
override func tearDown() {
    // Clear UserDefaults
    UserDefaults.standard.removePersistentDomain(
        forName: Bundle.main.bundleIdentifier!
    )
}
```

## Coverage Goals
- Overall: 80%+
- Critical paths: 95%+
- New features: 90%+

## Resources
- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [UI Testing Best Practices](https://developer.apple.com/videos/play/wwdc2015/406/)