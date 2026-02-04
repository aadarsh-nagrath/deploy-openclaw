# Deploy OpenClaw 🦞

**Production-ready deployment solutions for OpenClaw AI agent gateway**

[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](./docker)
[![Helm](https://img.shields.io/badge/helm-ready-purple.svg)](./helm)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

This repository provides multiple deployment options for [OpenClaw](https://github.com/openclaw/openclaw), the AI agent gateway that bridges WhatsApp, Telegram, Discord, Slack, and iMessage.

## Deployment Options

### 🐳 [Docker](./docker)

Docker Compose deployment for single-server setups.

**Features:**
- Multi-stage Dockerfile
- Docker Compose with all services
- Automated setup script
- Backup/restore utilities
- Development and production modes

**Quick Start:**
```bash
cd docker
./setup.sh
```

[Read Docker Documentation →](./docker/DOCKER_README.md)

---

### ⎈ [Helm](./helm)

Kubernetes deployment using Helm charts.

**Features:**
- Production-ready Helm chart
- Configurable via values.yaml
- Persistent storage support
- Secrets management
- Health checks and probes
- Horizontal scaling support

**Quick Start:**
```bash
helm install openclaw ./helm -f my-values.yaml
```

[Read Helm Documentation →](./helm/README.md)

---

## Which Should I Use?

| Use Case | Recommendation |
|----------|----------------|
| Single VPS/server | Docker |
| Local development | Docker |
| Kubernetes cluster | Helm |
| Cloud-native deployment | Helm |
| Quick testing | Docker |
| Production at scale | Helm |

## Requirements

### Docker
- Docker Engine 20.10+
- Docker Compose v2
- 2GB+ RAM
- 10GB+ disk space

### Helm
- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner (for persistence)

## Configuration

Both deployment methods support full configuration of:

- **AI Providers**: Anthropic, OpenAI, Google
- **Channels**: WhatsApp, Telegram, Discord, Slack, iMessage
- **Security**: Sandbox mode, tool restrictions
- **Performance**: Concurrency limits, resource allocation
- **Persistence**: Config and workspace volumes

## Resources

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Docker Hub Image](https://hub.docker.com/r/aadarshnagrath/openclaw-server)

## Contributing

Contributions welcome! Please submit issues and pull requests.

## License

MIT License - see [LICENSE](LICENSE) file

---

**Made with 🦞 by the OpenClaw community**
