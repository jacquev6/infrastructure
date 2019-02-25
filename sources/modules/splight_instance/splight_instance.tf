variable "suffix" {}

variable "images_version" {}

variable "api_public_url" {}

variable "restore" {}

variable "do_backups" {}

resource "google_compute_disk" "mongo" {
  name = "splight-${var.suffix}-mongo"
  type = "pd-standard"
  size = 10
}

resource "helm_release" "splight" {
  name = "splight-${var.suffix}"
  chart = "./charts/splight"

  set {
    name = "baseName"
    value = "splight-${var.suffix}"
  }

  set {
    name = "version"
    value = "${var.images_version}"
  }

  set {
    name = "mongoPersistentDiskName"
    value = "${google_compute_disk.mongo.name}"
  }

  set {
    name = "splightBackupServiceAccount"
    value = "${base64encode(file(format("splight-%s-backup.google-service-account.secret.json", var.suffix)))}"
  }

  set {
    name = "doBackups"
    value = "${var.do_backups}"
  }

  set {
    name = "restore"
    value = "${var.restore}"
  }

  set {
    name = "apiPublicUrl"
    value = "${var.api_public_url}"
  }
}
