resource "docker_container" "always_200" {
  name = "always_200"
  image = docker_image.nginx.latest
  rm = "false"
  restart = "always"
  networks_advanced {
    name = docker_network.fanout.name
  }
  upload {
    file = "/etc/nginx/nginx.conf"
    content = file("${path.module}/always_200.nginx.conf")
  }
}
