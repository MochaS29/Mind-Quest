# Mind Labs Quest Test Plan

## Test Coverage Overview

### Unit Tests
1. **GameManagerTests**
   - Character creation and management
   - Quest creation, completion, and rewards
   - Streak tracking and maintenance
   - Routine management
   - Time tracking functionality
   - Achievement integration
   - Data persistence

2. **NotificationManagerTests**
   - Quest reminder scheduling
   - Medication reminder functionality
   - Hyperfocus protection alerts
   - Timer notifications for different phases
   - Daily quest reminders
   - Notification cancellation

3. **AchievementManagerTests**
   - Achievement initialization
   - Quest-based achievements
   - Streak achievements
   - Level achievements
   - Focus time achievements
   - Collection achievements
   - Progress tracking
   - Persistence

4. **CalendarManagerTests**
   - Calendar sync settings
   - Event to quest conversion
   - Priority mapping
   - Event type handling
   - Date range calculations
   - Settings persistence

5. **ModelsTests**
   - Character model and calculations
   - Quest structure and rewards
   - Routine and step management
   - Achievement data structure
   - Calendar event model
   - Enum validations

### Integration Tests (To Be Implemented)
1. **End-to-End User Flows**
   - New user onboarding
   - Daily quest completion workflow
   - Pomodoro timer session
   - Calendar sync process
   - Achievement unlocking

2. **UI Tests**
   - Character creation flow
   - Quest management
   - Timer interaction
   - Settings navigation
   - Achievement viewing

### Performance Tests (To Be Implemented)
1. **Data Loading**
   - Large quest lists
   - Achievement calculations
   - Analytics data processing

2. **Memory Management**
   - View lifecycle
   - Timer operations
   - Notification scheduling

## Running Tests

### Command Line
```bash
# Run all tests
xcodebuild test -scheme MindLabsQuest -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test file
swift test --filter GameManagerTests
```

### Xcode
1. Open MindLabsQuest.xcodeproj
2. Press ⌘+U to run all tests
3. Or use Test Navigator (⌘+6) to run individual tests

## Test Data Management

### Mock Data
- Use factory methods like `Quest.testQuest()` for consistent test data
- Clear UserDefaults between tests when testing persistence
- Use dependency injection for testable components

### Test Isolation
- Each test should be independent
- Clean up any created notifications after tests
- Reset singleton states when necessary

## Continuous Integration

### Recommended CI Setup
1. Run tests on every pull request
2. Generate coverage reports
3. Fail builds if coverage drops below 80%
4. Run UI tests on multiple device sizes

### Coverage Goals
- Unit test coverage: 85%+
- Critical paths: 100%
- UI test coverage: Key user flows

## Adding New Tests

When adding new features:
1. Write tests first (TDD approach)
2. Ensure both positive and negative cases
3. Test edge cases and error conditions
4. Update this test plan

## Known Test Limitations

1. **EventKit Integration**
   - Requires simulator/device with calendar access
   - Mock EventStore for unit tests

2. **Notification Testing**
   - Limited ability to test actual notification delivery
   - Focus on scheduling logic

3. **Keychain Access**
   - Use mock keychain for unit tests
   - Integration tests on actual device

## Test Maintenance

### Regular Tasks
- Review and update tests when models change
- Remove obsolete tests
- Refactor duplicate test code
- Keep tests fast and focused

### Test Review Checklist
- [ ] Tests are readable and well-named
- [ ] No hardcoded delays or sleeps
- [ ] Proper use of async/await
- [ ] Clear assertions with helpful messages
- [ ] Adequate coverage of edge cases