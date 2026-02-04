# Deploy OpenClaw - Additional Scripts

## deploy.sh - Production Deployment
#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Deploying OpenClaw to production..."

# Pull latest
git pull origin main

# Build images
docker compose build --no-cache

# Stop existing services
docker compose down

# Start services
docker compose up -d

# Wait for health
echo "⏳ Waiting for services to be healthy..."
sleep 15

# Check status
docker compose ps

echo "✅ Deployment complete!"
docker compose logs --tail=50 openclaw-gateway
