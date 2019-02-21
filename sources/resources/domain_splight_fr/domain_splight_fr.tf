variable "gandi_api_key" {}

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
  account_key_pem = "${file("/ssh/id_rsa")}"
  common_name = "splight.fr"

  dns_challenge {
    provider = "gandiv5"

    config {
      GANDIV5_API_KEY = "${var.gandi_api_key}"
    }
  }
}

resource "google_compute_ssl_certificate" "certificate" {
  name = "splight-fr"
  description = "LetsEncrypt-issued certificate for splight.fr"
  private_key = "${acme_certificate.certificate.private_key_pem}"
  certificate = "${acme_certificate.certificate.certificate_pem}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "acme_certificate" "wildcard_certificate" {
  account_key_pem = "${file("/ssh/id_rsa")}"
  common_name = "*.splight.fr"

  dns_challenge {
    provider = "gandiv5"

    config {
      GANDIV5_API_KEY = "${var.gandi_api_key}"
    }
  }
}

resource "google_compute_ssl_certificate" "wildcard_certificate" {
  name = "wildcard-splight-fr"
  description = "LetsEncrypt-issued wildcard certificate for *.splight.fr"
  private_key = "${acme_certificate.wildcard_certificate.private_key_pem}"
  certificate = "${acme_certificate.wildcard_certificate.certificate_pem}"

# @todo Understand why the certificates make Firefox happy but curl sad.
# https://community.letsencrypt.org/t/curl-does-not-trust-le-certs-on-plain-debian/54091/10
# https://www.digicert.com/ssl-support/pem-ssl-creation.htm
# It looks like the GCP load balancer is not transmitting the intermediate cert
# but browsers are happy anyway because they cahce those interm certs.
# Curl doesn't. But the interm cert is available in as acme_certificate.certificate.issuer_pem
# So we should be able to pass it to google_compute_ssl_certificate.certificate like this:
# certificate = "${acme_certificate.wildcard_certificate.certificate_pem}\n${acme_certificate.wildcard_certificate.issuer_pem}"
# but we need to fix the fanout k8s ingress beforehand to be able to create google_compute_ssl_certificate with "name_prefix" instead of "name".

  lifecycle {
    create_before_destroy = true
  }
}
