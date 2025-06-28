provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

# 🔒 Security Group para la app Flask
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-app_csv"
  description = "Permitir acceso HTTP (5000) y SSH (22)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Flask HTTP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = var.ec2_name
  }
}

# 👤 Rol de ejecución EC2
resource "aws_iam_role" "ec2_app_role" {
  name = "ec2_role_csv"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# 📜 Política de acceso a S3 (solo lectura del bucket de salida)
resource "aws_iam_policy" "ec2_app_policy" {
  name = "ec2_policy_csv"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::${var.output_bucket_name}",
          "arn:aws:s3:::${var.output_bucket_name}/*"
        ]
      }
    ]
  })
}

# 🔗 Asociar política al rol
resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.ec2_app_policy.arn
}

# 🧾 Crear el Instance Profile automáticamente
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_flask_profile"
  role = aws_iam_role.ec2_app_role.name
}

# 💻 Instancia EC2 con user_data que descarga y ejecuta Flask
resource "aws_instance" "app_ec2" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
    bucket_name = var.output_bucket_name
  })

  tags = {
    Name = var.ec2_name
  }
}
