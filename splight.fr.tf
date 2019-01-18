module "splight_fr" {
  source = "modules/gandi-dns"
  domain_name = "splight.fr"
  zone_name = "splight.fr-2"
}

resource "gandi_zonerecord" "admin" {
  zone = "${module.splight_fr.zone_id}"
  name = "admin"
  type = "A"
  ttl = 3600
  values = ["35.210.122.49"]
}
