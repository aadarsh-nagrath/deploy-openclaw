# OpenClaw Helm Chart

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 2026.2.1](https://img.shields.io/badge/AppVersion-2026.2.1-informational?style=flat-square)

Helm chart for deploying OpenClaw AI agent gateway on Kubernetes.

## Features

- 🚀 Production-ready Kubernetes deployment
- 🔧 Highly configurable via values.yaml
- 🔒 Secrets management (native + external-secrets support)
- 📊 Prometheus metrics & ServiceMonitor
- 🔄 HPA & VPA autoscaling
- 🛡️ Network policies
- 💾 Persistent storage for config, workspace, sessions
- 🔗 Redis integration (optional)
- 🌐 Ingress with TLS support
- 📦 Multi-channel support (Telegram, Discord, Slack, WhatsApp)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner (if persistence enabled)

## Installation

### Quick Start

```bash
# Add your values
cat > my-values.yaml <<EOF
secrets:
  anthropicApiKey: "sk-ant-xxx"
  telegramBotToken: "123:ABC..."
  gatewayToken: "$(openssl rand -hex 32)"

openclaw:
  agent:
    model: "claude-sonnet-4"
  channels:
    telegram:
      enabled: true
EOF

# Install
helm install openclaw ./helm -f my-values.yaml
```

### With Ingress

```bash
helm install openclaw ./helm \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=openclaw.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix \
  --set ingress.tls[0].secretName=openclaw-tls \
  --set ingress.tls[0].hosts[0]=openclaw.example.com
```

### With External Secrets

```yaml
externalSecrets:
  enabled: true
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  data:
    - secretKey: anthropic-api-key
      remoteRef:
        key: openclaw/production
        property: anthropic-api-key
```

## Configuration

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `aadarshnagrath/openclaw-server` |
| `image.tag` | Image tag | `latest` |
| `openclaw.agent.model` | Default AI model | `claude-sonnet-4` |
| `openclaw.gateway.port` | Gateway port | `18789` |
| `openclaw.sandbox.mode` | Sandbox mode | `non-main` |
| `persistence.enabled` | Enable persistence | `true` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `metrics.enabled` | Enable Prometheus metrics | `false` |

### Secrets

| Parameter | Description |
|-----------|-------------|
| `secrets.gatewayToken` | Gateway authentication token |
| `secrets.anthropicApiKey` | Anthropic (Claude) API key |
| `secrets.openaiApiKey` | OpenAI API key |
| `secrets.googleApiKey` | Google API key |
| `secrets.telegramBotToken` | Telegram bot token |
| `secrets.discordBotToken` | Discord bot token |
| `secrets.slackBotToken` | Slack bot token |
| `secrets.slackAppToken` | Slack app token |

### Channel Configuration

```yaml
openclaw:
  channels:
    telegram:
      enabled: true
      dmPolicy: "pairing"
      groupPolicy: "allowlist"
    discord:
      enabled: true
    slack:
      enabled: true
      mode: "socket"
```

### Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
```

### Monitoring

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
```

## Upgrading

```bash
helm upgrade openclaw ./helm -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall openclaw
```

## Troubleshooting

### Pod not starting

```bash
kubectl logs -l app.kubernetes.io/name=openclaw
kubectl describe pod -l app.kubernetes.io/name=openclaw
```

### Check secrets

```bash
kubectl get secret openclaw-secrets -o yaml
```

### Validate chart

```bash
helm template openclaw ./helm -f my-values.yaml --debug
```

## Examples

### Production Setup

```yaml
replicaCount: 3

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 1000m
    memory: 2Gi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10

podDisruptionBudget:
  enabled: true
  minAvailable: 2

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: openclaw
          topologyKey: kubernetes.io/hostname

persistence:
  config:
    size: 5Gi
  workspace:
    size: 20Gi
  sessions:
    enabled: true
    size: 10Gi
```

### Development Setup

```yaml
replicaCount: 1

resources:
  limits:
    cpu: 500m
    memory: 512Mi

openclaw:
  logLevel: debug

persistence:
  config:
    size: 1Gi
  workspace:
    size: 2Gi
```

## License

MIT
