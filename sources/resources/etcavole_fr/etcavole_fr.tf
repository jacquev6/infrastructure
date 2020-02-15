variable "github_pages_ips" {
  type = "list"
}


module "gandi_dns" {
  source = "../../modules/gandi_dns"

  domain_name = "etcavole.fr"
  a_at_ips = "${var.github_pages_ips}"
}
