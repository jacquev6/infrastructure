module "vincent_jacques_net_monitors" {
  source = "./modules/monitors"

  alert_contact_id = uptimerobot_alert_contact.email.id
  domain           = "vincent-jacques.net"
}
