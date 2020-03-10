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
  doorman = {
    name = "doorman"
    mac = "B8:27:EB:39:27:DF"
    ip = "192.168.1.51"
    dns = true
  }
  home_machines = [
    {
      name = "nas2"
      mac = "00:11:32:49:8B:63"
      ip = "192.168.1.50"
      dns = true
    },
    local.doorman,
    {
      name = "idee"
      mac = "1C:6F:65:37:A6:C6"
      ip = "192.168.1.52"
      dns = true
    },
    {
      name = "macbook"
      mac = "A4:83:E7:5E:19:B1"
      ip = "192.168.1.53"
      dns = true
    },
    {
      name = "icule"
      mac = "08:00:27:EE:68:DC"
      ip = "192.168.1.54"
      dns = true
    },
    {
      name = "switch"
      mac = "B8:8A:EC:C3:94:5D"
      ip = "192.168.1.55"
      dns = false
    },
    {
      name = "ps4"
      mac = "B0:52:16:E0:FE:99"
      ip = "192.168.1.56"
      dns = false
    },
    {
      name = "hue"
      mac = "EC:B5:FA:00:D4:3D"
      ip = "192.168.1.57"
      dns = false
    },
    {
      name = "pixel3"
      mac = "3C:28:6D:F5:CB:7C"
      ip = "192.168.1.58"
      dns = false
    },
    {
      name = "firetv"
      mac = "FC:65:DE:50:E5:34"
      ip = "192.168.1.59"
      dns = false
    },
    {
      name = "alexa"
      mac = "CC:F7:35:A3:05:19"
      ip = "192.168.1.60"
      dns = false
    },
    {
      name = "macbook.claire"
      mac = "2C:F0:EE:19:E3:82"
      ip = "192.168.1.61"
      dns = false
    },
    {
      name = "printer"
      mac = "30:CD:A7:A4:6E:02"
      ip = "192.168.1.62"
      dns = false
    },
    {
      name = "iphone.claire"
      mac = "1C:91:48:6A:E8:B4"
      ip = "192.168.1.63"
      dns = false
    },
    {
      name = "freebox-mini"
      mac = "68:A3:78:23:EC:C8"
      ip = "192.168.1.64"
      dns = false
    },
    {
      name = "ps3"
      mac = "F8:D0:AC:9D:CA:13"
      ip = "192.168.1.65"
      dns = false
    },
    {
      name = "media"
      mac = "B8:27:EB:21:C9:E7"
      ip = "192.168.1.66"
      dns = false
    },
    {
      name = "eeepc"
      mac = "74:2F:68:2D:EB:F2"
      ip = "192.168.1.67"
      dns = false
    }
    # @todo Add kindle.claire
    # @todo Add ipad.claire
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
      if machine.dns
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


resource "multiverse_custom_resource" "host_naming" {
  for_each = {
    for machine in local.home_machines:
    machine.name => machine
  }

  executor = "python3"
  script = "/terraform-provider-multiverse-freebox.py"
  id_key = "id"
  data = <<-JSON
    {
      "kind": "host_naming",
      "mac": "${each.value.mac}",
      "name": "${each.value.name}"
    }
  JSON
}


resource "multiverse_custom_resource" "port_forwarding" {
  for_each = {
    ssh = 22
    http = 80
    https = 443
  }

  executor = "python3"
  script = "/terraform-provider-multiverse-freebox.py"
  id_key = "id"
  data = <<-JSON
    {
      "kind": "port_forwarding",
      "port": ${each.value},
      "ip": "${local.doorman.ip}"
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
