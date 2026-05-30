# On-demand brief workflow skill contract

This note defines the reviewable contract for issue #13: an on-demand brief workflow for YouTube, Twitch, and Stack and Flow with explicit inputs, outputs, approval points, and planned memory or ledger targets.

## Quick path

1. Use `skills/on-demand-brief-planner/SKILL.md` as the contract source of truth.
2. Review `examples/on-demand-brief.fake.yaml` for the fake input and output shape.
3. Confirm all drafting, publishing, scheduling, and durable memory or ledger writes remain approval-gated.

## Contract purpose

The on-demand brief planner turns approved context and a user prompt into a small brief set that humans can review before drafting, publishing, scheduling, or durable memory or ledger writes.

It exists to make the brief-planning surface explicit before any later automation work.

## Supported networks

The contract supports:

- `youtube`
- `twitch`
- `stack-and-flow`

A single request may target one or more of these networks.

## Inputs

The contract expects an on-demand brief request that covers:

- project identity;
- request id and timeframe;
- user prompt;
- goal;
- audience;
- desired networks;
- constraints;
- known assets;
- optional desired CTA;
- optional brand and ledger summaries;
- optional source context namespaces.

The fake fixture demonstrates these inputs under `source_context` and `brief_request`.

## Outputs

The contract returns a structured brief set with:

- `planning_basis.confirmed_facts`, `planning_basis.assumptions`, `planning_basis.format_rules`, and `planning_basis.proposed_angles`;
- `briefs` entries for YouTube, Twitch, and Stack and Flow;
- per-brief `brief_goal`, `audience`, `outline`, `required_assets`, `call_to_action`, and `rationale`;
- `approval.status` and `approval.checkpoints`;
- `memory_write_targets` for project strategy, content ledger, and the three network subtrees.

This keeps multi-network brief intent, approval requirements, and planned durable destinations reviewable in one artifact.

## Memory and ledger namespaces

Read candidates:

- `egdev-dashboard/project/egdev/brand`
- `egdev-dashboard/project/egdev/strategy`
- `egdev-dashboard/project/egdev/content-ledger`
- `egdev-dashboard/project/egdev/network/youtube`
- `egdev-dashboard/project/egdev/network/twitch`
- `egdev-dashboard/project/egdev/network/stack-and-flow`

Write candidates after human approval only:

- `egdev-dashboard/project/egdev/strategy`
- `egdev-dashboard/project/egdev/content-ledger`
- `egdev-dashboard/project/egdev/network/youtube`
- `egdev-dashboard/project/egdev/network/twitch`
- `egdev-dashboard/project/egdev/network/stack-and-flow`

Approved briefs may become ledger-write candidates after human approval, but they must still use the existing content-ledger status contract. An approved but unscheduled brief maps to `draft`; `queued` is reserved for items that also have scheduling approval. This contract does not claim the runtime already performs those writes.

These follow ADR 0002 exactly.

## Human approval points

Human approval remains mandatory:

- the requested networks and shared theme must still match approved brand context;
- each brief must be approved before drafting;
- publishing must be approved before any brief becomes live content;
- scheduling must be approved before any live slot or publishing calendar entry is created;
- durable memory and ledger writes must be approved before saving strategy, network, or content-ledger state, and ledger status must stay within the existing `draft|queued|published|archived` contract;
- this contract does not authorize Discord runtime actions, Buffer analytics, OpenClaw invocation, or Engram Cloud sync.

## Fake-data safety

The example fixture is safe for the public repo because it:

- uses fake/demo values only;
- references only `asset://demo/...` assets;
- uses no private brand, customer, creator, or Discord data;
- keeps `fixture_type: fake-demo` and `safe_for_repo: true` markers.

## Limitations

This contract defines a planning surface only.

It does not validate:

- OpenClaw invocation;
- live Engram writes;
- Discord routing;
- Buffer analytics;
- publishing or scheduling.
