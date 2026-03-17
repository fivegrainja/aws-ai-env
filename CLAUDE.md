# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AWS environment for AI experimentation. Terraform provisions a single EC2 t4g.medium (ARM64) in us-east-1 running Docker Compose services, accessed exclusively via Tailscale (no public ingress).

## Architecture

- **Networking**: Public subnet with NO inbound security group rules. Public IP for outbound internet only. All access via Tailscale.
- **Services**: LiteLLM (proxy) → Bedrock. Open WebUI as frontend. OpenClaw runs on a separate Mac Mini via Tailscale.
- **IaC split**: Terraform manages AWS infrastructure. Docker Compose managed separately on the instance, cloned from GitHub by userdata at first boot to /opt/ai-env.

## Constraints

- Notify me anytime a change would significantly increase cost, decrease security, or increase management overhead.
- Do not edit files until I specifically ask you to make a change. When I ask for information about a potential change, provide analysis only.
- Never add inbound security group rules — all access is via Tailscale.
- Never commit terraform.tfvars, .env, or tfstate files (see .gitignore).
- Coach me on best practices for using Claude Code as we go — I am new to it.
