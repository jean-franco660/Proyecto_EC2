variable "aws_region" {
  description = "Región donde se desplegará EC2"
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI para EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre de la clave SSH"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se lanzará EC2"
  type        = string
}

variable "output_bucket_name" {
  description = "Nombre del bucket de salida (donde EC2 leerá reportes)"
  type        = string
}

variable "ec2_name" {
  description = "Nombre de la instancia EC2"
  type        = string
}
