#!/bin/bash

echo "==================================="
echo "🚀 MindQuest Docker Setup Wizard"
echo "==================================="
echo ""
echo "This wizard will help you set up Docker for your MindQuest project."
echo "Just follow the prompts!"
echo ""

# Step 1: Check Docker is running
echo "Step 1: Checking Docker..."
if docker info > /dev/null 2>&1; then
    echo "✅ Docker is running!"
else
    echo "❌ Docker is not running."
    echo ""
    echo "Please start Docker Desktop by:"
    echo "1. Opening Finder"
    echo "2. Go to Applications"
    echo "3. Double-click Docker"
    echo "4. Wait for the whale icon to appear in your menu bar"
    echo ""
    read -p "Press Enter when Docker is running..."
    
    if ! docker info > /dev/null 2>&1; then
        echo "Docker still not running. Please start Docker Desktop and run this script again."
        exit 1
    fi
fi

echo ""
echo "Step 2: Setting up API keys..."
echo "--------------------------------"

# Check if .env exists
if [ ! -f .env ]; then
    cp .env.docker .env
    echo "Created .env file from template"
fi

# Check for Anthropic API key
if grep -q "your_anthropic_api_key_here" .env; then
    echo ""
    echo "📝 You need an Anthropic API key for the AI Project Manager."
    echo ""
    echo "To get your API key:"
    echo "1. Go to: https://console.anthropic.com/"
    echo "2. Sign in or create an account"
    echo "3. Go to API Keys section"
    echo "4. Create a new API key"
    echo "5. Copy the key"
    echo ""
    read -p "Paste your Anthropic API key here (or press Enter to skip): " api_key
    
    if [ ! -z "$api_key" ]; then
        # Use sed to replace the placeholder
        sed -i '' "s/your_anthropic_api_key_here/$api_key/" .env
        echo "✅ API key saved!"
    else
        echo "⚠️  Skipped - You can add it later by editing the .env file"
    fi
fi

echo ""
echo "Step 3: Building Docker images..."
echo "--------------------------------"
echo "This will take a few minutes the first time..."
echo ""

# Only build the essential services for now
echo "Building Project Manager Agent..."
docker-compose build pm-agent

echo ""
echo "Building React Native development environment..."
docker-compose build react-native-dev

echo ""
echo "✅ Docker images built successfully!"

echo ""
echo "Step 4: Starting services..."
echo "--------------------------------"

# Start only essential services
docker-compose up -d postgres redis pm-agent

echo ""
echo "Waiting for services to start (10 seconds)..."
sleep 10

# Check if services are running
echo ""
echo "Checking services status..."
docker-compose ps

echo ""
echo "==================================="
echo "✅ Setup Complete!"
echo "==================================="
echo ""
echo "Your Docker environment is ready!"
echo ""
echo "📚 Quick Guide:"
echo "---------------"
echo ""
echo "To start React Native app:"
echo "  docker-compose up -d react-native-dev"
echo "  Then open: http://localhost:19000"
echo ""
echo "To use the Project Manager:"
echo "  ./docker/scripts/pm-agent.sh"
echo ""
echo "To see what's running:"
echo "  docker-compose ps"
echo ""
echo "To stop everything:"
echo "  docker-compose down"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f [service-name]"
echo ""
echo "📖 For more help, see DOCKER_SETUP.md"
echo ""