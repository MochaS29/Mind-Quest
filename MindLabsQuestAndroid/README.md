# MindLabs Quest - Android Version

A gamified ADHD productivity app for Android, built with Kotlin and Jetpack Compose.

## Setup Instructions

1. **Open the project in Android Studio:**
   - Open Android Studio
   - Click "Open" and select the `/Users/mocha/MindLabsQuestAndroid` folder
   - Wait for Gradle to sync (this may take a few minutes on first load)

2. **Run the app:**
   - Click the green play button in the toolbar
   - Select an emulator or connected device
   - The app will build and launch

## Project Structure

```
app/
├── src/main/java/com/mindlabs/quest/
│   ├── data/
│   │   ├── models/        # Data models (Character, Quest, etc.)
│   │   ├── database/      # Room database and DAOs
│   │   └── repository/    # Data repositories
│   ├── ui/
│   │   ├── screens/       # Composable screens
│   │   ├── components/    # Reusable UI components
│   │   ├── theme/         # Material3 theme
│   │   └── navigation/    # Navigation setup
│   ├── viewmodel/         # ViewModels for state management
│   └── di/                # Dependency injection modules
```

## Key Features Implemented

- ✅ Character creation and management
- ✅ Quest system with categories and difficulties
- ✅ Material3 design with custom MindLabs theme
- ✅ Room database for local storage
- ✅ Navigation with bottom navigation bar
- ✅ Dependency injection with Hilt

## Next Steps

The following screens need to be implemented:
- Timer/Focus screen
- Character profile screen
- Social features screen
- Settings screen
- Calendar integration
- Analytics dashboard

## Tech Stack

- **Language:** Kotlin
- **UI Framework:** Jetpack Compose
- **Architecture:** MVVM
- **Database:** Room
- **DI:** Hilt
- **Navigation:** Navigation Compose
- **Async:** Coroutines & Flow

## Notes

- The app uses Material3 design system
- All data is stored locally using Room database
- The theme matches the iOS version's color scheme