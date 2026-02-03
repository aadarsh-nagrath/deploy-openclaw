#!/usr/bin/env bash
# Restore script for OpenClaw Docker volumes

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <timestamp>"
    echo "Example: $0 20240101_120000"
    exit 1
fi

TIMESTAMP=$1
BACKUP_DIR="${BACKUP_DIR:-./backups}"

echo "📥 Restoring OpenClaw from backup $TIMESTAMP..."

# Stop services
echo "Stopping services..."
docker compose down

# Restore config
if [ -f "$BACKUP_DIR/openclaw-config-$TIMESTAMP.tar.gz" ]; then
    echo "Restoring config..."
    docker run --rm \
      -v openclaw-config:/target \
      -v "$PWD/$BACKUP_DIR":/backup \
      alpine sh -c "cd /target && tar xzf /backup/openclaw-config-$TIMESTAMP.tar.gz"
fi

# Restore workspace
if [ -f "$BACKUP_DIR/openclaw-workspace-$TIMESTAMP.tar.gz" ]; then
    echo "Restoring workspace..."
    docker run --rm \
      -v openclaw-workspace:/target \
      -v "$PWD/$BACKUP_DIR":/backup \
      alpine sh -c "cd /target && tar xzf /backup/openclaw-workspace-$TIMESTAMP.tar.gz"
fi

# Restore redis
if [ -f "$BACKUP_DIR/openclaw-redis-$TIMESTAMP.tar.gz" ]; then
    echo "Restoring redis..."
    docker run --rm \
      -v openclaw-redis:/target \
      -v "$PWD/$BACKUP_DIR":/backup \
      alpine sh -c "cd /target && tar xzf /backup/openclaw-redis-$TIMESTAMP.tar.gz"
fi

# Restore .env
if [ -f "$BACKUP_DIR/.env-$TIMESTAMP" ]; then
    echo "Restoring environment..."
    cp "$BACKUP_DIR/.env-$TIMESTAMP" .env
fi

# Restart services
echo "Starting services..."
docker compose up -d

echo "✅ Restore complete!"
docker compose ps
