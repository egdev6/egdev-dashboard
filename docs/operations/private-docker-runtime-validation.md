# Private Docker runtime validation

This report captures the sanitized private Docker runtime validation for issue #104 on branch `test/104-private-docker-runtime-validation`.

## Scope

Validate the local/private Docker runtime only:

- Compose rendering
- private stack setup/startup
- loopback OpenClaw and Engram health checks
- workspace skill sync presence
- safe non-destructive shutdown

## Run metadata

| Field | Value |
|---|---|
| Issue | #104 |
| Date (UTC) | 2026-06-02T12:22:32Z |
| Branch | `test/104-private-docker-runtime-validation` |
| Docker | `Docker version 29.4.0, build 9d7ad9f` |
| Docker Compose | `Docker Compose version v5.1.2` |
| `.env` handling | Existing local `.env` was present and was not modified or committed. Rendered config/log output was not committed; only sanitized summaries are recorded here. |
| Credential requirement | The validated commands used the local OpenClaw/Engram/Postgres compose path only; no Discord plugin, Buffer service, production social credential, or external account login was required. |
| Loopback surfaces only | OpenClaw `127.0.0.1:18789`, Engram `127.0.0.1:18080` |

## Commands run

```bash
bash scripts/run-safe-validation-suite.sh
docker --version
docker compose version
docker compose config
docker compose config --quiet
docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
docker compose ps
docker compose logs --tail=50 postgres engram openclaw
docker compose exec -T openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) })"
curl -sS http://127.0.0.1:18080/health
docker compose exec -T openclaw sh -lc 'find /home/node/.openclaw/workspace/skills -maxdepth 2 -type f | LC_ALL=C sort | head -50'
docker compose down
docker compose up --build -d postgres engram openclaw
docker compose ps
docker compose exec -T openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) })"
curl -sS http://127.0.0.1:18080/health
docker compose down
```

## Results

| Check | Result |
|---|---|
| Safe validation suite | Passed before runtime validation. |
| `docker compose config` | Passed. Rendered output was reviewed locally but not committed. |
| `docker compose config --quiet` | Passed after review fix; validates compose rendering without printing resolved config. |
| `openclaw-setup` | Passed. |
| First startup attempt | Partial. `postgres` and `openclaw` were healthy, but `engram` was in a restart loop and local `curl` to `127.0.0.1:18080/health` failed. |
| Recovery step | A non-destructive `docker compose down` followed by restart was enough; no `down -v` was used. |
| Final startup (`up --build -d`) | Passed. `postgres`, `engram`, and `openclaw` were all up on loopback bindings only. |
| OpenClaw health | Passed: `200 {"ok":true,"status":"live"}` |
| Engram health | Passed: `{"service":"engram-cloud","status":"ok"}` |
| Skill sync | Passed. Six tracked skills were present in `/home/node/.openclaw/workspace/skills`. |
| Credential safety review | Passed. Resolved config and logs were not committed; no production credential values were required to execute the local compose/setup/health path. |
| Log safety review | Passed. Sampled logs showed no obvious secret/token/password values. |
| Shutdown | Passed with `docker compose down`. Containers and network were removed; named volumes remained. |

## Sanitized evidence

### Final `docker compose ps`

```text
NAME                                 IMAGE                                         SERVICE    STATUS                    PORTS
discord-project-manager-engram-1     ghcr.io/gentleman-programming/engram:latest   engram     Up 15 seconds             127.0.0.1:18080->18080/tcp
discord-project-manager-openclaw-1   discord-project-manager-openclaw:local        openclaw   Up 15 seconds (healthy)   127.0.0.1:18789->18789/tcp
discord-project-manager-postgres-1   postgres:16-alpine                            postgres   Up 26 seconds (healthy)   5432/tcp
```

### Health checks

```text
OpenClaw: 200 {"ok":true,"status":"live"}
Engram: {"service":"engram-cloud","status":"ok"}
```

### Skill sync sample

```text
/home/node/.openclaw/workspace/skills/brand-context/SKILL.md
/home/node/.openclaw/workspace/skills/content-ledger/SKILL.md
/home/node/.openclaw/workspace/skills/linkedin-weekly-planner/SKILL.md
/home/node/.openclaw/workspace/skills/on-demand-brief-planner/SKILL.md
/home/node/.openclaw/workspace/skills/strategy-planner/SKILL.md
/home/node/.openclaw/workspace/skills/x-queue-planner/SKILL.md
```

### Volume preservation after shutdown

```text
discord-project-manager_engram-postgres
discord-project-manager_openclaw-home
```

## Deviations and follow-up notes

- The first startup attempt encountered an `engram` restart loop with repeated sanitized DNS/connection failures to `postgres` from inside the container. A plain non-destructive `docker compose down` and retry resolved it.
- Earlier local logs also repeated the known Postgres init warnings from the checklist (`no usable system locales were found` and `trust authentication for local connections`). Those warnings were not present in the final short log sample and did not block the successful validation.
- No Discord plugin was installed or used.
- No Buffer service exists in the active compose graph; Buffer-related local environment keys, if present, were not used by any validation command.
- The evidence intentionally records credential handling by requirement and behavior only. It does not commit rendered config, logs, private `.env` values, or classifications of private values.

## Non-goals and privacy note

This validation did **not**:

- install or use the Discord plugin
- connect to live/public Discord or external social networks
- require production credentials
- perform durable production writes
- publish, schedule, or trigger Buffer activity
- validate live analytics
- execute runtime prompts
- mutate GitHub state
- commit raw logs, secrets, tokens, private payloads, transcripts, or source dumps
