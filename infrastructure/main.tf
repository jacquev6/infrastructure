terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57"
    }

    uptimerobot = {
      source  = "Revolgy-Business-Solutions/uptimerobot"
      version = "~> 0.9"
    }
  }

  # Remote backend added after using the local backend.
  # State was migrated by 'terraform init'.
  backend "s3" {
    bucket = "jacquev6"
    key    = "cloud-infrastructure/terraform.tfstate"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = "eu-west-3"

  default_tags {
    tags = {
      Managed = "by Terraform"
    }
  }
}

resource "uptimerobot_alert_contact" "email" {
  friendly_name = "uptimerobot.com@vincent-jacques.net"
  type          = "e-mail"
  value         = "uptimerobot.com@vincent-jacques.net"
}

module "jacquev6_net_monitors" {
  source = "./modules/monitors"

  alert_contact_id = uptimerobot_alert_contact.email.id
  domain           = "jacquev6.net"
}

module "vincent_jacques_net_monitors" {
  source = "./modules/monitors"

  alert_contact_id = uptimerobot_alert_contact.email.id
  domain           = "vincent-jacques.net"
}

resource "aws_security_group" "web_servers" {
  name        = "web-servers"
  description = "SSH and HTTP(S) access to web servers"
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
  ]
}

resource "aws_key_pair" "main" {
  key_name   = "main"
  public_key = file("../secrets/main.id_rsa.pub")
}

resource "aws_instance" "web_server" {
  ami           = "ami-05b457b541faec0ca"
  instance_type = "t2.micro"

  key_name        = aws_key_pair.main.key_name
  security_groups = [aws_security_group.web_servers.name]

  tags = {
    Name = "Web server"
  }
}

resource "aws_eip" "fanout" {
  instance = aws_instance.web_server.id
}

output "fanout_address" {
  value = aws_eip.fanout.public_ip
}
