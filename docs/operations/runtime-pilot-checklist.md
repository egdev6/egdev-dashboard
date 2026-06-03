# Runtime pilot checklist

This checklist drives the first private local OpenClaw + Engram + Postgres pilot after the M1-M7 roadmap baseline. Use it to validate reality before adding live Discord, live analytics, or a real dashboard/API stack.

Do **not** paste secrets, private memory, raw Discord IDs, or sensitive logs into this file.

## Quick path

1. Prepare a private `.env` without overwriting an existing one.
2. Start the Docker stack locally.
3. Validate OpenClaw, Engram, skill sync, logs, and shutdown.
4. Record only repo-safe findings and update runbooks when behavior differs.
5. Review the latest sanitized evidence reports in:
   - `docs/operations/private-docker-runtime-validation.md`
   - `docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md`
6. Before any private Discord rehearsal, review `docs/operations/private-discord-manual-verification-guide.md` and keep QA-07 execution gated until a no-op observation path is approved.

## First pilot result

The first private local pilot on 2026-05-31 completed successfully with sanitized findings only:

| Check | Result |
|---|---|
| Docker access | Docker worked through `sudo docker`; plain `docker` hit socket permission denial on this host. |
| Compose config | Passed. |
| Setup/startup | `openclaw-setup` completed, the local OpenClaw image built, and `postgres`, `engram`, and `openclaw` started. |
| OpenClaw health | `GET http://127.0.0.1:18789/healthz` returned `200 {"ok":true,"status":"live"}`. |
| Engram health | `GET http://127.0.0.1:18080/health` returned `200 {"service":"engram-cloud","status":"ok"}`. |
| Skill sync | Six tracked skills appeared under `/home/node/.openclaw/workspace/skills`. |
| Log safety | No generated secrets appeared in the sampled logs; only non-secret port/user values matched `.env`. |
| Bindings | OpenClaw and Engram were bound to `127.0.0.1`. |
| Shutdown | `docker compose down` removed containers/network and preserved `openclaw-home` plus `engram-postgres` volumes. |

## Skill sync count note

Use the six-skill result above as historical evidence for the 2026-05-31 pilot only.

Current expectation is documented in `docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md`: runtime-adjacent validation now tracks seven project `SKILL.md` files, including `skills/discord-approval-gate/SKILL.md`.

Rule of thumb:

- use this checklist and the #104 report to understand what the first pilot observed;
- use the #105 report when you need the current tracked skill set and checksum-confirmed sync evidence.

Non-blocking observed warnings:

- Postgres reported `no usable system locales were found` during init.
- Postgres reported `trust authentication for local connections` during init inside the container.

These findings do not validate live Discord, durable Engram application sync, live Buffer analytics, or production readiness.

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

If an existing private stack is already present but one service is stale or stuck restarting, prefer a non-destructive `docker compose down` followed by a fresh `docker compose up -d ...` before considering any volume reset.

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
curl -sS http://127.0.0.1:18080/health
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

Current expected tracked `SKILL.md` set for comparison:

- `skills/brand-context/SKILL.md`
- `skills/content-ledger/SKILL.md`
- `skills/discord-approval-gate/SKILL.md`
- `skills/linkedin-weekly-planner/SKILL.md`
- `skills/on-demand-brief-planner/SKILL.md`
- `skills/strategy-planner/SKILL.md`
- `skills/x-queue-planner/SKILL.md`

Suggested check:

```bash
docker compose exec openclaw sh -lc 'find /home/node/.openclaw/workspace/skills -maxdepth 2 -type f | sort | head -50'
```

Record:

- [ ] `skills/brand-context/SKILL.md` appears or equivalent path is documented.
- [ ] `skills/content-ledger/SKILL.md` appears or equivalent path is documented.
- [ ] `skills/discord-approval-gate/SKILL.md` appears or equivalent path is documented.
- [ ] `skills/strategy-planner/SKILL.md` appears or equivalent path is documented.
- [ ] Current expected count is seven tracked `SKILL.md` files unless a scoped follow-up explicitly changes the synced set.
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

If the next step is Discord-adjacent manual verification, use `docs/operations/private-discord-manual-verification-guide.md` together with the QA-07 gated plan.
