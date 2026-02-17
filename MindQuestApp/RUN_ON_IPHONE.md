# 📱 Running Mind Labs Quest on Your iPhone

## Prerequisites:
1. ✅ Xcode is now open with your project
2. 🔌 Connect your iPhone to your Mac with a USB cable
3. 🔓 Unlock your iPhone and trust this computer if prompted

## Step-by-Step Guide:

### 1. Select Your iPhone in Xcode
- Look at the top toolbar in Xcode
- Click on the device selector (next to "MindLabsQuest")
- Your iPhone should appear under "iOS Devices"
- Select it (e.g., "John's iPhone")

### 2. Configure Signing (IMPORTANT!)
If you see any signing errors:

1. Click on **"MindLabsQuest"** in the left sidebar
2. Select the **"Signing & Capabilities"** tab
3. Check **"Automatically manage signing"**
4. For Team, you need to:
   - Click the dropdown
   - Select "Add an Account..."
   - Sign in with your Apple ID (any Apple ID works)
   - Select your personal team (e.g., "John Doe (Personal Team)")

### 3. Trust Developer on iPhone
When you first run the app:

1. Xcode will install the app but it might not open
2. On your iPhone: Settings → General → VPN & Device Management
3. Under "Developer App" tap your Apple ID
4. Tap "Trust [Your Apple ID]"
5. Tap "Trust" again

### 4. Run the App
- Click the **▶️ Play button** in Xcode (or press Cmd+R)
- Wait for "Build Succeeded"
- The app will install and launch on your iPhone!

## Troubleshooting:

### ❌ "iPhone is not available"
- Unlock your iPhone
- Disconnect and reconnect the USB cable
- Trust this computer on your iPhone

### ❌ "Failed to register bundle identifier"
- Change the bundle ID slightly:
  1. In Signing & Capabilities
  2. Change "com.mindlabsquest.app" to "com.yourname.mindlabsquest"

### ❌ "Unable to install"
- On iPhone: Settings → General → iPhone Storage
- Delete any previous versions of Mind Labs Quest
- Try again

### ❌ Build errors
- Click Product → Clean Build Folder
- Try building again

## 🎉 Success Tips:
- First build takes 2-5 minutes
- Subsequent builds are much faster
- The app stays on your iPhone for 7 days
- After 7 days, just rebuild from Xcode

## Development Workflow:
1. Make changes in `/Users/mocha/MindQuestApp/App.js`
2. Save the file
3. Click Play in Xcode to see changes on your iPhone

## Free Apple Developer Account Limitations:
- Apps expire after 7 days (just rebuild)
- Can only install on your own devices
- Limited to 3 apps at a time

---

Your app should now be running on your iPhone! Create your character and start your quest! 🧙‍♂️✨