#!/bin/bash

# Start MindQuest Development Environment

echo "🚀 Starting MindQuest Development Environment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.docker .env
    echo "📝 Please edit .env and add your API keys"
    exit 1
fi

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Build images if needed
echo "🔨 Building Docker images..."
docker-compose build

# Start services
echo "🎯 Starting services..."
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo "🏥 Checking service health..."
docker-compose ps

# Display access URLs
echo ""
echo "✅ MindQuest Development Environment is ready!"
echo ""
echo "📱 Access your services at:"
echo "   React Native App: http://localhost:19000"
echo "   Expo DevTools: http://localhost:19002"
echo "   API Gateway: http://localhost:3000"
echo "   Database Admin: http://localhost:8080"
echo "   Grafana: http://localhost:3001 (admin/admin)"
echo "   Mailhog: http://localhost:8025"
echo ""
echo "📝 View logs with: docker-compose logs -f"
echo "🛑 Stop with: docker-compose down"
echo ""

# Follow logs
read -p "Press Enter to view logs (Ctrl+C to exit)..."
docker-compose logs -f