provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["099720109477"] #canonical
}

locals {
  instances = {
    instance1 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t3.micro"
    }
    instance2 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t3.micro"
    }
    instance3 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t3.micro"
    }
    instance4 = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t3.micro"
    }
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ec2"
  public_key = file(var.public_key)
}

resource "aws_instance" "this" {
  for_each                    = local.instances
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.ansible_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = each.key
  }
}

resource "aws_security_group" "ansible_ssh" {
  name        = "ansible-ssh"
  description = "Allow SSH for Ansible and HTTP for nginx"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}
