# @todo Manage UptimeRobot (https://github.com/louy/terraform-provider-uptimerobot)
# @todo Manage ports redirections and static DHCP leases in FreeBox

locals {
  github_pages_ips = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
}

module "etcavole_fr_dns" {
  source = "modules/gandi_dns"

  domain_name = "etcavole.fr"
  a_at_ips = "${local.github_pages_ips}"
}

module "jacquev6_net_dns" {
  source = "resources/jacquev6_net_dns"

  github_pages_ips = "${local.github_pages_ips}"
}

module "vincent_jacques_net_certificates" {
  source = "modules/acme_to_gcloud_certificates"

  domain_name = "vincent-jacques.net"
  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${acme_registration.registration.account_key_pem}"
}

module "vincent_jacques_net_dns" {
  source = "resources/vincent_jacques_net_dns"

  github_pages_ips = "${local.github_pages_ips}"
}

module "doorman_containers" {
  source = "resources/doorman_containers"

  providers {
    docker = "docker.doorman"
  }

  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${acme_registration.registration.account_key_pem}"
  wildcard_vjnet_key = "${module.vincent_jacques_net_certificates.wildcard_certificate_key}"
  wildcard_vjnet_crt = "${module.vincent_jacques_net_certificates.wildcard_certificate_crt}"
}
