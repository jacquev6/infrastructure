variable "acme_account_key" {
  type = string
}

variable "gandi_api_key" {
  type = string
}

variable "github_pages_ips" {
  type = list(string)
}

variable "home_ip" {
  type = string
}


module "dns" {
  source = "../../modules/gandi_dns"

  domain_name = "vincent-jacques.net"
  a_at_ips = var.github_pages_ips
  records = [
    {
      type = "A"
      name = "*"
      values = [var.home_ip]
    },
  ]
}

module "dyn_vincent_jacques_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "dyn.vincent-jacques.net"
}

module "www_vincent_jacques_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "www.vincent-jacques.net"
}

output "certificates" {
  value = {
    "dyn.vincent-jacques.net" = module.dyn_vincent_jacques_net_certificate.certificate
    "www.vincent-jacques.net" = module.www_vincent_jacques_net_certificate.certificate
  }
}
