variable "acme_account_key" {
  type = string
}

variable "gandi_api_key" {
  type = string
}

variable "uptimerobot_alert_contact_id" {
  type = string
}

variable "github_pages_ips" {
  type = list(string)
}

variable "home_ip" {
  type = string
}


locals {
  macbook = {
    name = "macbook"
    mac = "A4:83:E7:5E:19:B1"
    ip = "192.168.1.53"
    dns = true
  }
  pi4b4_1 = {
    name = "pi4b4-1"
    mac = "DC:A6:32:F6:AD:DE"
    # WiFi MAC address is DC:A6:32:F6:AD:E1
    ip = "192.168.1.100"
    dns = true
  }
  home_machines = [
    # Pets
    {
      name = "nas2"
      mac = "00:11:32:49:8B:63"
      ip = "192.168.1.50"
      dns = true
    },
    {
      name = "idee"
      mac = "00:0C:F6:0E:D4:BB"
      ip = "192.168.1.52"
      dns = true
    },
    local.macbook,
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
      name = "alexa-1"
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
      mac = "9A:F3:A7:55:41:34"
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
      name = "eeepc-eth"
      mac = "54:04:A6:29:1F:1B"
      ip = "192.168.1.66"
      dns = false
    },
    {
      name = "eeepc"
      mac = "74:2F:68:2D:EB:F2"
      ip = "192.168.1.67"
      dns = true
    },
    {
      name = "probe-eth"
      mac = "B8:27:EB:74:9C:B2"
      ip = "192.168.1.68"
      dns = false
    },
    {
      name = "probe"
      mac = "B8:27:EB:21:C9:E7"
      ip = "192.168.1.69"
      dns = true
    },
    {
      name = "msi.claire"
      mac = "6C:62:6D:1A:36:B9"
      ip = "192.168.1.72"
      dns = false
    },
    {
      name = "alexa-2"
      mac = "F0:F0:A4:AC:86:82"
      ip = "192.168.1.73"
      dns = false
    },
    {
      name = "msi-eth.claire"
      mac = "40:61:86:BA:61:91"
      ip = "192.168.1.74"
      dns = false
    },
    {
      name = "teuse"
      mac = "08:00:27:FE:36:3B"
      ip = "192.168.1.75"
      dns = true
    },
    # @todo Add kindle.claire
    # @todo Add ipad.claire
    # Cattle
    # Naming: prefix-index
    # Prefix: machine type
    # pi4b4: Raspberry Pi 4 Model B with 4GB RAM
    local.pi4b4_1,
    {
      name = "pi4b4-2"
      mac = "DC:A6:32:F8:A4:AE"
      # WiFi MAC address is DC:A6:32:F8:A4:AF
      ip = "192.168.1.101"
      dns = true
    },
    {
      name = "pi4b4-3"
      mac = "DC:A6:32:6F:D6:7F"
      # WiFi MAC address is DC:A6:32:6F:D6:80"
      ip = "192.168.1.102"
      dns = true
    }
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
        type = "A"
        name = "www"
        values = [var.home_ip]
      },
      {
        type = "A"
        name = "ts3"
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
        # @todo Import and manage the associated Google Storage bucket
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
  script = "/infra/terraform-provider-multiverse-freebox.py"
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
  script = "/infra/terraform-provider-multiverse-freebox.py"
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
    http = {
      protocol = "tcp"
      external_port = 80
      internal_machine = local.pi4b4_1
      internal_port = 10080
    }
    https = {
      protocol = "tcp"
      external_port = 443
      internal_machine = local.pi4b4_1
      internal_port = 10443
    }
    teamspeak_voice = {
      protocol = "udp"
      external_port = 9987
      internal_machine = local.macbook
      internal_port = 9987
    }
    teamspeak_data = {
      protocol = "tcp"
      external_port = 30033
      internal_machine = local.macbook
      internal_port = 30033
    }
    teamspeak_query = {
      protocol = "tcp"
      external_port = 10011
      internal_machine = local.macbook
      internal_port = 10011
    }
  }

  executor = "python3"
  script = "/infra/terraform-provider-multiverse-freebox.py"
  id_key = "id"
  data = <<-JSON
    {
      "kind": "port_forwarding",
      "protocol": "${each.value.protocol}",
      "external_port": ${each.value.external_port},
      "ip": "${each.value.internal_machine.ip}",
      "internal_port": ${each.value.internal_port}
    }
  JSON
}


resource "uptimerobot_monitor" "http_jacquev6_net" {
  friendly_name = "http://jacquev6.net/"
  type = "http"
  url = "http://jacquev6.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_jacquev6_net" {
  friendly_name = "https://jacquev6.net/"
  type = "http"
  url = "https://jacquev6.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "http_home_jacquev6_net" {
  friendly_name = "http://home.jacquev6.net/"
  type = "http"
  url = "http://home.jacquev6.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_home_jacquev6_net" {
  friendly_name = "https://home.jacquev6.net/"
  type = "http"
  url = "https://home.jacquev6.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "http_www_jacquev6_net" {
  friendly_name = "http://www.jacquev6.net/"
  type = "http"
  url = "http://www.jacquev6.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}

resource "uptimerobot_monitor" "https_www_jacquev6_net" {
  friendly_name = "https://www.jacquev6.net/"
  type = "http"
  url = "https://www.jacquev6.net/"
  alert_contact {
    id = var.uptimerobot_alert_contact_id
  }
}


module "home_jacquev6_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "home.jacquev6.net"
}

module "infra_jacquev6_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "infra.jacquev6.net"
}

module "registry_jacquev6_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "registry.jacquev6.net"
}

module "www_jacquev6_net_certificate" {
  source = "../../modules/acme_certificate_using_gandi"

  acme_account_key = var.acme_account_key
  gandi_api_key = var.gandi_api_key
  domain_name = "www.jacquev6.net"
}

output "certificates" {
  value = {
    "home.jacquev6.net" = module.home_jacquev6_net_certificate.certificate
    "infra.jacquev6.net" = module.infra_jacquev6_net_certificate.certificate
    "registry.jacquev6.net" = module.registry_jacquev6_net_certificate.certificate
    "www.jacquev6.net" = module.www_jacquev6_net_certificate.certificate
  }
}
