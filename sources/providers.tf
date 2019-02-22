# https://account.gandi.net/fr/users/jacquev6/security
variable "gandi_api_key" {}

provider "gandi" {
  key = "${var.gandi_api_key}"
}

# https://console.cloud.google.com/iam-admin/serviceaccounts/details/113793464457417850819?project=jacquev6-0001
provider "google" {
  credentials = "${file("gcp-account.json")}"
  project = "jacquev6-0001"
  region = "europe-west1"
  zone = "europe-west1-c"
}

# https://console.aws.amazon.com/iam/home?#/users/infrastructure-as-code Not used yet

# @todo Evaluate https://blog.jetstack.io/blog/kube-lego/
provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

# @todo Don't depend on file external to repository (except the git-crypt key file in .git/git-crypt)
resource "acme_registration" "registration" {
  account_key_pem = "${file("/ssh/id_rsa")}"
  email_address = "letsencrypt.org@vincent-jacques.net"
}
