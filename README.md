# AWS AI Environment

Sandbox environment for experimenting with AI infrastructure on AWS. A single EC2 instance runs containerized AI services that route to AWS Bedrock foundation models, with built-in cost controls via LiteLLM.

## Key Features

- **Cost controls** — LiteLLM enforces a configurable budget cap ($75/30 days default) across all model usage
- **Multi-model access** — Claude, Nova, and other Bedrock models through a single proxy
- **Zero-trust networking** — No inbound security group rules; all access via Tailscale

## Architecture Components

- **[LiteLLM](https://docs.litellm.ai/)** — OpenAI-compatible proxy that routes requests to 100+ LLM providers. Handles model routing, budget limits, and usage tracking. All services call Bedrock through LiteLLM rather than directly.
- **[Open WebUI](https://docs.openwebui.com/)** — Web-based chat interface for interacting with models via LiteLLM.
- **[OpenClaw](https://docs.openclaw.ai/)** — AI agent gateway (runs externally on a Mac Mini, connects to LiteLLM over Tailscale).

## Infrastructure

- **Compute**: EC2 t4g.medium (ARM64/Graviton) running Docker Compose
- **Models**: AWS Bedrock (Claude Sonnet, Claude Haiku, Nova Lite, Nova Pro)
- **Access**: Tailscale SSH + SSM Session Manager (backup)
- **IaC**: Terraform

## Deployment

1. Create `terraform/terraform.tfvars` with `tailscale_auth_key` and `github_repo_url`
2. `cd terraform && terraform init && terraform plan && terraform apply`
3. Access services via Tailscale: `http://ai-env:3000` (WebUI), `http://ai-env:4000` (LiteLLM)
