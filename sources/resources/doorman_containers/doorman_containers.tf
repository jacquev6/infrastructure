variable "certificates" {
  type = map(object({
    key = string
    crt = string
  }))
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
}

resource "docker_container" "fanout" {
  name  = "fanout"
  image = docker_image.nginx.latest
  rm = "false"
  restart = "always"
  # @todo readonly = "true"
  ports {
    internal = "80"
    external = "80"
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


resource "docker_image" "draw_turks_head_demo" {
  name = "jacquev6/draw-turks-head-demo:20200213-135841"
  pull_triggers = ["jacquev6/draw-turks-head-demo:20200213-135841"]
}

resource "docker_container" "draw_turks_head_demo" {
  name  = "draw_turks_head_demo"
  image = docker_image.draw_turks_head_demo.latest
  rm = "false"
  restart = "always"
  # @todo readonly = "true"
  # @todo Use a Docker network, don't publish this port
  ports {
    internal = "80"
    external = "8081"
  }
  working_dir = "/"  # Weirdly required to avoid re-creating the container on every "infra apply"
}

resource "docker_container" "always_200" {
  name  = "always_200"
  image = docker_image.nginx.latest
  rm = "false"
  restart = "always"
  # @todo readonly = "true"
  # @todo Use a Docker network, don't publish this port
  ports {
    internal = "80"
    external = "8082"
  }
  upload {
    file = "/etc/nginx/nginx.conf"
    content = file("${path.module}/always_200.nginx.conf")
  }
}
