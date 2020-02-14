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

output "wildcard_certificate_key" {
  value = "${acme_certificate.wildcard_certificate.private_key_pem}"
}

output "wildcard_certificate_crt" {
  value = "${acme_certificate.wildcard_certificate.certificate_pem}${acme_certificate.wildcard_certificate.issuer_pem}"
}
