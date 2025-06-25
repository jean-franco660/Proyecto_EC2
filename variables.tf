variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "ID de la AMI para la instancia EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 (por ejemplo, t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre de la clave SSH para acceder a la instancia EC2"
  type        = string
}

variable "output_bucket_name" {
  description = "Nombre del bucket donde se suben los reportes procesados"
  type        = string
}

variable "ec2_name" {
  description = "Nombre del recurso EC2 (tag Name)"
  type        = string
}

variable "env" {
  description = "Nombre del entorno (por ejemplo: dev, prod, test)"
  type        = string
  default     = "dev" 
}
