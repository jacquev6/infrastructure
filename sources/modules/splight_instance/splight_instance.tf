variable "instance_slug" {}
variable "images_version" {}

variable "api_public_url" {}
variable "cluster_name" {}

variable "instance_name" {}
variable "instance_warnings" {}

variable "periodical_backups" {}
variable "periodical_restores" {}
variable "periodical_test_data_restores" {}
variable "restore_once" {}

resource "google_compute_disk" "mongo" {
  name = "${var.cluster_name}-splight-${var.instance_slug}-mongo"
  type = "pd-standard"
  size = 10
}

resource "helm_release" "splight" {
  name = "splight-${var.instance_slug}"
  chart = "./charts/splight"

  set {
    name = "baseName"
    value = "splight-${var.instance_slug}"
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
    value = "${base64encode(file(format("splight-%s-backup.google-service-account.secret.json", var.instance_slug)))}"
  }

  set {
    name = "periodicalBackups"
    value = "${var.periodical_backups}"
  }

  set {
    name = "periodicalRestores"
    value = "${var.periodical_restores}"
  }

  set {
    name = "periodicalTestDataRestores"
    value = "${var.periodical_test_data_restores}"
  }

  set {
    name = "restoreOnce"
    value = "${var.restore_once}"
  }

  set {
    name = "apiPublicUrl"
    value = "${var.api_public_url}"
  }

  set {
    name = "instanceName"
    value = "${var.instance_name}"
  }

  set {
    name = "instanceWarnings"
    value = "${var.instance_warnings}"
  }
}
