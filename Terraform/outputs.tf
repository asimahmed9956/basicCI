# Output the public IP of the EC2 instance
output "public_ip" {
  description = "Public IP of the FastAPI EC2 instance"
  value       = aws_instance.fastapi_server.public_ip
}