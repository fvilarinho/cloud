resource "local_sensitive_file" "stack_secrets" {
  filename = "../.secrets"
  content  = <<EOT
export GITEA_RUNNER_REGISTRATION_TOKEN=${var.stack.git.runner_token}
export OPEN_TERMINAL_API_KEY=${var.stack.terminal.api_key}
EOT
}

resource "random_password" "search_token" {
  length  = 64
  special = false
}

resource "random_password" "mcp-servers-cameras-api_token" {
  length  = 64
  special = false
}
