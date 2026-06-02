# QA onboarding and documentation walkthrough

This evidence pack records QA-02 for issue #107. Result: a new operator can understand repo status, safety boundaries, local-only assumptions, safe validator commands, private runtime docs, and the Discord pilot roadmap from the current docs without needing live runtime or manual user intervention.

## Quick path

1. Start with `README.md` and `docs/project/roadmap-completion.md` to understand baseline status and known limits.
2. Use `docs/operations/safe-validation-suite.md`, `docs/operations/ci.md`, and the runtime docs to find safe validator and private runtime commands.
3. Use this evidence pack as the QA record for #107, then continue to #108.

## Evidence pack header

| Field | Value |
|---|---|
| Issue | #107 — QA-02 repository onboarding and documentation walkthrough |
| Test order | `QA-02` |
| Owner | `QA+agent` |
| Date (UTC) | 2026-06-02T13:48:00Z |
| Branch / commit | `test/107-qa-onboarding-docs-walkthrough` |
| Environment | Local docs-only walkthrough |
| Preconditions used | #106 matrix, AGENT evidence #102-#105, current `main` docs |
| Status | `pass` |

## Scope

- Validate that onboarding and operational docs are understandable to a new operator.
- Confirm the docs explain what is complete, what remains out of scope, and how to stay within safe/local boundaries.
- Confirm QA can find the commands for safe validator execution and private runtime validation.

## Non-goals

This walkthrough does **not**:

- run Docker, Discord, or live network workflows;
- validate runtime behavior directly;
- use production credentials;
- perform durable writes;
- publish, schedule, or trigger Buffer activity;
- validate live analytics;
- execute runtime prompts;
- mutate GitHub state.

## Preconditions

- `docs/operations/qa-acceptance-matrix.md` is approved and available as the QA source of truth.
- AGENT baseline evidence exists for:
  - safe validator suite (`docs/operations/safe-validation-suite.md`);
  - CI coverage (`docs/operations/ci.md`);
  - private Docker runtime validation (`docs/operations/private-docker-runtime-validation.md`);
  - OpenClaw skill sync and Engram roundtrip validation (`docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md`).
- No manual user step was required for this agent-assisted docs walkthrough. Human QA can review this evidence in the PR.

## Docs walked in order

| Order | Doc | Why it matters | Outcome |
|---|---|---|---|
| 1 | `README.md` | Entry point for repo purpose, stack, quick start, and current scope | Clear on planning/runtime-baseline status; does not claim finished product readiness |
| 2 | `docs/project/roadmap-completion.md` | Baseline status, completed milestones, known limits, next-phase framing | Clear on what is complete vs operationally unproven |
| 3 | `docs/operations/safe-validation-suite.md` | First safe verification step and local commands | Safe validator commands are easy to find and bounded |
| 4 | `docs/operations/ci.md` | CI workflow purpose plus local reproduction | Confirms where CI coverage ends and local reproduction begins |
| 5 | `docs/operations/runtime-pilot-checklist.md` | Private runtime walkthrough and safety checklist | Explains local/private runtime validation path without pushing into live claims |
| 6 | `docs/operations/private-docker-runtime-validation.md` | Sanitized AGENT runtime evidence | Shows a successful private runtime proof and its limits |
| 7 | `docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md` | Runtime-adjacent skill sync and local Engram evidence | Distinguishes local/disposable proof from durable production behavior |
| 8 | `docs/security/data-handling.md` | Secret, transcript, export, and storage boundaries | Makes private/public handling rules explicit |
| 9 | `docs/operations/discord-context-skill-pilot-roadmap.md` | Discord pilot order and non-goals | Explains fake-first and pilot-only scope clearly |
| 10 | `docs/operations/docker-runtime.md` | Local runtime runbook and optional Discord plugin note | Clarifies private runtime vs later gated Discord validation |

## Findings matrix

| Check | Docs used | Finding | Pass / fail |
|---|---|---|---|
| Completed vs out of scope | `README.md`, `docs/project/roadmap-completion.md`, `docs/operations/discord-context-skill-pilot-roadmap.md` | A new operator can identify that M1-M7 baseline work is complete, while live Discord, live analytics, real dashboard/API, and production-grade behavior remain out of scope or unproven. | **Pass** |
| Safe validator commands are discoverable | `docs/operations/safe-validation-suite.md`, `docs/operations/ci.md` | QA can find both `bash scripts/run-safe-validation-suite.sh` and `SAFE_VALIDATION_SKIP_STAGE0=1 bash scripts/run-safe-validation-suite.sh`, plus CI/local reproduction context. | **Pass** |
| Private runtime validation commands are discoverable | `docs/operations/runtime-pilot-checklist.md`, `docs/operations/docker-runtime.md`, `docs/operations/private-docker-runtime-validation.md` | QA can find `docker compose config`, setup/startup, health checks, skill sync checks, and safe shutdown commands, all framed as local/private only. | **Pass** |
| Fake-first vs private runtime vs live pilots is understandable | `README.md`, `docs/project/roadmap-completion.md`, `docs/operations/safe-validation-suite.md`, `docs/operations/private-docker-runtime-validation.md`, `docs/operations/discord-context-skill-pilot-roadmap.md` | Docs separate fake-first contracts (repo-safe), private runtime validation (local Docker proof), and later live pilots (explicitly gated and not yet default). | **Pass** |
| Production-readiness boundaries stay explicit | `README.md`, `docs/project/roadmap-completion.md`, `docs/security/data-handling.md`, `docs/operations/docker-runtime.md` | Docs do not imply production readiness, public Discord behavior, durable writes, or live analytics. Boundaries are repeated in multiple places. | **Pass** |
| Stale/confusing reference review | Full walkthrough set above | One confusing reference was found: older runtime docs report six synced skills, while current #105 evidence reports seven including `discord-approval-gate`. Follow-up #119 was filed to reconcile historical vs current expected skill counts. | **Pass with follow-up** |

## Evidence captured

- `README.md` as onboarding entry point.
- `docs/project/roadmap-completion.md` for completed-vs-unproven framing.
- `docs/operations/safe-validation-suite.md` for safe validator commands.
- `docs/operations/ci.md` for CI coverage and local reproduction.
- `docs/operations/runtime-pilot-checklist.md` and `docs/operations/docker-runtime.md` for private runtime procedures.
- `docs/operations/private-docker-runtime-validation.md` and `docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md` for AGENT runtime evidence reuse.
- `docs/security/data-handling.md` for privacy and secret-handling boundaries.
- `docs/operations/discord-context-skill-pilot-roadmap.md` for pilot scope and fake-first Discord framing.

## Actual result

The documentation set is sufficient for QA-02. A new operator can:

- understand that the repo is a planning/runtime baseline rather than a production-ready product;
- distinguish completed roadmap baseline work from later live or operational decisions;
- find the safe validator and private runtime command paths quickly;
- explain why fake-first contract validation comes before private runtime validation and why live Discord remains a later gated step;
- identify the repo-safe boundaries around credentials, writes, analytics, transcripts, and public surfaces.

## Pass / fail decision

- Status: `pass-with-follow-up`
- Why: the onboarding path is usable and all #107 acceptance criteria are met; the one confusing/stale reference found during review was filed as follow-up #119 instead of being fixed inline.

## Follow-up issues

- #119 — reconcile six-vs-seven skill sync count evidence across runtime docs.

## Next step

Proceed to #108 and use this evidence pack plus `docs/operations/qa-acceptance-matrix.md` as the QA source of truth for the skills and fake workflow contract walkthrough.
