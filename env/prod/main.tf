locals {
  name_prefix = "${var.project}-${var.env}"
  tags        = [var.project, var.env, "terraform"]
}

resource "digitalocean_vpc" "main" {
  name     = "${local.name_prefix}-vpc"
  region   = var.region
  ip_range = var.vpc_ip_range
}

data "digitalocean_project" "this" {
  name = var.do_project_name
}

resource "digitalocean_project_resources" "this" {
  project   = data.digitalocean_project.this.id
  resources = concat(
    module.droplets.droplet_urns,
    values(module.databases.postgres_urns),
    values(module.databases.mongo_urns),
    module.apps.app_urns
  )
}

module "droplets" {
  source = "../../modules/droplets"

  name_prefix            = "${local.name_prefix}-droplet"
  region                 = var.region
  droplet_count          = var.droplet_count
  size                   = var.droplet_size
  image                  = var.droplet_image
  ssh_key_fingerprints   = var.droplet_ssh_key_fingerprints
  user_data              = var.droplet_user_data
  user_data_list         = var.droplet_user_data_list
  vpc_uuid               = digitalocean_vpc.main.id
  tags                   = local.tags
}

module "databases" {
  source = "../../modules/databases"

  name_prefix = local.name_prefix
  region      = var.region
  vpc_uuid    = digitalocean_vpc.main.id
  droplet_ids = module.droplets.droplet_ids
  allowed_ips = var.db_allowed_ips
  allowed_app_ids = module.apps.app_ids
  tags        = local.tags

  postgres = {
    count   = 1
    version = var.pg_version
    size    = var.pg_size
    nodes   = var.pg_nodes
  }

  mongodb = {
    count   = 1
    version = var.mongo_version
    size    = var.mongo_size
    nodes   = var.mongo_nodes
  }

  db_name = var.db_name
}

module "apps" {
  source = "../../modules/appplatform"

  name_prefix         = local.name_prefix
  region              = var.region
  apps                = var.apps
  instance_size_slug  = var.app_instance_size_slug
  instance_count      = var.app_instance_count
  http_port           = var.app_http_port
  vpc_uuid            = coalesce(var.app_vpc_uuid, digitalocean_vpc.main.id)
  tags                = local.tags
}