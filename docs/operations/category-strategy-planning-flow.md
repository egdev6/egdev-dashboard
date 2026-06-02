# Category strategy planning flow

This runbook defines the fake-first category strategy pilot for issue #63. It reuses `skills/strategy-planner/SKILL.md`, keeps #57 as a transport/routing anchor only, and routes any durable strategy proposal through `docs/architecture/discord-memory-gateway.md` plus `skills/discord-approval-gate/SKILL.md`.

## Quick path

1. Start from a matched route and approved inherited context.
2. Prepare one Context Pack and one Skill Pack before any proposal.
3. Separate confirmed facts, assumptions, and missing context.
4. Return one structured strategy proposal before any write.
5. Keep `approve write`, `revise: <instruction>`, and `reject` behind the approval gate.

## Pilot boundaries

| Topic | Decision |
| --- | --- |
| Workflow owner | `strategy-planner` is a category strategy pilot, not a fixed channel-owned workflow. |
| Transport anchor | #57 stays transport/routing only. It does not define strategy semantics. |
| Source contracts | This pilot depends on #61, #62, #70, #71, #72, #73, #74, and #75 plus `docs/architecture/discord-context-skill-packs.md`. |
| Context inputs | Approved global inheritance, category/network overlays, content-ledger summaries, and optional dashboard/read-model summaries only. |
| Analytics boundary | Analytics are optional fake/safe read-model summaries only; no live analytics are required or implied. |
| Writeback boundary | Reusable strategy rules or planning overlays stay `confirmation-required` until exact `approve write`. |
| Reject/revise path | Rejected or revised proposals remain runtime-local/audit-only. |

## Input flow

Use this flow:

```text
matched route/category origin -> approved context hydration -> context pack -> skill pack -> strategy-planner proposal
```

Approved input sources may include these pack scopes when applicable: `global`, `category`, `channel`, `thread-session`, and `scoped-skill-context`.

Approved input sources may include:

- inherited `OpenClaw Global` context from `docs/operations/openclaw-global-brand-context-refresh.md`;
- content-ledger utility summaries from `docs/operations/content-ledger-utility-flow.md`;
- category or network overlays under approved project namespaces;
- safe dashboard/read-model summaries from `docs/architecture/dashboard-read-model-contracts.md` when available.

Before recommendations, the proposal must show:

- confirmed facts;
- assumptions;
- missing context.

Do not invent analytics, private notes, or unpublished operational data. Follow `docs/security/data-handling.md` exactly.

## Proposal shape

The strategy proposal must use the existing `skills/strategy-planner/SKILL.md` output shape under `strategy_slice`:

- `strategy_slice.goals`
- `strategy_slice.assumptions`
- `strategy_slice.planned_items`
- `strategy_slice.review_checkpoints`
- `strategy_slice.out_of_scope`

Keep the result reviewable and bounded to the requested timeframe and category/network scope.

## Approval and writeback policy

Optional durable writeback proposals may target reusable strategy rules under `discord-project-manager/project/<project-slug>/strategy` or category/network planning overlays under `discord-project-manager/project/<project-slug>/network/<network-slug>`.

Before `approve write`, do not perform live Discord execution, live Engram or other durable writes, live analytics calls, scheduling, publishing, Buffer activity, runtime provisioning, GitHub mutations, or runtime prompt execution.

Every writeback proposal must show:

- `classification: confirmation-required`
- `approval_state: approval-requested`
- exact `approval_phrase: approve write`
- `write_executed: false`
- a runtime audit namespace separate from the durable target namespace

## Non-goals

This pilot does not:

- implement live Discord execution;
- perform live Engram or other durable writes;
- require live analytics;
- schedule or publish content;
- trigger Buffer activity;
- provision runtime services or plugins;
- introduce GitHub mutations;
- persist raw transcripts or private payloads;
- use production credentials;
- execute runtime prompts.

## Related contracts

- #57 transport/routing anchor only
- #61 OpenClaw Global brand context refresh pilot
- #62 content-ledger utility pilot
- #70 scoped Discord skills registry
- #71 Discord Memory Gateway
- #72 Discord Context Pack and Skill Pack schemas
- #73 Runtime Orchestrator contract
- #74 OpenClaw to Gentle SDD handoff boundaries
- #75 context/skill pilot roadmap
- `skills/strategy-planner/SKILL.md`
- `skills/discord-approval-gate/SKILL.md`
- `docs/architecture/discord-memory-gateway.md`
- `docs/architecture/discord-context-skill-packs.md`
- `docs/architecture/dashboard-read-model-contracts.md`
- `docs/operations/discord-approval-responses.md`
- `docs/security/data-handling.md`
