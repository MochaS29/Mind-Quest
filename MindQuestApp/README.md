# Mind Labs Quest App

A gamified ADHD productivity app built with React Native that runs on iOS and in the browser.

## Setup Instructions

### Prerequisites

1. **Node.js** (v14 or higher)
2. **npm** or **yarn**
3. **Xcode** (for iOS development - Mac only)
4. **Expo CLI** (will be installed with the project)

### Installation

1. Navigate to the project directory:
```bash
cd /Users/mocha/MindQuestApp
```

2. Install dependencies:
```bash
npm install
```

### Running the App

#### For Web Browser:
```bash
npm run web
```
The app will open in your default browser at http://localhost:19006

#### For iOS Simulator (Mac only):
```bash
npm run ios
```
This will open the iOS Simulator and run the app.

#### For iOS Device:
1. Install the Expo Go app from the App Store
2. Run `npm start`
3. Scan the QR code with your iPhone camera
4. Open in Expo Go

### Building for Production

#### Web Build:
```bash
npm run build:web
```
The build files will be in the `web-build` directory.

To serve the web build locally:
```bash
npm run serve:web
```

#### iOS Build:
For a standalone iOS app, you'll need:
1. An Apple Developer account
2. Run `expo build:ios`
3. Follow the prompts to configure certificates

### Creating an Xcode Project

If you want to open this in Xcode:

1. First, eject from Expo (this is a one-way operation):
```bash
expo eject
```

2. This will create an `ios` folder with an Xcode project
3. Open `ios/MindLabsQuestApp.xcworkspace` in Xcode
4. You can now build and run directly from Xcode

### Project Structure

```
MindQuestApp/
├── App.js              # Main app component
├── index.js            # Entry point
├── package.json        # Dependencies and scripts
├── app.json           # Expo configuration
├── babel.config.js    # Babel configuration
├── metro.config.js    # Metro bundler config
├── assets/            # Images and assets
├── public/            # Web-specific files
│   └── index.html     # HTML template for web
├── ios/               # iOS native code (after ejecting)
└── web-build/         # Web production build
```

### Features

- **Character Creation**: D&D-style character creation with classes and stats
- **Quest System**: Complete tasks to gain XP and level up
- **Stat Tracking**: Track progress across different skill areas
- **Persistent Storage**: Character data saved locally
- **Cross-Platform**: Works on iOS and web browsers

### Development Notes

- The app uses React Native Web for browser compatibility
- Icons are provided by @expo/vector-icons
- Data persistence uses AsyncStorage
- The UI is optimized for mobile devices

### Troubleshooting

**Issue: Metro bundler errors**
```bash
npx expo start -c
```

**Issue: iOS Simulator not opening**
- Make sure Xcode is installed
- Open Xcode once to accept licenses
- Try running `expo doctor`

**Issue: Web build not working**
```bash
rm -rf node_modules
npm install
npm run web
```

### Assets Required

To complete the setup, add these image files to the `assets` folder:
- `icon.png` (1024x1024) - App icon
- `splash.png` (1284x2778) - Splash screen
- `adaptive-icon.png` (1024x1024) - Android adaptive icon
- `favicon.png` (48x48) - Web favicon

You can use placeholder images for now or create your own.