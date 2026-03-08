# Verify Deployment

Check that the deployed environment is healthy.

## Steps

1. `ssh ec2-user@ai-env 'docker compose -f /opt/ai-env/docker/docker-compose.yml ps'` — check container status
2. `ssh ec2-user@ai-env 'curl -s http://localhost:4000/health'` — LiteLLM health check
3. `ssh ec2-user@ai-env 'curl -s http://localhost:18789'` — OpenClaw gateway check
4. `ssh ec2-user@ai-env 'curl -s http://localhost:8080'` — Open WebUI check

## Notes

- Requires Tailscale connection to ai-env
- SSM Session Manager is available as backup: `aws ssm start-session --target <instance-id>`
