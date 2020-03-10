variable "gandi_smtp_password" {
  type = string
}


resource "docker_image" "python" {
  name = "python:alpine"
  pull_triggers = ["python:alpine"]
}

resource "docker_container" "remind_running" {
  name  = "remind_running"
  image = docker_image.python.latest
  rm = "false"
  restart = "always"
  command = ["/remind_running.py"]
  upload {
    # @todo Add output from htop and nvidia-smi
    file = "/remind_running.py"
    content = templatefile(
      "${path.module}/remind_running.py",
      {
        gandi_smtp_password = var.gandi_smtp_password
      }
    )
    executable = true
  }
}
