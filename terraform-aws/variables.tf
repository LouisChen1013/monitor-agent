variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-east-2"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet. Leave empty to use the first available AZ in aws_region."
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "192.168.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "instance_max" {
  description = "Max number of instances"
  type        = number
  default     = 5

  validation {
    condition     = var.instance_max < 6
    error_message = "Do not deploy more than 5 instances."
  }
}

variable "instances" {
  description = "EC2 instances as name => AMI ID or supported image alias. Supported aliases: ubuntu-2604, rhel-8, windows-server-2022."
  type        = map(string)

  validation {
    condition     = contains(keys(var.instances), "central")
    error_message = "Deployment failed: instances must include a central instance as the external entry point."
  }

  validation {
    condition     = length(var.instances) <= var.instance_max
    error_message = "Deployment failed: You have exceeded the maximum allowed instance limit."
  }

  validation {
    condition = alltrue([
      for _, image in var.instances : contains([
        "ubuntu-2604",
        "rhel-8",
        "windows-server-2022"
      ], image) || can(regex("^ami-[0-9a-f]+$", image))
    ])
    error_message = "Deployment failed: instances values must be valid AMI IDs, for example ami-0123456789abcdef0, or supported image aliases: ubuntu-2604, rhel-8, windows-server-2022."
  }
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for the EC2 key pair"
  type        = string
  default     = "ssh_public_key_path"
}

variable "key_pair_name" {
  description = "AWS EC2 key pair name to create from ssh_public_key_path"
  type        = string
  default     = "monitor-agent-key"
}

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
