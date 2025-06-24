variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "AMI Ubuntu 22.04 LTS"
  default     = "ami-080e1f13689e07408"  # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type - us-east-1
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Nombre de tu par de claves SSH"
}

variable "output_bucket_name" {
  default = "proyecto-reportes-procesados"
}

variable "ec2_name" {
  default = "flask-ec2"
}
