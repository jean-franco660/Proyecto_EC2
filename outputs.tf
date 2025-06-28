output "ec2_public_ip" {
  description = "IP pública de la EC2"
  value       = aws_instance.app_ec2.public_ip
}

output "ec2_instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.app_ec2.id
}


output "flask_url_ec2" {
  description = "URL de la app Flask desplegada en EC2"
  value       = "http://${aws_instance.app_ec2.public_ip}:5000"
}
