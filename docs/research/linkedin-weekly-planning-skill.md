# LinkedIn weekly planning skill contract

This note defines the reviewable contract for issue #11: a weekly LinkedIn planning slice with explicit inputs, outputs, approval points, and memory targets.

## Quick path

1. Use `skills/linkedin-weekly-planner/SKILL.md` as the contract source of truth.
2. Review `examples/linkedin-weekly-plan.fake.yaml` for the fake input/output shape.
3. Confirm all durable memory writes remain approval-gated.

## Contract purpose

The LinkedIn weekly planner turns approved context into a small weekly plan that humans can review before drafting, publishing, scheduling, or durable memory writes.

It exists to make the planning surface explicit before any later automation work.

## Inputs

The contract expects a weekly planning input set that covers:

- project and network identity;
- timeframe;
- goals;
- cadence;
- constraints;
- known assets;
- optional brand and ledger summaries;
- optional source context namespaces.

The fake fixture demonstrates these inputs under `source_context` and `planning_inputs`.

## Outputs

The contract returns a structured weekly plan with:

- `planning_basis.confirmed_facts`, `planning_basis.assumptions`, and `planning_basis.proposed_angles`;
- `weekly_plan.posts`;
- per-post `rationale`;
- `approval.status` and `approval.checkpoints`;
- `memory_write_targets` for both project strategy and the LinkedIn network subtree.

This keeps post ideas, approval requirements, and planned memory destinations reviewable in one artifact.

## Memory read and write namespaces

Read candidates:

- `egdev-dashboard/project/egdev/brand`
- `egdev-dashboard/project/egdev/strategy`
- `egdev-dashboard/project/egdev/content-ledger`
- `egdev-dashboard/project/egdev/network/linkedin`

Write candidates after human approval only:

- `egdev-dashboard/project/egdev/strategy`
- `egdev-dashboard/project/egdev/network/linkedin`

These follow ADR 0002 exactly.

## Human approval points

Human approval remains mandatory:

- weekly goals and cadence must still match approved brand context;
- each post angle must be approved before drafting;
- durable memory writes must be approved before saving strategy or network planning state;
- this contract does not authorize publishing, scheduling, Discord runtime actions, Buffer analytics, or Engram Cloud sync.

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
