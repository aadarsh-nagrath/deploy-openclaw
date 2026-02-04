#!/usr/bin/env bash
# ============================================================================
# OpenClaw Docker Setup Script
# ============================================================================
# Automated setup for OpenClaw in Docker
# Usage: ./setup.sh [options]
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# ============================================================================
# Prerequisites Check
# ============================================================================

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker Desktop or Docker Engine."
        exit 1
    fi
    log_success "Docker found: $(docker --version)"
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose v2 is not installed."
        exit 1
    fi
    log_success "Docker Compose found: $(docker compose version)"
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    log_success "Docker daemon is running"
}

# ============================================================================
# Environment Setup
# ============================================================================

setup_environment() {
    log_info "Setting up environment..."
    
    if [ ! -f .env ]; then
        log_info "Creating .env from template..."
        cp .env.template .env
        
        # Generate secure gateway token
        if command -v openssl &> /dev/null; then
            GATEWAY_TOKEN=$(openssl rand -hex 32)
            sed -i.bak "s/<generate-with-openssl-rand>/$GATEWAY_TOKEN/" .env
            rm .env.bak 2>/dev/null || true
            log_success "Generated secure gateway token"
        else
            log_warn "openssl not found. Please manually set OPENCLAW_GATEWAY_TOKEN in .env"
        fi
        
        log_warn "Please edit .env and add your API keys and tokens"
        
        # Prompt user to edit .env
        read -p "Press Enter to continue after editing .env (Ctrl+C to exit)..."
    else
        log_success ".env file already exists"
    fi
}

# ============================================================================
# Docker Build
# ============================================================================

build_images() {
    log_info "Building Docker images..."
    
    # Build production image
    docker compose build openclaw-gateway
    log_success "Built openclaw-gateway image"
    
    # Build sandbox image if needed
    if [ -f "Dockerfile.sandbox" ]; then
        docker build -t openclaw-sandbox:latest -f Dockerfile.sandbox .
        log_success "Built openclaw-sandbox image"
    fi
}

# ============================================================================
# Initialize Configuration
# ============================================================================

init_config() {
    log_info "Initializing OpenClaw configuration..."
    
    # Run onboarding wizard
    docker compose run --rm openclaw-cli onboard
    
    log_success "Configuration initialized"
}

# ============================================================================
# Start Services
# ============================================================================

start_services() {
    log_info "Starting OpenClaw services..."
    
    docker compose up -d openclaw-gateway redis
    
    log_success "Services started"
    
    # Wait for health check
    log_info "Waiting for services to be healthy..."
    sleep 10
    
    # Check status
    docker compose ps
}

# ============================================================================
# Post-Setup Instructions
# ============================================================================

show_info() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║             OpenClaw Docker Setup Complete! 🦞                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    log_success "OpenClaw Gateway is running!"
    echo ""
    echo "📊 Access the Control UI:"
    echo "   http://localhost:18789"
    echo ""
    echo "🔑 Gateway Token (from .env):"
    grep "OPENCLAW_GATEWAY_TOKEN=" .env | cut -d '=' -f2
    echo ""
    echo "📝 Common Commands:"
    echo "   Start services:    docker compose up -d"
    echo "   Stop services:     docker compose down"
    echo "   View logs:         docker compose logs -f"
    echo "   CLI access:        docker compose run --rm openclaw-cli <command>"
    echo "   Status:            docker compose ps"
    echo ""
    echo "🔧 Setup Channels:"
    echo "   WhatsApp:  docker compose run --rm openclaw-cli channels login"
    echo "   Telegram:  Add TELEGRAM_BOT_TOKEN to .env and restart"
    echo "   Discord:   Add DISCORD_BOT_TOKEN to .env and restart"
    echo ""
    echo "📚 Documentation: https://docs.openclaw.ai"
    echo ""
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          OpenClaw Docker Setup Script                         ║"
    echo "║          Production-Ready Container Deployment                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_prerequisites
    setup_environment
    build_images
    
    # Ask if user wants to run init
    read -p "Run configuration wizard? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        init_config
    fi
    
    start_services
    show_info
}

# Run main function
main "$@"
