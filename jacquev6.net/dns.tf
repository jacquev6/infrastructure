resource "gandi_zone" "jacquev6_net" {
  name = "jacquev6.net-2"
}

resource "gandi_zonerecord" "a_at_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "@"
  type = "A"
  ttl = 3600
  values = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
}

resource "gandi_zonerecord" "mx_at_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "@"
  type = "MX"
  ttl = 3600
  values = ["10 spool.mail.gandi.net.", "50 fb.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_imap_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "imap"
  type = "CNAME"
  ttl = 3600
  values = ["access.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_pop_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "pop"
  type = "CNAME"
  ttl = 3600
  values = ["access.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_smtp_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "smtp"
  type = "CNAME"
  ttl = 3600
  values = ["relay.mail.gandi.net"]
}

resource "gandi_zonerecord" "cname_webmail_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "webmail"
  type = "CNAME"
  ttl = 3600
  values = ["webmail.gandi.net."]
}

resource "gandi_zonerecord" "a_box_home_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "box.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.1"]
}

resource "gandi_zonerecord" "a_doorman_home_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "doorman.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.51"]
}

resource "gandi_zonerecord" "a_eeepc_home_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "eeepc.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.54"]
}

resource "gandi_zonerecord" "a_idee_home_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "idee.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.52"]
}

resource "gandi_zonerecord" "a_kodi_home_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "kodi.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.53"]
}

resource "gandi_zonerecord" "a_nas1_home_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "nas1.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.55"]
}

resource "gandi_zonerecord" "a_nas2_home_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "nas2.home"
  type = "A"
  ttl = 3600
  values = ["192.168.0.50"]
}

resource "gandi_zonerecord" "cname_home_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "home"
  type = "CNAME"
  ttl = 3600
  values = ["home-jacquev6-net.synology.me."]
}

resource "gandi_zonerecord" "cname_parents_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "parents"
  type = "CNAME"
  ttl = 3600
  values = ["parents-jacquev6-net.synology.me."]
}

resource "gandi_zonerecord" "cname_shared_jacquev6_net" {
  zone = "${gandi_zone.jacquev6_net.id}"
  name = "shared"
  type = "CNAME"
  ttl = 3600
  values = ["c.storage.googleapis.com."]
}


resource "gandi_domainattachment" "jacquev6_net" {
    domain = "jacquev6.net"
    zone = "${gandi_zone.jacquev6_net.id}"
}
