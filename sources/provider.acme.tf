provider "acme" {
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
# -- no wildcard certs?
# ++ no need to run ./infra apply at least once per three months
# == but anyway we'll soon be running it daily(?) on a Travis cron
