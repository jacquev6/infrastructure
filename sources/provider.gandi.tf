# https://account.gandi.net/fr/users/jacquev6/security
variable "gandi_api_key" {
  type = string
}

provider "gandi" {
  key = var.gandi_api_key
}
