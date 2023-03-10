variable "domain" {
  type = string
  nullable = false
}

variable "alert_contact_id" {
  type = string
  nullable = false
}

terraform {
  required_providers {
    uptimerobot = {
      source = "Revolgy-Business-Solutions/uptimerobot"
      version = "~> 0.9"
    }
  }
}

resource "uptimerobot_monitor" "http_root" {
  friendly_name = "http://${var.domain}/"
  type = "http"
  url = "http://${var.domain}/"

  alert_contact {
    id = var.alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_root" {
  friendly_name = "https://${var.domain}/"
  type = "http"
  url = "https://${var.domain}/"

  alert_contact {
    id = var.alert_contact_id
  }
}

resource "uptimerobot_monitor" "http_www" {
  friendly_name = "http://www.${var.domain}/"
  type = "http"
  url = "http://www.${var.domain}/"

  alert_contact {
    id = var.alert_contact_id
  }
}
