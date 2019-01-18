module "jacquev6_net" {
  source = "modules/gandi-dns"
  domain_name = "jacquev6.net"
  zone_name = "jacquev6.net-2"
}

resource "gandi_zonerecord" "a_box_home_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "box.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.1"]
}

resource "gandi_zonerecord" "a_doorman_home_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "doorman.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.51"]
}

resource "gandi_zonerecord" "a_eeepc_home_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "eeepc.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.54"]
}

resource "gandi_zonerecord" "a_idee_home_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "idee.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.52"]
}

resource "gandi_zonerecord" "a_kodi_home_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "kodi.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.53"]
}

resource "gandi_zonerecord" "a_nas1_home_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "nas1.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.55"]
}

resource "gandi_zonerecord" "a_nas2_home_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "nas2.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.50"]
}

resource "gandi_zonerecord" "cname_home_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "home"
  type = "CNAME"
  ttl = 3600
  values = ["home-jacquev6-net.synology.me."]
}

resource "gandi_zonerecord" "cname_parents_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "parents"
  type = "CNAME"
  ttl = 3600
  values = ["parents-jacquev6-net.synology.me."]
}

resource "gandi_zonerecord" "cname_shared_jacquev6_net" {
  zone = "${module.jacquev6_net.zone_id}"
  name = "shared"
  type = "CNAME"
  ttl = 3600
  values = ["c.storage.googleapis.com."]
}
