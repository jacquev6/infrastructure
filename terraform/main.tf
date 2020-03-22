locals {
  github_pages_ips = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]

  # Home IP is now fixed, thanks to Free.
  # Before that, I was using CNAME DNS records pointing at "home-jacquev6-net.synology.me."
  home_ip = "82.65.16.120"
}


terraform {
  required_version = ">= 0.12"
  required_providers {
    local = "~> 1.4"
    tls = "~> 2.1"
    acme = "~> 1.5"
    docker = "~> 2.7"
  }
}


provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "acme_account" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.acme_account.private_key_pem
  email_address = "letsencrypt.org@vincent-jacques.net"
}


variable "gandi_api_key" {
  type = string
}

variable "gandi_smtp_password" {
  type = string
}

provider "gandi" {
  key = var.gandi_api_key
}


variable "uptimerobot_api_key" {
  type = string
}

provider "uptimerobot" {
  api_key = var.uptimerobot_api_key
}

data "uptimerobot_account" "account" {}

data "uptimerobot_alert_contact" "default" {
  friendly_name = data.uptimerobot_account.account.email
}


module "etcavole_fr" {
  source = "./resources/etcavole_fr"

  uptimerobot_alert_contact_id = data.uptimerobot_alert_contact.default.id
  github_pages_ips = local.github_pages_ips
}


module "jacquev6_net" {
  source = "./resources/jacquev6_net"

  acme_account_key = acme_registration.registration.account_key_pem
  gandi_api_key = var.gandi_api_key
  uptimerobot_alert_contact_id = data.uptimerobot_alert_contact.default.id
  github_pages_ips = local.github_pages_ips
  home_ip = local.home_ip
}


module "vincent_jacques_net" {
  source = "./resources/vincent_jacques_net"

  acme_account_key = acme_registration.registration.account_key_pem
  gandi_api_key = var.gandi_api_key
  uptimerobot_alert_contact_id = data.uptimerobot_alert_contact.default.id
  github_pages_ips = local.github_pages_ips
  home_ip = local.home_ip
}


provider "docker" {
  alias = "butler"
  # @todo Use an other user
  host = "ssh://jacquev6@butler.home.jacquev6.net"
}

module "butler_containers" {
  source = "./resources/butler_containers"

  providers = {
    docker = docker.butler
  }

  certificates = merge(module.jacquev6_net.certificates, module.vincent_jacques_net.certificates)
  gandi_smtp_password = var.gandi_smtp_password
}
