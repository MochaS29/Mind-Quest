# MindQuest Project Manager Agent

An AI-powered project management agent for overseeing the development of MindQuest iOS and Android applications.

## Features

- **Automated Sprint Planning**: Generate sprint plans based on priorities and capacity
- **Daily Standup Reports**: Automated daily progress tracking
- **Feature Parity Analysis**: Monitor and maintain feature consistency across platforms
- **Code Analysis**: AI-powered codebase analysis for improvements
- **Task Management**: Create, track, and manage development tasks
- **Smart Suggestions**: AI-generated task recommendations
- **Metrics Tracking**: Monitor project velocity and progress

## Installation

### Prerequisites

- Python 3.8 or higher
- Anthropic API key
- GitHub account (optional, for GitHub integration)

### Setup

1. **Clone the repository:**
```bash
cd /Users/mocha/mindquest-pm-agent
```

2. **Create virtual environment:**
```bash
python3 -m venv venv
source venv/bin/activate  # On macOS/Linux
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Configure environment:**
```bash
cp .env.example .env
# Edit .env and add your ANTHROPIC_API_KEY
```

## Usage

### Command Line Interface

The agent provides a CLI for all operations:

```bash
# Activate virtual environment
source venv/bin/activate

# Run the CLI
python scripts/run_agent.py --help
```

### Available Commands

#### Daily Operations

```bash
# Generate daily standup
python scripts/run_agent.py standup

# Run all daily automation tasks
python scripts/run_agent.py daily

# View project metrics
python scripts/run_agent.py metrics
```

#### Sprint Management

```bash
# Generate sprint plan
python scripts/run_agent.py sprint-plan

# Check feature parity
python scripts/run_agent.py parity
```

#### Task Management

```bash
# Create a new task
python scripts/run_agent.py create-task "Add timer feature" "Implement pomodoro timer" --platform ios --priority high --hours 8

# List all tasks
python scripts/run_agent.py list-tasks

# Update task status
python scripts/run_agent.py update-status TASK-0001 in_progress

# Get AI suggestions for next tasks
python scripts/run_agent.py suggest --context "Focus on Android features"
```

#### Code Analysis

```bash
# Analyze codebase
python scripts/run_agent.py analyze --platform both

# Analyze specific platform
python scripts/run_agent.py analyze --platform android
```

### Programmatic Usage

```python
import asyncio
from src.project_manager import ProjectManagerAgent

async def main():
    # Initialize agent
    agent = ProjectManagerAgent(api_key="your_api_key")
    
    # Generate daily standup
    standup = await agent.generate_daily_standup()
    print(standup)
    
    # Create a task
    task = agent.create_task(
        title="Implement dark mode",
        description="Add dark mode support across the app",
        platform="both",
        estimated_hours=12
    )
    
    # Get AI suggestions
    suggestions = await agent.suggest_next_tasks("Performance improvements needed")
    
    # Run daily automation
    await agent.run_daily_automation()

asyncio.run(main())
```

## Configuration

Edit `config/agent_config.json` to customize:

- Sprint duration
- Work hours per day
- Team members
- AI model settings
- Code quality thresholds
- Feature flags

## Project Structure

```
mindquest-pm-agent/
├── src/
│   └── project_manager.py      # Main agent implementation
├── scripts/
│   └── run_agent.py            # CLI interface
├── config/
│   └── agent_config.json       # Agent configuration
├── reports/                    # Generated reports
│   ├── standups/               # Daily standup reports
│   ├── metrics/                # Project metrics
│   └── analysis/               # Code analysis reports
├── data/
│   └── tasks.json              # Task storage
├── docs/                       # Documentation
├── requirements.txt            # Python dependencies
├── .env.example               # Environment template
└── README.md                  # This file
```

## Reports

The agent generates various reports stored in the `reports/` directory:

- **Daily Standups**: `reports/standups/standup_YYYYMMDD.md`
- **Sprint Plans**: `reports/sprint_N.json`
- **Feature Parity**: `reports/parity_YYYYMMDD_HHMMSS.json`
- **Code Analysis**: `reports/analysis_YYYYMMDD_HHMMSS.json`
- **Metrics**: `reports/metrics/metrics_YYYYMMDD.json`

## Automation

### Daily Automation Script

Create a cron job for daily automation:

```bash
# Edit crontab
crontab -e

# Add daily automation at 9 AM
0 9 * * * cd /Users/mocha/mindquest-pm-agent && source venv/bin/activate && python scripts/run_agent.py daily
```

### GitHub Integration

The agent can integrate with GitHub for issue tracking:

```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# Set GitHub token in .env
GITHUB_TOKEN=$(gh auth token)
```

## API Integration

### Webhook Endpoints

You can expose the agent as a web service:

```python
# Example Flask integration (create api.py)
from flask import Flask, jsonify
from src.project_manager import ProjectManagerAgent

app = Flask(__name__)
agent = ProjectManagerAgent(api_key="your_key")

@app.route('/api/standup')
async def get_standup():
    standup = await agent.generate_daily_standup()
    return jsonify({"standup": standup})

@app.route('/api/metrics')
def get_metrics():
    return jsonify({
        "total_tasks": len(agent.tasks),
        "sprint_progress": agent.calculate_sprint_progress()
    })
```

## Best Practices

1. **Regular Updates**: Run daily automation to keep metrics current
2. **Task Grooming**: Review and update task statuses regularly
3. **Sprint Planning**: Generate sprint plans at the start of each sprint
4. **Feature Parity**: Check parity weekly to maintain consistency
5. **Code Analysis**: Run analysis before major releases

## Troubleshooting

### Issue: API Key Error
```bash
# Ensure API key is set
export ANTHROPIC_API_KEY="your_key"
# Or add to .env file
```

### Issue: Module Not Found
```bash
# Ensure you're in virtual environment
source venv/bin/activate
# Reinstall dependencies
pip install -r requirements.txt
```

### Issue: Permission Denied
```bash
# Make scripts executable
chmod +x scripts/run_agent.py
```

## Development

### Running Tests
```bash
pytest tests/
```

### Code Formatting
```bash
black src/ scripts/
flake8 src/ scripts/
mypy src/
```

### Adding New Features

1. Create feature branch
2. Implement in `src/project_manager.py`
3. Add CLI command in `scripts/run_agent.py`
4. Update documentation
5. Add tests

## Roadmap

- [ ] Web dashboard interface
- [ ] Slack integration
- [ ] Automated PR creation
- [ ] Test coverage monitoring
- [ ] Performance profiling
- [ ] Team collaboration features
- [ ] Machine learning for task estimation
- [ ] Integration with CI/CD pipelines

## Support

For issues or questions:
1. Check the documentation
2. Review existing GitHub issues
3. Create a new issue with details

## License

© 2024 Mocha's MindLab Inc. All rights reserved.