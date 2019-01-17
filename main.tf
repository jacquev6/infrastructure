variable "gandi_api_key" {}

# go get github.com/tiramiseb/terraform-provider-gandi
# ln -sf $HOME/go/bin/terraform-provider-gandi .terraform/plugins/linux_amd64
provider "gandi" {
  key = "${var.gandi_api_key}"
}

module "etcavole_fr" {
  source = "./etcavole.fr"
}
