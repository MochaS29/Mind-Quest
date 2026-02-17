#!/usr/bin/env python3
"""
MindQuest Project Manager Agent - CLI Runner
Provides command-line interface for agent operations
"""

import click
import asyncio
import os
import sys
from pathlib import Path
from dotenv import load_dotenv

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.project_manager import ProjectManagerAgent, TaskPriority, TaskStatus

# Load environment variables
load_dotenv()


@click.group()
@click.pass_context
def cli(ctx):
    """MindQuest Project Manager Agent CLI"""
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        click.echo("Error: ANTHROPIC_API_KEY not found in environment variables", err=True)
        sys.exit(1)
    
    ctx.obj = ProjectManagerAgent(api_key)


@cli.command()
@click.pass_obj
def standup(agent):
    """Generate daily standup report"""
    async def run():
        report = await agent.generate_daily_standup()
        click.echo(report)
    
    asyncio.run(run())


@cli.command()
@click.pass_obj
def sprint_plan(agent):
    """Generate sprint plan"""
    async def run():
        plan = await agent.generate_sprint_plan()
        click.echo(f"Sprint {plan['sprint_number']} Plan Generated")
        click.echo(f"Duration: {plan['start_date']} to {plan['end_date']}")
        click.echo(f"Capacity: {plan['capacity_hours']} hours")
        click.echo(f"Utilization: {plan['utilization']:.1f}%")
        click.echo("\nGoals:")
        for goal in plan['goals']:
            click.echo(f"  - {goal}")
    
    asyncio.run(run())


@cli.command()
@click.option('--platform', default='both', help='Platform to analyze (ios/android/both)')
@click.pass_obj
def analyze(agent, platform):
    """Analyze codebase for issues and improvements"""
    async def run():
        click.echo(f"Analyzing {platform} codebase...")
        analysis = await agent.analyze_codebase(platform)
        click.echo("Analysis complete. Report saved to reports/")
        if 'ai_insights' in analysis:
            click.echo("\nKey Insights:")
            click.echo(analysis['ai_insights'][:500] + "...")
    
    asyncio.run(run())


@cli.command()
@click.pass_obj
def parity(agent):
    """Check feature parity between platforms"""
    async def run():
        click.echo("Checking feature parity between iOS and Android...")
        report = await agent.check_feature_parity()
        click.echo("Parity check complete. Report saved to reports/")
        if 'analysis' in report:
            click.echo("\nAnalysis:")
            click.echo(report['analysis'][:500] + "...")
    
    asyncio.run(run())


@cli.command()
@click.argument('title')
@click.argument('description')
@click.option('--platform', default='both', help='Platform (ios/android/both)')
@click.option('--priority', default='medium', help='Priority (low/medium/high/critical)')
@click.option('--hours', default=4.0, help='Estimated hours')
@click.pass_obj
def create_task(agent, title, description, platform, priority, hours):
    """Create a new task"""
    task = agent.create_task(
        title=title,
        description=description,
        platform=platform,
        priority=TaskPriority(priority),
        estimated_hours=hours
    )
    click.echo(f"Task created: {task.id} - {task.title}")


@cli.command()
@click.pass_obj
def list_tasks(agent):
    """List all tasks"""
    if not agent.tasks:
        click.echo("No tasks found")
        return
    
    click.echo("\nTasks:")
    for task in agent.tasks.values():
        status_emoji = {
            TaskStatus.TODO: "📝",
            TaskStatus.IN_PROGRESS: "🔄",
            TaskStatus.REVIEW: "👀",
            TaskStatus.COMPLETED: "✅",
            TaskStatus.BLOCKED: "🚫"
        }
        
        priority_color = {
            TaskPriority.CRITICAL: "red",
            TaskPriority.HIGH: "yellow",
            TaskPriority.MEDIUM: "blue",
            TaskPriority.LOW: "green"
        }
        
        emoji = status_emoji.get(task.status, "")
        click.echo(
            f"{emoji} [{task.id}] {task.title} "
            f"({click.style(task.priority.value, fg=priority_color[task.priority])}) "
            f"- {task.platform} - {task.estimated_hours}h"
        )


@cli.command()
@click.argument('task_id')
@click.argument('status', type=click.Choice(['todo', 'in_progress', 'review', 'completed', 'blocked']))
@click.pass_obj
def update_status(agent, task_id, status):
    """Update task status"""
    agent.update_task_status(task_id, TaskStatus(status))
    click.echo(f"Task {task_id} status updated to {status}")


@cli.command()
@click.option('--context', default='', help='Additional context for suggestions')
@click.pass_obj
def suggest(agent, context):
    """Get AI-powered task suggestions"""
    async def run():
        click.echo("Generating task suggestions...")
        suggestions = await agent.suggest_next_tasks(context)
        click.echo(f"\nGenerated {len(suggestions)} suggestions:")
        for task in suggestions:
            click.echo(f"  - {task.title}: {task.description[:100]}...")
    
    asyncio.run(run())


@cli.command()
@click.pass_obj
def daily(agent):
    """Run daily automation tasks"""
    async def run():
        click.echo("Running daily automation...")
        await agent.run_daily_automation()
        click.echo("Daily automation complete!")
    
    asyncio.run(run())


@cli.command()
@click.pass_obj
def metrics(agent):
    """Display project metrics"""
    click.echo("\nProject Metrics:")
    click.echo(f"Total Tasks: {len(agent.tasks)}")
    
    completed = len([t for t in agent.tasks.values() if t.status == TaskStatus.COMPLETED])
    in_progress = len([t for t in agent.tasks.values() if t.status == TaskStatus.IN_PROGRESS])
    blocked = len([t for t in agent.tasks.values() if t.status == TaskStatus.BLOCKED])
    
    click.echo(f"Completed: {completed}")
    click.echo(f"In Progress: {in_progress}")
    click.echo(f"Blocked: {blocked}")
    
    if agent.tasks:
        completion_rate = (completed / len(agent.tasks)) * 100
        click.echo(f"Completion Rate: {completion_rate:.1f}%")
    
    click.echo(f"Average Completion Time: {agent.calculate_average_completion_time()} hours")
    click.echo(f"Sprint Velocity: {agent.calculate_sprint_velocity()} points")


if __name__ == '__main__':
    cli()