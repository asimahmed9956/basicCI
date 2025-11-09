provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "fastapi_server" {
  ami           = "ami-02b8269d5e85954ef" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "newkp"

  tags = {
    Name = "FastAPI-Server"
  }
}

output "public_ip" {
  value = aws_instance.fastapi_server.public_ip
}

# sample