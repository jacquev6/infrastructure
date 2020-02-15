variable "github_pages_ips" {
  type = "list"
}

variable "home_ip" {
  type = "string"
}


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
  values = ["${var.home_ip}"]
}
