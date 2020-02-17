variable "domain_name" {
  type = string
}

variable "a_at_ips" {
  type = list(string)
}

resource "gandi_zone" "zone" {
  name = var.domain_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "gandi_domainattachment" "attachment" {
  domain = var.domain_name
  zone = gandi_zone.zone.id
}


variable "records" {
  type = list(object({
    type = string
    name = string
    values = list(string)
  }))
  default = []
}

resource "gandi_zonerecord" "record" {
  for_each = {
    for record in concat(
      var.records,
      [
        for name, values in {
          webmail = ["webmail.gandi.net."]
          smtp = ["relay.mail.gandi.net."]
          pop = ["access.mail.gandi.net."]
          imap = ["access.mail.gandi.net."]
        }:
          {
            type = "CNAME"
            name = name
            values = values
          }
      ],
      [
        {
          type = "MX"
          name = "@"
          values = ["10 spool.mail.gandi.net.", "50 fb.mail.gandi.net."]
        },
        {
          type = "A"
          name = "@"
          values = var.a_at_ips
        },
      ],
    ):
      "${record.type} ${record.name}" => record
  }

  zone = gandi_zone.zone.id
  ttl = 3600
  name = each.value.name
  type = each.value.type
  values = each.value.values
}
