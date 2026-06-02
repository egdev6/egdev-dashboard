# LinkedIn weekly planning flow

This runbook defines the fake-first `egdev-linkedin` category-local operational pilot for issue #64. It reuses `skills/linkedin-weekly-planner/SKILL.md`, specializes `docs/operations/category-strategy-planning-flow.md`, keeps #57 as a transport/routing anchor only, and routes any planned durable update through `docs/architecture/discord-memory-gateway.md` plus `skills/discord-approval-gate/SKILL.md`.

## Quick path

1. Start from a matched route and approved inherited context.
2. Prepare one bounded Context Pack and one Skill Pack before any weekly plan candidate.
3. Separate confirmed facts, assumptions, and missing context.
4. Return one reviewable weekly plan candidate before any write.
5. Keep `approve write`, `revise: <instruction>`, and `reject` behind the approval gate.

## Pilot boundaries

| Topic | Decision |
| --- | --- |
| Workflow owner | `linkedin-weekly-planner` is the `egdev-linkedin` category-local pilot, not a fixed channel-owned workflow. |
| Transport anchor | #57 stays transport/routing only. It does not define LinkedIn planning semantics. |
| Source contracts | This pilot depends on #61, #62, #63, #70, #71, #72, #73, #74, and #75 plus `docs/architecture/discord-context-skill-packs.md`. |
| Context inputs | Approved inherited global context, LinkedIn category/channel context, approved strategy summaries, approved content-ledger summaries, and optional safe fake read-model summaries only. |
| Output boundary | The result is planning only. It does not generate final copy, publish posts, schedule posts, queue work, or trigger Buffer activity. |
| Writeback boundary | Any durable update stays `confirmation-required` until exact `approve write`. |
| Reject/revise path | Rejected or revised proposals remain runtime-local/audit-only. |

## Input flow

Use this flow:

```text
matched route/category origin -> approved context hydration -> context pack -> skill pack -> linkedin-weekly-planner weekly plan candidate
```

Approved input sources may include these pack scopes when applicable: `global`, `category`, `channel`, `thread-session`, and `scoped-skill-context`.

Approved input sources may include:

- inherited `OpenClaw Global` context from `docs/operations/openclaw-global-brand-context-refresh.md`;
- approved strategy summaries from `docs/operations/category-strategy-planning-flow.md`;
- approved content-ledger summaries from `docs/operations/content-ledger-utility-flow.md`;
- LinkedIn category/channel context under approved project namespaces;
- safe fake read-model summaries when available.

Before recommendations, the candidate must show:

- confirmed facts;
- assumptions;
- missing context;
- proposed angles;
- weekly posts;
- approval checkpoints.

Do not invent live analytics, private notes, unpublished operations, or raw transcripts. Follow `docs/security/data-handling.md` exactly.

## Candidate shape

The weekly plan candidate should reuse the existing `skills/linkedin-weekly-planner/SKILL.md` output shape:

- `source_context`
- `planning_inputs`
- `planning_basis`
- `weekly_plan`
- `approval`
- `memory_write_targets`
- `out_of_scope`

Keep the result reviewable and bounded to one timeframe for `egdev-linkedin`.

## Approval and writeback policy

Optional durable writeback proposals may target approved LinkedIn-local planning context under `discord-project-manager/project/<project-slug>/network/linkedin` or reusable strategy rules under `discord-project-manager/project/<project-slug>/strategy`.

Before `approve write`, do not perform live Discord/OpenClaw execution, live LinkedIn publishing, scheduling, Buffer activity, live analytics calls, live Engram or other durable writes, runtime provisioning, GitHub mutations, queue execution, final copy generation, or runtime prompt execution.

Every writeback proposal must show:

- `classification: confirmation-required`
- `approval_state: approval-requested`
- exact `approval_phrase: approve write`
- `write_executed: false`
- a runtime audit namespace separate from the durable target namespace

## Non-goals

This pilot does not:

- implement live Discord or OpenClaw execution;
- perform live LinkedIn publishing;
- perform scheduling or queue execution;
- trigger Buffer activity;
- require live analytics;
- perform live Engram or other durable writes;
- provision runtime services or plugins;
- introduce GitHub mutations;
- persist raw transcripts or private payloads;
- use production credentials;
- generate final copy;
- execute runtime prompts.

## Related contracts

- #57 transport/routing anchor only
- #61 OpenClaw Global brand context refresh pilot
- #62 content-ledger utility pilot
- #63 category strategy planning pilot
- #70 scoped Discord skills registry
- #71 Discord Memory Gateway
- #72 Discord Context Pack and Skill Pack schemas
- #73 Runtime Orchestrator contract
- #74 OpenClaw to Gentle SDD handoff boundaries
- #75 context/skill pilot roadmap
- `skills/linkedin-weekly-planner/SKILL.md`
- `skills/discord-approval-gate/SKILL.md`
- `docs/architecture/discord-memory-gateway.md`
- `docs/architecture/discord-context-skill-packs.md`
- `docs/architecture/discord-scoped-skills-registry.md`
- `docs/operations/category-strategy-planning-flow.md`
- `docs/operations/openclaw-global-brand-context-refresh.md`
- `docs/operations/content-ledger-utility-flow.md`
- `docs/operations/discord-approval-responses.md`
- `docs/security/data-handling.md`
