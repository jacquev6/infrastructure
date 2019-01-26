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
