variable "environment" {
  type        = string
  description = "Environment"
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_block" {
  type = string
}

variable "project_name" {
  type = string
}

# AWS EC2 Instance Key Pair
variable "instance_key_pair" {
  description = "Name of the EC2 Key Pair"
  type        = string
  default     = "tf-key"
}

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
  #sensitive   = true
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be one of: t3.micro, t3.small, t3.medium"
  }
}