data "local_file" "stack_private_key" {
  filename = abspath(pathexpand(var.host.private_key_filename))
}

resource "local_file" "stack" {
  filename = "../docker-compose.yml"
  content  = <<EOT
services:
  # ${var.stack.cloud.description}
  ${var.stack.cloud.name}:
    image: ${var.stack.cloud.package}
    container_name: ${var.stack.cloud.name}
    hostname: ${var.stack.cloud.origin_host}
    restart: always
    environment:
      - OWNCLOUD_DOMAIN=${var.stack.cloud.domain}
      - OWNCLOUD_TRUSTED_DOMAINS=localhost,${var.stack.cloud.origin_host},${var.stack.cloud.domain}
    volumes:
      - ${var.stack.cloud.name}_data:/mnt/data
      - /mnt/data/downloads:/media/downloads
      - /mnt/data/files:/media/files
      - /mnt/data/movies:/media/movies
      - /mnt/data/photos_videos:/media/photos_videos
      - /mnt/data/music:/media/music

  # ${var.stack.git.description}
  ${var.stack.git.name}:
    image: ${var.stack.git.package}
    container_name: ${var.stack.git.name}
    hostname: ${var.stack.git.origin_host}
    restart: always
    volumes:
      - ${var.stack.git.name}_data:/data

  # ${var.stack.git-runner.description}
  ${var.stack.git-runner.name}:
    image: ${var.stack.git-runner.package}
    container_name: ${var.stack.git-runner.name}
    hostname: ${var.stack.git-runner.origin_host}
    environment:
      - GITEA_INSTANCE_URL=${var.stack.git.origin_protocol}://${var.stack.git.origin_host}:${var.stack.git.origin_port}
      - GITEA_RUNNER_NAME=${var.stack.git-runner.name}
      - GITEA_RUNNER_LABELS=${var.stack.git-runner.labels}
      - GITEA_RUNNER_REGISTRATION_TOKEN=$${GITEA_RUNNER_REGISTRATION_TOKEN}
    restart: always
    volumes:
      - ${var.stack.git-runner.name}_data:/data
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - ${var.stack.git.name}

  # ${var.stack.gpt.description}
  ${var.stack.gpt.name}:
    image: ${var.stack.gpt.package}
    container_name: ${var.stack.gpt.name}
    hostname: ${var.stack.gpt.origin_host}
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: always
    environment:
      - OLLAMA_BASE_URL=${var.stack.gpt.backend_protocol}://${var.stack.gpt.backend_host}:${var.stack.gpt.backend_port}
    volumes:
      - ${var.stack.gpt.name}_data:/app/backend/data

  # ${var.stack.mcp-servers-cameras.description}
  ${var.stack.mcp-servers-cameras.name}:
    image: ${var.stack.mcp-servers-cameras.package}
    container_name: ${var.stack.mcp-servers-cameras.name}
    hostname: ${var.stack.mcp-servers-cameras.origin_host}
    restart: always
    volumes:
      - ./${var.stack.mcp-servers-cameras.base_dir}/etc/config.ini:/home/server/etc/config.ini:ro

  # ${var.stack.notify.description}
  ${var.stack.notify.name}:
    image: ${var.stack.notify.package}
    container_name: ${var.stack.notify.name}
    hostname: ${var.stack.notify.origin_host}
    restart: always
    command: serve
    environment:
      - NTFY_BASE_URL=https://${var.stack.notify.domain}
      - NTFY_ENABLE_LOGIN=true
      - NTFY_REQUIRE_LOGIN=true
      - NTFY_BEHIND_PROXY=true
      - NTFY_AUTH_FILE=/var/lib/ntfy/auth.db
      - NTFY_AUTH_DEFAULT_ACCESS=deny-all
      - NTFY_UPSTREAM_BASE_URL=https://ntfy.sh
    volumes:
      - ${var.stack.notify.name}_data:/var/lib/ntfy

  # ${var.stack.search.description}
  ${var.stack.search.name}:
    image: ${var.stack.search.package}
    container_name: ${var.stack.search.name}
    hostname: ${var.stack.search.origin_host}
    restart: always
    environment:
      - SEARXNG_BASE_URL=https://${var.stack.search.domain}
    volumes:
      - ./${var.stack.search.base_dir}/etc/limiter.toml:/etc/searxng/limiter.toml:ro
      - ./${var.stack.search.base_dir}/etc/settings.yml:/etc/searxng/settings.yml:ro
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID

  # ${var.stack.terminal.description}
  ${var.stack.terminal.name}:
    image: ${var.stack.terminal.package}
    container_name: ${var.stack.terminal.name}
    hostname: ${var.stack.terminal.origin_host}
    restart: always
    environment:
      - OPEN_TERMINAL_API_KEY=$${OPEN_TERMINAL_API_KEY}
    volumes:
      - ${var.stack.terminal.name}_data:/home/user
      - /var/run/docker.sock:/var/run/docker.sock

  # ${var.stack.stream.description}
  ${var.stack.stream.name}:
    image: ${var.stack.stream.package}
    container_name: ${var.stack.stream.name}
    hostname: ${var.stack.stream.origin_host}
    restart: always
    environment:
      - JELLYFIN_PublishedServerUrl=https://${var.stack.stream.domain}
    volumes:
      - ${var.stack.stream.name}_config:/config
      - ${var.stack.stream.name}_cache:/cache
      - /mnt/data/movies:/media/movies:ro
      - /mnt/data/music:/media/music:ro
      - /mnt/data/photos_videos:/media/photos_videos:ro

  # Settings server.
  etcd:
    image: ghcr.io/fvilarinho/etcd:1.2.0
    container_name: etcd
    hostname: etcd
    restart: always
    volumes:
      - ./nginx/etc/settings.json:/home/user/etc/nginx.json:ro
      - etcd_data:/home/user/data

  # Proxy server.
  nginx:
    image: ghcr.io/fvilarinho/nginx:1.2.0
    container_name: nginx
    hostname: nginx
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: always
    ports:
      - "${var.host.listen_port}:${var.host.listen_port}"
      - "${var.host.secure_listen_port}:${var.host.secure_listen_port}"
    volumes:
      - ./nginx/etc/ssl:/etc/nginx/ssl:ro
      - ./nginx/etc/conf.d/default.conf:/home/user/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - etcd
      - ${var.stack.cloud.name}
      - ${var.stack.git.name}
      - ${var.stack.git-runner.name}
      - ${var.stack.gpt.name}
      - ${var.stack.mcp-servers-cameras.name}
      - ${var.stack.notify.name}
      - ${var.stack.search.name}
      - ${var.stack.terminal.name}
      - ${var.stack.stream.name}

volumes:
  etcd_data:
  ${var.stack.cloud.name}_data:
  ${var.stack.git.name}_data:
  ${var.stack.git-runner.name}_data:
  ${var.stack.gpt.name}_data:
  ${var.stack.notify.name}_data:
  ${var.stack.terminal.name}_data:
  ${var.stack.stream.name}_config:
  ${var.stack.stream.name}_cache:
EOT
}

resource "null_resource" "stack_setup" {
  triggers = {
    hash = "${local_file.cloud_certificate.content_md5}|${local_file.git_certificate.content_md5}|${local_file.gpt_certificate.content_md5}|${local_file.mcp-servers-cameras-settings.content_md5}|${local_file.nginx_settings.content_md5}|${local_file.nginx_sites.content_md5}|${local_file.notify_certificate.content_md5}|${local_file.search_certificate.content_md5}|${local_file.search_limiter.content_md5}|${local_file.search_settings.content_md5}|${local_file.stack.content_md5}|${local_file.stream_certificate.content_md5}|${filemd5(abspath("../start.sh"))}|${filemd5(abspath("../stop.sh"))}"
  }

  connection {
    host        = var.host.name
    user        = var.host.user
    private_key = data.local_file.stack_private_key.content
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.host.home_dir}/etcd/etc",
      "mkdir -p ${var.host.home_dir}/nginx/etc/conf.d",
      "mkdir -p ${var.host.home_dir}/nginx/etc/ssl",
      "mkdir -p ${var.host.home_dir}/${var.stack.cloud.base_dir}/etc",
      "mkdir -p ${var.host.home_dir}/${var.stack.git.base_dir}/etc",
      "mkdir -p ${var.host.home_dir}/${var.stack.git-runner.base_dir}/etc",
      "mkdir -p ${var.host.home_dir}/${var.stack.gpt.base_dir}/etc",
      "mkdir -p ${var.host.home_dir}/${var.stack.mcp-servers-cameras.base_dir}/etc",
      "mkdir -p ${var.host.home_dir}/${var.stack.notify.base_dir}/etc",
      "mkdir -p ${var.host.home_dir}/${var.stack.search.base_dir}/etc",
      "mkdir -p ${var.host.home_dir}/${var.stack.stream.base_dir}/etc",
      "mkdir -p ${var.host.home_dir}/${var.stack.terminal.base_dir}/etc",
    ]
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.cloud_certificate.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.cloud_certificate.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.cloud_certificate_key.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.cloud_certificate_key.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.git_certificate.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.git_certificate.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.git_certificate_key.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.git_certificate_key.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.gpt_certificate.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.gpt_certificate.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.gpt_certificate_key.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.gpt_certificate_key.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.notify_certificate.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.notify_certificate.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.notify_certificate_key.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.notify_certificate_key.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.search_certificate.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.search_certificate.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.search_certificate_key.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.search_certificate_key.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.stream_certificate.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.stream_certificate.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.stream_certificate_key.filename))
    destination = "${var.host.home_dir}/nginx/etc/ssl/${basename(abspath(pathexpand(local_file.stream_certificate_key.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.mcp-servers-cameras-settings.filename))
    destination = "${var.host.home_dir}/${var.stack.mcp-servers-cameras.base_dir}/etc/${basename(abspath(pathexpand(local_file.mcp-servers-cameras-settings.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.nginx_settings.filename))
    destination = "${var.host.home_dir}/nginx/etc/${basename(abspath(pathexpand(local_file.nginx_settings.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.nginx_sites.filename))
    destination = "${var.host.home_dir}/nginx/etc/conf.d/${basename(abspath(pathexpand(local_file.nginx_sites.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.search_limiter.filename))
    destination = "${var.host.home_dir}/${var.stack.search.base_dir}/etc/${basename(abspath(pathexpand(local_file.search_limiter.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.search_settings.filename))
    destination = "${var.host.home_dir}/${var.stack.search.base_dir}/etc/${basename(abspath(pathexpand(local_file.search_settings.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_file.stack.filename))
    destination = "${var.host.home_dir}/${basename(abspath(pathexpand(local_file.stack.filename)))}"
  }

  provisioner "file" {
    source      = abspath(pathexpand(local_sensitive_file.stack_secrets.filename))
    destination = "${var.host.home_dir}/${basename(abspath(pathexpand(local_sensitive_file.stack_secrets.filename)))}"
  }

  provisioner "file" {
    source      = "../start.sh"
    destination = "${var.host.home_dir}/start.sh"
  }

  provisioner "file" {
    source      = "../stop.sh"
    destination = "${var.host.home_dir}/stop.sh"
  }

  depends_on = [
    local_file.cloud_certificate,
    local_file.cloud_certificate_key,
    local_file.git_certificate,
    local_file.git_certificate_key,
    local_file.gpt_certificate,
    local_file.gpt_certificate_key,
    local_file.mcp-servers-cameras-settings,
    local_file.notify_certificate,
    local_file.notify_certificate_key,
    local_file.nginx_settings,
    local_file.nginx_sites,
    local_file.search_limiter,
    local_file.search_settings,
    local_file.search_certificate,
    local_file.search_certificate_key,
    local_file.stream_certificate,
    local_file.stream_certificate_key,
    local_sensitive_file.stack_secrets,
    local_file.stack
  ]
}