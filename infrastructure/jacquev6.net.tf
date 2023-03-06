resource "uptimerobot_monitor" "http_jacquev6_net" {
  friendly_name = "http://jacquev6.net/"
  type          = "http"
  url           = "http://jacquev6.net/"

  alert_contact {
    id = uptimerobot_alert_contact.email.id
  }
}

resource "uptimerobot_monitor" "https_jacquev6_net" {
  friendly_name = "https://jacquev6.net/"
  type          = "http"
  url           = "https://jacquev6.net/"

  alert_contact {
    id = uptimerobot_alert_contact.email.id
  }
}
