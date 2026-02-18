variable "name_prefix" { type = string }
variable "region"      { type = string }

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

variable "instance_size_slug" {
  type    = string
  default = "basic-xxs"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "http_port" {
  type    = number
  default = 8080
}

variable "vpc_uuid" {
  type    = string
  default = null
}

variable "tags" {
  type    = list(string)
  default = []
}