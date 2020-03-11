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
    # One lead: periodicaly run
    # (date; echo; ps faux; echo; nvidia-smi) | docker exec -i remind-running sh -c "cat >/remind-running.txt"
    # and then add the contents of this file to the body of the e-mail.
    # Would be better to run it only once before sending the e-mail though...
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
