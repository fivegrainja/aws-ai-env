# Latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2" {
  name_prefix = "ai-env-ec2-"
  description = "No inbound access - Tailscale only"
  vpc_id      = aws_vpc.main.id

  # No ingress rules - all access via Tailscale

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = { Name = "ai-env-ec2-sg" }
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/userdata.sh", {
    tailscale_auth_key  = var.tailscale_auth_key
    tailscale_hostname  = var.tailscale_hostname
    github_repo_url     = var.github_repo_url
    aws_region          = var.aws_region
  })

  tags = { Name = "ai-env" }

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}
