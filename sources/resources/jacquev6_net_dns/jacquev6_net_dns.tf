variable "github_pages_ips" {
  type = "list"
}

module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "jacquev6.net"
  a_at_ips = "${var.github_pages_ips}"
}

locals {
  home_machines = [
    "box|192.168.0.1",
    "nas2|192.168.0.50|00:11:32:49:8b:63",
    "doorman|192.168.0.51|b8:27:eb:39:27:df",
    "idee|192.168.0.52|1c:6f:65:37:a6:c6"
  ],
  aliases = [
    "home|home-jacquev6-net.synology.me.",
    "parents|parents-jacquev6-net.synology.me.",
    "shared|c.storage.googleapis.com."
  ]
}

resource "gandi_zonerecord" "home_machine" {
  count = "${length(local.home_machines)}"
  zone = "${module.gandi_dns.zone_id}"
  name = "${element(split("|", element(local.home_machines, count.index)), 0)}.home"
  type = "A"
  ttl = 3600
  values = ["${element(split("|", element(local.home_machines, count.index)), 1)}"]
}

resource "sfrbox_dhcpentry" "home_machine" {
  count = "${length(local.home_machines) - 1}"
  mac = "${element(split("|", element(local.home_machines, count.index + 1)), 2)}"
  ip = "${element(split("|", element(local.home_machines, count.index + 1)), 1)}"
}

resource "gandi_zonerecord" "alias" {
  count = "${length(local.aliases)}"
  zone = "${module.gandi_dns.zone_id}"
  name = "${element(split("|", element(local.aliases, count.index)), 0)}"
  type = "CNAME"
  ttl = 3600
  values = ["${element(split("|", element(local.aliases, count.index)), 1)}"]
}
