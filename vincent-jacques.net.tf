module "vincent_jacques_net" {
  source = "modules/gandi-dns"
  domain_name = "vincent-jacques.net"
  zone_name = "vincent-jacques.net-2"
}

resource "gandi_zonerecord" "wildcard" {
  zone = "${module.vincent_jacques_net.zone_id}"
  name = "*"
  type = "A"
  ttl = 3600
  values = ["52.6.169.30"]
}
