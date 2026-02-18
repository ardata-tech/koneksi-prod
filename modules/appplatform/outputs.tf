output "app_live_urls" {
  value = {
    for a in digitalocean_app.this :
    a.spec[0].name => a.live_url
  }
}

output "app_urns" {
  value = [for a in digitalocean_app.this : a.urn]
}

output "app_ids" {
  value = [for a in digitalocean_app.this : a.id]
}