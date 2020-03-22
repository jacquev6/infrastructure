variable "acme_account_key" {
  type = string
}

variable "gandi_api_key" {
  type = string
}

variable "uptimerobot_alert_contact_id" {
  type = string
}

variable "github_pages_ips" {
  type = list(string)
}

variable "home_ip" {
  type = string
}


module "dns" {
  source = "../../modules/gandi_dns"

  domain_name = "vincent-jacques.net"
  a_at_ips = var.github_pages_ips
  records = [
    {
      type = "A"
      name = "www"
      values = [var.home_ip]
    },
    {
      type = "A"
      name = "dyn"
      values = [var.home_ip]
    },
  ]
}



resource "uptimerobot_monitor" "http_vincent_jacques_net" {
  friendly_name = "http://vincent-jacques.net/"
  type = "http"
  url = "http://vincent-jacques.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_vincent_jacques_net" {
  friendly_name = "https://vincent-jacques.net/"
  type = "http"
  url = "https://vincent-jacques.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "http_www_vincent_jacques_net" {
  friendly_name = "http://www.vincent-jacques.net/"
  type = "http"
  url = "http://www.vincent-jacques.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_www_vincent_jacques_net" {
  friendly_name = "https://www.vincent-jacques.net/"
  type = "http"
  url = "https://www.vincent-jacques.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_dyn_vincent_jacques_net_turkshead" {
  friendly_name = "https://dyn.vincent-jacques.net/turkshead"
  type = "http"
  url = "https://dyn.vincent-jacques.net/turkshead"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}


module "dyn_vincent_jacques_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "dyn.vincent-jacques.net"
}

module "www_vincent_jacques_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "www.vincent-jacques.net"
}

output "certificates" {
  value = {
    "dyn.vincent-jacques.net" = module.dyn_vincent_jacques_net_certificate.certificate
    "www.vincent-jacques.net" = module.www_vincent_jacques_net_certificate.certificate
  }
}
