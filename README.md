# My Own Cloud

A self-hosted personal cloud stack. Terraform generates all configuration and
TLS certificates, then deploys a Docker Compose stack of self-hosted services
behind an nginx reverse proxy. TLS certificates are issued automatically via
Let's Encrypt using a Cloudflare DNS-01 challenge.

## Architecture

Deployment is a two-phase flow:

1. **`deploy.sh`** runs Terraform (in `iac/`) to:
   - Register an ACME account and issue Let's Encrypt certificates for every
     service domain (`iac/certificate.tf`).
   - Render the `docker-compose.yml`, nginx config, and per-service config
     files from the `stack` variable (`iac/stack.tf`, `iac/nginx.tf`, etc.).
   - Write a `.secrets` file with generated tokens.
   - Copy all generated files and TLS certificates to the target host over SSH,
     along with `start.sh` / `stop.sh`.
2. **`start.sh` / `stop.sh`** run on the host to bring the Docker Compose stack
   up or down.

All external traffic terminates at nginx, which reverse-proxies each domain to
the appropriate backend container over HTTP.

## Services

| Service | Image / role | Description |
|---|---|---|
| server | [https://owncloud.com](https://owncloud.com/) | File storage and media server (downloads, files, movies, photos, music) |
| git | [https://about.gitea.com/](https://about.gitea.com/) | Self-hosted Git server |
| git-runner | [https://docs.gitea.com/usage/actions/act-runner](https://docs.gitea.com/usage/actions/act-runner) | CI runner registered against the Gitea instance |
| gpt | [https://openwebui.com/](https://openwebui.com/) | LLM chat UI backed by an [Ollama](https://ollama.com/) backend |
| mcp-servers-cameras | [https://github.com/fvilarinho/mcp-servers](https://github.com/fvilarinho/mcp-servers) | MCP server exposing a camera endpoint |
| notify | [https://ntfy.sh/](https://ntfy.sh/) | Push notification server |
| search | [https://docs.searxng.org/](https://docs.searxng.org/) | Privacy-respecting metasearch engine |
| stream | [https://jellyfin.org/](https://jellyfin.org/) | Media server for streaming movies, music, and photos/videos |
| terminal | [https://docs.openwebui.com/features/open-terminal/](https://docs.openwebui.com/features/open-terminal/) | Web-based terminal with Docker socket access |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (on the machine running `deploy.sh`)
- [Docker](https://docs.docker.com/get-docker/) with Compose (on the target host)
- A [Cloudflare](https://www.cloudflare.com/) account with an API token that can
  manage DNS for your domains
- SSH access to the target host with a private key
- DNS records for each service domain pointing at the host

## Configuration

Terraform variables are defined in `iac/variables.tf`. Provide values via a
`terraform.tfvars` file (git-ignored) or `-var` flags. The main inputs are:

- **`cloudflare`** — API token used for DNS-01 challenges (sensitive).
- **`host`** — target host attributes: `home_dir`, `name`, `user`,
  `private_key_filename`, `listen_port`, `secure_listen_port`.
- **`stack`** — per-service configuration (domain, container name, origin host/
  port/protocol, base dir, and service-specific settings).

Generated secrets (Gitea runner registration token, Open Terminal API key,
SearXNG secret key, camera MCP API token) are created by Terraform and written
to `.secrets` and per-service config files. These are not committed.

## Usage

Deploy (generate config + certificates, then push to the host):

```bash
./deploy.sh
```

Start the stack (run on the host):

```bash
./start.sh
```

Stop the stack (run on the host):

```bash
./stop.sh
```

`start.sh` / `stop.sh` source `.secrets` for the environment variables the
Compose stack needs, then run `docker compose up -d` / `docker compose down`.

## Repository layout

```
.
├── deploy.sh                 # Runs Terraform to generate config + deploy to host
├── start.sh                  # docker compose up -d (on host)
├── stop.sh                   # docker compose down (on host)
└── iac/                      # Terraform configuration
    ├── main.tf               # Providers (cloudflare, acme, local, null, random)
    ├── variables.tf          # Input variable definitions
    ├── stack.tf              # Host provisioning (copies config + certs, runs scripts)
    ├── settings.tf           # Generated config: docker-compose.yml, nginx, SearXNG, cameras
    ├── secrets.tf            # Generated secrets: .secrets file + random tokens
    └── certificate.tf        # ACME / Let's Encrypt certificates
```

Generated artifacts (`docker-compose.yml`, `.secrets`, `nginx/etc`,
`search/etc`, `mcp-servers/cameras/etc`, Terraform state) are git-ignored.

## License

Licensed under the [Apache License 2.0](LICENSE).
