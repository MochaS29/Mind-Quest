# Quick Fix for Xcode Build

## The Issue:
CocoaPods isn't installed on your system, which is needed for iOS dependencies.

## Easiest Solution: Use Expo Go App

Instead of dealing with Xcode build issues, try this simpler approach:

### 1. Run the development server:
```bash
cd /Users/mocha/MindQuestApp
npx expo start
```

### 2. Install Expo Go on your iPhone:
- Open App Store on your iPhone
- Search for "Expo Go"
- Install the free app

### 3. Connect:
- Make sure your iPhone and Mac are on the same WiFi
- In Terminal, you'll see a QR code
- Open Expo Go app on your phone
- Scan the QR code
- Your app will load!

## Alternative: Run in iOS Simulator without Xcode

Try this command which handles everything automatically:
```bash
cd /Users/mocha/MindQuestApp
npx expo start --ios
```

This will:
- Open iOS Simulator
- Install your app
- No Xcode needed!

## If You Really Want to Use Xcode:

You need to install CocoaPods first. Since you don't have admin access, the easiest way is:

1. **Install Homebrew** (if you don't have it):
   Visit https://brew.sh and follow instructions

2. **Install CocoaPods**:
   ```bash
   brew install cocoapods
   ```

3. **Install dependencies**:
   ```bash
   cd /Users/mocha/MindQuestApp/ios
   pod install
   ```

4. **Open the workspace** (not the project):
   ```bash
   open /Users/mocha/MindQuestApp/ios/MindLabsQuest.xcworkspace
   ```

## For Now: Just Use Expo!

The app works perfectly with Expo. You can always set up Xcode later when you need to publish to the App Store.

```bash
# This is all you need:
cd /Users/mocha/MindQuestApp
npx expo start
```

Then use:
- Press `i` for iOS Simulator
- Press `w` for Web Browser
- Scan QR with Expo Go app for real device