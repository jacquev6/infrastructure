variable "gandi_smtp_password" {
  type = string
}

locals {
  periodical_check_bot_version = "20200509-142054"
}

resource "docker_image" "periodical_check_bot" {
  name = "registry.jacquev6.net/periodical-check-bot:${local.periodical_check_bot_version}"
  pull_triggers = [local.periodical_check_bot_version, "a"]
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
