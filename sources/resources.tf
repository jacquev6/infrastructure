locals {
  github_pages_ips = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
  # @todo Get this from module.gke_cluster_jacquev6_0002.fanout_ip
  # (I didn't manage to a void a "Error: module.domain_vincent_jacques_net.gandi_zonerecord.wildcard: values: should be a list")
  # (I suspect this is due to the *apparent* circular dependency domain.dns -> cluster -> domain.certificate)
  fanout_ip = "35.244.252.247"
}

module "domain_etcavole_fr" {
  source = "resources/domain_etcavole_fr"

  github_pages_ips = "${local.github_pages_ips}"
}

module "domain_jacquev6_net" {
  source = "resources/domain_jacquev6_net"

  github_pages_ips = "${local.github_pages_ips}"
}

module "domain_splight_fr" {
  source = "resources/domain_splight_fr"

  github_pages_ips = "${local.github_pages_ips}"
  fanout_ips = "${list(local.fanout_ip)}"
  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${acme_registration.registration.account_key_pem}"
}

module "domain_vincent_jacques_net" {
  source = "resources/domain_vincent_jacques_net"

  github_pages_ips = "${local.github_pages_ips}"
  fanout_ips = "${list(local.fanout_ip)}"
  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${acme_registration.registration.account_key_pem}"
}

module "gke_cluster_jacquev6_0002" {
  source = "resources/gke_cluster_jacquev6_0002"

  pre_shared_certificates = "${module.domain_vincent_jacques_net.wildcard_certificate_name}\\,${module.domain_splight_fr.certificate_name}\\,${module.domain_splight_fr.wildcard_certificate_name}"
}
