variable "certificates" {
  type = map(object({
    key = string
    crt = string
  }))
}
