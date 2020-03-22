resource "docker_container" "redirect_http_to_https" {
  name = "redirect_http_to_https"
  image = docker_image.nginx.latest
  rm = "false"
  restart = "always"
  ports {
    internal = "80"
    external = "80"
  }
  upload {
    file = "/etc/nginx/nginx.conf"
    content = file("${path.module}/redirect_http_to_https.nginx.conf")
  }
}
