# OpenClaw skill sync and Engram roundtrip validation

This report captures the sanitized private local validation for issue #105 on branch `test/105-skill-sync-engram-roundtrips`.

## Scope

Validate the runtime-adjacent local proof after issue #104:

- safe validator baseline before runtime-adjacent checks
- OpenClaw workspace skill sync inside the private Docker runtime
- repo-to-runtime path/count/checksum confirmation for tracked `SKILL.md` files
- local Engram roundtrip validators with disposable data dirs
- namespace separation between runtime audit contracts and durable target namespaces
- safe non-destructive shutdown

## Run metadata

| Field | Value |
|---|---|
| Issue | #105 |
| Date (UTC) | 2026-06-02T12:53:54Z |
| Branch | `test/105-skill-sync-engram-roundtrips` |
| Docker | `Docker version 29.4.0, build 9d7ad9f` |
| Docker Compose | `Docker Compose version v5.1.2` |
| `.env` handling | Existing local `.env` was present and was not modified or committed. Only sanitized summaries are recorded here. |
| Loopback surfaces only | OpenClaw `127.0.0.1:18789`, Engram `127.0.0.1:18080` |
| Discord/plugin usage | No Discord plugin was installed or used. |

## Commands run

```bash
SAFE_VALIDATION_SKIP_STAGE0=1 bash scripts/run-safe-validation-suite.sh
docker --version
docker compose version
docker compose config --quiet
docker compose up -d postgres engram openclaw
docker compose ps
docker compose exec -T openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) }).catch(err => { console.error(err); process.exit(1) })"
sleep 10
docker compose exec -T openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) }).catch(err => { console.error(err); process.exit(1) })"
curl -sS http://127.0.0.1:18080/health
find skills -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | LC_ALL=C sort
find skills -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' -print | LC_ALL=C sort | while IFS= read -r f; do sha256sum "$f"; done
docker compose exec -T openclaw sh -lc "find /home/node/.openclaw/workspace/skills -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | LC_ALL=C sort"
docker compose exec -T openclaw sh -lc "find /home/node/.openclaw/workspace/skills -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | LC_ALL=C sort | while IFS= read -r f; do sha256sum \"\$f\"; done"
bash scripts/validate-brand-context-memory.sh
bash scripts/validate-content-ledger-memory.sh
bash scripts/validate-strategy-planning-memory.sh
docker compose down
docker volume ls --format '{{.Name}}' | grep '^discord-project-manager_' | LC_ALL=C sort
docker compose ps
```

## Results

| Check | Result |
|---|---|
| Safe validator suite (`SAFE_VALIDATION_SKIP_STAGE0=1`) | Passed. |
| `docker compose config --quiet` | Passed. |
| Stack startup | Passed on the first `up -d` for `postgres`, `engram`, and `openclaw`. |
| Initial OpenClaw health probe | Partial. An immediate probe returned `ECONNREFUSED` while the gateway was still in startup/health warmup. |
| Follow-up health probe | Passed after a short wait, with no restart required. |
| Engram health probe | Passed. |
| Skill sync path/count check | Passed. Seven tracked repo skills and seven runtime workspace skills were found. |
| Skill sync checksum check | Passed. Repo and container `SKILL.md` checksums matched for all seven tracked skills. |
| Brand context roundtrip validator | Passed with disposable `ENGRAM_DATA_DIR`. |
| Content-ledger roundtrip validator | Passed with disposable `ENGRAM_DATA_DIR`. |
| Strategy roundtrip validator | Passed with disposable `ENGRAM_DATA_DIR`. |
| Namespace separation review | Passed. Runtime audit namespace stayed contractual only; validator writes used disposable local durable namespaces only. |
| Shutdown | Passed with `docker compose down`. Containers and network were removed; named volumes remained. |

## Sanitized evidence

### Final healthy `docker compose ps`

```text
NAME                                 IMAGE                                         COMMAND                  SERVICE    CREATED          STATUS                    PORTS
discord-project-manager-engram-1     ghcr.io/gentleman-programming/engram:latest   "engram cloud serve"     engram     29 seconds ago   Up 18 seconds             127.0.0.1:18080->18080/tcp
discord-project-manager-openclaw-1   discord-project-manager-openclaw:local        "tini -s -- sh -lc '…"   openclaw   29 seconds ago   Up 17 seconds (healthy)   127.0.0.1:18789->18789/tcp
discord-project-manager-postgres-1   postgres:16-alpine                            "docker-entrypoint.s…"   postgres   30 seconds ago   Up 28 seconds (healthy)   5432/tcp
```

### Health checks

```text
Initial OpenClaw probe: fetch failed, connect ECONNREFUSED 127.0.0.1:18789
OpenClaw after wait: 200 {"ok":true,"status":"live"}
Engram: {"service":"engram-cloud","status":"ok"}
```

### Skill sync source paths

```text
skills/brand-context/SKILL.md
skills/content-ledger/SKILL.md
skills/discord-approval-gate/SKILL.md
skills/linkedin-weekly-planner/SKILL.md
skills/on-demand-brief-planner/SKILL.md
skills/strategy-planner/SKILL.md
skills/x-queue-planner/SKILL.md
```

### Skill sync destination paths

```text
/home/node/.openclaw/workspace/skills/brand-context/SKILL.md
/home/node/.openclaw/workspace/skills/content-ledger/SKILL.md
/home/node/.openclaw/workspace/skills/discord-approval-gate/SKILL.md
/home/node/.openclaw/workspace/skills/linkedin-weekly-planner/SKILL.md
/home/node/.openclaw/workspace/skills/on-demand-brief-planner/SKILL.md
/home/node/.openclaw/workspace/skills/strategy-planner/SKILL.md
/home/node/.openclaw/workspace/skills/x-queue-planner/SKILL.md
```

### Skill sync checksum confirmation

| Skill | Repo checksum | Container checksum | Match |
|---|---|---|---|
| `brand-context` | `6b78d6ec0fd0336ac35897e708d2acc267aabc798cf4a39ed1d74b74262950f0` | `6b78d6ec0fd0336ac35897e708d2acc267aabc798cf4a39ed1d74b74262950f0` | yes |
| `content-ledger` | `a0029c44d3c856631eda73a89506fd5bd8b41572f8b97c293a8875ffa0ea4849` | `a0029c44d3c856631eda73a89506fd5bd8b41572f8b97c293a8875ffa0ea4849` | yes |
| `discord-approval-gate` | `c28398e9af70746423ffe90328b27e4e25215e0f26515ea09bf6eff066408ef8` | `c28398e9af70746423ffe90328b27e4e25215e0f26515ea09bf6eff066408ef8` | yes |
| `linkedin-weekly-planner` | `0e13acca5f03fa8f537fae2f91093e62b836d5ef65275a0fd5841fbdb2544109` | `0e13acca5f03fa8f537fae2f91093e62b836d5ef65275a0fd5841fbdb2544109` | yes |
| `on-demand-brief-planner` | `e3648467a12e2ec0d33c7648d45e5d5b52aaa9eaa207c152384cd2eca46561c8` | `e3648467a12e2ec0d33c7648d45e5d5b52aaa9eaa207c152384cd2eca46561c8` | yes |
| `strategy-planner` | `aa5fd7e46f5b1e108f2d1fbe1f4e0685827228d63deb6a363a98213f36fc6f60` | `aa5fd7e46f5b1e108f2d1fbe1f4e0685827228d63deb6a363a98213f36fc6f60` | yes |
| `x-queue-planner` | `8f6f0a72c441e3a0f29d7166e51e9fd5c46520c5955964e66c070401bc81fd0c` | `8f6f0a72c441e3a0f29d7166e51e9fd5c46520c5955964e66c070401bc81fd0c` | yes |

### Engram roundtrip validator results

```text
Brand validator:
- project namespace: discord-project-manager/project/egdev/brand
- network namespace: discord-project-manager/project/egdev/network/linkedin
- ENGRAM_DATA_DIR: /tmp/tmp.MFqWBvnuis
- mode: disposable temp data dir

Content-ledger validator:
- ledger namespace: discord-project-manager/project/egdev/content-ledger
- network namespace: discord-project-manager/project/egdev/network/x
- content identifier: x-post-001-demo
- ENGRAM_DATA_DIR: /tmp/tmp.docVFtkWI8
- mode: disposable temp data dir

Strategy validator:
- brand namespace read: discord-project-manager/project/egdev/brand
- ledger namespace read: discord-project-manager/project/egdev/content-ledger
- strategy namespace written: discord-project-manager/project/egdev/strategy
- network strategy namespace written: discord-project-manager/project/egdev/network/linkedin
- approval status: approved-for-demo-validation
- ENGRAM_DATA_DIR: /tmp/tmp.qchMYNbQbz
- mode: disposable temp data dir
```

### Runtime audit vs durable namespace separation

| Evidence surface | Runtime audit namespace contract | Durable namespaces touched | Persistence mode | Notes |
|---|---|---|---|---|
| Docker skill sync validation | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` (contract only; not written here) | none | none | Skill sync checks compare repo paths to runtime workspace paths only. |
| Brand validator | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` (not used) | `discord-project-manager/project/egdev/brand`, `discord-project-manager/project/egdev/network/linkedin` | disposable local temp dir | Fake/demo data only; temp dir removed by script cleanup. |
| Content-ledger validator | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` (not used) | `discord-project-manager/project/egdev/content-ledger`, `discord-project-manager/project/egdev/network/x` | disposable local temp dir | Fake/demo data only; temp dir removed by script cleanup. |
| Strategy validator | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` (not used) | reads `discord-project-manager/project/egdev/brand` and `discord-project-manager/project/egdev/content-ledger`; writes `discord-project-manager/project/egdev/strategy` and `discord-project-manager/project/egdev/network/linkedin` | disposable local temp dir | Approval state remains fake/demo: `approved-for-demo-validation`. |

### Shutdown confirmation

Final `docker compose ps` after shutdown had no running services:

```text
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
```

### Volume preservation after shutdown

```text
discord-project-manager_engram-postgres
discord-project-manager_openclaw-home
```

## Deviations and follow-up notes

- An immediate OpenClaw health probe returned `ECONNREFUSED` because the gateway was still starting. The follow-up probe passed after a short wait; no rebuild or restart was needed.
- This run verified sync integrity more strictly than issue #104 by comparing source/destination paths, counts, and checksums for tracked `SKILL.md` files.
- The Engram validator scripts use disposable temp dirs by default. This confirms local/safe roundtrip behavior but does **not** claim durable application sync or production persistence.

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
- commit raw logs, rendered config, secrets, tokens, private payloads, transcripts, or source dumps
