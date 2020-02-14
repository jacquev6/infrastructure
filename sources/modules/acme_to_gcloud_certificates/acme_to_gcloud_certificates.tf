variable "domain_name" {}

variable "gandi_api_key" {}

variable "acme_account_key_pem" {}

resource "acme_certificate" "certificate" {
  account_key_pem = "${var.acme_account_key_pem}"
  common_name = "${var.domain_name}"
  min_days_remaining = "20"  # To match ACME's e-mail reminder

  dns_challenge {
    provider = "gandiv5"

    config {
      GANDIV5_API_KEY = "${var.gandi_api_key}"
    }
  }
}

# @todo Avoid terraform error when certificate changes
# Currently, the new certificate is created, then the fanout ingress is updated and terraform tries to delete the old
# certificate, but the load balancer is still using it, so there is a "resource in use" error.
# Could we maybe use a provisioner that just sleeps for a while?
resource "google_compute_ssl_certificate" "certificate" {
  name_prefix = "${replace(var.domain_name, ".", "-")}-"
  description = "LetsEncrypt-issued certificate for ${var.domain_name}"
  private_key = "${acme_certificate.certificate.private_key_pem}"
  certificate = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "acme_certificate" "wildcard_certificate" {
  account_key_pem = "${var.acme_account_key_pem}"
  common_name = "*.${var.domain_name}"
  min_days_remaining = "20"  # To match ACME's e-mail reminder

  dns_challenge {
    provider = "gandiv5"

    config {
      GANDIV5_API_KEY = "${var.gandi_api_key}"
    }
  }
}

resource "google_compute_ssl_certificate" "wildcard_certificate" {
  name_prefix = "wildcard-${replace(var.domain_name, ".", "-")}-"
  description = "LetsEncrypt-issued wildcard certificate for *.${var.domain_name}"
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

output "wildcard_certificate_key" {
  value = "${acme_certificate.wildcard_certificate.private_key_pem}"
}

output "wildcard_certificate_crt" {
  value = "${acme_certificate.wildcard_certificate.certificate_pem}${acme_certificate.wildcard_certificate.issuer_pem}"
}
