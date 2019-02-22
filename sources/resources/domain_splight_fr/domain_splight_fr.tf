variable "gandi_api_key" {}

variable "acme_account_key_pem" {}

module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "splight.fr"
}

resource "gandi_zonerecord" "admin" {
  zone = "${module.gandi_dns.zone_id}"
  name = "admin"
  type = "A"
  ttl = 3600
  values = ["35.244.252.247"]
}

resource "gandi_zonerecord" "api_v1" {
  zone = "${module.gandi_dns.zone_id}"
  name = "api-v1"
  type = "A"
  ttl = 3600
  values = ["35.244.252.247"]
}

resource "acme_certificate" "certificate" {
  account_key_pem = "${var.acme_account_key_pem}"
  common_name = "splight.fr"

  dns_challenge {
    provider = "gandiv5"

    config {
      GANDIV5_API_KEY = "${var.gandi_api_key}"
    }
  }
}

resource "google_compute_ssl_certificate" "certificate" {
  name_prefix = "splight-fr-"
  description = "LetsEncrypt-issued certificate for splight.fr"
  private_key = "${acme_certificate.certificate.private_key_pem}"
  certificate = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "acme_certificate" "wildcard_certificate" {
  account_key_pem = "${var.acme_account_key_pem}"
  common_name = "*.splight.fr"

  dns_challenge {
    provider = "gandiv5"

    config {
      GANDIV5_API_KEY = "${var.gandi_api_key}"
    }
  }
}

resource "google_compute_ssl_certificate" "wildcard_certificate" {
  name_prefix = "wildcard-splight-fr-"
  description = "LetsEncrypt-issued wildcard certificate for *.splight.fr"
  private_key = "${acme_certificate.wildcard_certificate.private_key_pem}"
  certificate = "${acme_certificate.wildcard_certificate.certificate_pem}${acme_certificate.wildcard_certificate.issuer_pem}"

  lifecycle {
    create_before_destroy = true
  }
}

output "certificate_name" {
  value = "${google_compute_ssl_certificate.certificate.name}"
}

output "wildcard_certificate_name" {
  value = "${google_compute_ssl_certificate.wildcard_certificate.name}"
}
