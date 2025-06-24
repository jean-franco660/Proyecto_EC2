provider "aws" {
  region = var.aws_region
}

# Obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {}

# Security Group (Flask, SSH)
resource "aws_security_group" "ec2_sg" {
  name        = "sg-flask-reportes"
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
    Name = "sg-flask-reportes"
  }
}

# Subnet pública
resource "aws_subnet" "subnet1" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

# Rol IAM para EC2
resource "aws_iam_role" "ec2_dynamodb_role" {
  name = "ec2_dynamodb_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Política: DynamoDB + S3 (lectura)
resource "aws_iam_policy" "ec2_dynamodb_s3_read_policy" {
  name = "ec2_dynamodb_s3_read_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["dynamodb:Scan", "dynamodb:GetItem"],
        Resource = "arn:aws:dynamodb:*:*:table/reportes_table"
      },
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

resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = aws_iam_role.ec2_dynamodb_role.name
  policy_arn = aws_iam_policy.ec2_dynamodb_s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_dynamodb_role.name
}

# Instancia EC2
resource "aws_instance" "app_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
    bucket_name = var.output_bucket_name
  })

  tags = {
    Name = var.ec2_name
  }
}
