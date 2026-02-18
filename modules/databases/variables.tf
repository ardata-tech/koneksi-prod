variable "name_prefix" { type = string }
variable "region"      { type = string }

variable "postgres" {
  type = object({
    count   = number
    version = string
    size    = string
    nodes   = number
  })
}

variable "mongodb" {
  type = object({
    count   = number
    version = string
    size    = string
    nodes   = number
  })
}

variable "db_name" {
  type    = string
  default = "koneksi"
}

variable "droplet_ids" {
  type    = list(string)
  default = []
}

variable "allowed_ips" {
  type    = list(string)
  default = []
}

variable "allowed_app_ids" {
  type    = list(string)
  default = []
}

variable "vpc_uuid" {
  type    = string
  default = null
}

variable "tags" {
  type    = list(string)
  default = []
}