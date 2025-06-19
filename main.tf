provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "ec2_sg" {
  name = "ec2"
  description = "Permitir acceso SSH"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "http"
    ##### Solo para pruebas #####
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = ".1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecurityGroupSSH"
  }
}

resource "aws_instance" "mi_ec2" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = var.ec2_name
  }
}

output "ec2_public_ip" {
  value = aws_instance.mi_ec2.public_ip
}