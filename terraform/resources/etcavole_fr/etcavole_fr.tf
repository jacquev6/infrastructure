variable "github_pages_ips" {
  type = list(string)
}


module "dns" {
  source = "../../modules/gandi_dns"

  domain_name = "etcavole.fr"
  a_at_ips = var.github_pages_ips
}

# @todo Add and monitor www. (for http and https, cf ../vincent_jacques_net)

data "uptimerobot_account" "account" {}

data "uptimerobot_alert_contact" "default" {
  friendly_name = "${data.uptimerobot_account.account.email}"
}

resource "uptimerobot_monitor" "http_etcavole_fr" {
  friendly_name = "http://etcavole.fr/"
  type = "http"
  url = "http://etcavole.fr/"
  alert_contact {
    id = data.uptimerobot_alert_contact.default.id
  }
}

resource "uptimerobot_monitor" "https_etcavole_fr" {
  friendly_name = "https://etcavole.fr/"
  type = "http"
  url = "https://etcavole.fr/"
  alert_contact {
    id = data.uptimerobot_alert_contact.default.id
  }
}
