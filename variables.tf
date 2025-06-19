variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nombre único para el bucket S3"
  type        = string
}

variable "ami_id" {
  type =  string
  description = "AMI para EC2"
}

variable "instance_type" {
  type = string
  description = "Tipo de instancia EC2"
}

variable "key_name" {
  type = string
  description = "Nombre del par de claves EC2"
}

variable "ec2_name" {
  type = string
  description = "Nombre de la instancia EC2"
}