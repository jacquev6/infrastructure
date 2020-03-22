resource "docker_network" "private_fanout" {
  name = "private_fanout"
}

resource "docker_container" "private_fanout" {
  name = "private_fanout"
  image = docker_image.nginx.latest
  rm = "false"
  restart = "always"
  networks_advanced {
    name = docker_network.private_fanout.name
  }
  ports {
    external = "443"
    internal = "443"
  }
  upload {
    file = "/etc/nginx/nginx.conf"
    content = file("${path.module}/private_fanout.nginx.conf")
  }
  upload {
    file = "/etc/nginx/infra.jacquev6.net.crt"
    content = var.certificates["infra.jacquev6.net"].crt
  }
  upload {
    file = "/etc/nginx/infra.jacquev6.net.key"
    content = var.certificates["infra.jacquev6.net"].key
  }
  upload {
    file = "/etc/nginx/registry.jacquev6.net.crt"
    content = var.certificates["registry.jacquev6.net"].crt
  }
  upload {
    file = "/etc/nginx/registry.jacquev6.net.key"
    content = var.certificates["registry.jacquev6.net"].key
  }
}
