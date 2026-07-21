# Retrieve available zones for the specified region
data "aws_availability_zones" "available" {
  state = "available"
}
# Retrieve information about the target region
data "aws_region" "current" {}

# Retrieve information about the current caller identity
data "aws_caller_identity" "current" {}

# Get latest AMI ID for Amazon Linux 2 OS
# Get latest Amazon Linux 3 AMI ID using AWS AMI Data Source
# Reference Datasource to get the latest AMI ID
# ami = data.aws_ami.amzlinux2.id 
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

######################################################################
# Create VPC
# 1. VPC for EC2 to host website (Resource: aws_vpc)
######################################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Manual Deployment"
    Region      = data.aws_region.current.region
    AccountID   = data.aws_caller_identity.current.account_id
  }
}

# 2. VPC Subnet (Resource: aws_subnet)
#  Note:  add availability_zone and map_public_ip_on_lauch
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Region      = data.aws_region.current.region
    AZ          = data.aws_availability_zones.available.names[0]
  }
}

# 3. VPC Internet Gateway (Resource: aws_internet_gateway)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# 4. VPC Route Table (Resource: aws_route_table)
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name        = "${var.environment}-route-table"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# 5. VPC Route Table Association (Resource: aws_main_route_table_association)
resource "aws_route_table_association" "rt-association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

######################################################################
# Security group rule for HTTP, HTTPS and SSH traffic
######################################################################
resource "aws_security_group" "swa_sg" {
  name        = "${var.environment}-${var.project_name}-sg"
  description = "Security Group to allow HTTP, HTTPS and SSH traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["MyIpaddress/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.project_name}-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

######################################################################
# EC2 Instance
######################################################################
resource "aws_instance" "secure-web-app-server" {
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.cloudwatch_agent_profile.name
  subnet_id              = aws_subnet.public.id
  key_name               = var.instance_key_pair
  vpc_security_group_ids = [aws_security_group.swa_sg.id]
  user_data              = file("${path.module}/website-install.sh")
  tags = {
    Name        = "${var.environment}-${var.project_name}-server"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Region      = data.aws_region.current.region
    AZ          = data.aws_availability_zones.available.names[0]
  }
}

