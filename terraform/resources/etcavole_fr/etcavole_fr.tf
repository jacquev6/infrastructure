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

  domain_name = "etcavole.fr"
  a_at_ips = var.github_pages_ips
  records = [
    {
      type = "A"
      name = "www"
      values = [var.home_ip]
    },
  ]
}


resource "uptimerobot_monitor" "http_etcavole_fr" {
  friendly_name = "http://etcavole.fr/"
  type = "http"
  url = "http://etcavole.fr/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_etcavole_fr" {
  friendly_name = "https://etcavole.fr/"
  type = "http"
  url = "https://etcavole.fr/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "http_www_etcavole_fr" {
  friendly_name = "http://www.etcavole.fr/"
  type = "http"
  url = "http://www.etcavole.fr/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_www_etcavole_fr" {
  friendly_name = "https://www.etcavole.fr/"
  type = "http"
  url = "https://www.etcavole.fr/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}
