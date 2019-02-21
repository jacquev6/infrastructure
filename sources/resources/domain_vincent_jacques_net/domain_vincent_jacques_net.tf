variable "gandi_api_key" {}

module "gandi_dns" {
  source = "../../modules/gandi_dns"
  domain_name = "vincent-jacques.net"
}

resource "gandi_zonerecord" "wildcard" {
  zone = "${module.gandi_dns.zone_id}"
  name = "*"
  type = "A"
  ttl = 3600
  # @todo How to use module.gke_cluster_jacquev6_0002.google_compute_global_address.fanout.address
  values = ["35.244.252.247"]
}

resource "acme_certificate" "wildcard_certificate" {
  account_key_pem = "${file("/ssh/id_rsa")}"
  common_name = "*.vincent-jacques.net"

  dns_challenge {
    provider = "gandiv5"

    config {
      GANDIV5_API_KEY = "${var.gandi_api_key}"
    }
  }
}

resource "google_compute_ssl_certificate" "wildcard_certificate" {
  name = "wildcard-vincent-jacques-net"
  description = "LetsEncrypt-issued wildcard certificate for *.vincent-jacques.net"
  private_key = "${acme_certificate.wildcard_certificate.private_key_pem}"
  certificate = "${acme_certificate.wildcard_certificate.certificate_pem}"

  lifecycle {
    create_before_destroy = true
  }
}

output "wildcard_certificate_name" {
  value = "${google_compute_ssl_certificate.wildcard_certificate.name}"
}
