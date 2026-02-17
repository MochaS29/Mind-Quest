# 🔐 Fix Xcode Signing Issue

## Quick Fix Steps:

### 1. Add Your Apple ID to Xcode
1. In Xcode, go to **Xcode menu → Settings** (or press Cmd+,)
2. Click **Accounts** tab
3. Click the **+** button at bottom left
4. Select **Apple ID**
5. Sign in with ANY Apple ID (your regular one is fine)
6. Close Settings

### 2. Configure Project Signing
1. In the left sidebar, click **"MindLabsQuest"** (blue icon)
2. Make sure **"MindLabsQuest"** is selected under TARGETS
3. Go to **"Signing & Capabilities"** tab
4. Check ✅ **"Automatically manage signing"**
5. For **Team**, select your Apple ID (e.g., "Your Name (Personal Team)")

### 3. Change Bundle Identifier (Optional)
If it still doesn't work, make the bundle ID unique:
1. Still in "Signing & Capabilities"
2. Change **Bundle Identifier** from `com.mindlabsquest.app` to:
   - `com.yourname.mindlabsquest` (replace "yourname" with your actual name)
   - Example: `com.john.mindlabsquest`

### 4. Build and Run
1. Select your iPhone from device dropdown
2. Press ▶️ Play button
3. Wait for build to complete

## First Time Running on iPhone:
1. When the app installs, it might not open
2. On your iPhone: **Settings → General → VPN & Device Management**
3. Under "Developer App" tap your email
4. Tap **"Trust [Your Email]"**
5. Tap **"Trust"** again
6. Now the app will run!

## Still Having Issues?

### Try this bundle ID format:
Instead of `com.mindlabsquest.app`, use:
- `com.${YOUR_NAME}.mindlabsquest`
- `io.${YOUR_NAME}.mindlabsquest`
- `app.mindlabsquest.${YOUR_NAME}`

The key is making it UNIQUE to you!

### Alternative: Use Simulator First
If signing is still problematic:
1. Select **"iPhone 15"** from device dropdown (instead of your real phone)
2. Press Play - no signing needed for simulator!
3. Test your app there first

---
💡 **Note**: Free Apple Developer accounts can install apps on your own devices. The app will work for 7 days, then you just rebuild it.