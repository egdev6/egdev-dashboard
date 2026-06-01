# X queue planning skill contract

This note defines the reviewable contract for issue #12: an X queue planning slice with explicit inputs, outputs, approval points, and memory targets.

## Quick path

1. Use `skills/x-queue-planner/SKILL.md` as the contract source of truth.
2. Review `examples/x-queue-plan.fake.yaml` for the fake input/output shape.
3. Confirm all drafting, publishing, scheduling, and durable memory writes remain approval-gated.

## Contract purpose

The X queue planner turns approved context into a small X queue that humans can review before drafting, publishing, scheduling, or durable memory writes.

It exists to make the queue-planning surface explicit before any later automation work.

## Inputs

The contract expects an X queue planning input set that covers:

- project and network identity;
- timeframe;
- topics;
- cadence;
- tone;
- constraints;
- known assets;
- optional brand and ledger summaries;
- optional source context namespaces.

The fake fixture demonstrates these inputs under `source_context` and `planning_inputs`.

## Outputs

The contract returns a structured queue plan with:

- `planning_basis.confirmed_facts`, `planning_basis.assumptions`, `planning_basis.variation_rules`, and `planning_basis.proposed_angles`;
- `queue_plan.status` and `queue_plan.entries`;
- per-entry `rationale` and `variation_note`;
- `approval.status` and `approval.checkpoints`;
- `memory_write_targets` for both project strategy and the X network subtree.

This keeps queue diversity, approval requirements, and planned memory destinations reviewable in one artifact.

## Memory read and write namespaces

Read candidates:

- `discord-project-manager/project/egdev/brand`
- `discord-project-manager/project/egdev/strategy`
- `discord-project-manager/project/egdev/content-ledger`
- `discord-project-manager/project/egdev/network/x`

Write candidates after human approval only:

- `discord-project-manager/project/egdev/strategy`
- `discord-project-manager/project/egdev/network/x`

These follow ADR 0002 exactly.

## Human approval points

Human approval remains mandatory:

- queue topics, cadence, and tone must still match approved brand context;
- each queue entry must be approved before drafting;
- publishing must be approved before any queue item leaves review state;
- scheduling must be approved before any queue item is placed on a calendar;
- durable memory writes must be approved before saving strategy or network queue state;
- this contract does not authorize Discord runtime actions, Buffer analytics, or Engram Cloud sync.

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
