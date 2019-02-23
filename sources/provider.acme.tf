provider "acme" {
  version = "~> 1.0.1"

  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "acme" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = "${tls_private_key.acme.private_key_pem}"
  email_address = "letsencrypt.org@vincent-jacques.net"
}

# About https://blog.jetstack.io/blog/kube-lego/:
# -- no wildcard certs? (and we kinda need them because we can't put many certs on a GCP LB)
# ++ no need to run ./infra apply at least once per three months
# == but anyway we'll soon be running it daily(?) on a Travis cron
