resource "local_file" "nginx_settings" {
  filename = "../nginx/etc/settings.json"
  content  = <<EOT
{
	"port": {
		"description": "Network port to listen the requests.",
		"value": ${var.host.listen_port}
	},
	"securePort": {
		"description": "Network port to listen the secure requests.",
		"value": ${var.host.secure_listen_port}
	}
}
EOT
}

resource "local_file" "nginx_sites" {
  filename = "../nginx/etc/conf.d/default.conf"
  content  = <<EOT
server {
	listen ${var.host.listen_port};
	listen ${var.host.secure_listen_port} ssl;
	http2 on;

    server_name ${var.stack.cloud.domain};

	ssl_certificate /etc/nginx/ssl/${var.stack.cloud.name}.pem;
	ssl_certificate_key /etc/nginx/ssl/${var.stack.cloud.name}.key;

	client_max_body_size 1G;

	location / {
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection Upgrade;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass ${var.stack.cloud.origin_protocol}://${var.stack.cloud.origin_host}:${var.stack.cloud.origin_port};
	}
}

server {
	listen ${var.host.listen_port};
	listen ${var.host.secure_listen_port} ssl;
	http2 on;

	server_name ${var.stack.git.domain};

	ssl_certificate /etc/nginx/ssl/${var.stack.git.name}.pem;
	ssl_certificate_key /etc/nginx/ssl/${var.stack.git.name}.key;

	location / {
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection Upgrade;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass ${var.stack.git.origin_protocol}://${var.stack.git.origin_host}:${var.stack.git.origin_port};
	}
}

server {
	listen ${var.host.listen_port};
	listen ${var.host.secure_listen_port} ssl;
	http2 on;

	server_name ${var.stack.gpt.domain};

	ssl_certificate /etc/nginx/ssl/${var.stack.gpt.name}.pem;
	ssl_certificate_key /etc/nginx/ssl/${var.stack.gpt.name}.key;

	location / {
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection Upgrade;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass ${var.stack.gpt.origin_protocol}://${var.stack.gpt.origin_host}:${var.stack.gpt.origin_port};
	}
}

server {
	listen ${var.host.listen_port};
	listen ${var.host.secure_listen_port} ssl;
	http2 on;

	server_name ${var.stack.notify.domain};

	ssl_certificate /etc/nginx/ssl/${var.stack.notify.name}.pem;
	ssl_certificate_key /etc/nginx/ssl/${var.stack.notify.name}.key;

	location / {
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection Upgrade;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass ${var.stack.notify.origin_protocol}://${var.stack.notify.origin_host}:${var.stack.notify.origin_port};
	}
}

server {
	listen ${var.host.listen_port};
	listen ${var.host.secure_listen_port} ssl;
	http2 on;

	server_name ${var.stack.search.domain};

	ssl_certificate /etc/nginx/ssl/${var.stack.search.name}.pem;
	ssl_certificate_key /etc/nginx/ssl/${var.stack.search.name}.key;

	location / {
        proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection Upgrade;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass ${var.stack.search.origin_protocol}://${var.stack.search.origin_host}:${var.stack.search.origin_port};
	}
}


server {
	listen ${var.host.listen_port};
	listen ${var.host.secure_listen_port} ssl;
	http2 on;

	server_name ${var.stack.stream.domain};

	ssl_certificate /etc/nginx/ssl/${var.stack.stream.name}.pem;
	ssl_certificate_key /etc/nginx/ssl/${var.stack.stream.name}.key;

	location / {
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection Upgrade;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass ${var.stack.stream.origin_protocol}://${var.stack.stream.origin_host}:${var.stack.stream.origin_port};
	}
}
EOT
}

resource "local_file" "search_limiter" {
  filename = "../${var.stack.search.base_dir}/etc/limiter.toml"
  content  = <<EOT
[botdetection.ip_lists]
pass_ip = [
  "127.0.0.1",
  "192.168.0.0/16",
  "10.0.0.0/8",
  "172.16.0.0/12"
]

[botdetection.ip_limit]
filter_link_local = false
EOT
}

resource "local_file" "search_settings" {
  filename = "../${var.stack.search.base_dir}/etc/settings.yml"
  content  = <<EOT
use_default_settings: true

server:
  secret_key: "${random_password.search_token.result}"
  bind_address: "0.0.0.0"
  port: ${var.stack.search.origin_port}
  limiter: false
  public_instance: false

search:
  safe_search: 0
  formats:
    - html
    - json
EOT

  depends_on = [random_password.search_token]
}

resource "local_file" "mcp-servers-cameras-settings" {
  filename = "../${var.stack.mcp-servers-cameras.base_dir}/etc/config.ini"
  content  = <<EOT
[server]
bearer_token = ${random_password.mcp-servers-cameras-api_token.result}

[camera1]
bearer_token = ${random_password.mcp-servers-cameras-api_token.result}
url = ${var.stack.mcp-servers-cameras.api_base_url}/office
timeout = ${var.stack.mcp-servers-cameras.api_timeout}
EOT

  depends_on = [random_password.mcp-servers-cameras-api_token]
}