variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.medium"
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key for joining the tailnet"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "Public GitHub repo URL containing docker-compose.yml"
  type        = string
}

variable "tailscale_hostname" {
  description = "Hostname for this device on the tailnet"
  type        = string
  default     = "ai-env"
}

variable "volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30
}
