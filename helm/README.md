# OpenClaw Helm Chart

Helm chart for deploying OpenClaw AI agent gateway on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support (if persistence enabled)

## Installation

```bash
# Add values file with your configuration
helm install openclaw ./helm -f my-values.yaml

# Or with inline values
helm install openclaw ./helm \
  --set secrets.anthropicApiKey=sk-xxx \
  --set secrets.telegramBotToken=xxx
```

## Configuration

See `values.yaml` for all available options.

### Key Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Image repository | `aadarshnagrath/openclaw-server` |
| `image.tag` | Image tag | `latest` |
| `openclaw.agent.model` | Default AI model | `claude-sonnet-4` |
| `openclaw.gateway.port` | Gateway port | `18789` |
| `secrets.anthropicApiKey` | Anthropic API key | `""` |
| `secrets.telegramBotToken` | Telegram bot token | `""` |
| `persistence.enabled` | Enable persistence | `true` |

## Upgrading

```bash
helm upgrade openclaw ./helm -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall openclaw
```
