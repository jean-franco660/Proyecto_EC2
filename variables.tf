variable "aws_region" {
  description = "Región AWS"
  type        = string
}

variable "ec2_name" {
  description = "Nombre de la instancia EC2"
  type        = string
}

variable "ami_id" {
  description = "AMI para la instancia EC2"
  type        = string
}

variable "key_name" {
  description = "Par de llaves SSH"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se creará la instancia EC2"
  type        = string
}

variable "output_bucket_name" {
  description = "Bucket de salida S3"
  type        = string
}
