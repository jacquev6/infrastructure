resource "tls_private_key" "acme_account" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = "${tls_private_key.acme_account.private_key_pem}"
  email_address = "letsencrypt.org@vincent-jacques.net"
}


output "account_key_pem" {
  value = "${acme_registration.registration.account_key_pem}"
}
