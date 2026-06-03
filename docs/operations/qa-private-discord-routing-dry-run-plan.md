# QA private Discord routing dry-run plan

This evidence pack records the approved plan-only slice for QA-07 in issue #112. Execution was **not** performed in this PR. The outcome here is a gated, reviewer-facing plan for a future private Discord dry-run once a non-production guild/channel, non-production credentials, and explicit execution approval are available.

## Quick path

1. Reuse AGENT runtime evidence and the completed QA packs before attempting any Discord-live-adjacent step.
2. Review `docs/operations/private-discord-manual-verification-guide.md` to organize topology, channel roles, and sanitized manual evidence.
3. Prepare only a private non-production Discord environment with reversible setup and sanitized evidence rules.
4. Stop before execution unless a human explicitly authorizes the dry-run and provides the required private inputs.

## Evidence pack header

| Field | Value |
|---|---|
| Issue | #112 — QA-07 private Discord routing dry-run |
| Test order | `QA-07` |
| Owner | `QA+agent` |
| Date (UTC) | 2026-06-02T16:39:27Z |
| Branch / commit | `test/112-qa-private-discord-routing-plan` |
| Environment | Not executed / gated private Discord dry-run plan |
| Preconditions used | #106 matrix, #108 skills walkthrough, #109 approval-gate walkthrough, #111 private runtime smoke walkthrough, AGENT evidence #104 and #105 |
| Status | `blocked` |

## Scope

- Define the reversible setup and evidence shape for a future private Discord routing dry-run.
- Define the route-resolution observation plan for a private non-production guild/channel.
- Define how approval-response behavior should be checked without bypassing write gates.
- Record the manual inputs and explicit approvals required before any execution starts.

## Non-goals

This plan does **not**:

- install or use the Discord plugin in this PR;
- connect to Discord;
- use public channels or production credentials;
- execute runtime prompts;
- perform durable writes;
- mutate GitHub state;
- publish, schedule, or trigger Buffer activity;
- validate live analytics;
- commit `.env` values, tokens, raw logs, private payloads, transcripts, screenshots, or source dumps;
- claim that QA-07 acceptance criteria passed.

## Preconditions

- `docs/operations/qa-acceptance-matrix.md` remains the QA source of truth.
- `docs/operations/qa-private-docker-runtime-smoke-walkthrough.md` is complete and proves the local private runtime smoke path.
- `docs/operations/runtime-pilot-checklist.md` remains the runtime baseline before any Discord-live-adjacent step.
- `docs/operations/discord-routing.md` defines the routing contract and unknown-channel fallback.
- `docs/operations/discord-approval-responses.md` defines the approval-response contract and audit fields.
- `docs/architecture/discord-channel-routing.md`, `docs/architecture/channel-context-namespace-mapping.md`, and `docs/architecture/discord-context-skill-packs.md` remain the resolver and pack references.
- `examples/discord-runtime-orchestrator.fake.yaml` remains the fake orchestration baseline for matched-route and fallback behavior.
- A human operator must provide a private non-production Discord guild/channel, non-production credentials, and explicit approval before execution.

Manual user steps required before execution: `provide a private non-production Discord guild/channel, provide non-production credentials outside the repo, and explicitly approve QA-07 execution`.

## Execution status for this PR

Dry-run execution was **not performed** in this PR.

Reason:

- the approved scope is `plan gated only`;
- no private Discord environment or non-production credentials were authorized here; and
- QA-07 is the first Discord-live-adjacent slice, so execution remains blocked until a human explicitly unlocks it.

## Reversible setup checklist for a future run

Use this checklist only after explicit execution approval.

### Private environment inputs

| Input | Requirement | Repo rule |
|---|---|---|
| Private guild | Non-production guild dedicated to testing | Do not commit the real guild ID |
| Private channel | Non-production channel with an approved route name or explicit unmapped test case | Do not commit the real channel ID |
| Bot credentials | Non-production credentials only | Keep outside git and outside PR text |
| Local runtime | Existing private/local Docker path already validated by QA-06 | Reuse, do not broaden scope |
| Operator approval | Explicit approval to execute QA-07 | Record only the approval decision, not secrets |

### Reversible runtime steps

1. Confirm `main` is current and the local runtime path from QA-06 still works.
2. Confirm the Discord route under test is either:
   - a matched-route example such as `<network-slug>-<project-slug>`; or
   - an intentional unmapped fallback example.
3. If the external Discord plugin is not yet installed, install it only in the private runtime used for the dry-run, then restart the runtime.
4. Record the uninstall/revert path before proceeding:
   - stop the private runtime;
   - remove the Discord plugin from that private runtime if rollback is needed;
   - restart the private runtime without the plugin;
   - confirm no repo files, credentials, or durable memory were changed.
5. Keep the runtime bound to private/local surfaces only and do not expose public Discord behavior.

## Planned observation flow

QA-07 execution is not safe to unlock by sending live Discord messages until the runtime can prove a no-op observation mode. The current fake orchestration baseline sets `live_prompt_execution: false`, `prompt_execution: none`, and `workspace_file_writes_allowed: false`; the approval-response runbook also records that an earlier write-like Discord request created workspace files before approval.

A future execution must therefore use one of these safe observation mechanisms before any private channel message is sent:

- a resolver-only diagnostic that accepts a sanitized event envelope and returns route metadata without invoking prompts, tools, workspace writes, or durable memory writes;
- a plugin/runtime dry-run mode that receives the Discord event but stops before prompt execution and write-capable tools; or
- an updated runtime enforcement layer that has already been re-tested to prove write-like Discord requests are response-only until explicit approval.

If none of those mechanisms exists, keep QA-07 `blocked` and do not execute the private Discord dry-run.

### A. Route-resolution check

Goal: observe whether the runtime resolver would classify a private channel as `matched-route` or `unmapped-channel` without prompt execution or writes.

Planned checks:

1. Use only the approved no-op resolver diagnostic, dry-run mode, or re-tested enforcement path described above.
2. Confirm the runtime namespace shape remains `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` using placeholders or redacted IDs in evidence.
3. Confirm channel-name normalization follows the `<network-slug>-<project-slug>` contract when applicable, but publish only fake/demo names or redacted names.
4. For matched routes, confirm the reported durable read candidates align with:
   - `brand`
   - `strategy`
   - `content-ledger`
   - `network/<network-slug>`
5. For unmapped routes, confirm the runtime stays in fallback mode and requests human route selection.
6. Do **not** convert route resolution into runtime prompt execution, workspace writes, or durable memory writes.

### B. Approval-response check

Goal: verify that a write-like request would be held behind the approval boundary without running the live Discord path into prompt execution or workspace writes.

Planned checks:

1. Use a sanitized synthetic event envelope or a proven no-op preview path; do not send a write-like private Discord message unless runtime enforcement has already been re-tested.
2. Confirm the response state would be `proposal` or `approval-requested`, not `approved-for-write`.
3. Confirm the response shows:
   - runtime namespace;
   - routing status;
   - resolved route or `none`;
   - target namespaces;
   - approval status `pending`;
   - explicit no-op boundaries.
4. Confirm the response asks for an explicit approval phrase and does not treat silence or unrelated replies as approval.
5. Do **not** send the approval phrase during the initial dry-run unless a narrower follow-up explicitly authorizes write testing.

## Sanitized evidence plan

Capture only reviewer-safe evidence for a future execution.

| Evidence item | Safe capture shape | Forbidden content |
|---|---|---|
| Route outcome | `matched-route` or `unmapped-channel`, fake/demo or redacted normalized channel name, fake placeholders for IDs | Real guild/channel IDs or real private channel names |
| Runtime namespace | Placeholder form such as `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | Real Discord IDs |
| Approval response | Sanitized excerpt showing state, target namespaces, and explicit approval phrase requirement | Raw transcripts, secrets, private payloads |
| Runtime logs | Minimal sanitized excerpt only if needed for triage | Raw logs, tokens, `.env` values |
| Screenshots | Optional cropped proof with IDs/tokens redacted | Full Discord exports or private message history |
| Follow-up notes | Pass/fail/block reason plus next action | Source dumps or customer/private content |

## Future execution template

Use this template only when QA-07 execution is explicitly approved.

| Check | Expected result | Evidence placeholder |
|---|---|---|
| Private guild/channel used | Non-production only | `<redacted-private-guild-channel-proof>` |
| Plugin setup | Documented and reversible | `<sanitized-setup-note>` |
| Route resolution | `matched-route` or `unmapped-channel` observed through no-op resolver/dry-run mode | `<sanitized-route-outcome>` |
| Approval response | Approval gate visible through no-op preview, no bypass | `<sanitized-approval-response>` |
| Durable writes | None during initial gated observation unless separately authorized | `<explicit-no-write-note>` |
| Public/prod behavior | None | `<boundary-confirmation>` |

## Stop rules and triage notes

Stop the future execution immediately and mark QA-07 `blocked` if any of these happen:

- the environment requires production credentials;
- the route points at a public guild/channel;
- the runtime requires prompt execution or workspace writes to prove basic routing;
- the flow attempts durable writes before explicit approval;
- the flow creates publishing, scheduling, Buffer, analytics, or GitHub side effects;
- the evidence requires raw transcripts, screenshots with secrets, or private payload dumps;
- the plugin setup cannot be reversed safely in the private environment.

Safe first responses:

| Scenario | Safe first response | Avoid |
|---|---|---|
| Missing private Discord environment | Stop and request the private guild/channel plus non-production credentials from the operator | Do not substitute a public or production environment |
| Route does not match expected naming | Record the sanitized mismatch and fall back to `unmapped-channel` behavior | Do not force a guessed route |
| Approval gate is bypassed or cannot be previewed without writes | Stop, capture a sanitized excerpt if safe, and file a scoped follow-up before any write testing | Do not continue into durable writes |
| Plugin/runtime setup is unclear | Revert to the last known private runtime state and update the plan/runbook first | Do not improvise undocumented setup in production-like space |

## Actual result

For this PR, QA-07 now has a reviewable gated plan with explicit manual requirements, reversible setup expectations, no-op route-observation requirements, approval-response preview checks, and sanitized evidence rules.

Execution remains blocked until a human provides the private Discord environment and explicitly approves the dry-run.

## Pass / fail decision

- Status: `blocked`
- Why: this slice intentionally documents the plan only. No private Discord environment or non-production credentials were authorized here, so QA-07 execution was not performed and cannot be claimed as passed.

## Follow-up issues

- none specific to this plan-only slice
- execution remains under #112 until a human authorizes the private dry-run

## Next step

Keep #112 in a gated state. Use `docs/operations/private-discord-manual-verification-guide.md` for operator-facing preparation, and execute the private Discord routing dry-run only after a human provides the required private environment, non-production credentials, and explicit execution approval.