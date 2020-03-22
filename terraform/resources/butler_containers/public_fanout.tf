variable "certificates" {
  type = map(object({
    key = string
    crt = string
  }))
}

resource "docker_network" "public_fanout" {
  name = "public_fanout"
}

data "docker_registry_image" "nginx" {
  name = "nginx:1.17-alpine"
}

resource "docker_image" "nginx" {
  name = data.docker_registry_image.nginx.name
  pull_triggers = [data.docker_registry_image.nginx.sha256_digest]
  keep_locally = true
}

resource "docker_container" "public_fanout" {
  name = "public_fanout"
  image = docker_image.nginx.latest
  rm = "false"
  restart = "always"
  networks_advanced {
    name = docker_network.public_fanout.name
  }
  ports {
    external = "10443"
    internal = "443"
  }
  upload {
    file = "/etc/nginx/nginx.conf"
    content = file("${path.module}/public_fanout.nginx.conf")
  }
  upload {
    file = "/etc/nginx/home.jacquev6.net.crt"
    content = var.certificates["home.jacquev6.net"].crt
  }
  upload {
    file = "/etc/nginx/home.jacquev6.net.key"
    content = var.certificates["home.jacquev6.net"].key
  }
  upload {
    file = "/etc/nginx/www.vincent-jacques.net.crt"
    content = var.certificates["www.vincent-jacques.net"].crt
  }
  upload {
    file = "/etc/nginx/www.vincent-jacques.net.key"
    content = var.certificates["www.vincent-jacques.net"].key
  }
  upload {
    file = "/etc/nginx/dyn.vincent-jacques.net.crt"
    content = var.certificates["dyn.vincent-jacques.net"].crt
  }
  upload {
    file = "/etc/nginx/dyn.vincent-jacques.net.key"
    content = var.certificates["dyn.vincent-jacques.net"].key
  }
}
