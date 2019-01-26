module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "vincent-jacques.net"
}

resource "gandi_zonerecord" "wildcard" {
  zone = "${module.gandi_dns.zone_id}"
  name = "*"
  type = "A"
  ttl = 3600
  values = ["35.210.187.225"]
}
