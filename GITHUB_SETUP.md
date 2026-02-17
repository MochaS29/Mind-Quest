# GitHub Setup Guide for MindQuest Project

## Step-by-Step GitHub Repository Setup

### 1. Create GitHub Repository

1. **Go to GitHub.com** and sign in to your account
2. **Click the "+" icon** in the top right corner
3. **Select "New repository"**
4. **Configure repository settings:**
   - Repository name: `mindquest-platform`
   - Description: "Gamified ADHD productivity platform - iOS, Android, and Web apps with AI project management"
   - Visibility: Private (recommended initially)
   - Initialize with README: No (we'll push our own)
   - Add .gitignore: No (we'll create custom ones)
   - Choose a license: MIT or your preferred license

5. **Click "Create repository"**

### 2. Set Up Local Git Configuration

```bash
# Navigate to your home directory
cd /Users/mocha

# Configure git globally (if not already done)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. Initialize Git Repository Locally

```bash
# Initialize git in the main directory
cd /Users/mocha
git init

# Add the remote repository
git remote add origin https://github.com/YOUR_USERNAME/mindquest-platform.git
```

### 4. Create Proper .gitignore Files

I'll create comprehensive .gitignore files for each component:

#### Main .gitignore (/Users/mocha/.gitignore)
```gitignore
# System files
.DS_Store
Thumbs.db
*.log

# Environment files
.env
.env.local
.env.*.local

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Python
venv/
__pycache__/
*.py[cod]
*$py.class
.Python
env/
ENV/

# API Keys and Secrets
**/config/secrets.json
**/config/api_keys.json

# Personal directories to exclude
Desktop/
Documents/
Downloads/
Movies/
Music/
Pictures/
Public/
Library/
Business Documents/

# Other apps not part of MindQuest
CommissaryBot/
HealthTracker/
HealthTracker bk/
IPhone Apps/
LabResultsApp/
MyFirstApp/
ProgressChallengeApp/
commissary-voicebot/
meal-planner/
innovation-journal/
mindlabs-website/
mochamindlabs-website/

# Keep only MindQuest related projects
!MindQuestApp/
!MindLabsQuestAndroid/
!MindLabsQuestSwiftUI/
!mindquest-pm-agent/
!MINDQUEST_README.md
!GITHUB_SETUP.md
```

#### React Native App .gitignore (/Users/mocha/MindQuestApp/.gitignore)
```gitignore
# Dependencies
node_modules/
.pnp
.pnp.js

# Expo
.expo/
dist/
web-build/

# Native builds
*.ipa
*.apk
*.aab

# iOS
ios/Pods/
ios/build/
ios/DerivedData/
*.pbxuser
*.mode1v3
*.mode2v3
*.perspectivev3
xcuserdata/
*.xccheckout
*.xcscmblueprint

# Android
android/.gradle/
android/build/
android/local.properties
android/app/build/

# Testing
coverage/

# Metro
.metro-health-check*

# Temporary files
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.yarn-integrity

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
```

#### Android App .gitignore (/Users/mocha/MindLabsQuestAndroid/.gitignore)
```gitignore
# Gradle
.gradle/
build/
*/build/
gradle-app.setting
local.properties

# Android Studio
.idea/
*.iml
.navigation/
captures/
.externalNativeBuild/
.cxx/

# Android
*.apk
*.aab
*.ap_
*.dex
*.class
bin/
gen/
out/
release/

# Proguard
proguard/

# Logs
*.log

# OS files
.DS_Store
Thumbs.db
```

#### SwiftUI App .gitignore (/Users/mocha/MindLabsQuestSwiftUI/.gitignore)
```gitignore
# Xcode
build/
DerivedData/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.xccheckout
*.moved-aside
*.xcuserstate
*.xcscmblueprint
*.xcscheme
*.playground

# Swift Package Manager
.build/
Packages/
Package.pins
Package.resolved

# CocoaPods
Pods/
*.xcworkspace

# Carthage
Carthage/Build/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# OS files
.DS_Store
.Trashes
```

### 5. Create Initial Commit

```bash
# Add the README files
git add MINDQUEST_README.md
git add GITHUB_SETUP.md

# Add project directories
git add MindQuestApp/
git add MindLabsQuestAndroid/
git add MindLabsQuestSwiftUI/
git add mindquest-pm-agent/

# Create initial commit
git commit -m "Initial commit: MindQuest platform with iOS, Android, and project manager"

# Push to GitHub
git push -u origin main
```

### 6. Set Up GitHub Project Features

After pushing your code, configure these GitHub features:

#### A. Create GitHub Project Board
1. Go to your repository
2. Click "Projects" tab
3. Click "New project"
4. Choose "Board" template
5. Name it "MindQuest Development"
6. Add columns: Backlog, To Do, In Progress, Review, Done

#### B. Set Up GitHub Actions
Create `.github/workflows/ci.yml` for continuous integration:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  react-native:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./MindQuestApp
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: '18'
    - run: npm ci
    - run: npm test
    - run: npm run lint

  android:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./MindLabsQuestAndroid
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    - run: ./gradlew test
    - run: ./gradlew lint

  ios:
    runs-on: macos-latest
    defaults:
      run:
        working-directory: ./MindLabsQuestSwiftUI
    steps:
    - uses: actions/checkout@v3
    - run: xcodebuild test -scheme MindLabsQuest -destination 'platform=iOS Simulator,name=iPhone 14'
```

#### C. Enable GitHub Issues
1. Go to Settings > General
2. Ensure "Issues" is checked
3. Create issue templates for:
   - Bug reports
   - Feature requests
   - Task tracking

#### D. Set Up Branch Protection
1. Go to Settings > Branches
2. Add rule for `main` branch:
   - Require pull request reviews
   - Require status checks to pass
   - Require branches to be up to date
   - Include administrators

### 7. Integrate Project Manager Agent with GitHub

Add GitHub integration to your project manager agent:

```bash
# Install GitHub CLI
brew install gh

# Authenticate with GitHub
gh auth login

# Set up environment variable for the agent
export GITHUB_TOKEN=$(gh auth token)
```

Update your agent to create issues automatically:
```python
# In project_manager.py, add:
import subprocess

def create_github_issue(title, body, labels=None):
    cmd = [
        "gh", "issue", "create",
        "--title", title,
        "--body", body,
        "--repo", "YOUR_USERNAME/mindquest-platform"
    ]
    if labels:
        cmd.extend(["--label", ",".join(labels)])
    
    subprocess.run(cmd)
```

### 8. Set Up Secrets for CI/CD

1. Go to Settings > Secrets and variables > Actions
2. Add these secrets:
   - `ANTHROPIC_API_KEY` - For project manager agent
   - `EXPO_TOKEN` - For React Native builds
   - `ANDROID_KEYSTORE` - For Android signing
   - `IOS_CERTIFICATE` - For iOS signing

### 9. Create Development Workflow

#### Branch Strategy
```
main           - Production-ready code
├── develop    - Integration branch
    ├── feature/ios-*     - iOS features
    ├── feature/android-* - Android features
    ├── feature/agent-*   - Agent features
    └── bugfix/*         - Bug fixes
```

#### Commit Message Convention
```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor code
test: Add tests
chore: Update dependencies
```

### 10. Team Collaboration Setup

If working with others:

1. **Add collaborators:**
   - Settings > Manage access > Invite collaborators

2. **Create team workflow:**
   - Use pull requests for all changes
   - Require code reviews
   - Use GitHub Discussions for planning

3. **Set up notifications:**
   - Watch the repository
   - Configure email notifications
   - Use GitHub mobile app

## Next Steps

1. **Run initial setup:**
```bash
# Create all .gitignore files
# Initialize git repository
# Make initial commit
# Push to GitHub
```

2. **Test the setup:**
```bash
# Clone to a different directory to verify
git clone https://github.com/YOUR_USERNAME/mindquest-platform.git test-clone
cd test-clone
# Verify all files are present
```

3. **Start using the project manager agent:**
```bash
cd /Users/mocha/mindquest-pm-agent
python src/project_manager.py
```

4. **Create your first GitHub issue:**
```bash
gh issue create --title "Set up CI/CD pipeline" --body "Configure automated testing and deployment"
```

## Troubleshooting

### Issue: Permission denied when pushing
```bash
# Use personal access token
git remote set-url origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/mindquest-platform.git
```

### Issue: Large files blocking push
```bash
# Use Git LFS for large files
brew install git-lfs
git lfs track "*.zip"
git lfs track "*.sqlite"
```

### Issue: Merge conflicts
```bash
# Pull latest changes
git pull origin main --rebase
# Resolve conflicts manually
# Continue rebase
git rebase --continue
```

## Security Best Practices

1. **Never commit secrets** - Use environment variables
2. **Use signed commits** - `git config --global commit.gpgsign true`
3. **Enable 2FA** on GitHub account
4. **Regularly rotate API keys**
5. **Review dependencies** for vulnerabilities

## Useful GitHub Commands

```bash
# Create issue
gh issue create

# Create pull request
gh pr create

# Check workflow status
gh workflow view

# List issues
gh issue list

# View project board
gh project list
```

---

Ready to set up your GitHub repository! Follow these steps in order and you'll have a professional development environment with CI/CD, project management, and team collaboration features.