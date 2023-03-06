resource "uptimerobot_monitor" "http_vincent_jacques_net" {
  friendly_name = "http://vincent-jacques.net/"
  type          = "http"
  url           = "http://vincent-jacques.net/"

  alert_contact {
    id = uptimerobot_alert_contact.email.id
  }
}

resource "uptimerobot_monitor" "https_vincent_jacques_net" {
  friendly_name = "https://vincent-jacques.net/"
  type          = "http"
  url           = "https://vincent-jacques.net/"

  alert_contact {
    id = uptimerobot_alert_contact.email.id
  }
}
