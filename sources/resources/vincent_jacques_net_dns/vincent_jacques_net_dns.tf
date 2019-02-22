variable "github_pages_ips" {
  type = "list"
}

variable "fanout_ip" {}

variable "gandi_api_key" {}

variable "acme_account_key_pem" {}

module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "vincent-jacques.net"
  a_at_ips = "${var.github_pages_ips}"
}

resource "gandi_zonerecord" "wildcard" {
  zone = "${module.gandi_dns.zone_id}"
  name = "*"
  type = "A"
  ttl = 3600
  values = ["${var.fanout_ip}"]
}
