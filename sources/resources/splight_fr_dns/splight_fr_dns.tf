variable "github_pages_ips" {
  type = "list"
}

variable "fanout_ip" {}

module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "splight.fr"
  a_at_ips = "${var.github_pages_ips}"
}

resource "gandi_zonerecord" "wildcard" {
  zone = "${module.gandi_dns.zone_id}"
  name = "*"
  type = "A"
  ttl = 3600
  values = ["${var.fanout_ip}"]
}
