# QA skills and fake workflow contract walkthrough

This evidence pack records QA-03 for issue #108. Result: the implemented skills and fake workflow contracts are coherent enough for QA review, with one follow-up filed for LinkedIn `missing_context` modeling (#121). Existing follow-up #119 was reviewed and does not block this walkthrough because it is runtime evidence hygiene, not a skill/workflow contract mismatch.

## Quick path

1. Reuse AGENT baseline evidence from #102-#105 before reviewing individual workflows.
2. Walk each workflow across skill, fixture, runbook/doc, validator, and approval gate.
3. Record only sanitized findings and stop if any workflow implies live execution or unapproved durable writes.

## Evidence pack header

| Field | Value |
|---|---|
| Issue | #108 — QA-03 skills and fake workflow contract walkthrough |
| Test order | `QA-03` |
| Owner | `QA+agent` |
| Date (UTC) | 2026-06-02T14:34:00Z |
| Branch / commit | `test/108-qa-skills-workflow-walkthrough` |
| Environment | Local docs/fixtures/validators walkthrough |
| Preconditions used | #106 matrix, #107 onboarding evidence, AGENT evidence #102-#105 |
| Status | `pass-with-follow-up` |

## Scope

- Validate that each workflow is reviewable from a tester perspective, not just individually green in validators.
- Map every workflow to its skill, fixture, runbook/doc, validator, approval gate, and network-scope expectation.
- Confirm facts/assumptions/missing-context/proposed-action/approval-state handling where applicable.

## Non-goals

This walkthrough does **not**:

- run live Docker, Discord, or public-network workflows;
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
- No manual user step was required for this agent-assisted walkthrough. Human QA can review the evidence in the PR.

## Steps executed

1. Reused AGENT and QA baseline evidence from #102-#107.
2. Walked each workflow across its skill, fake fixture, runbook/doc, validator, expected approval gate, and network-scope expectation.
3. Reviewed whether each workflow separates confirmed facts, assumptions, missing context, proposed actions, and approval states where applicable.
4. Reviewed safety boundaries for live fetching, production execution, scheduling/publishing, Buffer activity, live analytics, public-channel behavior, and durable writes without approval.
5. Recorded mismatches as follow-up issues instead of fixing contracts inline during QA.

## Expected result

- Every walked workflow maps to a skill, fixture, runbook/doc, validator, and approval gate.
- Network-specific outputs remain separate where required.
- Safety boundaries remain fake-first and approval-gated.
- Any doc/skill/fixture/validator mismatch is captured as a follow-up issue.

## Workflow mapping matrix

| Workflow | Skill | Fixture | Runbook / doc | Validator | Approval gate | Network separation | QA finding |
|---|---|---|---|---|---|---|---|
| OpenClaw Global context refresh (#61) | `skills/brand-context/SKILL.md` | `examples/openclaw-global-brand-context-refresh.fake.yaml` | `docs/operations/openclaw-global-brand-context-refresh.md` | `scripts/validate-openclaw-global-brand-context-refresh.sh` | Mandatory `discord-approval-gate`; exact `approve write` | Global control areas stay explicit opt-in; not a fixed channel workflow | Coherent: draft summary, inheritance proposal, pack preview, and writeback proposal are clearly separated. |
| Content-ledger utility (#62) | `skills/content-ledger/SKILL.md` | `examples/content-ledger-utility-flow.fake.yaml` | `docs/operations/content-ledger-utility-flow.md` | `scripts/validate-content-ledger-utility-flow.sh` | Mandatory `discord-approval-gate`; exact `approve write` | Durable ledger vs runtime audit vs approved overlay stay separate | Coherent: normalized ledger candidate, duplicate review, and gate responses are distinct. |
| Category strategy planning (#63) | `skills/strategy-planner/SKILL.md` | `examples/category-strategy-planning-flow.fake.yaml` | `docs/operations/category-strategy-planning-flow.md` | `scripts/validate-category-strategy-planning-flow.sh` | Mandatory `discord-approval-gate`; exact `approve write` | Category/network overlay is distinct from cross-network strategy memory | Coherent: context hydration, strategy slice, and writeback proposal are cleanly split. |
| LinkedIn weekly planning (#64) | `skills/linkedin-weekly-planner/SKILL.md` | `examples/linkedin-weekly-planning-flow.fake.yaml` | `docs/operations/linkedin-weekly-planning-flow.md` | `scripts/validate-linkedin-weekly-planning-flow.sh` | Mandatory `discord-approval-gate`; exact `approve write` | LinkedIn-local plan stays separate from project strategy and content ledger | Mostly coherent, but follow-up #121 was filed because `missing_context` is required by the workflow docs/fixture/validator while the skill output shape does not model it explicitly. |
| X queue source ingestion (#58) | `skills/x-queue-planner/SKILL.md` | `examples/x-queue-source-ingestion.fake.yaml` | `docs/operations/x-queue-discord-approval-flow.md`, `docs/research/x-queue-planning-skill.md` | `scripts/validate-x-queue-source-ingestion.sh`, `scripts/validate-discord-approval-gate.sh` | Mandatory `approve write` / `revise` / `reject` path | X queue candidates stay under network/x; runtime audit namespace remains separate | Coherent: this slice is explicitly ingestion-to-proposal, not a full publish/schedule flow. |
| On-demand brief workflow (#65) | `skills/on-demand-brief-planner/SKILL.md` | `examples/on-demand-brief-flow.fake.yaml` | `docs/operations/on-demand-brief-flow.md` | `scripts/validate-on-demand-brief-flow.sh` | Mandatory `discord-approval-gate`; exact `approve write` | Network briefs stay separated by output surface; strategy/ledger targets remain planned-only | Coherent: route -> pack -> intent -> brief candidate flow is reviewable and approval-gated. |

## Tester-facing contract findings

| Workflow | Confirmed facts | Assumptions | Missing context | Proposed actions | Approval state |
|---|---|---|---|---|---|
| #61 OpenClaw Global | Allowed fake control inputs become a bounded draft summary and explicit inheritance facts. | Open questions stay open questions, not facts. | Not modeled as a named field; uncertainty is carried as `open_questions`, which is acceptable for this global-summary slice. | Inheritance proposal + derived pack preview + writeback proposal. | `confirmation-required`, `approval-requested`, `approve write`, `revise`, `reject`. |
| #62 Ledger utility | Content identity/status/assets are explicit facts in one normalized candidate. | No freeform assumptions layer; this utility slice focuses on candidate normalization and duplicate/conflict review. | Not modeled as a separate field; unknowns are explicit values like `published_at: unknown` or operator escalation. | Build one ledger candidate, review conflicts, then propose writeback. | `confirmation-required`, `approval-requested`, `approve write`, `revise`, `reject`. |
| #63 Category strategy | Input summary and proposal both separate confirmed facts from assumptions. | Explicit under `assumptions` and `strategy_slice.assumptions`. | Explicit under `missing_context`. | Planned items + review checkpoints + optional writeback proposal. | `confirmation-required`, `approval-requested`, `approve write`, `revise`, `reject`. |
| #64 LinkedIn weekly | Input summary and candidate planning basis both surface confirmed facts and assumptions. | Explicit under `assumptions`. | Present in the fixture and expected by the workflow doc/validator, but not represented in the current skill output shape; follow-up #121 tracks this. | Proposed angles + weekly posts + optional writeback proposal. | `pending-human-approval` in candidate plus `confirmation-required` writeback proposal. |
| #58 X queue ingestion | Normalized signals are treated as approved fake source cues. | Not emphasized as a first-class field in the ingestion fixture; this slice is about proposal-only queue candidates from fake source input. | Not represented explicitly in the source-ingestion fixture; acceptable because the slice is narrower than full queue planning. | Queue candidates + proposed queue update + approval request. | `approval-requested`, `approve write`, `revise`, `reject`; writes before approval stay false. |
| #65 On-demand briefs | Planning basis explicitly shows confirmed facts. | Explicit under `planning_basis.assumptions`. | Explicit under `planning_basis.missing_context`. | Proposed angles + per-network brief candidates + planned write targets. | `pending-human-approval` in candidate plus `confirmation-required` writeback proposal. |

## Safety claims review

| Workflow | Safety finding |
|---|---|
| #61 OpenClaw Global | No live Engram writes, publishing, scheduling, Buffer activity, GitHub mutations, or production credentials are claimed before approval. |
| #62 Ledger utility | No live Discord execution, durable writes before approval, scheduling, publishing, Buffer activity, or GitHub mutations are claimed. |
| #63 Category strategy | No live analytics, durable writes before approval, scheduling, publishing, Buffer activity, runtime prompts, or GitHub mutations are claimed. |
| #64 LinkedIn weekly | No live OpenClaw/Discord execution, publishing, scheduling, queue execution, Buffer activity, live analytics, final copy generation, runtime prompts, or GitHub mutations are claimed. |
| #58 X queue ingestion | No durable writes before approval, workspace file writes before approval, publishing, scheduling, Buffer activity, or production credentials are claimed. |
| #65 On-demand briefs | No live source fetching, live writes, publishing, scheduling, Buffer activity, live analytics, runtime prompts, public-channel behavior, or GitHub mutations are claimed before approval. |

## Mismatch review

| Finding | Status |
|---|---|
| Existing runtime evidence mismatch tracked in #119 (six vs seven synced skills across runtime docs) | Reviewed, but not blocking here because QA-03 is about skill/workflow contract coherence rather than runtime evidence history. |
| LinkedIn weekly planning `missing_context` is required by the workflow doc and fixture/validator, but not represented explicitly in `skills/linkedin-weekly-planner/SKILL.md` output shape | Follow-up #121 filed. |
| Other walked workflows | No new mismatch requiring a follow-up issue was found. |

## Evidence captured

- `skills/brand-context/SKILL.md`, `skills/content-ledger/SKILL.md`, `skills/strategy-planner/SKILL.md`, `skills/linkedin-weekly-planner/SKILL.md`, `skills/x-queue-planner/SKILL.md`, `skills/on-demand-brief-planner/SKILL.md`, and `skills/discord-approval-gate/SKILL.md`.
- Workflow docs:
  - `docs/operations/openclaw-global-brand-context-refresh.md`
  - `docs/operations/content-ledger-utility-flow.md`
  - `docs/operations/category-strategy-planning-flow.md`
  - `docs/operations/linkedin-weekly-planning-flow.md`
  - `docs/operations/x-queue-discord-approval-flow.md`
  - `docs/operations/on-demand-brief-flow.md`
  - `docs/research/x-queue-planning-skill.md`
- Fixtures:
  - `examples/openclaw-global-brand-context-refresh.fake.yaml`
  - `examples/content-ledger-utility-flow.fake.yaml`
  - `examples/category-strategy-planning-flow.fake.yaml`
  - `examples/linkedin-weekly-planning-flow.fake.yaml`
  - `examples/x-queue-source-ingestion.fake.yaml`
  - `examples/on-demand-brief-flow.fake.yaml`
  - `examples/discord-approval-gate.fake.yaml`
- Validators:
  - `scripts/validate-openclaw-global-brand-context-refresh.sh`
  - `scripts/validate-content-ledger-utility-flow.sh`
  - `scripts/validate-category-strategy-planning-flow.sh`
  - `scripts/validate-linkedin-weekly-planning-flow.sh`
  - `scripts/validate-x-queue-source-ingestion.sh`
  - `scripts/validate-on-demand-brief-flow.sh`
  - `scripts/validate-discord-approval-gate.sh`

## Actual result

From a QA perspective, the fake workflow contract set is coherent and reviewable:

- each walked workflow maps cleanly to a skill, fixture, doc/runbook, validator, and approval gate;
- workflows that should separate facts, assumptions, missing context, and approval states do so, or clearly stay narrower by design;
- approval-gated persistence boundaries are explicit across the set;
- network-specific outputs stay separated where the workflow requires them;
- one contract-modeling mismatch was found and filed as #121 instead of being patched inline during the walkthrough.

## Pass / fail decision

- Status: `pass-with-follow-up`
- Why: the workflow set is coherent enough for QA-03, and the one contract-modeling mismatch found during review was recorded as follow-up #121.

## Follow-up issues

- #119 — reconcile six-vs-seven skill sync count evidence across runtime docs.
- #121 — reconcile LinkedIn `missing_context` modeling across skill, workflow doc, fixture, and validator.

## Next step

Proceed to #109 and use this evidence pack plus `docs/operations/qa-acceptance-matrix.md` as the QA source of truth for the memory and approval-gate walkthrough.
