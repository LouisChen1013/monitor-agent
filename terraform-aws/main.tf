data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "windows_server_2022" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

data "aws_ami" "ubuntu_2604" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "rhel_8" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-8.*_HVM-*-x86_64-*-Hourly2-GP3"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  availability_zone = var.availability_zone != "" ? var.availability_zone : data.aws_availability_zones.available.names[0]

  image_aliases = {
    rhel-8              = data.aws_ami.rhel_8.id
    ubuntu-2604         = data.aws_ami.ubuntu_2604.id
    windows-server-2022 = data.aws_ssm_parameter.windows_server_2022.value
  }

  instance_ami_ids = {
    for name, image in var.instances :
    name => lookup(local.image_aliases, image, image)
  }

  common_tags = {
    ManagedBy = "terraform"
    Project   = "monitor-agent"
  }
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "monitor-vpc"
  })
}

# Internet gateway for public subnet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "monitor-igw"
  })
}

# Public subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "monitor-subnet"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "monitor-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.public.id
}

# Security group (SSH)
resource "aws_security_group" "allow_ssh" {
  name        = "monitor-allow-ssh"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr_blocks
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "monitor-allow-ssh"
  })
}

resource "aws_key_pair" "ssh" {
  key_name   = var.key_pair_name
  public_key = file(var.ssh_public_key_path)

  tags = local.common_tags
}

# EC2 instances
resource "aws_instance" "monitor_vm" {
  for_each = var.instances

  ami                         = local.instance_ami_ids[each.key]
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  key_name                    = aws_key_pair.ssh.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = merge(local.common_tags, {
    Name = each.key
    Role = each.key
  })
}
