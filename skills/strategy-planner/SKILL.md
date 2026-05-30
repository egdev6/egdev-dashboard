---
name: strategy-planner
description: "Produce small planning outputs for network-specific content workflows using approved brand context."
license: MIT
---

# Strategy Planner

Use this skill to turn approved brand context into a compact planning slice such as a weekly LinkedIn outline, an X queue draft, or a scoped campaign brief.

This skill proposes plans only. It does **not** publish, schedule, or claim that Discord, Buffer, or Engram write paths are already fully wired.

## Inputs

Required inputs:

- `project_slug`
- `network_slug`
- `brand_context_summary`
- `timeframe`
- `goals`
- `constraints`

Optional inputs:

- `campaign_name`
- `recent_ledger_summary`
- `known_assets`
- `review_preferences`

## Behavior

1. Start from approved brand context when available.
2. Separate confirmed facts from assumptions.
3. Produce concise planning structures instead of long prose.
4. Put cross-network planning rules in project strategy memory and network-local planning state in the network subtree.
5. Keep execution steps for publishing, analytics, and Discord operations out of scope.
6. Use only fake/demo values in repository-facing examples.
7. Follow ADR 0002 for all namespace references.

## Output shape

Return a YAML-like structure similar to this:

```yaml
project: <project-slug>
network: <network-slug>
timeframe: <timeframe>
strategy_slice:
  goals:
    - <goal>
  assumptions:
    - <assumption>
  planned_items:
    - title: <item>
      purpose: <why>
      required_assets:
        - <asset>
  review_checkpoints:
    - <checkpoint>
  out_of_scope:
    - <explicit non-goal>
```

## Memory behavior

### Read candidates

- `egdev-dashboard/project/<project-slug>/brand`
- `egdev-dashboard/project/<project-slug>/strategy`
- `egdev-dashboard/project/<project-slug>/content-ledger`
- `egdev-dashboard/project/<project-slug>/network/<network-slug>`

### Write candidates

- cross-network strategy rules under `egdev-dashboard/project/<project-slug>/strategy`
- network-local planning context under `egdev-dashboard/project/<project-slug>/network/<network-slug>`

### Approval gate

Do not write or revise durable planning memory until a human approves the proposed strategy slice.

### Namespace target

Use ADR 0002 exactly:

- `egdev-dashboard/project/<project-slug>/strategy`
- `egdev-dashboard/project/<project-slug>/network/<network-slug>`

Canonical ADR examples that this skill may mirror when using fake/demo values:

- `egdev-dashboard/project/egdev/strategy`
- `egdev-dashboard/project/egdev/network/stack-and-flow`
- `egdev-dashboard/project/egdev/network/youtube`
- `egdev-dashboard/project/egdev/network/twitch`

### Promotion to repo artifact

Promote reusable planning rules, review checkpoints, and skill behavior into repo artifacts when they become canonical, reusable, or architecture-relevant. Temporary drafts may remain in Engram until approved.

## Safety rules

- Do not pretend memory writes, Discord routing, or Buffer analytics are already operational.
- Do not publish or schedule content from this contract alone.
- Do not put durable cross-network strategy inside runtime Discord namespaces.
- Keep repository examples generic and fake.

## Demo example (fake)

```yaml
project: egdev
network: stack-and-flow
timeframe: 2026-W23
strategy_slice:
  goals:
    - test whether short technical clips create demand for longer live sessions
  assumptions:
    - audience prefers implementation trade-offs over motivational framing
  planned_items:
    - title: stack-and-flow demo clip 01
      purpose: tease a longer build breakdown
      required_assets:
        - asset://demo/clip-outline-01
  review_checkpoints:
    - confirm tone still matches project brand context
  out_of_scope:
    - direct publishing
```

This example is fake/demo data only and must not be treated as a live editorial plan.
