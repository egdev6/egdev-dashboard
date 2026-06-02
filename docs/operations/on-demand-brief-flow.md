# On-demand brief flow

This runbook defines the fake-first multi-network on-demand brief pilot for issue #65. It reuses `skills/on-demand-brief-planner/SKILL.md`, keeps #57 as a transport/routing anchor only, and routes any planned durable update through `docs/architecture/discord-memory-gateway.md` plus `skills/discord-approval-gate/SKILL.md`.

## Quick path

1. Start from a matched route and approved hydration only.
2. Prepare one bounded Context Pack and one Skill Pack before any brief candidate.
3. Separate confirmed facts, assumptions, missing context, format rules, and proposed angles.
4. Return reviewable network-separated brief candidates before any write.
5. Keep `approve write`, `revise: <instruction>`, and `reject` behind the approval gate.

## Pilot boundaries

| Topic | Decision |
| --- | --- |
| Workflow owner | `on-demand-brief-planner` is a multi-network brief pilot, not a fixed channel-owned workflow. |
| Transport anchor | #57 stays transport/routing only. It does not define brief semantics. |
| Source contracts | This pilot depends on #61, #62, #63, #64, #70, #71, #72, #73, #74, and #75 plus `docs/architecture/discord-context-skill-packs.md`. |
| Context inputs | Approved inherited/global/category/channel context, approved strategy summaries, approved content-ledger summaries, and optional safe fake read-model summaries only. |
| SDD boundary | Gentle SDD is optional only when intent is actual `sdd_dev_work`; this pilot is not SDD-first. |
| Writeback boundary | Any durable update stays `confirmation-required` until exact `approve write`. |
| Reject/revise path | Rejected or revised proposals remain runtime-local/audit-only. |

## Input flow

Use this flow:

```text
matched route -> approved hydration -> context pack -> skill pack -> intent classification -> on-demand brief candidates
```

Required runtime/review metadata must include:

- `runtime_namespace`
- `routing_status`
- `resolved_route`
- `effective_skills`
- `mandatory_skills`
- `intent_classification`

Approved input sources may include these pack scopes when applicable: `global`, `category`, `channel`, `thread-session`, and `scoped-skill-context`.

Approved input sources may include:

- inherited `OpenClaw Global` context from `docs/operations/openclaw-global-brand-context-refresh.md`;
- approved strategy summaries from `docs/operations/category-strategy-planning-flow.md`;
- approved content-ledger summaries from `docs/operations/content-ledger-utility-flow.md`;
- approved category or network context under project namespaces;
- optional safe fake read-model summaries.

Live source fetching, raw source dumps, live analytics, and raw transcripts are out of scope. Follow `docs/security/data-handling.md` exactly.

## Candidate shape

The brief candidate should reuse the existing `skills/on-demand-brief-planner/SKILL.md` output shape:

- `source_context`
- `brief_request`
- `planning_basis.confirmed_facts`
- `planning_basis.assumptions`
- `planning_basis.missing_context`
- `planning_basis.format_rules`
- `planning_basis.proposed_angles`
- `briefs`
- `approval`
- `memory_write_targets`

Keep briefs separated by network/output surface and bounded to reviewable fake/demo examples.

## Approval and writeback policy

`discord-approval-gate` is mandatory for any strategy, network, or content-ledger save proposal.

Before `approve write`, do not perform live source fetching, live Discord/OpenClaw execution, runtime prompt execution, live Engram or other durable writes, live analytics, publishing, scheduling, queue execution, Buffer activity, runtime provisioning, GitHub mutations, or public-channel behavior.

Every writeback proposal must show:

- `classification: confirmation-required`
- `approval_state: approval-requested`
- exact `approval_phrase: approve write`
- `write_executed: false`
- a runtime audit namespace separate from durable target namespaces

If ledger candidates are included, durable states stay:

- `draft`
- `queued`
- `published`
- `archived`

`queued` requires approval separate from scheduling and must not imply scheduling happened.

## Non-goals

This pilot does not:

- implement live source fetching;
- implement live Discord or OpenClaw execution;
- execute runtime prompts;
- perform live Engram or other durable writes;
- require live analytics;
- publish, schedule, or queue content;
- trigger Buffer activity;
- provision runtime services or plugins;
- introduce GitHub mutations;
- persist raw transcripts, raw source dumps, or private payloads;
- use production credentials;
- validate public-channel behavior.

## Related contracts

- #57 transport/routing anchor only
- #61 OpenClaw Global brand context refresh pilot
- #62 content-ledger utility pilot
- #63 category strategy planning pilot
- #64 `egdev-linkedin` weekly planning pilot
- #70 scoped Discord skills registry
- #71 Discord Memory Gateway
- #72 Discord Context Pack and Skill Pack schemas
- #73 Runtime Orchestrator contract
- #74 OpenClaw to Gentle SDD handoff boundaries
- #75 context/skill pilot roadmap
- `skills/on-demand-brief-planner/SKILL.md`
- `skills/discord-approval-gate/SKILL.md`
- `docs/architecture/discord-context-skill-packs.md`
- `docs/architecture/discord-memory-gateway.md`
- `docs/architecture/discord-runtime-orchestrator.md`
- `docs/architecture/discord-gentle-sdd-handoff.md`
- `docs/operations/openclaw-global-brand-context-refresh.md`
- `docs/operations/category-strategy-planning-flow.md`
- `docs/operations/content-ledger-utility-flow.md`
- `docs/operations/discord-approval-responses.md`
- `docs/security/data-handling.md`
