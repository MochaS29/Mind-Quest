# Docker Setup for MindQuest Platform

## Overview

This Docker setup provides a complete containerized environment for the MindQuest platform, including:
- React Native/Expo development server
- Android build environment
- AI Project Manager Agent
- PostgreSQL database
- Redis cache
- Nginx reverse proxy
- Monitoring with Grafana and Prometheus

## Prerequisites

- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- Docker Compose v2.0+
- At least 8GB RAM allocated to Docker
- 20GB free disk space

## Quick Start

### 1. Clone and Setup

```bash
cd /Users/mocha
cp .env.docker .env
# Edit .env and add your API keys
```

### 2. Start Development Environment

```bash
# Start all services
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Or use the helper script
./docker/scripts/start-dev.sh
```

### 3. Access Services

- **React Native App**: http://localhost:19000
- **Expo DevTools**: http://localhost:19002
- **API Gateway**: http://localhost:3000
- **Grafana Dashboard**: http://localhost:3001 (admin/admin)
- **Adminer (DB Admin)**: http://localhost:8080
- **Mailhog (Email Testing)**: http://localhost:8025

## Service Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Nginx (Port 80/443)                  │
└─────────────┬───────────────────────┬───────────────────┘
              │                       │
    ┌─────────▼──────────┐  ┌────────▼──────────┐
    │  React Native Dev  │  │   API Gateway     │
    │    (Port 19000)    │  │   (Port 3000)     │
    └────────────────────┘  └─────────┬─────────┘
                                      │
                ┌─────────────────────┼─────────────────────┐
                │                     │                     │
      ┌─────────▼────────┐  ┌────────▼────────┐  ┌─────────▼────────┐
      │  PM Agent        │  │   PostgreSQL    │  │     Redis        │
      │  (Python)        │  │   (Port 5432)   │  │   (Port 6379)    │
      └──────────────────┘  └─────────────────┘  └──────────────────┘
```

## Services

### Project Manager Agent

AI-powered project management using Claude API.

```bash
# Run specific commands
docker-compose exec pm-agent python scripts/run_agent.py standup
docker-compose exec pm-agent python scripts/run_agent.py sprint-plan
docker-compose exec pm-agent python scripts/run_agent.py analyze --platform both
```

### React Native Development

Expo-based React Native app with hot reloading.

```bash
# View logs
docker-compose logs -f react-native-dev

# Access shell
docker-compose exec react-native-dev bash

# Install new packages
docker-compose exec react-native-dev npm install package-name
```

### Android Build Environment

Automated Android APK building.

```bash
# Build APK
docker-compose run android-build ./gradlew assembleDebug

# Build release APK
docker-compose run android-build ./gradlew assembleRelease
```

### Database Management

PostgreSQL with Adminer GUI.

```bash
# Access database CLI
docker-compose exec postgres psql -U mindquest -d mindquest

# Backup database
docker-compose exec postgres pg_dump -U mindquest mindquest > backup.sql

# Restore database
docker-compose exec -T postgres psql -U mindquest mindquest < backup.sql
```

## Development Workflow

### 1. Initial Setup

```bash
# Build all images
docker-compose build

# Initialize database
docker-compose up -d postgres
docker-compose exec postgres psql -U mindquest -d mindquest -f /docker-entrypoint-initdb.d/init.sql

# Start all services
docker-compose up -d
```

### 2. Daily Development

```bash
# Start services
./docker/scripts/start-dev.sh

# Watch logs
docker-compose logs -f [service-name]

# Stop services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

### 3. Running Tests

```bash
# React Native tests
docker-compose exec react-native-dev npm test

# Android tests
docker-compose run android-build ./gradlew test

# PM Agent tests
docker-compose exec pm-agent pytest tests/
```

## Production Deployment

### 1. Build Production Images

```bash
# Build production images
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
```

### 2. Deploy with SSL

```bash
# Start production services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Setup SSL with Let's Encrypt
./docker/scripts/setup-ssl.sh your-domain.com
```

### 3. Scaling

```bash
# Scale React Native web servers
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale react-native-prod=3
```

## Monitoring

### Grafana Dashboards

1. Access Grafana at http://localhost:3001
2. Login with admin/admin
3. Import dashboards from `docker/grafana/dashboards/`

### Prometheus Metrics

- Access at http://localhost:9090
- Metrics endpoints:
  - `/metrics` - Application metrics
  - `/api/metrics` - API metrics

### Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs -f pm-agent

# Export logs
docker-compose logs > logs.txt
```

## Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Find process using port
lsof -i :19000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
```

#### 2. Out of Memory
```bash
# Increase Docker memory in Docker Desktop settings
# Or add resource limits in docker-compose.yml
```

#### 3. Permission Denied
```bash
# Fix permissions
sudo chown -R $USER:$USER .

# Or run with sudo (not recommended)
sudo docker-compose up
```

#### 4. Container Won't Start
```bash
# Check logs
docker-compose logs [service-name]

# Rebuild image
docker-compose build --no-cache [service-name]

# Remove and restart
docker-compose rm -f [service-name]
docker-compose up -d [service-name]
```

### Reset Everything

```bash
# Stop all containers
docker-compose down

# Remove all volumes
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Clean Docker system
docker system prune -a
```

## Helper Scripts

### Start Development
```bash
#!/bin/bash
# docker/scripts/start-dev.sh
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
docker-compose logs -f
```

### Build Android APK
```bash
#!/bin/bash
# docker/scripts/build-android.sh
docker-compose run android-build ./gradlew assembleDebug
echo "APK available at: MindLabsQuestAndroid/app/build/outputs/apk/debug/"
```

### Backup Database
```bash
#!/bin/bash
# docker/scripts/backup-db.sh
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec postgres pg_dump -U mindquest mindquest > backups/backup_$DATE.sql
echo "Backup saved to backups/backup_$DATE.sql"
```

### Update Dependencies
```bash
#!/bin/bash
# docker/scripts/update-deps.sh
docker-compose exec react-native-dev npm update
docker-compose exec pm-agent pip install --upgrade -r requirements.txt
docker-compose run android-build ./gradlew dependencies --refresh-dependencies
```

## Environment Variables

### Required
- `ANTHROPIC_API_KEY` - Claude API key for PM Agent
- `GITHUB_TOKEN` - GitHub access token

### Optional
- `DB_PASSWORD` - PostgreSQL password (default: mindquest123)
- `REDIS_PASSWORD` - Redis password (empty by default)
- `GRAFANA_PASSWORD` - Grafana admin password (default: admin)
- `NODE_ENV` - Node environment (development/production)

## Security Considerations

### Production Checklist
- [ ] Change all default passwords
- [ ] Enable SSL/TLS
- [ ] Set up firewall rules
- [ ] Enable Redis password
- [ ] Rotate API keys regularly
- [ ] Set up backup automation
- [ ] Monitor resource usage
- [ ] Enable log rotation
- [ ] Set up health checks
- [ ] Configure rate limiting

### Secrets Management

```bash
# Create secrets directory
mkdir -p docker/secrets

# Store secrets
echo "your-password" > docker/secrets/db_password.txt
chmod 600 docker/secrets/*

# Use in docker-compose.prod.yml
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/docker.yml
name: Docker CI

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build images
        run: docker-compose build
      - name: Run tests
        run: docker-compose run pm-agent pytest
```

### Deployment Pipeline

1. Push to GitHub
2. GitHub Actions builds images
3. Push images to registry
4. Deploy to production server
5. Run health checks

## Performance Tuning

### Docker Settings
```yaml
# Optimize build cache
DOCKER_BUILDKIT=1

# Limit resources
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```

### Database Optimization
```sql
-- Add indexes
CREATE INDEX idx_quests_user_id ON quests(user_id);
CREATE INDEX idx_characters_user_id ON characters(user_id);
```

## Backup and Recovery

### Automated Backups
```bash
# Setup cron job
0 2 * * * /Users/mocha/docker/scripts/backup-db.sh
```

### Disaster Recovery
1. Stop services: `docker-compose down`
2. Restore database: `./docker/scripts/restore-db.sh backup.sql`
3. Restart services: `docker-compose up -d`

## Support

### Logs Location
- Container logs: `docker-compose logs`
- App logs: `./logs/`
- Nginx logs: `/var/log/nginx/`

### Debug Mode
```bash
# Enable debug logging
export DEBUG=true
docker-compose up
```

### Getting Help
1. Check logs: `docker-compose logs [service]`
2. Check documentation: This file and service-specific docs
3. GitHub Issues: Report bugs and request features

---

## Quick Commands Reference

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild service
docker-compose build [service]

# Execute command in container
docker-compose exec [service] [command]

# Scale service
docker-compose up -d --scale [service]=3

# Clean everything
docker-compose down -v --rmi all
```

Ready to develop with Docker! 🐳