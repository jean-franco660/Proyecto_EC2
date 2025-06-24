variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI para EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre del par de claves EC2"
  type        = string
}

variable "ec2_name" {
  description = "Nombre de la instancia EC2"
  type        = string
}

variable "output_bucket_name" {
  description = "Nombre del bucket donde están los reportes"
  type        = string
}
