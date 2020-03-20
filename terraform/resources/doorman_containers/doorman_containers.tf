variable "certificates" {
  type = map(object({
    key = string
    crt = string
  }))
}

variable "gandi_smtp_password" {
  type = string
}
