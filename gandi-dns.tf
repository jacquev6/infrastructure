variable "gandi_api_key" {}

# go get github.com/tiramiseb/terraform-provider-gandi
# ln -sf $HOME/go/bin/terraform-provider-gandi .terraform/plugins/linux_amd64
provider "gandi" {
  key = "${var.gandi_api_key}"
}

resource "gandi_zone" "etcavole_fr" {
  name = "etcavole.fr"
}

resource "gandi_zonerecord" "a_at_etcavole_fr" {
  zone = "${gandi_zone.etcavole_fr.id}"
  name = "@"
  type = "A"
  ttl = 3600
  values = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
}

resource "gandi_zonerecord" "mx_at_etcavole_fr" {
  zone = "${gandi_zone.etcavole_fr.id}"
  name = "@"
  type = "MX"
  ttl = 3600
  values = ["10 spool.mail.gandi.net.", "50 fb.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_imap_etcavole_fr" {
  zone = "${gandi_zone.etcavole_fr.id}"
  name = "imap"
  type = "CNAME"
  ttl = 3600
  values = ["access.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_pop_etcavole_fr" {
  zone = "${gandi_zone.etcavole_fr.id}"
  name = "pop"
  type = "CNAME"
  ttl = 3600
  values = ["access.mail.gandi.net."]
}

resource "gandi_zonerecord" "cname_smtp_etcavole_fr" {
  zone = "${gandi_zone.etcavole_fr.id}"
  name = "smtp"
  type = "CNAME"
  ttl = 3600
  values = ["relay.mail.gandi.net"]
}

resource "gandi_zonerecord" "cname_webmail_etcavole_fr" {
  zone = "${gandi_zone.etcavole_fr.id}"
  name = "webmail"
  type = "CNAME"
  ttl = 3600
  values = ["webmail.gandi.net."]
}

resource "gandi_domainattachment" "etcavole_fr" {
    domain = "etcavole.fr"
    zone = "${gandi_zone.etcavole_fr.id}"
}
