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
cat <<EOF > /opt/ai-env/docker/.env
AWS_DEFAULT_REGION=${aws_region}
LITELLM_MASTER_KEY=$${LITELLM_MASTER_KEY}
POSTGRES_PASSWORD=$${POSTGRES_PASSWORD}
EOF

# Start services
cd /opt/ai-env/docker
docker compose up -d

echo "=== AI env bootstrap complete ==="
