#!/bin/bash

# Run Project Manager Agent commands

echo "🤖 MindQuest Project Manager Agent"
echo "=================================="

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if PM agent container is running
if ! docker-compose ps | grep -q "mindquest-pm-agent.*Up"; then
    echo "Starting PM Agent container..."
    docker-compose up -d pm-agent
    sleep 5
fi

# If no arguments, show menu
if [ $# -eq 0 ]; then
    echo ""
    echo "Available commands:"
    echo "  1) Daily Standup"
    echo "  2) Sprint Planning"
    echo "  3) Analyze Codebase"
    echo "  4) Check Feature Parity"
    echo "  5) List Tasks"
    echo "  6) Create Task"
    echo "  7) Suggest Next Tasks"
    echo "  8) View Metrics"
    echo "  9) Run Daily Automation"
    echo "  0) Exit"
    echo ""
    read -p "Select option: " option
    
    case $option in
        1)
            docker-compose exec pm-agent python scripts/run_agent.py standup
            ;;
        2)
            docker-compose exec pm-agent python scripts/run_agent.py sprint-plan
            ;;
        3)
            echo "Platform (ios/android/both):"
            read platform
            docker-compose exec pm-agent python scripts/run_agent.py analyze --platform ${platform:-both}
            ;;
        4)
            docker-compose exec pm-agent python scripts/run_agent.py parity
            ;;
        5)
            docker-compose exec pm-agent python scripts/run_agent.py list-tasks
            ;;
        6)
            echo "Task title:"
            read title
            echo "Task description:"
            read description
            docker-compose exec pm-agent python scripts/run_agent.py create-task "$title" "$description"
            ;;
        7)
            docker-compose exec pm-agent python scripts/run_agent.py suggest
            ;;
        8)
            docker-compose exec pm-agent python scripts/run_agent.py metrics
            ;;
        9)
            docker-compose exec pm-agent python scripts/run_agent.py daily
            ;;
        0)
            exit 0
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
else
    # Pass arguments directly to PM agent
    docker-compose exec pm-agent python scripts/run_agent.py "$@"
fi