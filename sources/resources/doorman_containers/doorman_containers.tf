resource "docker_container" "always_200" {
  name  = "always_200"
  image = "nginx:latest"
  rm = "false"
  restart = "always"
  ports {
    internal = "80"
    external = "8080"
  }
}
