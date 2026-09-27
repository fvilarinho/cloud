resource "acme_registration" "account" {
  account_key_pem = data.local_file.stack_private_key.content
  email_address   = "me@vila.net.br"
}

resource "acme_certificate" "cloud" {
  account_key_pem           = acme_registration.account.account_key_pem
  common_name               = var.stack.cloud.domain
  subject_alternative_names = [ var.stack.cloud.domain ]

  dns_challenge {
    provider = "cloudflare"
    config   = {
      CLOUDFLARE_DNS_API_TOKEN = var.cloudflare.api_token
    }
  }

  depends_on = [ acme_registration.account ]
}

resource "acme_certificate" "git" {
  account_key_pem           = acme_registration.account.account_key_pem
  common_name               = var.stack.git.domain
  subject_alternative_names = [ var.stack.git.domain ]

  dns_challenge {
    provider = "cloudflare"
    config   = {
      CLOUDFLARE_DNS_API_TOKEN = var.cloudflare.api_token
    }
  }

  depends_on = [ acme_registration.account ]
}

resource "acme_certificate" "gpt" {
  account_key_pem           = acme_registration.account.account_key_pem
  common_name               = var.stack.gpt.domain
  subject_alternative_names = [ var.stack.gpt.domain ]

  dns_challenge {
    provider = "cloudflare"
    config   = {
      CLOUDFLARE_DNS_API_TOKEN = var.cloudflare.api_token
    }
  }

  depends_on = [ acme_registration.account ]
}

resource "acme_certificate" "notify" {
  account_key_pem           = acme_registration.account.account_key_pem
  common_name               = var.stack.notify.domain
  subject_alternative_names = [ var.stack.notify.domain ]

  dns_challenge {
    provider = "cloudflare"
    config   = {
      CLOUDFLARE_DNS_API_TOKEN = var.cloudflare.api_token
    }
  }

  depends_on = [ acme_registration.account ]
}

resource "acme_certificate" "search" {
  account_key_pem           = acme_registration.account.account_key_pem
  common_name               = var.stack.search.domain
  subject_alternative_names = [ var.stack.search.domain ]

  dns_challenge {
    provider = "cloudflare"
    config   = {
      CLOUDFLARE_DNS_API_TOKEN = var.cloudflare.api_token
    }
  }

  depends_on = [ acme_registration.account ]
}

resource "acme_certificate" "stream" {
  account_key_pem           = acme_registration.account.account_key_pem
  common_name               = var.stack.stream.domain
  subject_alternative_names = [ var.stack.stream.domain ]

  dns_challenge {
    provider = "cloudflare"
    config   = {
      CLOUDFLARE_DNS_API_TOKEN = var.cloudflare.api_token
    }
  }

  depends_on = [ acme_registration.account ]
}

resource "local_file" "cloud_certificate" {
  filename = "../nginx/etc/ssl/${var.stack.cloud.name}.pem"
  content  = acme_certificate.cloud.certificate_pem

  depends_on = [ acme_certificate.cloud ]
}

resource "local_file" "cloud_certificate_key" {
  filename = "../nginx/etc/ssl/${var.stack.cloud.name}.key"
  content  = acme_certificate.cloud.private_key_pem

  depends_on = [ acme_certificate.cloud ]
}

resource "local_file" "git_certificate" {
  filename = "../nginx/etc/ssl/${var.stack.git.name}.pem"
  content  = acme_certificate.git.certificate_pem

  depends_on = [ acme_certificate.git ]
}

resource "local_file" "git_certificate_key" {
  filename = "../nginx/etc/ssl/${var.stack.git.name}.key"
  content  = acme_certificate.git.private_key_pem

  depends_on = [ acme_certificate.git ]
}

resource "local_file" "gpt_certificate" {
  filename = "../nginx/etc/ssl/${var.stack.gpt.name}.pem"
  content  = acme_certificate.gpt.certificate_pem

  depends_on = [ acme_certificate.gpt ]
}

resource "local_file" "gpt_certificate_key" {
  filename = "../nginx/etc/ssl/${var.stack.gpt.name}.key"
  content  = acme_certificate.gpt.private_key_pem

  depends_on = [ acme_certificate.gpt ]
}

resource "local_file" "notify_certificate" {
  filename = "../nginx/etc/ssl/${var.stack.notify.name}.pem"
  content  = acme_certificate.notify.certificate_pem

  depends_on = [ acme_certificate.notify ]
}

resource "local_file" "notify_certificate_key" {
  filename = "../nginx/etc/ssl/${var.stack.notify.name}.key"
  content  = acme_certificate.notify.private_key_pem

  depends_on = [ acme_certificate.notify ]
}

resource "local_file" "search_certificate" {
  filename = "../nginx/etc/ssl/${var.stack.search.name}.pem"
  content  = acme_certificate.search.certificate_pem

  depends_on = [ acme_certificate.search ]
}

resource "local_file" "search_certificate_key" {
  filename = "../nginx/etc/ssl/${var.stack.search.name}.key"
  content  = acme_certificate.search.private_key_pem

  depends_on = [ acme_certificate.search ]
}

resource "local_file" "stream_certificate" {
  filename = "../nginx/etc/ssl/${var.stack.stream.name}.pem"
  content  = acme_certificate.stream.certificate_pem

  depends_on = [ acme_certificate.stream ]
}

resource "local_file" "stream_certificate_key" {
  filename = "../nginx/etc/ssl/${var.stack.stream.name}.key"
  content  = acme_certificate.stream.private_key_pem

  depends_on = [ acme_certificate.stream ]
}
