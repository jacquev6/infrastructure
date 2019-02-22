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

module "splight_fr_certificates" {
  source = "modules/acme_to_gcloud_certificates"

  domain_name = "splight.fr"
  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${acme_registration.registration.account_key_pem}"
}

module "vincent_jacques_net_certificates" {
  source = "modules/acme_to_gcloud_certificates"

  domain_name = "vincent-jacques.net"
  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${acme_registration.registration.account_key_pem}"
}

module "gke_cluster_jacquev6_0002" {
  source = "resources/gke_cluster_jacquev6_0002"

  pre_shared_certificates = "${module.vincent_jacques_net_certificates.wildcard_certificate_name}\\,${module.splight_fr_certificates.certificate_name}\\,${module.splight_fr_certificates.wildcard_certificate_name}"
}

module "splight_fr_dns" {
  source = "resources/splight_fr_dns"

  github_pages_ips = "${local.github_pages_ips}"
  fanout_ip = "${module.gke_cluster_jacquev6_0002.fanout_ip}"
}

module "vincent_jacques_net_dns" {
  source = "resources/vincent_jacques_net_dns"

  github_pages_ips = "${local.github_pages_ips}"
  fanout_ip = "${module.gke_cluster_jacquev6_0002.fanout_ip}"
}
