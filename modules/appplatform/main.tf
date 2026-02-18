terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

resource "digitalocean_app" "this" {
  count = length(var.apps)

  spec {
    name   = "${var.name_prefix}-${var.apps[count.index].name}"
    region = var.region

    dynamic "vpc" {
      for_each = var.vpc_uuid == null ? [] : [var.vpc_uuid]
      content {
        id = vpc.value
      }
    }

    dynamic "domain" {
      for_each = var.apps[count.index].domains == null ? [] : var.apps[count.index].domains
      content {
        name = domain.value
      }
    }

    service {
      name               = "web"
      instance_count     = var.instance_count
      instance_size_slug = var.instance_size_slug

      dynamic "github" {
        for_each = var.apps[count.index].source == "github" ? [var.apps[count.index]] : []
        content {
          repo           = github.value.repo
          branch         = github.value.branch
          deploy_on_push = try(github.value.auto_deploy, true)
        }
      }

      dynamic "image" {
        for_each = var.apps[count.index].source == "image" ? [var.apps[count.index]] : []
        content {
          registry_type = "DOCKER_HUB"
          registry      = split("/", image.value.image)[0]
          repository    = split(":", split("/", image.value.image)[1])[0]
          tag           = length(split(":", split("/", image.value.image)[1])) > 1 ? split(":", split("/", image.value.image)[1])[1] : "latest"

          deploy_on_push {
            enabled = try(image.value.auto_deploy, true)
          }
        }
      }

      source_dir = try(var.apps[count.index].source_dir, null)

      http_port = coalesce(try(var.apps[count.index].http_port, null), var.http_port)

      health_check {
        http_path = try(
          length(trimspace(var.apps[count.index].health_check_path)) > 0
          ? var.apps[count.index].health_check_path
          : "/",
          "/"
        )
      }

      dynamic "env" {
        for_each = var.apps[count.index].env == null ? {} : var.apps[count.index].env
        content {
          key   = env.key
          value = env.value
          scope = try(var.apps[count.index].env_scope, "RUN_TIME")
        }
      }
    }
  }
}