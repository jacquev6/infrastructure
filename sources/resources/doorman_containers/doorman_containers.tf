resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "always_200" {
  name  = "always_200"
  image = "${docker_image.nginx.latest}"  # Don't simply use "nginx:latest" here: it triggers a new container on every "infra apply"
  rm = "false"
  restart = "always"
  ports {
    internal = "80"
    external = "8080"
  }
}
