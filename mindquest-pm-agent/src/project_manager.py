#!/usr/bin/env python3
"""
MindQuest Project Manager Agent
AI-powered project management for iOS and Android MindQuest apps
"""

import os
import json
import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from pathlib import Path
import anthropic
from dataclasses import dataclass, asdict
from enum import Enum

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class TaskPriority(Enum):
    """Task priority levels"""
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class TaskStatus(Enum):
    """Task status states"""
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    REVIEW = "review"
    COMPLETED = "completed"
    BLOCKED = "blocked"


@dataclass
class Task:
    """Represents a development task"""
    id: str
    title: str
    description: str
    priority: TaskPriority
    status: TaskStatus
    platform: str  # ios, android, both
    estimated_hours: float
    assigned_to: Optional[str] = None
    due_date: Optional[datetime] = None
    dependencies: List[str] = None
    tags: List[str] = None
    created_at: datetime = None
    updated_at: datetime = None

    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now()
        if self.updated_at is None:
            self.updated_at = datetime.now()
        if self.dependencies is None:
            self.dependencies = []
        if self.tags is None:
            self.tags = []

    def to_dict(self) -> dict:
        """Convert task to dictionary"""
        data = asdict(self)
        data['priority'] = self.priority.value
        data['status'] = self.status.value
        data['created_at'] = self.created_at.isoformat()
        data['updated_at'] = self.updated_at.isoformat()
        if self.due_date:
            data['due_date'] = self.due_date.isoformat()
        return data


class ProjectManagerAgent:
    """AI-powered project manager for MindQuest apps"""
    
    def __init__(self, api_key: str, config_path: str = "config/agent_config.json"):
        """Initialize the project manager agent"""
        self.client = anthropic.Anthropic(api_key=api_key)
        self.config_path = Path(config_path)
        self.config = self.load_config()
        
        # Project paths
        self.ios_path = Path("/Users/mocha/MindQuestApp")
        self.android_path = Path("/Users/mocha/MindLabsQuestAndroid")
        self.swiftui_path = Path("/Users/mocha/MindLabsQuestSwiftUI")
        
        # Task storage
        self.tasks: Dict[str, Task] = {}
        self.load_tasks()
        
        # Sprint information
        self.current_sprint = None
        self.sprint_velocity = 0
        
    def load_config(self) -> dict:
        """Load configuration from file"""
        if self.config_path.exists():
            with open(self.config_path, 'r') as f:
                return json.load(f)
        return {
            "sprint_duration_days": 14,
            "work_hours_per_day": 6,
            "platforms": ["ios", "android"],
            "team_members": ["developer"],
            "code_review_threshold": 100,  # lines changed
            "auto_assign_tasks": True
        }
    
    def save_config(self):
        """Save configuration to file"""
        os.makedirs(os.path.dirname(self.config_path), exist_ok=True)
        with open(self.config_path, 'w') as f:
            json.dump(self.config, f, indent=2)
    
    def load_tasks(self):
        """Load tasks from storage"""
        tasks_file = Path("data/tasks.json")
        if tasks_file.exists():
            with open(tasks_file, 'r') as f:
                tasks_data = json.load(f)
                for task_id, task_data in tasks_data.items():
                    # Convert string enums back to enum types
                    task_data['priority'] = TaskPriority(task_data['priority'])
                    task_data['status'] = TaskStatus(task_data['status'])
                    # Convert ISO strings back to datetime
                    task_data['created_at'] = datetime.fromisoformat(task_data['created_at'])
                    task_data['updated_at'] = datetime.fromisoformat(task_data['updated_at'])
                    if task_data.get('due_date'):
                        task_data['due_date'] = datetime.fromisoformat(task_data['due_date'])
                    
                    self.tasks[task_id] = Task(**task_data)
    
    def save_tasks(self):
        """Save tasks to storage"""
        os.makedirs("data", exist_ok=True)
        tasks_data = {
            task_id: task.to_dict() 
            for task_id, task in self.tasks.items()
        }
        with open("data/tasks.json", 'w') as f:
            json.dump(tasks_data, f, indent=2)
    
    async def analyze_codebase(self, platform: str = "both") -> Dict[str, Any]:
        """Analyze codebase for issues and improvements"""
        analysis = {
            "timestamp": datetime.now().isoformat(),
            "platform": platform,
            "issues": [],
            "improvements": [],
            "metrics": {}
        }
        
        prompt = f"""Analyze the following project structure and provide insights:
        
        iOS React Native App: {self.ios_path}
        - Stack: React Native, Expo, JavaScript
        - Features: Character creation, quest system, XP tracking
        
        Android Native App: {self.android_path}
        - Stack: Kotlin, Jetpack Compose, Room Database
        - Features: Material3 design, MVVM architecture
        
        Please identify:
        1. Critical issues that need immediate attention
        2. Feature parity gaps between platforms
        3. Code quality improvements
        4. Performance optimization opportunities
        5. Security considerations
        6. Testing coverage gaps
        
        Format as JSON with categories: issues, improvements, feature_gaps, metrics
        """
        
        try:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=2000,
                messages=[{"role": "user", "content": prompt}]
            )
            
            # Parse response and extract insights
            content = response.content[0].text
            logger.info(f"Codebase analysis completed for {platform}")
            
            # Store analysis results
            analysis["ai_insights"] = content
            self.save_analysis_report(analysis)
            
            return analysis
            
        except Exception as e:
            logger.error(f"Error analyzing codebase: {e}")
            analysis["error"] = str(e)
            return analysis
    
    def save_analysis_report(self, analysis: dict):
        """Save analysis report to file"""
        os.makedirs("reports", exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"reports/analysis_{timestamp}.json"
        with open(filename, 'w') as f:
            json.dump(analysis, f, indent=2)
        logger.info(f"Analysis report saved to {filename}")
    
    async def generate_sprint_plan(self) -> Dict[str, Any]:
        """Generate a sprint plan based on current tasks and priorities"""
        sprint_plan = {
            "sprint_number": self.get_next_sprint_number(),
            "start_date": datetime.now().date().isoformat(),
            "end_date": (datetime.now() + timedelta(days=self.config["sprint_duration_days"])).date().isoformat(),
            "goals": [],
            "tasks": [],
            "estimated_hours": 0,
            "capacity_hours": self.config["sprint_duration_days"] * self.config["work_hours_per_day"]
        }
        
        # Get high priority and in-progress tasks
        priority_tasks = [
            task for task in self.tasks.values()
            if task.status in [TaskStatus.TODO, TaskStatus.IN_PROGRESS]
            and task.priority in [TaskPriority.CRITICAL, TaskPriority.HIGH]
        ]
        
        # Sort by priority and add to sprint
        priority_tasks.sort(key=lambda x: (x.priority.value, x.created_at))
        
        total_hours = 0
        for task in priority_tasks:
            if total_hours + task.estimated_hours <= sprint_plan["capacity_hours"]:
                sprint_plan["tasks"].append(task.to_dict())
                total_hours += task.estimated_hours
        
        sprint_plan["estimated_hours"] = total_hours
        sprint_plan["utilization"] = (total_hours / sprint_plan["capacity_hours"]) * 100
        
        # Generate sprint goals using AI
        goals = await self.generate_sprint_goals(sprint_plan["tasks"])
        sprint_plan["goals"] = goals
        
        # Save sprint plan
        self.save_sprint_plan(sprint_plan)
        
        return sprint_plan
    
    async def generate_sprint_goals(self, tasks: List[dict]) -> List[str]:
        """Generate sprint goals based on tasks"""
        if not tasks:
            return ["Complete backlog grooming", "Improve test coverage"]
        
        task_summaries = [f"- {task['title']}: {task['description']}" for task in tasks[:10]]
        
        prompt = f"""Based on these sprint tasks, generate 3-5 concise sprint goals:
        
        Tasks:
        {chr(10).join(task_summaries)}
        
        Generate strategic goals that encompass these tasks. Be specific and measurable.
        Return as a JSON array of strings.
        """
        
        try:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=500,
                messages=[{"role": "user", "content": prompt}]
            )
            
            content = response.content[0].text
            # Parse JSON array from response
            import re
            json_match = re.search(r'\[.*?\]', content, re.DOTALL)
            if json_match:
                goals = json.loads(json_match.group())
                return goals
            
        except Exception as e:
            logger.error(f"Error generating sprint goals: {e}")
        
        return ["Complete high-priority features", "Maintain platform parity"]
    
    def get_next_sprint_number(self) -> int:
        """Get the next sprint number"""
        sprint_files = list(Path("reports").glob("sprint_*.json"))
        if not sprint_files:
            return 1
        
        numbers = [int(f.stem.split("_")[1]) for f in sprint_files]
        return max(numbers) + 1
    
    def save_sprint_plan(self, sprint_plan: dict):
        """Save sprint plan to file"""
        os.makedirs("reports", exist_ok=True)
        filename = f"reports/sprint_{sprint_plan['sprint_number']}.json"
        with open(filename, 'w') as f:
            json.dump(sprint_plan, f, indent=2)
        logger.info(f"Sprint plan saved to {filename}")
    
    async def check_feature_parity(self) -> Dict[str, Any]:
        """Check feature parity between iOS and Android apps"""
        parity_report = {
            "timestamp": datetime.now().isoformat(),
            "ios_features": [],
            "android_features": [],
            "missing_in_ios": [],
            "missing_in_android": [],
            "recommendations": []
        }
        
        prompt = """Analyze feature parity between MindQuest iOS and Android apps:
        
        iOS (React Native):
        - Character creation with D&D classes
        - Quest system with XP
        - Cross-platform (iOS/Web)
        - AsyncStorage for persistence
        
        Android (Kotlin):
        - Character creation and management
        - Quest system with categories
        - Material3 design
        - Room database
        
        Identify:
        1. Features present in iOS but missing in Android
        2. Features present in Android but missing in iOS
        3. Implementation differences
        4. Priority recommendations for achieving parity
        
        Return as structured JSON.
        """
        
        try:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=1500,
                messages=[{"role": "user", "content": prompt}]
            )
            
            parity_report["analysis"] = response.content[0].text
            
            # Create tasks for missing features
            await self.create_parity_tasks(parity_report)
            
            # Save report
            self.save_parity_report(parity_report)
            
            return parity_report
            
        except Exception as e:
            logger.error(f"Error checking feature parity: {e}")
            parity_report["error"] = str(e)
            return parity_report
    
    async def create_parity_tasks(self, parity_report: dict):
        """Create tasks for achieving feature parity"""
        # This would parse the AI response and create specific tasks
        pass
    
    def save_parity_report(self, report: dict):
        """Save feature parity report"""
        os.makedirs("reports", exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"reports/parity_{timestamp}.json"
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2)
        logger.info(f"Parity report saved to {filename}")
    
    async def generate_daily_standup(self) -> str:
        """Generate daily standup report"""
        yesterday = datetime.now() - timedelta(days=1)
        
        # Get completed tasks
        completed = [
            task for task in self.tasks.values()
            if task.status == TaskStatus.COMPLETED
            and task.updated_at.date() == yesterday.date()
        ]
        
        # Get in-progress tasks
        in_progress = [
            task for task in self.tasks.values()
            if task.status == TaskStatus.IN_PROGRESS
        ]
        
        # Get blocked tasks
        blocked = [
            task for task in self.tasks.values()
            if task.status == TaskStatus.BLOCKED
        ]
        
        standup = f"""
# Daily Standup - {datetime.now().strftime('%Y-%m-%d')}

## Yesterday's Accomplishments
{self._format_task_list(completed)}

## Today's Focus
{self._format_task_list(in_progress)}

## Blockers
{self._format_task_list(blocked)}

## Metrics
- Tasks Completed: {len(completed)}
- Tasks In Progress: {len(in_progress)}
- Blocked Tasks: {len(blocked)}
- Sprint Progress: {self.calculate_sprint_progress()}%
        """
        
        return standup
    
    def _format_task_list(self, tasks: List[Task]) -> str:
        """Format task list for standup"""
        if not tasks:
            return "- None"
        
        return "\n".join([
            f"- [{task.platform.upper()}] {task.title} ({task.priority.value})"
            for task in tasks[:5]  # Limit to 5 items
        ])
    
    def calculate_sprint_progress(self) -> float:
        """Calculate current sprint progress"""
        sprint_tasks = [
            task for task in self.tasks.values()
            if task.status != TaskStatus.TODO
        ]
        
        if not sprint_tasks:
            return 0
        
        completed = len([t for t in sprint_tasks if t.status == TaskStatus.COMPLETED])
        return round((completed / len(sprint_tasks)) * 100, 1)
    
    def create_task(
        self,
        title: str,
        description: str,
        platform: str = "both",
        priority: TaskPriority = TaskPriority.MEDIUM,
        estimated_hours: float = 4.0,
        **kwargs
    ) -> Task:
        """Create a new task"""
        task_id = f"TASK-{len(self.tasks) + 1:04d}"
        
        task = Task(
            id=task_id,
            title=title,
            description=description,
            platform=platform,
            priority=priority,
            status=TaskStatus.TODO,
            estimated_hours=estimated_hours,
            **kwargs
        )
        
        self.tasks[task_id] = task
        self.save_tasks()
        
        logger.info(f"Created task {task_id}: {title}")
        return task
    
    def update_task_status(self, task_id: str, status: TaskStatus):
        """Update task status"""
        if task_id in self.tasks:
            self.tasks[task_id].status = status
            self.tasks[task_id].updated_at = datetime.now()
            self.save_tasks()
            logger.info(f"Updated task {task_id} status to {status.value}")
        else:
            logger.error(f"Task {task_id} not found")
    
    async def suggest_next_tasks(self, developer_context: str = "") -> List[Task]:
        """AI-powered task suggestions based on current state"""
        prompt = f"""Based on the MindQuest project status, suggest the next 5 high-impact tasks:
        
        Project: Gamified ADHD productivity app
        Platforms: iOS (React Native), Android (Kotlin)
        
        Current Context: {developer_context}
        
        Consider:
        1. Feature parity between platforms
        2. User experience improvements
        3. Performance optimizations
        4. Bug fixes
        5. Testing coverage
        
        Return as JSON array with: title, description, platform, priority, estimated_hours
        """
        
        try:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=1000,
                messages=[{"role": "user", "content": prompt}]
            )
            
            content = response.content[0].text
            
            # Parse JSON and create tasks
            import re
            json_match = re.search(r'\[.*?\]', content, re.DOTALL)
            if json_match:
                suggestions = json.loads(json_match.group())
                
                created_tasks = []
                for suggestion in suggestions:
                    task = self.create_task(
                        title=suggestion.get("title", "New Task"),
                        description=suggestion.get("description", ""),
                        platform=suggestion.get("platform", "both"),
                        priority=TaskPriority(suggestion.get("priority", "medium")),
                        estimated_hours=suggestion.get("estimated_hours", 4.0)
                    )
                    created_tasks.append(task)
                
                return created_tasks
                
        except Exception as e:
            logger.error(f"Error suggesting tasks: {e}")
        
        return []
    
    async def run_daily_automation(self):
        """Run daily automation tasks"""
        logger.info("Running daily automation...")
        
        # Generate daily standup
        standup = await self.generate_daily_standup()
        
        # Save standup
        os.makedirs("reports/standups", exist_ok=True)
        date_str = datetime.now().strftime("%Y%m%d")
        with open(f"reports/standups/standup_{date_str}.md", 'w') as f:
            f.write(standup)
        
        # Check for stale tasks
        await self.check_stale_tasks()
        
        # Update metrics
        await self.update_project_metrics()
        
        logger.info("Daily automation completed")
    
    async def check_stale_tasks(self):
        """Check for tasks that haven't been updated recently"""
        stale_threshold = datetime.now() - timedelta(days=7)
        
        stale_tasks = [
            task for task in self.tasks.values()
            if task.status == TaskStatus.IN_PROGRESS
            and task.updated_at < stale_threshold
        ]
        
        for task in stale_tasks:
            logger.warning(f"Stale task detected: {task.id} - {task.title}")
    
    async def update_project_metrics(self):
        """Update project metrics"""
        metrics = {
            "timestamp": datetime.now().isoformat(),
            "total_tasks": len(self.tasks),
            "completed_tasks": len([t for t in self.tasks.values() if t.status == TaskStatus.COMPLETED]),
            "in_progress_tasks": len([t for t in self.tasks.values() if t.status == TaskStatus.IN_PROGRESS]),
            "blocked_tasks": len([t for t in self.tasks.values() if t.status == TaskStatus.BLOCKED]),
            "ios_tasks": len([t for t in self.tasks.values() if t.platform in ["ios", "both"]]),
            "android_tasks": len([t for t in self.tasks.values() if t.platform in ["android", "both"]]),
            "average_completion_time": self.calculate_average_completion_time(),
            "sprint_velocity": self.calculate_sprint_velocity()
        }
        
        # Save metrics
        os.makedirs("reports/metrics", exist_ok=True)
        date_str = datetime.now().strftime("%Y%m%d")
        with open(f"reports/metrics/metrics_{date_str}.json", 'w') as f:
            json.dump(metrics, f, indent=2)
        
        logger.info("Project metrics updated")
    
    def calculate_average_completion_time(self) -> float:
        """Calculate average task completion time in hours"""
        completed_tasks = [
            task for task in self.tasks.values()
            if task.status == TaskStatus.COMPLETED
        ]
        
        if not completed_tasks:
            return 0
        
        total_hours = sum(task.estimated_hours for task in completed_tasks)
        return round(total_hours / len(completed_tasks), 1)
    
    def calculate_sprint_velocity(self) -> float:
        """Calculate sprint velocity (story points per sprint)"""
        # This would need historical sprint data
        # For now, return estimated velocity
        return 40.0


async def main():
    """Main entry point for the project manager agent"""
    # Load API key from environment or config
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        logger.error("ANTHROPIC_API_KEY not found in environment variables")
        return
    
    # Initialize agent
    agent = ProjectManagerAgent(api_key)
    
    # Run daily automation
    await agent.run_daily_automation()
    
    # Generate sprint plan
    sprint_plan = await agent.generate_sprint_plan()
    logger.info(f"Sprint plan generated: {sprint_plan['sprint_number']}")
    
    # Check feature parity
    parity_report = await agent.check_feature_parity()
    logger.info("Feature parity check completed")
    
    # Suggest next tasks
    suggestions = await agent.suggest_next_tasks("Focus on improving Android app features")
    logger.info(f"Generated {len(suggestions)} task suggestions")


if __name__ == "__main__":
    asyncio.run(main())