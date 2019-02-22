variable "pre_shared_certificates" {}

resource "google_compute_global_address" "fanout" {
  name = "fanout"
}

resource "google_container_cluster" "cluster" {
  name = "jacquev6-0002"
  min_master_version = "1.11.6"

  initial_node_count = 1
  remove_default_node_pool = "true"
}

resource "google_container_node_pool" "node_pool_0001" {
  name = "${google_container_cluster.cluster.name}-0001"
  cluster = "${google_container_cluster.cluster.name}"
  node_count = 2

  node_config {
    machine_type = "g1-small"
  }
}

provider "kubernetes" {
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
  depends_on = ["google_container_cluster.cluster"]
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
}
