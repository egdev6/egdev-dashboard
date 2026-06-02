# QA memory and approval-gate walkthrough

This evidence pack records QA-04 for issue #109. Result: memory hydration, writeback proposals, approval gating, revise/reject behavior, and audit-vs-durable namespace separation are understandable and safe from a QA perspective using fake/local evidence only.

## Quick path

1. Reuse AGENT evidence from #102-#105 before repeating any runtime-adjacent claim.
2. Walk the Memory Gateway, approval-gate contract, approval-response runbook, and representative writeback workflows together.
3. Confirm runtime audit notes stay separate from durable targets and that writes stop until exact approval language is present.

## Evidence pack header

| Field | Value |
|---|---|
| Issue | #109 — QA-04 memory and approval-gate behavior walkthrough |
| Test order | `QA-04` |
| Owner | `QA+agent` |
| Date (UTC) | 2026-06-02T15:05:00Z |
| Branch / commit | `test/109-qa-memory-approval-walkthrough` |
| Environment | Local docs/fixtures/validators walkthrough |
| Preconditions used | #106 matrix, #107 onboarding evidence, #108 skills walkthrough, AGENT evidence #102-#105 |
| Status | `pass` |

## Scope

- Validate that QA can distinguish runtime audit context from durable memory targets.
- Validate that writeback proposals remain gated as `confirmation-required` / `approval-requested` until exact approval language is present.
- Validate that `revise` and `reject` remain runtime-local/audit-only.
- Reuse sanitized local Engram roundtrip evidence for fake/demo memory behavior.

## Non-goals

This walkthrough does **not**:

- run live Discord or public-network workflows;
- use production credentials;
- perform durable production writes;
- publish, schedule, or trigger Buffer activity;
- validate live analytics;
- execute runtime prompts;
- mutate GitHub state;
- commit raw transcripts, raw source dumps, or private payloads.

## Preconditions

- `docs/operations/qa-acceptance-matrix.md` is approved and available as the QA source of truth.
- AGENT baseline evidence exists for:
  - safe validator suite (`docs/operations/safe-validation-suite.md`);
  - private Docker runtime validation (`docs/operations/private-docker-runtime-validation.md`);
  - OpenClaw skill sync and Engram roundtrip validation (`docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md`).
- Memory/approval source contracts are available:
  - `docs/architecture/discord-memory-gateway.md`;
  - `docs/operations/discord-approval-responses.md`;
  - `skills/discord-approval-gate/SKILL.md`;
  - representative writeback workflows from #61-#65 and #58.
- No manual user step was required for this agent-assisted walkthrough. Human QA can review the evidence in the PR.

## Steps executed

1. Reviewed the Memory Gateway contract, approval responses runbook, approval-gate skill, and the fake fixtures for gateway and approval-gate behavior.
2. Reviewed representative writeback workflows (#61, #62, #63, #64, #65, and #58) for `confirmation-required`, `approval-requested`, runtime audit namespace, and revise/reject behavior.
3. Re-ran local fake/demo validators for Memory Gateway, approval gate, and the three Engram roundtrip scripts.
4. Compared the runtime audit namespace contract against durable project namespaces used by brand, ledger, strategy, and network overlays.
5. Checked for safety/privacy regressions: raw transcripts, raw source dumps, private payloads, and production credential claims.

## Expected result

- QA can explain the difference between runtime audit notes and durable memory targets.
- Writeback proposals stop at `approval-requested` until the exact phrase `approve write` is present.
- `revise` and `reject` remain runtime-local/audit-only.
- Local Engram roundtrip evidence is disposable, sanitized, and clearly non-production.
- No evidence leaks secrets, raw transcripts, raw source dumps, private payloads, or production credentials.

## Evidence surface matrix

| Evidence surface | Runtime audit namespace | Durable target namespace(s) | Approval state / phrase | Revise / reject behavior | QA finding |
|---|---|---|---|---|---|
| Memory Gateway contract + fixture | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | Example matched-route durable reads/writes under `discord-project-manager/project/egdev/...` | `confirmation-required`, `approval-requested`, `approve write` | Gateway fixture uses `discord/audit/approval-decision` as approval-decision topic metadata; unmapped fallback rejects writes | Clear separation: runtime namespace is the audit surface, project namespaces are durable targets only after approval |
| Approval responses runbook | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | Displayed `target_namespaces` only | Proposal stays `approval-requested` until exact `approve write` | `revise: <instruction>` and `reject` stop persistence and keep no-op boundaries explicit | Clear and reviewable: the operator sees route, target namespace, runtime audit namespace, and what did not happen |
| Approval-gate skill + fixture | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | Example network target `discord-project-manager/project/egdev/network/x` | Exact phrase `approve write` only | Rejection and unmapped-route scenarios explicitly prevent writes | Enforcement contract is explicit: no file, memory, queue, ledger, publishing, scheduling, or workspace writes before approval |
| OpenClaw Global writeback (#61) | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | `discord-project-manager/project/egdev/brand` | `confirmation-required`, `approval-requested`, `approve write` | Revised/rejected drafts remain runtime-local/audit-only | Global governance writes are bounded and do not bypass approval |
| Content-ledger utility (#62) | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | `discord-project-manager/project/egdev/content-ledger` | `confirmation-required`, `approval-requested`, `approve write` | `revise`/`reject` remain runtime-local/audit-only, not durable ledger state | Ledger state and gate responses remain distinct |
| Category strategy / LinkedIn / Briefs (#63/#64/#65) | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | Strategy/network/ledger target namespaces shown in each workflow | `confirmation-required` plus explicit `approval-requested` writeback proposals | `revise`/`reject` remain runtime-local/audit-only across fixtures | Approval behavior is consistent across planning workflows |
| X queue ingestion (#58) | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | `discord-project-manager/project/egdev/network/x` | `approval-requested`, `approve write`, `revise`, `reject` | Writes before approval remain false; runtime audit remains separate | Narrower ingestion flow still follows the same gate semantics |

## Local Engram roundtrip evidence

The following validators were re-run successfully with disposable temp directories only:

| Validator | Durable namespace(s) touched | Sanitized evidence |
|---|---|---|
| `bash scripts/validate-brand-context-memory.sh` | `discord-project-manager/project/egdev/brand`, `discord-project-manager/project/egdev/network/linkedin` | Fake/demo fixture, disposable `ENGRAM_DATA_DIR`, non-zero-on-fail behavior documented |
| `bash scripts/validate-content-ledger-memory.sh` | `discord-project-manager/project/egdev/content-ledger`, `discord-project-manager/project/egdev/network/x` | Fake/demo fixture, content id `x-post-001-demo`, disposable `ENGRAM_DATA_DIR` |
| `bash scripts/validate-strategy-planning-memory.sh` | Reads brand + ledger; writes `discord-project-manager/project/egdev/strategy` and `discord-project-manager/project/egdev/network/linkedin` | Approval state stays `approved-for-demo-validation`; disposable `ENGRAM_DATA_DIR`; export/search readback proves local fake roundtrip only |

These validators confirm local/disposable behavior only. They do **not** claim durable application sync or production persistence.

## Safety and privacy review

| Check | Finding |
|---|---|
| Raw transcripts / raw source dumps | Not present in the walked docs, fixtures, or validator output captured here |
| Private payloads | Not present; only fake/demo fixture markers and sanitized namespace/value summaries are referenced |
| Production credentials | Not required and not shown |
| Durable writes before approval | Prohibited across the walked approval-gate and workflow contracts |
| Runtime prompt execution | Out of scope and not required for proof |
| Public Discord behavior | Out of scope and not implied |

## Mismatch review

| Finding | Status |
|---|---|
| Existing runtime evidence follow-up #119 (six vs seven synced skills) | Reviewed; not blocking for QA-04 because this walkthrough is about memory and approval semantics, not runtime skill-count history |
| Existing LinkedIn `missing_context` follow-up #121 | Reviewed; not blocking for QA-04 because it is a skill/workflow modeling issue, not a memory/approval-gate contradiction |
| New mismatches in memory/approval semantics | None found that required a new follow-up issue |

## Evidence captured

- `docs/architecture/discord-memory-gateway.md`
- `docs/operations/discord-approval-responses.md`
- `skills/discord-approval-gate/SKILL.md`
- `examples/discord-memory-gateway.fake.yaml`
- `examples/discord-approval-gate.fake.yaml`
- `scripts/validate-discord-memory-gateway.sh`
- `scripts/validate-discord-approval-gate.sh`
- `scripts/validate-brand-context-memory.sh`
- `scripts/validate-content-ledger-memory.sh`
- `scripts/validate-strategy-planning-memory.sh`
- Representative workflow docs/fixtures for #61, #62, #63, #64, #65, and #58 where writeback, revise, and reject are modeled.

## Actual result

From a QA perspective, the memory and approval-gate behavior is understandable and safe:

- runtime audit notes are clearly distinct from durable project namespaces;
- writeback proposals remain `confirmation-required` / `approval-requested` until exact approval language is present;
- `revise` and `reject` stay runtime-local/audit-only;
- local memory roundtrip evidence is present, disposable, and sanitized;
- no raw transcripts, raw source dumps, private payloads, or production credentials appear in this evidence.

## Pass / fail decision

- Status: `pass`
- Why: all #109 acceptance criteria are met with fake/local evidence only, and no blocking mismatch was found.

## Follow-up issues

- #119 — reconcile six-vs-seven skill sync count evidence across runtime docs.
- #121 — reconcile LinkedIn `missing_context` modeling across skill, workflow doc, fixture, and validator.

## Next step

Proceed to #110 and use this evidence pack plus `docs/operations/qa-acceptance-matrix.md` as the QA source of truth for the dashboard and analytics read-only walkthrough.
