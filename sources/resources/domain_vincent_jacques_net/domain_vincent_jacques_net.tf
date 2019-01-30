module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "vincent-jacques.net"
}

resource "gandi_zonerecord" "wildcard" {
  zone = "${module.gandi_dns.zone_id}"
  name = "*"
  type = "A"
  ttl = 3600
  # @todo How to use module.gke_cluster_jacquev6_0002.google_compute_global_address.fanout.address
  values = ["35.244.252.247"]
}
