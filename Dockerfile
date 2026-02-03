# ============================================================================
# OpenClaw Production-Ready Multi-Stage Dockerfile
# ============================================================================
# Features:
# - Multi-stage build for minimal image size
# - Configurable via environment variables
# - Security-hardened (non-root user, minimal packages)
# - Health checks and monitoring support
# - Development and production modes
# ============================================================================

# ============================================================================
# Stage 1: Base Image with Dependencies
# ============================================================================
FROM node:22-bookworm-slim AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    procps \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Bun (required for OpenClaw build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Enable pnpm via corepack
RUN corepack enable

WORKDIR /build

# ============================================================================
# Stage 2: Dependencies Installation
# ============================================================================
FROM base AS deps

# Copy package manifests for dependency caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/
COPY scripts ./scripts

# Install all dependencies (including dev dependencies for build)
RUN pnpm install --frozen-lockfile

# ============================================================================
# Stage 3: Build
# ============================================================================
FROM deps AS builder

# Copy source code
COPY . .

# Build OpenClaw
RUN pnpm build

# Build UI
RUN pnpm ui:install
RUN pnpm ui:build

# ============================================================================
# Stage 4: Production Runtime
# ============================================================================
FROM node:22-bookworm-slim AS runtime

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    procps \
    tini \
    # Optional: Chromium for browser automation
    # chromium \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r openclaw && useradd -r -g openclaw -u 1000 openclaw

# Enable pnpm
RUN corepack enable

WORKDIR /app

# Copy built application from builder
COPY --from=builder --chown=openclaw:openclaw /build/dist ./dist
COPY --from=builder --chown=openclaw:openclaw /build/node_modules ./node_modules
COPY --from=builder --chown=openclaw:openclaw /build/package.json ./
COPY --from=builder --chown=openclaw:openclaw /build/ui ./ui

# Create necessary directories
RUN mkdir -p /home/openclaw/.openclaw /home/openclaw/.openclaw/workspace && \
    chown -R openclaw:openclaw /home/openclaw

# Switch to non-root user
USER openclaw

# Environment variables with defaults
ENV NODE_ENV=production \
    OPENCLAW_HOME=/home/openclaw/.openclaw \
    OPENCLAW_WORKSPACE=/home/openclaw/.openclaw/workspace \
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

# Default command
CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured"]

# ============================================================================
# Stage 5: Development Image (with dev tools)
# ============================================================================
FROM runtime AS development

USER root

# Install development tools
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    less \
    htop \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

USER openclaw

# Override command for development
CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured", "--verbose"]

# ============================================================================
# Stage 6: Sandbox Image (minimal for agent isolation)
# ============================================================================
FROM debian:bookworm-slim AS sandbox

RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    bash \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# Create sandbox user
RUN groupadd -r sandbox && useradd -r -g sandbox -u 1000 sandbox

WORKDIR /workspace

USER sandbox

# Sandbox-specific environment
ENV LANG=C.UTF-8

CMD ["/bin/bash"]
