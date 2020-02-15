# @todo Manage UptimeRobot (https://github.com/louy/terraform-provider-uptimerobot)
# @todo Manage ports redirections and static DHCP leases in FreeBox

locals {
  github_pages_ips = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
  # Home IP is now fixed, thanks to Free.
  # Before that, I was using CNAME DNS records pointing at "home-jacquev6-net.synology.me."
  home_ip = "82.65.16.120"
}


module "acme_registration" {
  source = "resources/acme_registration"
}


module "etcavole_fr" {
  source = "resources/etcavole_fr"

  github_pages_ips = "${local.github_pages_ips}"
}


module "jacquev6_net" {
  source = "resources/jacquev6_net"

  github_pages_ips = "${local.github_pages_ips}"
  home_ip = "${local.home_ip}"
}


module "vincent_jacques_net_wildcard_certificate" {
  source = "modules/acme_certificate_using_gandi"

  acme_account_key_pem = "${module.acme_registration.account_key_pem}"
  gandi_api_key = "${var.gandi_api_key}"
  domain_name = "*.vincent-jacques.net"
}


module "vincent_jacques_net" {
  source = "resources/vincent_jacques_net"

  github_pages_ips = "${local.github_pages_ips}"
  home_ip = "${local.home_ip}"
}


module "doorman_containers" {
  source = "resources/doorman_containers"

  providers {
    docker = "docker.doorman"
  }

  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${module.acme_registration.account_key_pem}"
  wildcard_vjnet_key = "${module.vincent_jacques_net_wildcard_certificate.key}"
  wildcard_vjnet_crt = "${module.vincent_jacques_net_wildcard_certificate.crt}"
}
