variable "github_pages_ips" {
  type = list(string)
}

variable "home_ip" {
  type = string
}


module "gandi_dns" {
  source = "../../modules/gandi_dns"

  domain_name = "jacquev6.net"
  a_at_ips = var.github_pages_ips
}


locals {
  home_machines = [
    "box|192.168.0.1",
    # WARNING, the static DHCP configuration is maintained by hand at http://mafreebox.freebox.fr/
    "nas2|192.168.1.50|00:11:32:49:8b:63",
    "doorman|192.168.1.51|b8:27:eb:39:27:df",
    "idee|192.168.1.52|1c:6f:65:37:a6:c6",
    "macbook|192.168.1.53|a4:83:e7:5e:19:b1",
    "icule|192.168.1.54|08:00:27:ee:68:dc"
  ]
  aliases = [
    "home|home-jacquev6-net.synology.me.",
    "parents|parents-jacquev6-net.synology.me.",
    "shared|c.storage.googleapis.com."
  ]
}

resource "gandi_zonerecord" "home_machine" {
  count = length(local.home_machines)
  zone = module.gandi_dns.zone_id
  name = "${element(split("|", element(local.home_machines, count.index)), 0)}.home"
  type = "A"
  ttl = 3600
  values = [element(split("|", element(local.home_machines, count.index)), 1)]
}

resource "gandi_zonerecord" "alias" {
  count = length(local.aliases)
  zone = module.gandi_dns.zone_id
  name = element(split("|", element(local.aliases, count.index)), 0)
  type = "CNAME"
  ttl = 3600
  values = [element(split("|", element(local.aliases, count.index)), 1)]
}
