# =============================================================================
# One EC2 server, ready to run the Notes app with Docker Compose.
# Only YOUR IP can reach it, on SSH (22) and HTTP (80).
# =============================================================================

# Latest Ubuntu 24.04 for ARM (Graviton), looked up from AWS's public catalogue
data "aws_ssm_parameter" "ubuntu_arm64" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/arm64/hvm/ebs-gp3/ami-id"
}

# The ready-made network every AWS account has
data "aws_vpc" "default" {
  default = true
}

resource "aws_default_subnet" "app" {
  availability_zone = var.availability_zone

  tags = {
    Name = "default-${var.availability_zone}"
  }
}

# Upload your PUBLIC key, so your private key can log in
resource "aws_key_pair" "deployer" {
  key_name   = "three-tier-notes"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# -----------------------------------------------------------------------------
# The firewall
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "three-tier-notes-web"
  description = "Notes app: SSH and HTTP from the owner IP only"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP (Nginx) from my IP only"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from my IP only"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# Outgoing: allowed, so the server can download Docker and container images
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# -----------------------------------------------------------------------------
# The server
# -----------------------------------------------------------------------------
resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.ubuntu_arm64.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  subnet_id                   = aws_default_subnet.app.id
  associate_public_ip_address = true

  # Runs ONCE, at first boot: installs Docker (see user-data.sh)
  user_data                   = file("${path.module}/user-data.sh")
  user_data_replace_on_change = true

  # Require IMDSv2: blocks a common way attackers steal server credentials
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # 20 GB, encrypted. Room for the OS, Docker images (~1.4 GB) and data
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "three-tier-notes"
  }
}