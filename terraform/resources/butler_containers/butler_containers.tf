variable "certificates" {
  type = map(object({
    key = string
    crt = string
  }))
}

data "docker_registry_image" "nginx" {
  name = "nginx:1.17-alpine"
}

resource "docker_image" "nginx" {
  name = data.docker_registry_image.nginx.name
  pull_triggers = [data.docker_registry_image.nginx.sha256_digest]
  keep_locally = true
}
