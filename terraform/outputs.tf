output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP (only used for outbound internet, not for access)"
  value       = aws_instance.main.public_ip
}

output "next_steps" {
  description = "Post-deployment instructions"
  value       = <<-EOT
    1. Wait a few minutes for the instance to finish bootstrapping
    2. Check your Tailscale admin console for the new device: https://login.tailscale.com/admin/machines
    3. SSH into the instance via Tailscale: ssh ec2-user@<tailscale-ip>
    4. Verify services: cd /opt/ai-env/docker && docker compose ps
    5. Access Open WebUI: http://<tailscale-ip>:3000
    6. Access LiteLLM: http://<tailscale-ip>:4000
  EOT
}
