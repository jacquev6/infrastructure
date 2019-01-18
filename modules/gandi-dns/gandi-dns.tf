variable "domain_name" {}
variable "zone_name" {
  default = ""
}

resource "gandi_zone" "zone" {
  name = "${coalesce(var.zone_name, var.domain_name)}"
}

resource "gandi_domainattachment" "attachment" {
    domain = "${var.domain_name}"
    zone = "${gandi_zone.zone.id}"
}

resource "gandi_zonerecord" "a_at" {
  zone = "${gandi_zone.zone.id}"
  name = "@"
  type = "A"
  ttl = 3600
  values = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
}

resource "gandi_zonerecord" "mx_at" {
  zone = "${gandi_zone.zone.id}"
  name = "@"
  type = "MX"
  ttl = 3600
  values = ["10 spool.mail.gandi.net.", "50 fb.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_imap" {
  zone = "${gandi_zone.zone.id}"
  name = "imap"
  type = "CNAME"
  ttl = 3600
  values = ["access.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_pop" {
  zone = "${gandi_zone.zone.id}"
  name = "pop"
  type = "CNAME"
  ttl = 3600
  values = ["access.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_smtp" {
  zone = "${gandi_zone.zone.id}"
  name = "smtp"
  type = "CNAME"
  ttl = 3600
  values = ["relay.mail.gandi.net"]
}

resource "gandi_zonerecord" "cname_webmail" {
  zone = "${gandi_zone.zone.id}"
  name = "webmail"
  type = "CNAME"
  ttl = 3600
  values = ["webmail.gandi.net."]
}

output "zone_id" {
  value = "${gandi_zone.zone.id}"
}
