# Runtime and incident runbook

This runbook is the portable local operations guide for `discord-project-manager`. It covers startup, shutdown, common failures, backup/export notes, and first-response incident handling for the current Docker runtime. It is **not** a full production SRE playbook.

## Quick path

1. Confirm Docker is available and `.env` does not keep `change-me-*` values for real use.
2. Run OpenClaw setup once, then start `postgres`, `engram`, and `openclaw` with `docker compose`.
3. Validate container state, logs, and loopback-only endpoints before using the runtime.
4. Stop with `docker compose down`; use `down -v` only for disposable smoke environments.
5. If data exposure is suspected, stop sharing, rotate affected secrets, remove exposed files, and document the incident privately.

## Status and scope

| Topic | Decision |
|---|---|
| Runtime scope | Portable local runtime for OpenClaw, Engram Cloud, and Postgres |
| Environment scope | Local/dev smoke usage first, not a production HA design |
| Supported control path | `docker compose` happy path |
| Data sensitivity | `.env`, Docker volumes, logs, and exports are private by default |
| Incident scope | First-response containment and evidence capture |

## Startup

### Preflight

Before starting the runtime:

- [ ] Copy `.env.example` to `.env` if the file does not exist.
- [ ] Replace every `change-me-*` value before storing real memory or real credentials.
- [ ] For pre-rename checkouts, update the local `.env` to use `discord-project-manager` for Compose project, image, and Engram namespace values.
- [ ] Keep `.env`, exports, dumps, screenshots, and logs with private data out of git.
- [ ] Confirm Docker Compose is available.
- [ ] Review `docs/security/data-handling.md` before using real Discord, Engram, or Buffer credentials.

Happy-path commands:

```bash
test -f .env || cp .env.example .env
# edit every change-me value before real use; never overwrite an existing .env blindly
# pre-rename .env files: use discord-project-manager for project/image/namespace values before validating

docker compose config
docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
docker compose ps
```

### Validate runtime state

Use these checks after startup:

```bash
docker compose logs --tail=50 postgres engram openclaw
docker compose exec openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) })"
curl -sS http://127.0.0.1:18080/health
```

Expected local surfaces:

| Service | Expected local address | Notes |
|---|---|---|
| OpenClaw gateway | `http://127.0.0.1:18789` | Token-auth gateway, loopback only |
| Engram Cloud | `http://127.0.0.1:18080` | Runtime service only; real enrollment/sync still requires validation |
| Postgres | internal compose service | Not published on a host port in current compose |

### Operator reminders

- Do not paste real tokens into issues, PRs, screenshots, or docs.
- Do not assume Discord routing, Engram sync, or Buffer analytics are validated just because containers start.
- Use fake/demo fixtures in public artifacts.

## Shutdown

### Normal stop

```bash
docker compose down
```

Use normal stop when you want to preserve:

- OpenClaw workspace state in `openclaw-home`;
- Engram/Postgres state in `engram-postgres`;
- `.env` and tracked repo configuration.

### Destructive reset warning

```bash
docker compose down -v
```

Use `down -v` only for disposable smoke environments. Do **not** use it when Docker volumes may contain real memory, real credentials, or evidence needed for incident review unless a human has confirmed backup/export first.

## Common failures

| Failure | Typical signal | First response |
|---|---|---|
| Docker unavailable or socket denied | `docker: command not found`, daemon not running, compose cannot connect, or permission denied on `/var/run/docker.sock` | Start Docker Desktop/Engine, retry `docker compose version`, use `sudo docker ...` when the socket is permission-denied, and on this WSL host use `/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe` only if plain `docker` is unavailable. |
| `.env` missing or still using `change-me-*` | Auth failures, unsafe local defaults, or operator notices placeholder values | If `.env` is missing, create it from `.env.example`; if it exists, edit it in place to replace placeholders. Keep the real `.env` untracked. |
| Image pull/build issue | Compose fails on image pull or OpenClaw build | Retry `docker compose build openclaw`, confirm network access to image registries, and review `docker/openclaw/Dockerfile` assumptions. |
| Postgres unhealthy | `postgres` never reaches healthy state | Inspect `docker compose logs postgres`, confirm `POSTGRES_*` values in `.env`, and avoid destructive reset unless the volume is disposable. The first pilot observed non-blocking init warnings for missing system locales and container-local trust authentication. |
| Engram unhealthy or unreachable | `engram` restarts, OpenClaw cannot reach `ENGRAM_CLOUD_URL`, or health pages fail | Inspect `docker compose logs engram`, confirm Postgres is healthy first, then recheck `ENGRAM_CLOUD_TOKEN`, `ENGRAM_CLOUD_ADMIN`, and `ENGRAM_JWT_SECRET` locally without pasting them into shared channels. |
| OpenClaw skill sync issue | Gateway starts without expected workspace skills or setup step fails | Confirm tracked `skills/` exist, inspect `docker/openclaw/sync-skills.sh`, rebuild the OpenClaw image if tracked skills changed, then restart `openclaw` so startup sync copies baked skills into the workspace. Use `docker compose --profile setup run --rm openclaw-setup` only when setup-specific workspace files need repair. |
| Discord routing ambiguity | Channel cannot be mapped to project/network | Stay runtime-only, do not read or write durable project memory, and follow `docs/operations/discord-routing.md`. |
| Buffer analytics unavailable | Operator expects live LinkedIn/X analytics from Buffer | Stop and use the fake snapshot contracts; public Buffer docs do not currently expose read-only LinkedIn/X analytics metrics. |
| CI or local validator failure | Markdown, YAML, shell, or repo contract checks fail | Re-run the failing local command, fix the documented contract mismatch, and avoid broad unrelated edits in the same work unit. |

## Backup and export notes

Treat runtime backups as private operational assets.

### What to preserve

| Surface | What to snapshot or export | Storage rule |
|---|---|---|
| `.env` and private config | Secret-bearing local config | Keep outside the repo |
| `openclaw-home` volume | Workspace/runtime state, sessions, config | Private only |
| `engram-postgres` volume | Engram Cloud database state | Private only |
| Sanitized docs and contracts | ADRs, runbooks, approved repo artifacts | Safe in git when sanitized |
| Incident evidence | Minimal logs, timestamps, affected surfaces, rotation notes | Private by default |

### Export rules

- Never commit raw Engram exports, Postgres dumps, volume archives, or secret-bearing logs.
- Name backups as private operational assets, not as repo fixtures.
- Sanitize before sharing any screenshot or log excerpt.
- Keep a restore drill as a future hardening task; this repo does not yet define an automated restore workflow.

## Security incident checklist

Use this checklist for first response. Prefer containment first, detailed forensics second.

### Immediate checklist

- [ ] Stop sharing links, screenshots, logs, exports, or PR updates that may contain private data.
- [ ] Identify the affected surface: repo, `.env`, Docker volume, Engram export, Discord routing, or Buffer token.
- [ ] Revoke, rotate, or replace affected credentials.
- [ ] Remove exposed files from the working tree and future commits.
- [ ] Assess whether runtime data, logs, or backups also require purge or replacement.
- [ ] Record a private incident note with time, reporter, scope, and containment steps.
- [ ] Promote only sanitized lessons back into repo docs.

### Incident-specific actions

| Incident | Immediate actions |
|---|---|
| Suspected credential exposure | Rotate the secret, remove it from files/history as needed, and recheck `.env.example` to ensure only placeholders remain public. |
| Private memory leak | Stop exports/sharing, isolate affected backups/logs, review Engram and volume exposure, and sanitize any copied excerpts. |
| Discord route mistake | Stop durable writes, keep work in runtime-only context, confirm approved route with a human, and review `docs/operations/discord-routing.md` plus `docs/operations/discord-approval-responses.md`. |
| Buffer token leak | Revoke/rotate the token, remove all traces from local files and shared artifacts, and avoid client-side/browser exposure. |
| Public fixture contamination | Replace contaminated fixture data with fake/demo values, audit nearby docs/screenshots, and re-run local validators before resuming review. |

## Escalation and evidence template

Capture the smallest useful private record first:

```text
Incident time:
Reporter:
Affected surface:
Suspected data class:
Current exposure state:
Immediate containment:
Secrets rotated or revoked:
Durable data affected:
Follow-up owner:
Next review time:
```

Do not paste real secrets, raw private memory, real Discord IDs, or full database dumps into the template.

## Related docs

- `docs/operations/docker-runtime.md`
- `docs/security/data-handling.md`
- `docs/operations/discord-routing.md`
- `docs/operations/discord-approval-responses.md`
- `docs/research/buffer-readonly-analytics-auth.md`
- `.env.example`
- `docker-compose.yml`
