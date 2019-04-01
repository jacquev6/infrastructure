variable "sfrbox_login" {}

variable "sfrbox_password" {}

provider "sfrbox" {
  login = "${var.sfrbox_login}"
  password = "${var.sfrbox_password}"
}
