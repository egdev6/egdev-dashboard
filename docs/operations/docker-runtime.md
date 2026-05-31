# Docker runtime runbook

This runbook covers the M1 portable runtime foundation. It is suitable for local smoke testing only until Discord, Engram memory contracts, and production secrets are validated.

## Prerequisites

- Docker Desktop or Docker Engine with Docker Compose.
- Access to the public images:
  - `ghcr.io/openclaw/openclaw:latest` as the OpenClaw base image
  - `ghcr.io/gentleman-programming/engram:latest`
  - `postgres:16-alpine`

Compose builds a small local image, `egdev-dashboard-openclaw:local`, from `docker/openclaw/Dockerfile`. That image bakes the repo's tracked `skills/` and `openclaw/config/` seed files on top of the official OpenClaw image.

On this WSL machine, Docker Desktop was reachable through the Windows binary:

```bash
/mnt/c/Program\ Files/Docker/Docker/resources/bin/docker.exe version
/mnt/c/Program\ Files/Docker/Docker/resources/bin/docker.exe compose version
```

Use plain `docker` if your shell has Docker integration enabled. If Docker is installed but the socket is not accessible, use `sudo docker ...` for the pilot or fix local Docker group permissions outside the repo.

## First-time setup

```bash
test -f .env || cp .env.example .env
# edit every change-me value before storing real memory; never overwrite an existing .env blindly

docker compose --profile setup run --rm openclaw-setup
```

`openclaw-setup` runs non-interactive OpenClaw onboarding with explicit risk acknowledgement and writes the baseline config/workspace into the `openclaw-home` Docker volume.

## Start

```bash
docker compose up -d postgres engram openclaw
```

OpenClaw is published on loopback only:

```text
http://127.0.0.1:18789
```

Engram Cloud is published on loopback only:

```text
http://127.0.0.1:18080
```

## Health checks

```bash
docker compose config
docker compose exec openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) })"
docker compose ps
```

OpenClaw should report:

```text
200 {"ok":true,"status":"live"}
```

Engram Cloud should report:

```bash
curl -sS http://127.0.0.1:18080/health
```

```json
{"service":"engram-cloud","status":"ok"}
```

The first runtime pilot validated service reachability only. The project still needs to validate client enrollment and sync behavior before storing real context.

## Stop

```bash
docker compose down
```

## Volumes

| Volume | Purpose | Safe to delete? |
|---|---|---|
| `openclaw-home` | OpenClaw config, workspace, sessions, and runtime state | Only for disposable smoke tests |
| `engram-postgres` | Engram Cloud Postgres data | No, if it contains real memory |

To reset a disposable local smoke environment:

```bash
docker compose down -v
```

Never run `down -v` against a runtime that contains real Engram memory unless you have an export/backup.

## Skill mounting

The repository's tracked `skills/` directory is copied into the local OpenClaw runtime image and synced into:

```text
/home/node/.openclaw/workspace/skills
```

The M1 smoke test confirmed OpenClaw discovers workspace `SKILL.md` files from this shape. Runtime-generated workspace state remains in the `openclaw-home` volume, not in git.

## Security notes

- `--auth token` is required for the OpenClaw gateway.
- Host ports are bound to `127.0.0.1` only.
- Example `change-me-*` values are not secrets; replace them before real use.
- Do not commit `.env`, Docker volume exports, Discord tokens, Buffer tokens, or real Engram memory.
