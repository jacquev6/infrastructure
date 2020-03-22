variable "certificates" {
  type = map(object({
    key = string
    crt = string
  }))
}

resource "docker_network" "fanout" {
  name = "fanout"
}

resource "docker_image" "nginx" {
  name = "nginx:1.17-alpine"

  # It's very weird that changing name does not trigger a new resource.
  # As a result, without pull_triggers, we need to run "infra apply" twice
  # after building a new version of draw_turks_head_demo.
  # This might be a bug in the provider. This might be fixed in more recent versions of Terraform and/or the provider.
  # @todo (after upgrading to latest terraform and provider versions) Remove the pull_triggers workaround and test if changing the name does replace the associated container.
  # If not, open an issue on https://github.com/terraform-providers/terraform-provider-docker.
  pull_triggers = ["nginx:1.17-alpine"]

  # Too many issues when deleting the image through Terrafom:
  #  - container stays down longer because next download is slow because common layers have been deleted
  #  - delete error because the image is still being used by another container
  keep_locally = true
}

resource "docker_container" "fanout" {
  name = "fanout"
  image = docker_image.nginx.latest
  rm = "false"
  restart = "always"
  networks_advanced {
    name = docker_network.fanout.name
  }
  ports {
    internal = "443"
    external = "443"
  }
  upload {
    file = "/etc/nginx/nginx.conf"
    content = file("${path.module}/fanout.nginx.conf")
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
    file = "/etc/nginx/infra.jacquev6.net.crt"
    content = var.certificates["infra.jacquev6.net"].crt
  }
  upload {
    file = "/etc/nginx/infra.jacquev6.net.key"
    content = var.certificates["infra.jacquev6.net"].key
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
