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
