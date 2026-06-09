# Docker runtime runbook

This runbook covers the M1 portable runtime foundation. It is suitable for local smoke testing only until Discord, Engram memory contracts, and production secrets are validated.

## Prerequisites

- Docker Desktop or Docker Engine with Docker Compose.
- Access to the public images:
  - `ghcr.io/openclaw/openclaw:latest` as the OpenClaw base image
  - `ghcr.io/gentleman-programming/engram:latest`
  - `postgres:16-alpine`

Compose builds a small local image, `discord-project-manager-openclaw:local`, from `docker/openclaw/Dockerfile`. That image bakes the repo's tracked `skills/` and `openclaw/config/` seed files on top of the official OpenClaw image.

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
# if this checkout existed before the rename, update .env to use discord-project-manager for project/image/namespace values

docker compose --profile setup run --rm openclaw-setup
```

`openclaw-setup` runs non-interactive OpenClaw onboarding with explicit risk acknowledgement and writes the baseline config/workspace into the `openclaw-home` Docker volume.

## Optional Discord plugin

The base OpenClaw image used by this repository does not include the Discord channel plugin by default. A private Discord pilot found that `channels.discord.enabled=true` and a valid bot token are not enough: OpenClaw reported `plugin not installed: discord` and the bot stayed offline until the external plugin was installed.

Install it in the runtime before validating Discord routing:

```bash
docker compose exec openclaw openclaw plugins install @openclaw/discord
docker compose restart openclaw
```

If the local WSL Docker socket is not available, use the Docker Desktop Windows binary from WSL:

```bash
/mnt/c/Program\ Files/Docker/Docker/resources/bin/docker.exe compose exec openclaw openclaw plugins install @openclaw/discord
/mnt/c/Program\ Files/Docker/Docker/resources/bin/docker.exe compose restart openclaw
```

After restart, `openclaw channels status --deep --probe` should include Discord before any route validation begins. If the plugin does not survive a container rebuild or volume reset, reinstall it before repeating Discord validation.

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

## Managed channel registry backend

The local OpenClaw image includes a private runtime CLI for the Project Manager managed channel metadata registry:

```bash
docker compose exec openclaw discord-project-manager-managed-registry backend-status
```

The backend stores private bindings under the OpenClaw workspace volume, outside git:

```text
/home/node/.openclaw/workspace/private-runtime-managed-channel-registry/managed-channel-bindings.jsonl
```

Use `preview-repair` to show metadata that would be written without applying it, and use `put` only after the exact `approve write` gate has been satisfied:

```bash
docker compose exec openclaw discord-project-manager-managed-registry preview-repair \
  '<guild-id>' '<category-id>' '<channel-id>' global context none \
  'project-manager-global:<guild-id>' '/project-manager init'
```

Status verification must resolve from this backend and report `OK`, `MISSING_METADATA`, `NEEDS_REPAIR_PREVIEW`, `WRONG_SCOPE`, `WRONG_FIELD`, or `WRONG_PROJECT`; visible channel-name inference is not accepted as success.

For destructive or permission-sensitive status/repair edge cases, use the non-writing simulation path instead of deleting channels or changing Discord permissions during a private rehearsal:

```bash
docker compose exec openclaw discord-project-manager-managed-registry simulate-edge-case deleted-managed-channel project tasks linkedin
docker compose exec openclaw discord-project-manager-managed-registry simulate-edge-case missing-persisted-id project tasks linkedin
docker compose exec openclaw discord-project-manager-managed-registry simulate-edge-case permission-failure project tasks linkedin manage_messages_for_pin
```

Each simulation must return sanitized output with `write_executed:false`.

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

## Skill and Gentle-AI mounting

The repository's tracked `skills/` directory is copied into the local OpenClaw runtime image and synced into:

```text
/home/node/.openclaw/workspace/skills
```

The M1 smoke test confirmed OpenClaw discovers workspace `SKILL.md` files from this shape. Runtime-generated workspace state remains in the `openclaw-home` volume, not in git.

The local OpenClaw image also installs a pinned `gentle-ai` binary into:

```text
/usr/local/bin/gentle-ai
```

On `openclaw-setup` and normal `openclaw` startup, `discord-project-manager-sync-skills` checks whether the OpenClaw workspace already has the Gentle-AI SDD/Engram protocol. If it is missing, the script runs:

```bash
gentle-ai install --agent openclaw --preset full-gentleman --scope=workspace
```

The expected runtime artifacts are:

```text
/usr/local/bin/gentle-ai
/usr/local/bin/engram
/home/node/.openclaw/workspace/AGENTS.md
/home/node/.openclaw/workspace/SOUL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-init/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-*/SKILL.md
/home/node/.openclaw/openclaw.json  # mcp.servers includes engram/context7
/home/node/.openclaw/engram-data    # OpenClaw-local Engram CLI data
```

OpenClaw uses the Gentle-AI SDD flow as a **solo-agent** workflow: the protocol is injected through workspace instructions instead of Pi-style SDD subagents/chains.

The Engram MCP server configured by Gentle-AI is a stdio process (`engram mcp --tools=agent`), so the OpenClaw runtime image must include the `engram` CLI locally. Its data directory is set to `/home/node/.openclaw/engram-data` by default so local MCP memory survives container recreation with the `openclaw-home` volume. This is separate from the optional `engram` cloud service used elsewhere in the compose stack.

Validate the packaging contract without Docker credentials:

```bash
bash scripts/validate-openclaw-gentle-ai-runtime.sh
```

Validate a running Docker runtime after services are up:

```bash
OPENCLAW_GENTLE_RUNTIME=1 bash scripts/validate-openclaw-gentle-ai-runtime.sh
```

If the Discord bot was already in a long-running session before Gentle-AI sync, start a new session or reset the old session before expecting it to answer SDD/Engram questions. Existing sessions may keep their earlier prompt context.

## Security notes

- `--auth token` is required for the OpenClaw gateway.
- Host ports are bound to `127.0.0.1` only.
- Example `change-me-*` values are not secrets; replace them before real use.
- Do not commit `.env`, Docker volume exports, Discord tokens, Buffer tokens, or real Engram memory.
