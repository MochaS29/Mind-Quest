# Docker Beginner's Guide for MindQuest

## What is Docker? 🐳

Think of Docker like a shipping container for your apps. Just like shipping containers can hold anything and be moved anywhere, Docker containers hold your app and everything it needs to run, making it work the same on any computer.

## Why Use Docker?

- **No more "it works on my machine"** - It will work the same everywhere
- **Easy setup** - One command starts everything
- **Clean** - Doesn't mess up your computer with installations
- **Professional** - This is how real companies deploy apps

## Getting Started - The Easy Way

### Step 1: Make Sure Docker Desktop is Running

1. Look at the top of your Mac screen (menu bar)
2. You should see a whale icon 🐳
3. If you don't see it:
   - Open **Finder**
   - Go to **Applications**
   - Double-click **Docker**
   - Wait for the whale to appear in the menu bar

### Step 2: Run the Setup Wizard

Open Terminal and run these commands one at a time:

```bash
# Go to your project folder
cd /Users/mocha

# Run the setup wizard
./setup-docker.sh
```

The wizard will guide you through everything!

### Step 3: Get Your API Key (Optional but Recommended)

The AI Project Manager needs an API key to work. Here's how to get one:

1. **Go to**: https://console.anthropic.com/
2. **Sign up** for a free account (or sign in)
3. **Click** on "API Keys" in the sidebar
4. **Click** "Create Key"
5. **Copy** the key that appears
6. **Paste** it when the setup wizard asks for it

Don't worry - this key is kept safe in your .env file and never shared.

## Daily Use - Simple Commands

### Starting Your Development Environment

```bash
# Start everything
docker-compose up -d

# What this means:
# docker-compose = the Docker tool
# up = start things up
# -d = run in background (so you can use Terminal for other things)
```

### Checking What's Running

```bash
# See what's running
docker-compose ps

# You'll see a list like:
# mindquest-pm-agent     Running
# mindquest-db          Running
# mindquest-redis       Running
```

### Stopping Everything

```bash
# Stop all Docker containers
docker-compose down

# This stops everything cleanly
```

### Using the Project Manager

We have an AI assistant that helps manage your project:

```bash
# Run the Project Manager menu
./docker/scripts/pm-agent.sh

# You'll see a menu like:
# 1) Daily Standup
# 2) Sprint Planning
# 3) Analyze Codebase
# ...

# Just type a number and press Enter!
```

## Common Tasks Made Simple

### Want to See Your React Native App?

```bash
# Start the app
docker-compose up -d react-native-dev

# Open your browser and go to:
# http://localhost:19000

# Your app will appear!
```

### Want to Build an Android App?

```bash
# Build an Android APK file
./docker/scripts/build-android.sh

# The app file will appear on your Desktop!
```

### Want to See Logs (What's Happening)?

```bash
# See all logs
docker-compose logs

# See logs for one service
docker-compose logs pm-agent

# Keep watching logs (live)
docker-compose logs -f
# Press Ctrl+C to stop watching
```

## Troubleshooting - Common Problems

### "Docker is not running"

**Solution**: Start Docker Desktop from Applications

### "Port already in use"

**Solution**: Something else is using that port. Just stop it:
```bash
# Stop everything and start fresh
docker-compose down
docker-compose up -d
```

### "Permission denied"

**Solution**: Make the script executable:
```bash
chmod +x scriptname.sh
```

### Everything is Broken!

**Don't panic!** Reset everything:
```bash
# Stop everything
docker-compose down

# Remove everything (clean slate)
docker-compose down -v

# Start fresh
docker-compose up -d
```

## Understanding the Services

Here's what each service does (in simple terms):

| Service | What it Does | Access URL |
|---------|-------------|------------|
| **pm-agent** | AI that helps manage your project | Run commands via Terminal |
| **react-native-dev** | Your mobile app | http://localhost:19000 |
| **postgres** | Database (stores data) | Managed automatically |
| **redis** | Cache (makes things fast) | Managed automatically |
| **nginx** | Web server (directs traffic) | http://localhost |

## Quick Reference Card

Print this out and keep it handy:

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# See what's running
docker-compose ps

# View logs
docker-compose logs

# Run Project Manager
./docker/scripts/pm-agent.sh

# Build Android app
./docker/scripts/build-android.sh

# Get help
cat DOCKER_BEGINNER_GUIDE.md
```

## Getting Help

### If you're stuck:

1. **Check the logs**: `docker-compose logs [service-name]`
2. **Read this guide**: It has most answers
3. **Google the error**: Someone else has had the same problem
4. **Ask ChatGPT or Claude**: They're great at Docker help

### Resources:

- **This Guide**: Start here always
- **DOCKER_SETUP.md**: More detailed information
- **Docker Desktop**: Has a nice GUI to see what's running
- **YouTube**: Search "Docker basics" for video tutorials

## Tips for Success

1. **Don't be afraid to experiment** - You can always reset
2. **Read error messages** - They usually tell you what's wrong
3. **Start small** - Get one service working before starting all
4. **Use the scripts** - They do the hard work for you
5. **Keep notes** - Write down what works for you

## Next Steps

Once you're comfortable with the basics:

1. ✅ Run the setup wizard
2. ✅ Start the Project Manager
3. ✅ View your React Native app
4. ✅ Try building an Android APK
5. ✅ Commit your changes to GitHub

## Remember

- **Docker is just a tool** - It helps you run your apps
- **Containers are temporary** - Your code is safe in files
- **It's OK to restart** - `docker-compose down` then `up -d`
- **You're doing great!** - This is professional-level stuff!

---

## Super Simple Cheat Sheet

```bash
# Just remember these 3 commands:

# 1. Start stuff
docker-compose up -d

# 2. Stop stuff
docker-compose down

# 3. See stuff
docker-compose ps
```

That's it! You're ready to use Docker! 🎉