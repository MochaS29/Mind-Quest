# Google Calendar Integration Setup

## Prerequisites
1. A Google Cloud Console account
2. A registered iOS app bundle identifier

## Setup Steps

### 1. Create a Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Calendar API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Calendar API"
   - Click "Enable"

### 2. Create OAuth 2.0 Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth Client ID"
3. Select "iOS" as the application type
4. Enter your bundle identifier: `com.mindlabs.quest` (or your actual bundle ID)
5. Click "Create"
6. Copy the Client ID

### 3. Configure URL Scheme
1. In Xcode, select your project
2. Go to the "Info" tab
3. Add a new URL Type:
   - URL Schemes: `com.mindlabs.quest`
   - Role: Editor
   - Identifier: Google Sign-In

### 4. Update GoogleCalendarManager
Replace `YOUR_GOOGLE_CLIENT_ID` in GoogleCalendarManager.swift with your actual Client ID:
```swift
private let clientID = "YOUR_ACTUAL_CLIENT_ID_HERE"
```

### 5. Update Info.plist
Add the following to your Info.plist:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.mindlabs.quest</string>
        </array>
    </dict>
</array>
```

### 6. Configure OAuth Consent Screen
1. In Google Cloud Console, go to "APIs & Services" > "OAuth consent screen"
2. Fill in the required information:
   - App name: Mind Labs Quest
   - User support email: Your email
   - App logo: Upload if available
   - Application home page: Your website or github repo
   - Application privacy policy: Link to privacy policy
   - Application terms of service: Link to terms
3. Add scopes:
   - `https://www.googleapis.com/auth/calendar.readonly`
   - `https://www.googleapis.com/auth/calendar.events`
4. Add test users if in development

## Testing
1. Build and run the app
2. Navigate to Calendar > Sync > Google Calendar
3. Sign in with a Google account
4. Grant calendar permissions
5. Select a calendar to sync

## Security Notes
- Never commit your Client ID to version control
- Use environment variables or configuration files
- Implement token refresh for production
- Store tokens securely in Keychain (already implemented)

## Troubleshooting
- If authentication fails, check your bundle ID matches
- Ensure URL scheme is properly configured
- Verify OAuth consent screen is configured
- Check that Calendar API is enabled in Google Cloud Console