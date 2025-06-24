provider "aws" {
  region = var.aws_region
}

# 🔍 Obtener VPC por defecto (necesario para asociar el security group)
data "aws_vpc" "default" {
  default = true
}

# 🔐 Grupo de seguridad para permitir acceso SSH (22) y Flask (5000)
resource "aws_security_group" "ec2_sg" {
  name        = "sg-flask-reportes"
  description = "Permitir acceso HTTP (5000) y SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress = [
    {
      description = "Permitir acceso HTTP (Flask)"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Permitir SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]

  tags = {
    Name = "sg-flask-reportes"
  }
}

# 🖥️ Instancia EC2
resource "aws_instance" "app_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  # Script de inicio que levanta la app Flask
  user_data = templatefile("${path.module}/user_data.sh", {
    report_bucket = var.output_bucket_name
  })

  tags = {
    Name = var.ec2_name
  }
}
