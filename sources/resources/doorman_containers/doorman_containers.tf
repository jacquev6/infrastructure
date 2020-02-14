variable "gandi_api_key" {}

variable "acme_account_key_pem" {}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

data "local_file" "always_200_nginx_conf" {
    filename = "${path.module}/nginx.conf"
}

resource "acme_certificate" "certificate" {
  account_key_pem = "${var.acme_account_key_pem}"
  common_name = "home.jacquev6.net"
  min_days_remaining = "20"  # To match ACME's e-mail reminder

  dns_challenge {
    provider = "gandiv5"

    config {
      GANDIV5_API_KEY = "${var.gandi_api_key}"
    }
  }
}

resource "docker_container" "always_200" {
  name  = "always_200"
  image = "${docker_image.nginx.latest}"  # Don't simply use "nginx:latest" here: it triggers a new container on every "infra apply"
  rm = "false"
  restart = "always"
  ports {
    internal = "80"
    external = "80"
  }
  ports {
    internal = "443"
    external = "443"
  }
  upload {
    file = "/usr/share/nginx/html/index.html"
    content = "This is fine\n"
  }
  upload {
    file = "/etc/nginx/nginx.conf"
    content = "${data.local_file.always_200_nginx_conf.content}"
  }
  upload {
    file = "/etc/nginx/home.jacquev6.net.crt"
    content = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
  }
  upload {
    file = "/etc/nginx/home.jacquev6.net.key"
    content = "${acme_certificate.certificate.private_key_pem}"
  }
}


resource "docker_image" "draw_turks_head_demo" {
  name = "jacquev6/draw-turks-head-demo:20200213-135841"
  # It's very weird that changing name does not trigger a new resource.
  # As a result, without pull_triggers, we need to run "infra apply" twice
  # after building a new version of draw_turks_head_demo.
  # This might be a bug in the provider. This might be fixed in more recent versions of Terraform and/or the provider.
  # @todo (after upgrading to latest terraform and provider versions) Remove the pull_triggers workaround and test if changing the name does replace the associated container.
  # If not, open an issue on https://github.com/terraform-providers/terraform-provider-docker.
  pull_triggers = ["jacquev6/draw-turks-head-demo:20200213-135841"]
}

resource "docker_container" "draw_turks_head_demo" {
  name  = "draw_turks_head_demo"
  image = "${docker_image.draw_turks_head_demo.latest}"
  rm = "false"
  restart = "always"
  # @todo readonly = "true"
  ports {
    internal = "80"
    external = "8081"
  }
  working_dir = "/"  # Weirdly required to avoid re-creating the container on every "infra apply"
}
