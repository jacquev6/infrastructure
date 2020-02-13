resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "always_200" {
  name  = "always_200"
  image = "${docker_image.nginx.latest}"  # Don't simply use "nginx:latest" here: it triggers a new container on every "infra apply"
  rm = "false"
  restart = "always"
  ports {
    internal = "80"
    external = "8080"
  }
}


resource "docker_image" "draw_turks_head_demo" {
  name = "jacquev6/draw-turks-head-demo:20200213-135841"
  pull_triggers = ["jacquev6/draw-turks-head-demo:20200213-135841"]
}

resource "docker_container" "draw_turks_head_demo" {
  name  = "draw_turks_head_demo"
  image = "${docker_image.draw_turks_head_demo.latest}"
  rm = "false"
  restart = "always"
  ports {
    internal = "80"
    external = "8081"
  }
  working_dir = "/"  # Weirdly required to avoid re-creating the container on every "infra apply"
}
