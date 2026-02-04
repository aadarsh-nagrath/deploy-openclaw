# ============================================================================
# OpenClaw Production Docker Image - NPM Install
# ============================================================================
# This Dockerfile installs OpenClaw from npm and creates a production-ready
# container for deployment.
# ============================================================================

FROM node:22-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    procps \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Enable pnpm
RUN corepack enable

# Install OpenClaw globally as root
RUN npm install -g openclaw@latest

# Create directories
RUN mkdir -p /home/node/.openclaw /home/node/.openclaw/workspace && \
    chown -R node:node /home/node

# Switch to non-root user
USER node

WORKDIR /home/node

# Environment variables with defaults
ENV NODE_ENV=production \
    OPENCLAW_HOME=/home/node/.openclaw \
    OPENCLAW_WORKSPACE=/home/node/.openclaw/workspace \
    OPENCLAW_PORT=18789 \
    OPENCLAW_CANVAS_PORT=18793 \
    OPENCLAW_BIND=lan

# Expose ports
EXPOSE 18789 18793

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:${OPENCLAW_PORT}/health || exit 1

# Use tini for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

# Default command - start gateway
CMD ["openclaw", "gateway", "--allow-unconfigured"]
