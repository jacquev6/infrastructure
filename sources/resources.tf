module "domain_etcavole_fr" {
  source = "resources/domain_etcavole_fr"
}

module "domain_jacquev6_net" {
  source = "resources/domain_jacquev6_net"
}

module "domain_splight_fr" {
  source = "resources/domain_splight_fr"
  gandi_api_key = "${var.gandi_api_key}"
}

module "domain_vincent_jacques_net" {
  source = "resources/domain_vincent_jacques_net"
  gandi_api_key = "${var.gandi_api_key}"
}

module "gke_cluster_jacquev6_0002" {
  source = "resources/gke_cluster_jacquev6_0002"
}
