data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["al2023-ami-*-x86_64"]
    }
}

resource "aws_security_group" "ec2_sg" {
    name        = "ec2-ssh-sg"
    description = "Allow SSH access"

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "ec2-ssh-sg"
    }
}

resource "aws_instance" "this" {
    ami                    = data.aws_ami.amazon_linux.id
    instance_type          = var.instance_type
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]

    tags = {
        Name = var.instance_name
    }
}
