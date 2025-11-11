provider "aws" {
  region = "ap-south-1"
}

# 🔹 Fetch default VPC so we can attach the security group
data "aws_vpc" "default" {
  default = true
}

# 🔹 Security group allowing SSH + FastAPI
resource "aws_security_group" "fastapi_sg2" {
  name        = "fastapi-sg2"
  description = "Allow SSH and FastAPI traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow SSH from anywhere (fine for testing)
  }

  ingress {
    description = "Allow FastAPI default port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow public access to app
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 EC2 instance
resource "aws_instance" "fastapi_server" {
  ami           = "ami-02b8269d5e85954ef" 
  instance_type = "t2.micro"
  key_name      = "newkp"
  security_groups = [aws_security_group.fastapi_sg2.name]

  tags = {
    Name = "FastAPI-Server"
  }
}

# 🔹 Output public IP for later use (Ansible, etc.)
output "public_ip_one" {
  value = aws_instance.fastapi_server.public_ip
}