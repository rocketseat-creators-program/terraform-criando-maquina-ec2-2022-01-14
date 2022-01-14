##### BLOCO VARIAVEIS
variable "awsvars" {
    type = map(string)
    default = {
    type = "t2.micro"
  }
}


#### BLOCO PROVIDER
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.REGION
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET
}


#### BLOCO VM

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

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "ec-vm" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = lookup(var.awsvars,"type")
  key_name =      "novokey"

  tags = {
    Name = "NOSSA_VM"
  }

  network_interface {
    network_interface_id = aws_network_interface.ec-netint.id
    device_index         = 0
  }
}

resource "aws_security_group" "ec-secgroup" {
  name        = "allow_connection"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.ec-vpc.id


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

}





#### BLOCO SAIDA

output "instance_ip" {
  value = aws_instance.ec-vm.public_ip
  depends_on = [
    aws_instance.ec-vm
  ]
}