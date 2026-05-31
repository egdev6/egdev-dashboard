# Runtime pilot checklist

This checklist drives the first private local OpenClaw + Engram + Postgres pilot after the M1-M7 roadmap baseline. Use it to validate reality before adding live Discord, live analytics, or a real dashboard/API stack.

Do **not** paste secrets, private memory, raw Discord IDs, or sensitive logs into this file.

## Quick path

1. Prepare a private `.env` without overwriting an existing one.
2. Start the Docker stack locally.
3. Validate OpenClaw, Engram, skill sync, logs, and shutdown.
4. Record only repo-safe findings and update runbooks when behavior differs.

## Pilot boundaries

| Topic | Rule |
|---|---|
| Runtime | Local/private only |
| Discord | No live bot until routing is validated privately |
| Engram | Validate service reachability before storing real memory |
| Buffer | No live analytics calls |
| Dashboard | Static artifact only; no live API in this pilot |
| Data | Fake or sanitized findings only in git |
| Volumes | Preserve by default; no `down -v` without explicit confirmation |

## Phase 0: preflight

- [ ] Confirm this branch is current with `main`.
- [ ] Confirm Docker is available.
- [ ] Confirm `.env` handling is safe:

  ```bash
  test -f .env || cp .env.example .env
  ```

- [ ] Replace every `change-me-*` value before storing real memory.
- [ ] Keep `.env` untracked.
- [ ] Read `docs/security/data-handling.md` and `docs/operations/runtime-incident-runbook.md`.

## Phase 1: compose validation

Run:

```bash
docker compose config
```

Record:

- [ ] Compose config passes.
- [ ] No secret values are copied into issue/PR text.
- [ ] Any config failure is summarized with a sanitized excerpt.

Repo-safe finding:

```text
Compose config result:
Sanitized note:
Follow-up needed:
```

## Phase 2: setup and startup

Run:

```bash
docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
docker compose ps
```

Record:

- [ ] OpenClaw setup completes or a safe blocker is documented.
- [ ] `postgres` starts.
- [ ] `engram` starts.
- [ ] `openclaw` starts.
- [ ] Services bind only to expected local surfaces.

Repo-safe finding:

```text
Startup result:
Unexpected service state:
Follow-up needed:
```

## Phase 3: health checks

Run:

```bash
docker compose logs --tail=50 postgres engram openclaw
docker compose exec openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) })"
```

Record:

- [ ] OpenClaw gateway health passes.
- [ ] Engram is reachable locally or a blocker is documented.
- [ ] Logs do not expose secrets before any excerpt is shared.
- [ ] Any failing health check gets a sanitized error summary.

Repo-safe finding:

```text
OpenClaw health:
Engram reachability:
Log safety review:
Follow-up needed:
```

## Phase 4: skill sync check

Validate that tracked project skills are present in the OpenClaw workspace after startup.

Suggested check:

```bash
docker compose exec openclaw sh -lc 'find /home/node/.openclaw/workspace/skills -maxdepth 2 -type f | sort | head -50'
```

Record:

- [ ] `skills/brand-context/SKILL.md` appears or equivalent path is documented.
- [ ] `skills/content-ledger/SKILL.md` appears or equivalent path is documented.
- [ ] `skills/strategy-planner/SKILL.md` appears or equivalent path is documented.
- [ ] Missing skills are handled by rebuild/restart guidance, not only setup reruns.

Repo-safe finding:

```text
Skill sync result:
Missing expected skills:
Follow-up needed:
```

## Phase 5: safe shutdown

Run:

```bash
docker compose down
```

Record:

- [ ] Shutdown completes cleanly.
- [ ] Volumes are preserved.
- [ ] `docker compose down -v` was not used.
- [ ] Any shutdown issue is summarized safely.

Repo-safe finding:

```text
Shutdown result:
Volume preservation confirmed:
Follow-up needed:
```

## Phase 6: runbook updates

If observed behavior differs from docs, update the relevant doc in a small follow-up commit:

- `docs/operations/docker-runtime.md`
- `docs/operations/runtime-incident-runbook.md`
- `docs/security/data-handling.md`

Checklist:

- [ ] Findings are sanitized.
- [ ] No real tokens, memory, Discord IDs, or private logs are committed.
- [ ] Runbook changes are limited to observed pilot behavior.

## Completion criteria

This pilot is complete when:

- [ ] Compose config passes.
- [ ] Setup/startup behavior is known.
- [ ] OpenClaw health behavior is known.
- [ ] Engram reachability behavior is known.
- [ ] Skill sync behavior is known.
- [ ] Logs were reviewed for obvious secret exposure.
- [ ] Normal shutdown preserves volumes.
- [ ] Any runbook mismatch is documented or filed as a follow-up.

## Next decision

After this pilot, choose one next step:

1. private Discord route validation;
2. real Engram persistence validation;
3. dashboard/API stack decision;
4. operational hardening follow-up for any pilot blocker.
