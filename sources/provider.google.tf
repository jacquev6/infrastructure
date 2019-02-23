# https://console.cloud.google.com/iam-admin/serviceaccounts/details/113793464457417850819?project=jacquev6-0001
provider "google" {
  version = "~> 1.20.0"

  credentials = "${file("provider.google.secret.json")}"
  project = "jacquev6-0001"
  region = "europe-west1"
  zone = "europe-west1-c"
}
