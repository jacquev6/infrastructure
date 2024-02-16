locals {
  # https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site
  github_pages_ips = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
}

terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36"
    }

    uptimerobot = {
      source  = "Revolgy-Business-Solutions/uptimerobot"
      version = "~> 0.9"
    }

    gandi = {
      source  = "go-gandi/gandi"
      version = "~> 2.3"
    }

    local = {
      source = "hashicorp/local"
      version = "~> 2.4"
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

# @todo Manage monitoring in an independent Terraform configuration.
# module "jacquev6_net_monitors" {
#   source = "./modules/monitors"

#   alert_contact_id = uptimerobot_alert_contact.email.id
#   domain           = "jacquev6.net"
# }

# module "vincent_jacques_net_monitors" {
#   source = "./modules/monitors"

#   alert_contact_id = uptimerobot_alert_contact.email.id
#   domain           = "vincent-jacques.net"
# }

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
  public_key = file("../configuration/ssh/id_rsa.pub")
}

resource "aws_instance" "web_server" {
  ami           = "ami-05b457b541faec0ca"
  # @todo Switch to an ARM-based instance (e.g. t4g.micro). Requires choosing another AMI.
  instance_type = "t3a.micro"

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

data "gandi_domain" "jacquev6_net" {
  name = "jacquev6.net"
}

resource "gandi_livedns_record" "jacquev6_net" {
  zone   = data.gandi_domain.jacquev6_net.id
  name   = "@"
  type   = "A"
  ttl    = 3600
  values = local.github_pages_ips
}

resource "gandi_livedns_record" "www_jacquev6_net" {
  zone   = data.gandi_domain.jacquev6_net.id
  name   = "www"
  type   = "A"
  ttl    = 3600
  values = [aws_eip.fanout.public_ip]
}

resource "gandi_livedns_record" "cloud_jacquev6_net" {
  zone   = data.gandi_domain.jacquev6_net.id
  name   = "cloud"
  type   = "A"
  ttl    = 3600
  values = [aws_eip.fanout.public_ip]
}

# {home,parents}.jacquev6.net run on hardware I own so they are outside the scope of this repository.

# @todo Import and manage shared.jacquev6.net (Google Storage bucket)

data "gandi_domain" "vincent_jacques_net" {
  name = "vincent-jacques.net"
}

resource "gandi_livedns_record" "vincent_jacques_net" {
  zone   = data.gandi_domain.vincent_jacques_net.id
  name   = "@"
  type   = "A"
  ttl    = 3600
  values = local.github_pages_ips
}

resource "gandi_livedns_record" "www_vincent_jacques_net" {
  zone   = data.gandi_domain.vincent_jacques_net.id
  name   = "www"
  type   = "A"
  ttl    = 3600
  values = [aws_eip.fanout.public_ip]
}

resource "gandi_livedns_record" "dyn_vincent_jacques_net" {
  zone   = data.gandi_domain.vincent_jacques_net.id
  name   = "dyn"
  type   = "A"
  ttl    = 3600
  values = [aws_eip.fanout.public_ip]
}

resource "gandi_livedns_record" "gabby_vincent_jacques_net" {
  zone   = data.gandi_domain.vincent_jacques_net.id
  name   = "gabby"
  type   = "A"
  ttl    = 3600
  values = [aws_eip.fanout.public_ip]
}

resource "gandi_livedns_record" "gabby_next_vincent_jacques_net" {
  zone   = data.gandi_domain.vincent_jacques_net.id
  name   = "gabby-next"
  type   = "A"
  ttl    = 3600
  values = [aws_eip.fanout.public_ip]
}

resource "local_file" "ansible_inventory" {
  content = <<EOT
# THIS FILE IS GENERATED by Terraform. MANUAL CHANGES WILL BE LOST.

all:
  vars:
    ansible_user: ubuntu

  children:
    web_server:
      hosts:
        ${aws_eip.fanout.public_ip}:
EOT
  filename = "../configuration/inventory.yml"
}
