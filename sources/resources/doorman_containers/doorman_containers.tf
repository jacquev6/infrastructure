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
  # It's very weird that changing name does not trigger a new resource.
  # As a result, without pull_triggers, we need to run "infra apply" twice
  # after building a new version of draw_turks_head_demo.
  # This might be a bug in the provider.
  # @todo (after upgrading to latest terraform and provider versions) Remove the pull_triggers workaround and test if changing the name does replace the associated container.
  # If not, open an issue on https://github.com/terraform-providers/terraform-provider-docker.
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
