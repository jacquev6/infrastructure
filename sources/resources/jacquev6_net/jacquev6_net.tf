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
    # WARNING, the static DHCP configuration is maintained by hand at http://mafreebox.freebox.fr/
    {
      name = "nas2"
      mac = "00:11:32:49:8b:63"
      ip = "192.168.1.50"
    },
    {
      name = "doorman"
      mac = "b8:27:eb:39:27:df"
      ip = "192.168.1.51"
    },
    {
      name = "idee"
      mac = "1c:6f:65:37:a6:c6"
      ip = "192.168.1.52"
    },
    {
      name = "macbook"
      mac = "a4:83:e7:5e:19:b1"
      ip = "192.168.1.53"
    },
    {
      name = "icule"
      mac = "08:00:27:ee:68:dc"
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
