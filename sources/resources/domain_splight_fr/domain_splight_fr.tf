module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "splight.fr"
}

resource "gandi_zonerecord" "admin" {
  zone = "${module.gandi_dns.zone_id}"
  name = "admin"
  type = "A"
  ttl = 3600
  values = ["35.244.252.247"]
}
