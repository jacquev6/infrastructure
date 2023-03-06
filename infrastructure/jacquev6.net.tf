module "jacquev6_net_monitors" {
  source = "./modules/monitors"

  alert_contact_id = uptimerobot_alert_contact.email.id
  domain           = "jacquev6.net"
}
