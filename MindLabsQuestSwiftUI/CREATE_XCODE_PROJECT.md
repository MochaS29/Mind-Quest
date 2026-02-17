# 🚀 Creating Mind Labs Quest in Xcode (Pure SwiftUI)

## Step 1: Create New Xcode Project

1. Open **Xcode**
2. Click **"Create a new Xcode project"**
3. Choose:
   - Platform: **iOS**
   - Template: **App**
   - Click **Next**

## Step 2: Configure Project

- **Product Name**: MindLabsQuest
- **Team**: Select your Apple ID
- **Organization Identifier**: com.yourname
- **Bundle Identifier**: Will auto-fill as `com.yourname.MindLabsQuest`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Use Core Data**: ❌ Unchecked (we're using UserDefaults)
- **Include Tests**: ❌ Unchecked (for now)

Click **Next** and save to `/Users/mocha/MindLabsQuestSwiftUI`

## Step 3: Add the Swift Files

1. Delete the default `ContentView.swift` file
2. Right-click on the project folder → **New File** → **Swift File**
3. Add each of these files:
   - `Models.swift`
   - `GameManager.swift`
   - `ContentView.swift`
   - `CharacterCreationView.swift`
   - `DashboardView.swift`
   - `NewQuestView.swift`
   - `QuestsView.swift`
   - `CharacterView.swift`
   - `TimerView.swift`

4. Copy the code from each file I created into the corresponding Xcode file

## Step 4: Update MindLabsQuestApp.swift

Replace the default code with:
```swift
import SwiftUI

@main
struct MindLabsQuestApp: App {
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
        }
    }
}
```

## Step 5: Run the App!

1. Select your iPhone or a Simulator
2. Press **▶️ Play**
3. No CocoaPods needed! 🎉

## Features Included:

✅ **Character Creation** - D&D style with classes and backgrounds
✅ **Quest System** - Create and complete tasks for XP
✅ **Stats & Leveling** - Track character progression
✅ **Timer** - Focus timer for quests
✅ **Data Persistence** - Saves automatically with UserDefaults
✅ **100% SwiftUI** - No dependencies, no CocoaPods!

## Customization Ideas:

- Add more character classes
- Create achievement system
- Add daily quest suggestions
- Implement streak tracking
- Add sound effects
- Create widgets for home screen

## Next Steps:

1. Run the app
2. Create your character
3. Add your first quest
4. Complete it to gain XP!

The app is now pure SwiftUI - much simpler than React Native! 🎮