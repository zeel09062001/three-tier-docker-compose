variable "aws_region" {
  description = "AWS region for the server"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 size. t4g.small = ARM, 2 vCPU, 2 GB (chosen from measured memory use)"
  type        = string
  default     = "t4g.small"
}

variable "my_ip_cidr" {
  description = "Your public IP as 142.198.109.182/32. The ONLY address allowed to reach the server"
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0)) && endswith(var.my_ip_cidr, "/32")
    error_message = "my_ip_cidr must be a single IP address in the form 142.198.109.182/32."
  }
}
variable "ssh_public_key_path" {
  description = "Path to your SSH PUBLIC key (.pub)"
  type        = string
  default     = "~/.ssh/three-tier-notes.pub"
}
variable "availability_zone" {
  description = "The data centre (Availability Zone) to place the server in"
  type        = string
  default     = "us-east-1a"
}