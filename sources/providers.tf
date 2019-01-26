variable "gandi_api_key" {}

provider "gandi" {
  key = "${var.gandi_api_key}"
}

provider "google" {
  credentials = "${file("gcp-account.json")}"
  project = "jacquev6-0001"
  region = "europe-west1"
  zone = "europe-west1-c"
}
