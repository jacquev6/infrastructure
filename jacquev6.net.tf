module "jacquev6_net" {
  source = "modules/gandi-dns"
  domain_name = "jacquev6.net"
  zone_name = "jacquev6.net-2"
}

locals {
  home_machines = [
    "box:1",
    "nas2:50",
    "doorman:51",
    "idee:52",
    "kodi:53",
    "eeepc:54",
    "nas1:55"
  ],
  aliases = [
    "home:home-jacquev6-net.synology.me.",
    "parents:parents-jacquev6-net.synology.me.",
    "shared:c.storage.googleapis.com."
  ]
}

resource "gandi_zonerecord" "home_machine" {
  count = "${length(local.home_machines)}"
  zone = "${module.jacquev6_net.zone_id}"
  name = "${element(split(":", element(local.home_machines, count.index)), 0)}.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.${element(split(":", element(local.home_machines, count.index)), 1)}"]
}

resource "gandi_zonerecord" "alias" {
  count = "${length(local.aliases)}"
  zone = "${module.jacquev6_net.zone_id}"
  name = "${element(split(":", element(local.aliases, count.index)), 0)}"
  type = "CNAME"
  ttl = 3600
  values = ["${element(split(":", element(local.aliases, count.index)), 1)}"]
}
