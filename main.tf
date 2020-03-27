provider "aws" {
  version    = "~> 2.0"
  region     = "us-east-2"
  access_key = "<AWS Access Key>"
  secret_key = "<AWS Secret Key>"
}

resource "tls_private_key" "demo_key_1" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "demo_key_1" {
  key_name   = "demo-key-1"
  public_key = tls_private_key.demo_key_1.public_key_openssh
}

resource "local_file" "local_ssh_private_key" {
  content         = tls_private_key.demo_key_1.private_key_pem
  filename        = "ssh-key-private.pem"
  file_permission = "0400"
}

resource "local_file" "local_ssh_public_key" {
  content         = tls_private_key.demo_key_1.public_key_openssh
  filename        = "ssh-key-public.pem"
  file_permission = "0400"
}

resource "aws_security_group" "allow_ssh" {
  name        = "Allow SSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = "<Your VPC Id>"
  ingress {
    description = "SSH from Entire world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow SSH on 22"
  }
}

resource "aws_instance" "web" {
  ami                    = "<Your AMI Id>"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.demo_key_1.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  subnet_id              = "<Your Subnet Id>"
  tags = {
    Name = "Demo Instance 1"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
