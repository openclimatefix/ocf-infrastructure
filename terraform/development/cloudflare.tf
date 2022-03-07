resource "cloudflare_record" "api-dev" {
  zone_id = var.cloudflare_zone_id
  name    = "api-dev"
  value   = "nowcasting-api-development.eu-west-1.elasticbeanstalk.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "api-prod" {
  zone_id = var.cloudflare_zone_id
  name    = "api"
  value   = "nowcasting-api-dev.eba-ubddnyyw.eu-west-1.elasticbeanstalk.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "frontend-app" {
  zone_id = var.cloudflare_zone_id
  name    = "app"
  value   = "cname.vercel-dns.com"
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "frontend-website" {
  zone_id = var.cloudflare_zone_id
  name    = "nowcasting.io"
  value   = "cname.vercel-dns.com"
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "frontend-website-www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  value   = "cname.vercel-dns.com"
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "public-status-dashboard" {
  zone_id = var.cloudflare_zone_id
  name    = "status"
  value   = "statuspage.betteruptime.com"
  type    = "CNAME"
  ttl     = 1
  proxied = false
}
