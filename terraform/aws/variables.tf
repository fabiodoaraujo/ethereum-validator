variable "aws_region" {
    description = "AWS region"
    type        = string
    default     = "us-east-1"
}

variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    default     = "t3.micro"
}

variable "key_name" {
    description = "SSH key pair name"
    type        = string
}

variable "instance_name" {
    description = "EC2 instance name"
    type        = string
    default     = "terraform-ec2"
}
