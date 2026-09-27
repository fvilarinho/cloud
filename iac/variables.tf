variable "cloudflare" {
  description = "Cloudflare API configuration."

  type = object({
    api_token = string
  })

  sensitive = true
}

variable "host" {
  description = "Host attributes."

  type = object({
    home_dir             = string
    name                 = string
    user                 = string
    private_key_filename = string
    listen_port          = number
    secure_listen_port   = number
  })
}

variable "stack" {
  description = "Stack configuration for services"

  type = object({
    cloud = object({
      description     = string
      package         = string
      domain          = string
      name            = string
      origin_host     = string
      origin_port     = number
      origin_protocol = string
      base_dir        = string
    })

    git = object({
      description     = string
      package         = string
      domain          = string
      name            = string
      origin_host     = string
      origin_port     = number
      origin_protocol = string
      runner_token    = string
      base_dir        = string
    })

    git-runner = object({
      description = string
      package     = string
      name        = string
      labels      = string
      origin_host = string
      base_dir    = string
    })

    gpt = object({
      description      = string
      package          = string
      domain           = string
      name             = string
      origin_host      = string
      origin_port      = number
      origin_protocol  = string
      backend_host     = string
      backend_port     = number
      backend_protocol = string
      base_dir         = string
    })

    mcp-servers-cameras = object({
      description  = string
      package      = string
      name         = string
      origin_host  = string
      base_dir     = string
      api_base_url = string
      api_timeout  = number
    })

    notify = object({
      description     = string
      package         = string
      domain          = string
      name            = string
      origin_host     = string
      origin_port     = number
      origin_protocol = string
      base_dir        = string
    })

    search = object({
      description     = string
      package         = string
      domain          = string
      name            = string
      origin_host     = string
      origin_port     = number
      origin_protocol = string
      base_dir        = string
    })

    stream = object({
      description     = string
      package         = string
      domain          = string
      name            = string
      origin_host     = string
      origin_port     = number
      origin_protocol = string
      base_dir        = string
    })

    terminal = object({
      description = string
      package     = string
      name        = string
      origin_host = string
      base_dir    = string
      api_key     = string
    })
  })
}