data "docker_registry_image" "docker_registry" {
  name = "registry:2"
}

resource "docker_image" "docker_registry" {
  name = data.docker_registry_image.docker_registry.name
  pull_triggers = [data.docker_registry_image.docker_registry.sha256_digest]
  keep_locally = true
}

resource "docker_container" "docker_registry" {
  name = "docker_registry"
  image = docker_image.docker_registry.latest
  rm = "false"
  restart = "always"
  networks_advanced {
    name = docker_network.private_fanout.name
  }
  mounts {
    type = "bind"
    source = "/home/jacquev6/Data/Hacking/DockerRegistry"
    target = "/var/lib/registry"
  }
}
