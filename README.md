# OpenClaw Docker Deployment 🦞

**Production-ready, highly configurable Docker deployment for OpenClaw**

[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Features

🐳 **Multi-Stage Docker Build** - Optimized for minimal image size and security  
⚙️ **Fully Configurable** - Environment variables for all settings  
🔒 **Security-First** - Non-root user, health checks, sandboxing support  
📦 **Complete Setup** - Docker Compose with all services included  
🚀 **Production Ready** - Restart policies, logging, monitoring  
🛠️ **Development Mode** - Separate dev image with debugging tools  
📚 **Comprehensive Docs** - Detailed guides and examples  

## Quick Start

### Prerequisites

- Docker Desktop (or Docker Engine) + Docker Compose v2
- At least 2GB RAM available
- Ports 18789 and 18793 available

### One-Command Setup

```bash
git clone https://github.com/aadarsh-nagrath/deploy-openclaw.git
cd deploy-openclaw
./setup.sh
```

The setup script will:
1. Check prerequisites
2. Create `.env` from template
3. Generate secure gateway token
4. Build Docker images
5. Initialize configuration
6. Start all services

### Manual Setup

If you prefer manual control:

```bash
# 1. Create environment file
cp .env.template .env

# 2. Edit .env and add your API keys
nano .env

# 3. Build images
docker compose build

# 4. Initialize configuration
docker compose run --rm openclaw-cli onboard

# 5. Start services
docker compose up -d

# 6. Check status
docker compose ps
docker compose logs -f
```

## Architecture

### Services

- **openclaw-gateway** - Main OpenClaw process (Gateway + agent)
- **redis** - Optional cache and session store
- **openclaw-cli** - CLI container for management tasks

### Docker Images

The `Dockerfile` includes 6 build stages:

1. **base** - System dependencies and Bun installation
2. **deps** - Node.js dependency installation
3. **builder** - Application build
4. **runtime** - Production runtime (minimal)
5. **development** - Development image with debug tools
6. **sandbox** - Agent isolation container

### Volumes

- `openclaw-config` - Configuration and state (`~/.openclaw`)
- `openclaw-workspace` - Agent workspace files
- `openclaw-redis` - Redis persistence

## Configuration

### Environment Variables

All configuration is done via `.env` file:

#### Core Settings
```env
OPENCLAW_PORT=18789                    # Gateway WebSocket port
OPENCLAW_CANVAS_PORT=18793             # Canvas HTTP port
OPENCLAW_BIND=lan                      # Bind mode: lan|loopback|tailnet
OPENCLAW_GATEWAY_TOKEN=<secure-token>  # Gateway authentication token
```

#### AI Providers
```env
ANTHROPIC_API_KEY=sk-ant-xxx           # Claude models
OPENAI_API_KEY=sk-xxx                  # GPT models
GOOGLE_API_KEY=AIza...                 # Gemini models
OPENCLAW_AGENT_MODEL=claude-sonnet-4   # Default model
```

#### Messaging Platforms
```env
TELEGRAM_BOT_TOKEN=123:ABC...          # Telegram bot
DISCORD_BOT_TOKEN=MTk...               # Discord bot
SLACK_BOT_TOKEN=xoxb-...               # Slack bot
SLACK_APP_TOKEN=xapp-...               # Slack app token
```

#### Security
```env
OPENCLAW_SANDBOX_MODE=non-main         # off|non-main|all
OPENCLAW_TOOLS_ELEVATED=false          # Elevated tool access
```

#### Performance
```env
OPENCLAW_MAX_CONCURRENT=4              # Max concurrent requests
OPENCLAW_SUBAGENT_MAX_CONCURRENT=8     # Max subagent concurrency
```

### Advanced Configuration

For advanced settings, mount a custom `openclaw.json`:

```yaml
services:
  openclaw-gateway:
    volumes:
      - ./config/openclaw.json:/home/openclaw/.openclaw/openclaw.json:ro
```

## Usage

### Common Commands

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f

# View logs for specific service
docker compose logs -f openclaw-gateway

# Restart gateway
docker compose restart openclaw-gateway

# Check service status
docker compose ps

# Execute CLI command
docker compose run --rm openclaw-cli <command>

# Shell access to running container
docker compose exec openclaw-gateway bash
```

### Channel Setup

#### WhatsApp (QR Code)
```bash
docker compose run --rm openclaw-cli channels login
```

#### Telegram
1. Create bot with @BotFather
2. Add `TELEGRAM_BOT_TOKEN` to `.env`
3. Restart services

#### Discord
1. Create bot in Discord Developer Portal
2. Add `DISCORD_BOT_TOKEN` to `.env`
3. Restart services

#### Slack
1. Create Slack app with Bot and Socket Mode
2. Add `SLACK_BOT_TOKEN` and `SLACK_APP_TOKEN` to `.env`
3. Restart services

### Development Mode

Run with development image and tools:

```bash
docker compose --profile dev up openclaw-dev
```

Features in dev mode:
- Debug logging enabled
- Source code hot-reload (if mounted)
- Additional debugging tools (vim, htop, etc.)
- TTY access for interactive debugging

### CLI Management

```bash
# Check gateway status
docker compose run --rm openclaw-cli status

# List active sessions
docker compose run --rm openclaw-cli sessions list

# Configure channels
docker compose run --rm openclaw-cli channels add --channel telegram

# View dashboard URL with token
docker compose run --rm openclaw-cli dashboard --no-open

# Approve pairing requests
docker compose run --rm openclaw-cli devices list
docker compose run --rm openclaw-cli devices approve <requestId>
```

## Security

### Best Practices

1. **Gateway Token**: Always use a strong random token
   ```bash
   openssl rand -hex 32
   ```

2. **Non-Root User**: Container runs as `openclaw` user (UID 1000)

3. **Network Isolation**: Services communicate via private Docker network

4. **Sandbox Mode**: Enable `OPENCLAW_SANDBOX_MODE=non-main` for untrusted sessions

5. **API Keys**: Use environment variables, never commit to git

6. **Firewall**: Expose only necessary ports (18789, 18793)

### Sandboxing

OpenClaw supports agent sandboxing for tool isolation. See [Docker documentation](https://docs.openclaw.ai/install/docker) for details.

To enable:
```env
OPENCLAW_SANDBOX_MODE=non-main
```

Build sandbox image:
```bash
docker build -t openclaw-sandbox:latest -f Dockerfile.sandbox .
```

## Monitoring

### Health Checks

All services include health checks:

```bash
# Check all services
docker compose ps

# Manual health check
curl http://localhost:18789/health
```

### Logs

```bash
# All logs
docker compose logs -f

# Specific service
docker compose logs -f openclaw-gateway

# Last 100 lines
docker compose logs --tail=100 openclaw-gateway

# Since timestamp
docker compose logs --since="2024-01-01T00:00:00"
```

### Resource Usage

```bash
# Container stats
docker stats openclaw-gateway

# Disk usage
docker system df

# Clean up unused resources
docker system prune -a
```

## Production Deployment

### Recommended Setup

1. **Use Docker Swarm or Kubernetes** for orchestration
2. **External Redis** for high availability
3. **Reverse Proxy** (nginx/Caddy) for SSL termination
4. **Volume Backups** for persistence
5. **Monitoring** (Prometheus/Grafana)
6. **Log Aggregation** (ELK/Loki)

### Example with nginx

```nginx
server {
    listen 443 ssl http2;
    server_name openclaw.yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Scaling

For high traffic:

```yaml
services:
  openclaw-gateway:
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          memory: 2G
```

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Find process using port
lsof -i :18789

# Change port in .env
OPENCLAW_PORT=18790
```

#### Permission Errors
```bash
# Fix volume permissions
sudo chown -R 1000:1000 ~/.openclaw
```

#### Container Won't Start
```bash
# Check logs
docker compose logs openclaw-gateway

# Rebuild image
docker compose build --no-cache openclaw-gateway
```

#### WhatsApp QR Not Showing
```bash
# Ensure TTY allocation
docker compose run --rm openclaw-cli channels login
```

#### Health Check Failing
```bash
# Check gateway logs
docker compose logs openclaw-gateway

# Verify port binding
docker compose ps
netstat -tulpn | grep 18789
```

### Debug Mode

Enable verbose logging:

```env
OPENCLAW_LOG_LEVEL=debug
```

Or run with development image:

```bash
docker compose --profile dev up openclaw-dev
```

## Updates

### Updating OpenClaw

```bash
# Pull latest code
git pull origin main

# Rebuild images
docker compose build --no-cache

# Restart services
docker compose down
docker compose up -d

# Verify version
docker compose run --rm openclaw-cli --version
```

### Rollback

```bash
# Stop services
docker compose down

# Checkout previous version
git checkout <previous-commit>

# Rebuild and restart
docker compose build
docker compose up -d
```

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `docker compose up`
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file

## Resources

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## Support

- **Issues**: [GitHub Issues](https://github.com/aadarsh-nagrath/deploy-openclaw/issues)
- **Discord**: [OpenClaw Community](https://discord.gg/openclaw)
- **Documentation**: [docs.openclaw.ai](https://docs.openclaw.ai)

---

**Made with 🦞 by the OpenClaw community**
