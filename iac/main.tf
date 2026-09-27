terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare.api_token
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}