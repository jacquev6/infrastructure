module "domain_etcavole_fr" {
  source = "resources/domain_etcavole_fr"
}

module "domain_jacquev6_net" {
  source = "resources/domain_jacquev6_net"
}

module "domain_splight_fr" {
  source = "resources/domain_splight_fr"

  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${acme_registration.registration.account_key_pem}"
}

module "domain_vincent_jacques_net" {
  source = "resources/domain_vincent_jacques_net"

  gandi_api_key = "${var.gandi_api_key}"
  acme_account_key_pem = "${acme_registration.registration.account_key_pem}"
}

module "gke_cluster_jacquev6_0002" {
  source = "resources/gke_cluster_jacquev6_0002"

  pre_shared_certificates = "${module.domain_vincent_jacques_net.wildcard_certificate_name}\\,${module.domain_splight_fr.certificate_name}\\,${module.domain_splight_fr.wildcard_certificate_name}"
}
