provider "aws" {
  region = "ap-south-1"
}

# 🔹 Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# 🔹 Random suffix to avoid name conflicts
resource "random_id" "suffix" {
  byte_length = 2
}

# 🔹 Security Group for SSH + HTTP
resource "aws_security_group" "fastapi_sg" {
  name        = "fastapi-sg-${random_id.suffix.hex}"
  description = "Allow SSH and FastAPI traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP access (FastAPI)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 EC2 instance (Ubuntu)
resource "aws_instance" "fastapi_server" {
  ami           = "ami-02b8269d5e85954ef" # ✅ Ubuntu 22.04 LTS in ap-south-1
  instance_type = "t2.micro"
  key_name      = "newkp"
  security_groups = [aws_security_group.fastapi_sg.name]

  # 🟢 Ubuntu setup user_data script
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io git
    systemctl start docker
    systemctl enable docker
    cd /home/ubuntu
    git clone https://github.com/asimahmed9956/basicCI.git  
    cd basicCI
    docker build -t fastapi-app .
    sudo docker run -d -p 80:8000 fastapi-app
  EOF

  tags = {
    Name = "FastAPI-Ubuntu-Server"
  }
}

# 🔹 Output EC2 public IP
output "public_ip" {
  value = aws_instance.fastapi_server.public_ip
}