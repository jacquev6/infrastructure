variable "name" {}

variable "pre_shared_certificates" {}

# @todo Handle deletion of prod_cluster
# Currently, deleting an instance of this module makes terraform complain about the missing providers
# because resources are still in the state but no provider is configured to handle their deletion.
# This suggests we need to find a way to configure the kubernetes and helm providers outside the module,
# even if they do depend on the cluster created here.

resource "google_container_cluster" "cluster" {
  name = "${var.name}"
  min_master_version = "1.11.7"

  initial_node_count = 1
  remove_default_node_pool = "true"
}

resource "google_container_node_pool" "np_01" {
  name = "np-01"
  cluster = "${google_container_cluster.cluster.name}"
  node_count = 2

  node_config {
    machine_type = "g1-small"
  }
}

provider "kubernetes" {
  version = "~> 1.5.1"

  host = "${google_container_cluster.cluster.endpoint}"
  username = "${google_container_cluster.cluster.master_auth.0.username}"
  password = "${google_container_cluster.cluster.master_auth.0.password}"
  client_certificate = "${base64decode(google_container_cluster.cluster.master_auth.0.client_certificate)}"
  client_key = "${base64decode(google_container_cluster.cluster.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)}"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
  automount_service_account_token = true
  depends_on = ["google_container_node_pool.np_01"]
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }
  subject {
    kind = "ServiceAccount"
    name = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
    api_group = ""
  }
  role_ref {
    kind  = "ClusterRole"
    name = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

provider "helm" {
  version = "~> 0.8.0"

  install_tiller = true
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  kubernetes = {
    host = "${google_container_cluster.cluster.endpoint}"
    username = "${google_container_cluster.cluster.master_auth.0.username}"
    password = "${google_container_cluster.cluster.master_auth.0.password}"
    client_certificate = "${base64decode(google_container_cluster.cluster.master_auth.0.client_certificate)}"
    client_key = "${base64decode(google_container_cluster.cluster.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)}"
  }
}

module "splight_preprod" {
  source = "../splight_instance"

  suffix = "preprod"
  images_version = "20190224-163505"
  api_public_url = "https://api-preprod.splight.fr/graphql" # @todo Remove "graphql"
  do_backups = "false"
  restore = "false" # Set to the date of the mongodump to restore e.g. "20190223-155347"

  providers {
    helm = "helm"
  }
}

module "splight_prod" {
  source = "../splight_instance"

  suffix = "prod"
  images_version = "20190224-163505"
  api_public_url = "https://api-prod.splight.fr/graphql" # @todo Remove "graphql"
  do_backups = "false"
  restore = "20190225-090010" # Set to the date of the mongodump to restore e.g. "20190223-155347"

  providers {
    helm = "helm"
  }
}

resource "google_compute_disk" "mongo" {
  name = "${var.name}-splight-mongo"
  type = "pd-standard"
  size = 10
}

resource "helm_release" "splight" {
  name = "splight"
  chart = "./charts/splight"

  set {
    name = "version"
    value = "20190224-163505"
  }

  set {
    name = "mongoPersistentDiskName"
    value = "${google_compute_disk.mongo.name}"
  }

  set {
    name = "splightBackupServiceAccount"
    value = "${base64encode(file("splight-backup.google-service-account.secret.json"))}"
  }

  set {
    name = "restore"
    value = "false" # Set to the date of the mongodump to restore e.g. "20190223-155347"
  }

  depends_on = [
    "kubernetes_cluster_role_binding.tiller"
  ]
}

resource "google_compute_global_address" "fanout" {
  name = "${var.name}-fanout"
}

output "fanout_ip" {
  value = "${google_compute_global_address.fanout.address}"
}

resource "helm_release" "main" {
  name = "main"
  chart = "./charts/main"

  set {
    name = "fanoutName"
    value = "${google_compute_global_address.fanout.name}"
  }

  set {
    name = "preSharedCertificates"
    value = "${var.pre_shared_certificates}"
  }

  depends_on = [
    "kubernetes_cluster_role_binding.tiller",
    "helm_release.splight"
  ]
}
