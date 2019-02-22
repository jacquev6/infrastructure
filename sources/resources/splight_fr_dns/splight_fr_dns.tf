variable "github_pages_ips" {
  type = "list"
}

variable "fanout_ip" {}

variable "gandi_api_key" {}

variable "acme_account_key_pem" {}

module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "splight.fr"
  a_at_ips = "${var.github_pages_ips}"
}

resource "gandi_zonerecord" "admin" {
  zone = "${module.gandi_dns.zone_id}"
  name = "admin"
  type = "A"
  ttl = 3600
  values = ["${var.fanout_ip}"]
}

resource "gandi_zonerecord" "api_v1" {
  zone = "${module.gandi_dns.zone_id}"
  name = "api-v1"
  type = "A"
  ttl = 3600
  values = ["${var.fanout_ip}"]
}
