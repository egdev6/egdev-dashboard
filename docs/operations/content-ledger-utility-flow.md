# Content ledger utility flow

This runbook defines the fake-first content-ledger utility pilot for issue #62. It reuses `skills/content-ledger/SKILL.md`, keeps #57 as a transport/routing anchor only, and routes any durable ledger proposal through `docs/architecture/discord-memory-gateway.md` plus `skills/discord-approval-gate/SKILL.md`.

## Quick path

1. Start from a matched route and hydrated context prepared under #70-#74.
2. Build one ledger candidate before any write.
3. Review duplicate/conflict risk over `content_entry.id` plus route/network context.
4. Show the approval prompt with the exact phrase `approve write`.
5. Keep `revise: <instruction>` and `reject` outcomes runtime-local/audit-only.

## Utility boundaries

| Topic | Decision |
| --- | --- |
| Workflow owner | `content-ledger` is a category/channel utility skill, not a fixed channel-owned workflow. |
| Transport anchor | #57 stays transport/routing only. It does not define ledger semantics. |
| Source contracts | This pilot depends on #70, #71, #72, #73, #74, and #75 plus `docs/architecture/discord-context-skill-packs.md`. |
| Durable ledger states | Only `draft`, `queued`, `published`, and `archived` are ledger states. |
| Approval responses | `approve write`, `revise: <instruction>`, and `reject` are gate responses, not durable ledger states. |
| Queue boundary | `queued` is not scheduling implementation. This slice does not schedule, publish, or trigger Buffer. |
| Runtime notes | Runtime-only notes stay outside durable ledger entries and may remain in runtime audit or an approved overlay only. |

## Candidate-before-write flow

| Step | Decision |
| --- | --- |
| 1. Resolve route | Use a matched route plus hydrated context from `docs/architecture/discord-memory-gateway.md` and `docs/architecture/discord-context-skill-packs.md`. |
| 2. Draft candidate | Reuse `skills/content-ledger/SKILL.md` to produce one normalized ledger candidate with fake/demo data only. |
| 3. Review duplicates | Compare `content_entry.id` against route/network context and escalate duplicate or conflicting candidates to the operator. |
| 4. Ask for approval | Return a `confirmation-required` proposal using `skills/discord-approval-gate/SKILL.md` and the exact phrase `approve write`. |
| 5. Stop before persistence | Keep the durable target planned only, with `write_executed: false`, until the operator decides. |

## Candidate shape

The reviewable candidate must include:

- `project`
- `network`
- `content_entry.id`
- `content_entry.status`
- `content_entry.published_at` or `unknown`
- `content_entry.assets`
- `content_entry.source_link` or `none`
- `follow_up`
- `proposal_summary`
- `target_namespaces`
- `no_op_boundaries`

Use `docs/security/data-handling.md` exactly: fake/demo values only, no raw Discord transcripts, no real guild or channel IDs, no production credentials, and no private exports.

## Approval and audit policy

Durable ledger proposals target `discord-project-manager/project/<project-slug>/content-ledger`. Runtime-only audit context stays separate under `discord-project-manager/runtime/discord/<guild-id>/<channel-id>`.

Duplicate/conflict review is contract behavior only. It may surface `operator-escalation-required`, but it does not claim automated runtime enforcement.

Before `approve write`, do not perform live Discord execution, live Engram or other durable writes, publishing, scheduling, Buffer activity, runtime provisioning, or GitHub mutations.

## Non-goals

This pilot does not:

- implement live Discord execution;
- perform live Engram or other durable writes;
- automate duplicate enforcement;
- implement scheduling or publishing;
- trigger Buffer activity;
- persist raw transcripts;
- use production credentials.

## Related contracts

- #57 transport/routing anchor only
- #70 scoped Discord skills registry
- #71 Discord Memory Gateway
- #72 Discord Context Pack and Skill Pack schemas
- #73 Runtime Orchestrator contract
- #74 OpenClaw to Gentle SDD handoff boundaries
- #75 context/skill pilot roadmap
- `skills/content-ledger/SKILL.md`
- `skills/discord-approval-gate/SKILL.md`
- `docs/architecture/discord-memory-gateway.md`
- `docs/architecture/discord-context-skill-packs.md`
- `docs/operations/discord-approval-responses.md`
- `docs/security/data-handling.md`
