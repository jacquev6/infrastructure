variable "certificates" {
  type = map(object({
    key = string
    crt = string
  }))
}

variable "gandi_smtp_password" {
  type = string
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


locals {
  draw_turks_head_demo_version = "20200321-072601"
}

resource "docker_image" "draw_turks_head_demo" {
  name = "jacquev6/draw-turks-head-demo:${local.draw_turks_head_demo_version}"
  pull_triggers = [local.draw_turks_head_demo_version]
  keep_locally = true
}

resource "docker_container" "draw_turks_head_demo" {
  name = "draw_turks_head_demo"
  image = docker_image.draw_turks_head_demo.latest
  rm = "false"
  restart = "always"
  networks_advanced {
    name = docker_network.fanout.name
  }
  working_dir = "/"  # Weirdly required to avoid re-creating the container on every "infra apply"
}

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


locals {
  periodical_check_bot_version = "20200318-144050"
}

resource "docker_image" "periodical_check_bot" {
  name = "jacquev6/infrastructure-tools:periodical_check_bot-${local.periodical_check_bot_version}"
  pull_triggers = [local.periodical_check_bot_version]
  keep_locally = true
}

resource "docker_container" "periodical_check_bot" {
  name = "periodical_check_bot"
  image = docker_image.periodical_check_bot.latest
  rm = "false"
  restart = "always"
  command = [
    "butler", "idee.home.jacquev6.net",
    "jacquev6@gmail.com",
    "--delay", "10800", "--period", "10800"
  ]
  env = [
    "SMTP_HOST=mail.gandi.net",
    "SMTP_PORT=465",
    "SMTP_USER=no-reply@vincent-jacques.net",
    "SMTP_PASSWORD=${var.gandi_smtp_password}",
    "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",  # Weirdly required to avoid re-creating the container on every "infra apply"
  ]
  upload {
    file = "/root/.ssh/id_rsa"
    content = file("${path.module}/butler.id_rsa")
  }
  mounts {
    type = "bind"
    target = "/etc/ssh/ssh_known_hosts"
    source = "/etc/ssh/ssh_known_hosts"
    read_only = true
  }
}
