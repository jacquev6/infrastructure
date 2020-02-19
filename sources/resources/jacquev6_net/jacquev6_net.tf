variable "acme_account_key" {
  type = string
}

variable "gandi_api_key" {
  type = string
}

variable "github_pages_ips" {
  type = list(string)
}

variable "home_ip" {
  type = string
}


locals {
  home_machines = [
    {
      name = "nas2"
      mac = "00:11:32:49:8B:63"
      ip = "192.168.1.50"
    },
    {
      name = "doorman"
      mac = "B8:27:EB:39:27:DF"
      ip = "192.168.1.51"
    },
    {
      name = "idee"
      mac = "1C:6F:65:37:A6:C6"
      ip = "192.168.1.52"
    },
    {
      name = "macbook"
      mac = "A4:83:E7:5E:19:B1"
      ip = "192.168.1.53"
    },
    {
      name = "icule"
      mac = "08:00:27:EE:68:DC"
      ip = "192.168.1.54"
    },
  ]
}

module "dns" {
  source = "../../modules/gandi_dns"

  domain_name = "jacquev6.net"
  a_at_ips = var.github_pages_ips
  records = concat(
    [
      for machine in local.home_machines:
        {
          type = "A"
          name = "${machine.name}.home"
          values = [machine.ip]
        }
    ],
    [
      {
        type = "A"
        name = "home"
        values = [var.home_ip]
      },
      {
        type = "CNAME"
        name = "parents"
        values = ["parents-jacquev6-net.synology.me."]
      },
      {
        type = "CNAME"
        name = "shared"
        values = ["c.storage.googleapis.com."]
      },
    ]
  )
}


resource "multiverse_custom_resource" "static_dhcp_lease" {
  for_each = {
    for machine in local.home_machines:
    machine.name => machine
  }

  executor = "python3"
  script = "/terraform-provider-multiverse-freebox.py"
  id_key = "id"
  data = <<-JSON
    {
      "kind": "static_dhcp_lease",
      "mac": "${each.value.mac}",
      "ip": "${each.value.ip}"
    }
  JSON
}


data "uptimerobot_account" "account" {}

data "uptimerobot_alert_contact" "default" {
  friendly_name = "${data.uptimerobot_account.account.email}"
}

resource "uptimerobot_monitor" "http_jacquev6_net" {
  friendly_name = "http://jacquev6.net/"
  type = "http"
  url = "http://jacquev6.net/"
  alert_contact {
    id = data.uptimerobot_alert_contact.default.id
  }
}

resource "uptimerobot_monitor" "https_jacquev6_net" {
  friendly_name = "https://jacquev6.net/"
  type = "http"
  url = "https://jacquev6.net/"
  alert_contact {
    id = data.uptimerobot_alert_contact.default.id
  }
}

resource "uptimerobot_monitor" "http_home_jacquev6_net" {
  friendly_name = "http://home.jacquev6.net/"
  type = "http"
  url = "http://home.jacquev6.net/"
  alert_contact {
    id = data.uptimerobot_alert_contact.default.id
  }
}

resource "uptimerobot_monitor" "https_home_jacquev6_net" {
  friendly_name = "https://home.jacquev6.net/"
  type = "http"
  url = "https://home.jacquev6.net/"
  alert_contact {
    id = data.uptimerobot_alert_contact.default.id
  }
}


module "home_jacquev6_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "home.jacquev6.net"
}

output "certificates" {
  value = {
    "home.jacquev6.net" = module.home_jacquev6_net_certificate.certificate
  }
}
