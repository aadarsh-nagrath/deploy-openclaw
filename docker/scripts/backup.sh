#!/usr/bin/env bash
# Backup script for OpenClaw Docker volumes

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "📦 Starting OpenClaw backup..."

mkdir -p "$BACKUP_DIR"

# Backup config volume
echo "Backing up config..."
docker run --rm \
  -v openclaw-config:/source:ro \
  -v "$PWD/$BACKUP_DIR":/backup \
  alpine tar czf "/backup/openclaw-config-$TIMESTAMP.tar.gz" -C /source .

# Backup workspace volume
echo "Backing up workspace..."
docker run --rm \
  -v openclaw-workspace:/source:ro \
  -v "$PWD/$BACKUP_DIR":/backup \
  alpine tar czf "/backup/openclaw-workspace-$TIMESTAMP.tar.gz" -C /source .

# Backup redis data
echo "Backing up redis..."
docker run --rm \
  -v openclaw-redis:/source:ro \
  -v "$PWD/$BACKUP_DIR":/backup \
  alpine tar czf "/backup/openclaw-redis-$TIMESTAMP.tar.gz" -C /source .

# Backup .env
echo "Backing up environment..."
cp .env "$BACKUP_DIR/.env-$TIMESTAMP"

echo "✅ Backup complete!"
echo "📁 Files saved to: $BACKUP_DIR"
ls -lh "$BACKUP_DIR"/*-$TIMESTAMP*
