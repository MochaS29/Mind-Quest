# MindQuest - Gamified ADHD Productivity Platform

## Overview
MindQuest is a comprehensive gamified productivity platform designed specifically for individuals with ADHD. The platform transforms daily tasks, habits, and challenges into an engaging RPG-style adventure, making productivity fun and sustainable.

## Project Components

### 📱 Mobile Applications

#### iOS App (React Native/Expo)
- **Location**: `/Users/mocha/MindQuestApp/`
- **Stack**: React Native, Expo, JavaScript
- **Status**: Active Development
- **Features**: Cross-platform (iOS/Web), character creation, quest system, XP tracking
- **Run**: `npm run ios` or `npm run web`

#### Android App (Native Kotlin)
- **Location**: `/Users/mocha/MindLabsQuestAndroid/`
- **Stack**: Kotlin, Jetpack Compose, Room Database
- **Status**: Active Development
- **Features**: Material3 design, local storage, MVVM architecture
- **Run**: Open in Android Studio

#### SwiftUI App (iOS Native)
- **Location**: `/Users/mocha/MindLabsQuestSwiftUI/`
- **Stack**: SwiftUI, Core Data, CloudKit
- **Status**: Feature Complete
- **Features**: Native iOS experience, calendar integration, social features

## Core Features

### 🎮 Gamification System
- **Character Creation**: D&D-style character classes (Warrior, Mage, Rogue, Ranger)
- **XP & Leveling**: Gain experience points for completing real-world tasks
- **Stats System**: STR (Physical), INT (Learning), WIS (Mindfulness), CHA (Social)
- **Achievements**: Unlock badges and rewards for consistency

### 📋 Task Management
- **Quest System**: Transform tasks into engaging quests
- **Difficulty Levels**: Easy (10 XP), Medium (25 XP), Hard (50 XP), Epic (100 XP)
- **Categories**: Work, Personal, Health, Learning, Social
- **Recurring Quests**: Set up daily/weekly habits

### ⏰ ADHD-Specific Tools
- **Focus Timer**: Pomodoro-style timer with visual progress
- **Task Breakdown**: Break complex tasks into manageable steps
- **Visual Calendar**: Color-coded schedule visualization
- **Body Doubling**: Virtual co-working sessions
- **Quick Task Switching**: Seamless transition between activities

### 📊 Analytics & Insights
- **Progress Tracking**: Visual charts of productivity trends
- **Time Analytics**: Understand where time is spent
- **Pattern Recognition**: Identify peak productivity periods
- **Export Reports**: PDF/CSV export capabilities

### 👥 Social Features
- **Friend System**: Connect with accountability partners
- **Community Challenges**: Participate in group quests
- **Leaderboards**: Friendly competition
- **Achievement Sharing**: Celebrate victories together

### 👨‍👩‍👧‍👦 Parent Mode
- **Reward Management**: Parents can set real-world rewards
- **Progress Monitoring**: Track child's productivity
- **Screen Time Integration**: Link achievements to privileges
- **Custom Challenges**: Create family-specific quests

## Development Status

| Platform | Version | Status | Next Release |
|----------|---------|--------|--------------|
| iOS (React Native) | 1.0.0 | 🟢 Active | Feature parity with SwiftUI |
| Android (Kotlin) | 0.8.0 | 🟢 Active | Timer & Social features |
| iOS (SwiftUI) | 1.2.0 | ✅ Complete | Maintenance only |
| Web | 1.0.0 | 🟢 Active | Via React Native Web |

## Quick Start

### Prerequisites
- Node.js v14+ (for React Native app)
- Xcode 14+ (for iOS development)
- Android Studio (for Android development)
- npm or yarn package manager

### iOS/Web (React Native)
```bash
cd /Users/mocha/MindQuestApp
npm install
npm run ios  # For iOS Simulator
npm run web  # For browser
```

### Android (Kotlin)
```bash
cd /Users/mocha/MindLabsQuestAndroid
# Open in Android Studio
# Sync Gradle and run
```

### iOS (SwiftUI)
```bash
cd /Users/mocha/MindLabsQuestSwiftUI/MindLabsQuest
# Open MindLabsQuest.xcodeproj in Xcode
# Build and run
```

## Architecture

### Data Flow
```
User Interface (UI Layer)
       ↓
View Models (State Management)
       ↓
Repositories (Data Layer)
       ↓
Local Storage (Database/AsyncStorage)
```

### Tech Stack Comparison

| Component | React Native | Android | SwiftUI |
|-----------|-------------|---------|---------|
| UI | React Native | Compose | SwiftUI |
| State | React Hooks | ViewModel | @State |
| Storage | AsyncStorage | Room | Core Data |
| Navigation | React Navigation | Navigation Compose | NavigationStack |
| DI | Context | Hilt | Environment |

## Project Management

### AI Project Manager Agent
- **Location**: `/Users/mocha/mindquest-pm-agent/`
- **Purpose**: Automated project oversight and development assistance
- **Features**: Code analysis, feature tracking, sprint planning, quality monitoring

### Development Workflow
1. Feature planning in project manager agent
2. Parallel development across platforms
3. Feature parity checks
4. Testing and QA
5. Synchronized releases

## Design System

### Brand Colors
- **Primary**: #6B46C1 (Purple)
- **Secondary**: #9333EA (Bright Purple)
- **Success**: #10B981 (Green)
- **Warning**: #F59E0B (Amber)
- **Error**: #EF4444 (Red)
- **Background**: #1F2937 (Dark Gray)
- **Surface**: #374151 (Medium Gray)

### Typography
- **Headings**: System Bold
- **Body**: System Regular
- **Monospace**: SF Mono (iOS), Roboto Mono (Android)

## Testing

### Unit Tests
- React Native: Jest + React Native Testing Library
- Android: JUnit + Mockito
- SwiftUI: XCTest

### UI Tests
- React Native: Detox
- Android: Espresso
- iOS: XCUITest

## Deployment

### iOS App Store
- Bundle ID: `com.mindlabs.quest`
- Requires Apple Developer Account
- TestFlight for beta testing

### Google Play Store
- Package: `com.mindlabs.quest.android`
- Requires Google Play Console Account
- Internal testing track available

### Web Deployment
- Platform: Vercel/Netlify
- Build: `npm run build:web`
- Deploy: `npm run deploy`

## Contributing

### Code Style
- JavaScript/TypeScript: ESLint + Prettier
- Kotlin: ktlint
- Swift: SwiftLint

### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `release/*`: Release preparation

## Support

### Documentation
- [React Native App Guide](./MindQuestApp/README.md)
- [Android App Guide](./MindLabsQuestAndroid/README.md)
- [SwiftUI App Guide](./MindLabsQuestSwiftUI/README.md)
- [Project Manager Agent](./mindquest-pm-agent/README.md)

### Resources
- [ADHD Tools & Strategies](https://www.additudemag.com/)
- [React Native Docs](https://reactnative.dev/)
- [Android Developers](https://developer.android.com/)
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)

## License

© 2024 Mocha's MindLab Inc. All rights reserved.

---

**Vision**: Empowering individuals with ADHD to achieve their full potential through gamification and community support.

**Mission**: Transform the daily struggle of ADHD management into an engaging, rewarding adventure that makes productivity sustainable and fun.