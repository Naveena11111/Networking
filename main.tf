provider "aws" {
  region = "eu-west-1"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ca1-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
#comment
resource "local_file" "private_key_file" {
  content              = tls_private_key.ssh_key.private_key_pem
  filename             = "${path.module}/key.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  availability_zone = "eu-west-1a"
}

resource "aws_security_group" "web_sg" {
  name        = "app-server-sg"
  description = "Allowing"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "testappSG"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-028727bd3039c5a1f" 
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.default.id
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "TestApp"
  }
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}
