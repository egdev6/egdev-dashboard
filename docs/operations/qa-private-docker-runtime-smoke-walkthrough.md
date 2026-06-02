# QA private Docker runtime smoke walkthrough

This evidence pack records QA-06 for issue #111. Result: the private/local Docker runtime smoke path is followable from the checklist, loopback health and service state are observable, and safe shutdown remains non-destructive by default.

## Quick path

1. Reuse AGENT runtime evidence from #104 and #105 before treating this as new runtime scope.
2. Follow the private Docker checklist with sanitized evidence only: compose validation, setup, startup, health, sampled logs, and shutdown.
3. Confirm failures have non-destructive triage guidance and that no live Discord, public channels, production credentials, or destructive cleanup are needed.

## Evidence pack header

| Field | Value |
|---|---|
| Issue | #111 — QA-06 private Docker runtime smoke walkthrough |
| Test order | `QA-06` |
| Owner | `QA+agent` |
| Date (UTC) | 2026-06-02T16:24:43Z to 2026-06-02T16:25:10Z |
| Branch / commit | `test/111-qa-runtime-smoke-walkthrough` |
| Environment | Local/private Docker runtime smoke walkthrough |
| Preconditions used | #106 matrix, #107 onboarding evidence, #110 dashboard evidence style, AGENT evidence #104 and #105 |
| Status | `pass` |

## Scope

- Validate that QA can follow the private Docker runtime checklist without undocumented steps.
- Validate that startup, health checks, sampled logs, and shutdown are observable with sanitized evidence.
- Validate that failures can be triaged with non-destructive restart guidance instead of volume deletion.

## Non-goals

This walkthrough does **not**:

- install or use the Discord plugin;
- connect to public Discord or external social networks;
- use production credentials;
- perform durable production writes;
- publish, schedule, or trigger Buffer activity;
- validate live analytics;
- execute runtime prompts;
- mutate GitHub state;
- commit rendered compose config, `.env` values, raw logs, tokens, private payloads, transcripts, or source dumps;
- run `docker compose down -v` or delete volumes.

## Preconditions

- `docs/operations/qa-acceptance-matrix.md` is approved and available as the QA source of truth.
- `docs/operations/runtime-pilot-checklist.md` defines the private/local runtime path.
- `docs/operations/private-docker-runtime-validation.md` provides the AGENT-03 baseline for compose, loopback health, and safe shutdown.
- `docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md` provides the AGENT-04 baseline for adjacent runtime behavior and disposable Engram checks.
- A local `.env` already exists and was not modified or committed during this walkthrough.
- Docker was available locally, so no manual user step was required.

## Steps executed

1. Reviewed the runtime checklist, AGENT runtime evidence, data-handling rules, and runtime incident runbook.
2. Confirmed local Docker and Docker Compose availability.
3. Ran `docker compose config --quiet` to validate compose rendering without committing resolved config.
4. Ran `docker compose --profile setup run --rm openclaw-setup` to confirm the documented setup path still works.
5. Started `postgres`, `engram`, and `openclaw` with `docker compose up -d postgres engram openclaw`.
6. Captured `docker compose ps`, sampled logs, loopback OpenClaw health, and loopback Engram health.
7. Shut the stack down with `docker compose down`, confirmed `docker compose ps` was empty, and confirmed named volumes remained.

## Expected result

- QA can follow the runtime checklist without undocumented steps.
- Stack startup, health checks, sampled logs, and shutdown are observable and understandable.
- Failures have clear triage instructions and do not require destructive cleanup by default.
- No Discord live plugin, public channels, production credentials, or durable production writes are used.
- QA evidence includes sanitized command output and timestamps only.

## Observed command results

| Command | Observed result | QA note |
|---|---|---|
| `docker --version` | `Docker version 29.4.0, build 9d7ad9f` | Docker was available locally. |
| `docker compose version` | `Docker Compose version v5.1.2` | Compose was available locally. |
| `docker compose config --quiet` | pass | Compose validation succeeded without printing resolved config. |
| `docker compose --profile setup run --rm openclaw-setup` | pass | Setup returned `"ok": true`, local mode, loopback bind, and no daemon install. |
| `docker compose up -d postgres engram openclaw` | pass | All three services started without requiring `--build`. |
| `docker compose ps` | partial at first | `postgres` was healthy, `engram` was up, and `openclaw` was still `health: starting` on the first sample. |
| OpenClaw loopback health probe | pass after one short retry | First immediate probe needed a 10-second wait; second probe returned `200 {"ok":true,"status":"live"}`. |
| Engram loopback health probe | pass | `{"service":"engram-cloud","status":"ok"}` |
| `docker compose logs --tail=25 ...` | pass | Sampled logs showed service-ready state only; no obvious secret/token values were copied into this doc. |
| `docker compose down` | pass | Containers and default network were removed without deleting volumes. |
| Final `docker compose ps` | pass | No running services remained after shutdown. |
| Volume check after shutdown | pass | `discord-project-manager_engram-postgres` and `discord-project-manager_openclaw-home` remained present. |

## Sanitized evidence

### Runtime versions

```text
Docker version 29.4.0, build 9d7ad9f
Docker Compose version v5.1.2
```

### Setup confirmation

```json
{
  "ok": true,
  "mode": "local",
  "workspace": "/home/node/.openclaw/workspace",
  "authChoice": "skip",
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "authMode": "token",
    "tailscaleMode": "off"
  },
  "installDaemon": false,
  "skipSkills": false,
  "skipHealth": true
}
```

### First `docker compose ps`

```text
NAME                                 IMAGE                                         SERVICE    STATUS                                     PORTS
discord-project-manager-engram-1     ghcr.io/gentleman-programming/engram:latest   engram     Up Less than a second                      127.0.0.1:18080->18080/tcp
discord-project-manager-openclaw-1   discord-project-manager-openclaw:local        openclaw   Up Less than a second (health: starting)   127.0.0.1:18789->18789/tcp
discord-project-manager-postgres-1   postgres:16-alpine                            postgres   Up 11 seconds (healthy)                    5432/tcp
```

### Loopback health checks

```text
OpenClaw probe attempt: retry-after-10s
OpenClaw: 200 {"ok":true,"status":"live"}
Engram: {"service":"engram-cloud","status":"ok"}
```

### Safe log sample

```text
postgres-1  | database system is ready to accept connections
engram-1    | Starting Engram cloud server on port 18080
engram-1    | [engram-cloud] listening on 0.0.0.0:18080
```

### Final `docker compose ps` after shutdown

```text
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
```

### Preserved named volumes after shutdown

```text
discord-project-manager_engram-postgres
discord-project-manager_openclaw-home
```

## Failure and triage notes

| Scenario | Safe first response | Avoid |
|---|---|---|
| Docker unavailable or socket permission denied | Restore local Docker access, then rerun `docker --version` and `docker compose version`. | Do not rewrite the walkthrough around a different runtime. |
| `openclaw` still shows `health: starting` | Wait 10 seconds and retry the loopback health probe before assuming failure. | Do not use destructive cleanup. |
| `engram` or `openclaw` stays unhealthy | Inspect `docker compose ps` and `docker compose logs --tail=25 postgres engram openclaw`, confirm Postgres is healthy, then try a plain `docker compose down` followed by `docker compose up -d postgres engram openclaw`. | Do not use `docker compose down -v` by default. |
| Service state differs from the checklist | Record the sanitized mismatch and update the runbook in a scoped follow-up. | Do not paste rendered config, `.env` values, or raw secret-bearing logs into repo docs. |

Manual user steps for this run: `none`.

## Actual result

From a QA perspective, the private runtime smoke path is understandable and reproducible:

- the checklist path worked without undocumented commands;
- setup, startup, loopback health, sampled logs, and shutdown were all observable;
- OpenClaw needed one short warm-up retry, which is now explicit as operator-facing triage guidance;
- shutdown remained non-destructive and preserved named volumes;
- no Discord plugin, public channels, production credentials, or durable production writes were used.

## Pass / fail decision

- Status: `pass`
- Why: all #111 acceptance criteria were met with sanitized local-only evidence, clear non-destructive triage guidance, and successful final shutdown.

## Follow-up issues

- #119 — reconcile six-vs-seven skill sync count evidence across runtime docs.
- #121 — reconcile LinkedIn `missing_context` modeling across skill, workflow doc, fixture, and validator.
- none specific to QA-06.

## Next step

Proceed to #112 only if explicit approval is given for the private Discord routing dry-run; otherwise keep using this and the earlier QA packs as the current QA source of truth.
