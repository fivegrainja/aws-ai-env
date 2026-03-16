#!/bin/bash
set -euo pipefail
exec > /var/log/userdata.log 2>&1

echo "=== Starting AI env bootstrap ==="

# System updates
dnf update -y

# Install Docker
dnf install -y docker git
systemctl enable docker
systemctl start docker

# Install Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins
ARCH=$(uname -m)
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$${ARCH}" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --auth-key="${tailscale_auth_key}" --hostname="${tailscale_hostname}" --ssh

# Clone the docker compose repo
git clone "${github_repo_url}" /opt/ai-env
chown -R ec2-user:ec2-user /opt/ai-env

# Fetch secrets from SSM and write .env
LITELLM_MASTER_KEY=$(aws ssm get-parameter --region ${aws_region} --name /ai-env/litellm-master-key --with-decryption --query Parameter.Value --output text)
POSTGRES_PASSWORD=$(aws ssm get-parameter --region ${aws_region} --name /ai-env/postgres-password --with-decryption --query Parameter.Value --output text)
OPENCLAW_GATEWAY_TOKEN=$(aws ssm get-parameter --region ${aws_region} --name /ai-env/openclaw-gateway-token --with-decryption --query Parameter.Value --output text)
cat <<EOF > /opt/ai-env/docker/.env
AWS_DEFAULT_REGION=${aws_region}
LITELLM_MASTER_KEY=$${LITELLM_MASTER_KEY}
POSTGRES_PASSWORD=$${POSTGRES_PASSWORD}
OPENCLAW_GATEWAY_TOKEN=$${OPENCLAW_GATEWAY_TOKEN}
EOF

# Pre-create volumes with correct ownership so containers don't get root-owned dirs
# OpenClaw runs as node (UID 1000)
docker volume create docker_openclaw-data
mkdir -p /var/lib/docker/volumes/docker_openclaw-data/_data
chown -R 1000:1000 /var/lib/docker/volumes/docker_openclaw-data/_data

# Render OpenClaw config template and copy into volume
LITELLM_MASTER_KEY=$${LITELLM_MASTER_KEY} envsubst '$LITELLM_MASTER_KEY' \
  < /opt/ai-env/docker/openclaw.json.template \
  > /var/lib/docker/volumes/docker_openclaw-data/_data/openclaw.json
chown 1000:1000 /var/lib/docker/volumes/docker_openclaw-data/_data/openclaw.json

# Generate Tailscale TLS cert for Caddy (OpenClaw HTTPS proxy)
mkdir -p /etc/tailscale/certs
tailscale cert \
  --cert-file /etc/tailscale/certs/ai-env.crt \
  --key-file  /etc/tailscale/certs/ai-env.key \
  "${tailscale_hostname}.$(tailscale status --json | python3 -c 'import sys,json; print(json.load(sys.stdin)["MagicDNSSuffix"])')"
chmod 644 /etc/tailscale/certs/ai-env.crt /etc/tailscale/certs/ai-env.key

# Start services
cd /opt/ai-env/docker
docker compose up -d

echo "=== AI env bootstrap complete ==="
