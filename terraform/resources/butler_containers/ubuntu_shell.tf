locals {
  ubuntu_shell_version = "20200321-155158"
}

resource "docker_image" "ubuntu_shell" {
  name = "jacquev6/infrastructure-tools:ubuntu_shell-${local.ubuntu_shell_version}"
  pull_triggers = [local.ubuntu_shell_version]
  keep_locally = true
}

resource "docker_volume" "ubuntu_shell_host_keys" {
  name = "ubuntu_shell_host_keys"
}

resource "docker_container" "ubuntu_shell" {
  name = "ubuntu_shell"
  hostname = "ubu_butler"
  image = docker_image.ubuntu_shell.latest
  rm = "false"
  restart = "always"
  # @todo docker run --init (to avoid defunk sshd processes)
  upload {
    file = "/ubuntu_shell.json"
    content = file("${path.module}/ubuntu_shell.json")
  }
  ports {
    internal = "22"
    external = "2222"
  }
  mounts {
    type = "volume"
    source = docker_volume.ubuntu_shell_host_keys.name
    target = "/etc/ssh/host_keys"
  }
  mounts {
    type = "bind"
    source = "/home/jacquev6"
    target = "/home/jacquev6"
  }
  mounts {
    type = "bind"
    source = "/etc/ssh/ssh_known_hosts"
    target = "/etc/ssh/ssh_known_hosts"
    read_only = true
  }
  mounts {
    type = "bind"
    source = "/var/run/docker.sock"
    target = "/var/run/docker.sock"
  }
}
