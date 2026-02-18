variable "project" {
  type    = string
  default = "koneksi"
}

variable "do_token" {
  type      = string
  sensitive = true
}

variable "env" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "sgp1"
}

variable "do_project_name" {
  type    = string
  default = "koneksi-prod"
}

variable "vpc_ip_range" {
  type    = string
  default = "10.10.0.0/16"
}

# Droplets (1 redis + 3 vault = 4 total)
variable "droplet_count" {
  type    = number
  default = 3
}

variable "droplet_size" {
  type    = string
  default = "s-2vcpu-2gb"
}

variable "droplet_image" {
  type    = string
  default = "ubuntu-22-04-x64"
}

variable "droplet_ssh_key_fingerprints" {
  type    = list(string)
  default = []
}

variable "droplet_user_data" {
  type    = string
  default = null
}

variable "droplet_user_data_list" {
  type    = list(string)
  default = []
}

# Databases
variable "pg_version" {
  type    = string
  default = "15"
}

variable "pg_size" {
  type    = string
  default = "db-s-1vcpu-2gb"
}

variable "pg_nodes" {
  type    = number
  default = 1
}

variable "mongo_version" {
  type    = string
  default = "6"
}

variable "mongo_size" {
  type    = string
  default = "db-s-1vcpu-2gb"
}

variable "mongo_nodes" {
  type    = number
  default = 1
}

variable "db_allowed_ips" {
  type    = list(string)
  default = []
}

variable "db_name" {
  type    = string
  default = "koneksi"
}

# App Platform
variable "apps" {
  type = list(object({
    name        = string
    source      = string
    repo        = optional(string)
    branch      = optional(string)
    source_dir  = optional(string)
    image       = optional(string)
    auto_deploy = optional(bool, true)
    env         = optional(map(string), {})
    env_scope   = optional(string, "RUN_TIME")
    http_port   = optional(number)
    health_check_path = optional(string)
    domains     = optional(list(string), [])
  }))
  validation {
    condition = alltrue([
      for a in var.apps : (
        a.source == "github"
        ? (try(a.repo != null && a.branch != null, false))
        : (
          a.source == "image"
          ? (try(a.image != null, false) && can(regex("^.+/.+$", a.image)))
          : false
        )
      )
    ])
    error_message = "Each app must set source = \"github\" with repo/branch, or source = \"image\" with image in the form \"org/repo[:tag]\"."
  }
}

variable "app_instance_size_slug" {
  type    = string
  default = "basic-xs"
}

variable "app_instance_count" {
  type    = number
  default = 1
}

variable "app_http_port" {
  type    = number
  default = 8080
}

variable "app_vpc_uuid" {
  type    = string
  default = null
}