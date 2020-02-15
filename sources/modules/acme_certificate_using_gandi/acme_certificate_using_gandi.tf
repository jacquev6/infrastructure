variable "domain_name" {
  type = string
}

variable "gandi_api_key" {
  type = string
}

variable "acme_account_key_pem" {
  type = string
}


resource "acme_certificate" "certificate" {
  account_key_pem = var.acme_account_key_pem
  common_name = var.domain_name
  min_days_remaining = "20"  # To match ACME's e-mail reminder

  dns_challenge {
    provider = "gandiv5"

    config = {
      GANDIV5_API_KEY = var.gandi_api_key
    }
  }
}


output "key" {
  value = acme_certificate.certificate.private_key_pem
}

output "crt" {
  value = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
}
