provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-flask-sg_${var.env}"
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }
  
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
    Name = "ec2-flask-sg_${var.env}"
  }
}

resource "aws_iam_role" "ec2_app_role" {
  name = "ec2_app_role_${var.env}"

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

resource "aws_iam_policy" "ec2_app_policy" {
  name = "ec2_app_policy_${var.env}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["dynamodb:Scan", "dynamodb:GetItem"],
        Resource = aws_dynamodb_table.reportes.arn
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
  depends_on = [aws_dynamodb_table.reportes]
}

resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.ec2_app_policy.arn
}

resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = "ec2_app_profile_${var.env}"
  role = aws_iam_role.ec2_app_role.name
}


resource "aws_instance" "app_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  subnet_id                   = "subnet-0b31b0b57cbc5c1cf"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_app_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
    bucket_name = var.output_bucket_name
  })

  tags = {
    Name = var.ec2_name
  }
}


# --- DynamoDB Table para los reportes ---
resource "aws_dynamodb_table" "reportes" {
  name         = "reportes_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "reportes_table"
    Environment = var.env
  }
}
