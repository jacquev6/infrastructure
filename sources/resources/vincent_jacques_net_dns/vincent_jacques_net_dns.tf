variable "github_pages_ips" {
  type = "list"
}

module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "vincent-jacques.net"
  a_at_ips = "${var.github_pages_ips}"
}

resource "gandi_zonerecord" "wildcard" {
  zone = "${module.gandi_dns.zone_id}"
  name = "*"
  type = "CNAME"
  ttl = 3600
  values = ["home-jacquev6-net.synology.me."]
}
