locals {
  draw_turks_head_demo_version = "20200322-152746"
}

resource "docker_image" "draw_turks_head_demo" {
  name = "jacquev6/draw-turks-head-demo:${local.draw_turks_head_demo_version}"
  pull_triggers = [local.draw_turks_head_demo_version]
  keep_locally = true
}

resource "docker_container" "draw_turks_head_demo" {
  name = "draw_turks_head_demo"
  image = docker_image.draw_turks_head_demo.latest
  rm = "false"
  restart = "always"
  networks_advanced {
    name = docker_network.public_fanout.name
  }
  working_dir = "/"  # Weirdly required to avoid re-creating the container on every "infra apply"
}
