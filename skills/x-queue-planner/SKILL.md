---
name: x-queue-planner
description: "Define a reviewable X queue planning slice from approved context, cadence, tone, and known assets."
license: MIT
---

# X Queue Planner

Use this skill to turn approved project context into a small X queue plan that humans can review before any drafting, publishing, scheduling, or durable memory write happens.

This skill defines a planning contract only. It does **not** publish, schedule, sync to Buffer, route Discord traffic, or claim that memory writes are already wired.

## Inputs

Required inputs:

- `project_slug`
- `network_slug: x`
- `timeframe`
- `topics`
- `cadence`
- `tone`
- `constraints`
- `known_assets` or `none`

Optional inputs:

- `brand_context_summary`
- `recent_ledger_summary`
- `queue_goal`
- `review_preferences`
- `source_context`

## Behavior

1. Start from approved brand context and recent ledger context when they are available.
2. Keep X queue planning separate from cross-network strategy rules.
3. Separate confirmed facts, assumptions, and variation rules or proposed angles.
4. Keep each queued item small enough for human review before any drafting or publishing.
5. Treat memory writes as planned targets until a human approves the queue.
6. Use only fake/demo values in repository-facing examples.
7. Follow ADR 0002 for all namespace references.

## Output shape

Return a YAML-like structure similar to this:

```yaml
project: <project-slug>
network: x
timeframe: <timeframe>
source_context:
  brand_namespace_key: <brand namespace>
  strategy_namespace_key: <strategy namespace>
  ledger_namespace_key: <content ledger namespace>
  network_namespace_key: <x namespace>
planning_inputs:
  topics:
    - <topic>
  cadence:
    items_per_week: <count>
    preferred_publish_days:
      - <day>
  tone:
    - <tone cue>
  constraints:
    - <constraint>
  known_assets:
    - <asset>
planning_basis:
  confirmed_facts:
    - <approved fact from source context>
  assumptions:
    - <planning assumption to review>
  variation_rules:
    - <queue diversity rule>
  proposed_angles:
    - <queued angle under consideration>
queue_plan:
  status: <draft-review|approved-for-demo-validation>
  entries:
    - id: <stable-demo-id>
      entry_type: <single-post|thread>
      working_title: <title>
      objective: <why this item exists>
      rationale:
        ties_to_topic: <topic linkage>
        brand_alignment: <approved context>
        ledger_reference: <content history cue or none>
      variation_note: <how this item differs from adjacent queue items>
      required_assets:
        - <asset>
      approval_checkpoint:
        - <human review step>
approval:
  status: <pending-human-approval|approved-for-demo-validation>
  checkpoints:
    - <approval rule>
memory_write_targets:
  project_strategy_namespace_key: <strategy namespace>
  network_namespace_key: <x namespace>
  write_mode: <planned-only-until-approved>
```

## Memory behavior

### Read candidates

- `egdev-dashboard/project/<project-slug>/brand`
- `egdev-dashboard/project/<project-slug>/strategy`
- `egdev-dashboard/project/<project-slug>/content-ledger`
- `egdev-dashboard/project/<project-slug>/network/x`

### Write candidates

- reusable cross-network queue-planning rules under `egdev-dashboard/project/<project-slug>/strategy`
- approved X-local queue planning context under `egdev-dashboard/project/<project-slug>/network/x`

### Approval gate

Do not write or revise durable X queue planning memory until a human approves the queue.

### Namespace target

Use ADR 0002 exactly:

- `egdev-dashboard/project/<project-slug>/strategy`
- `egdev-dashboard/project/<project-slug>/network/x`

Canonical ADR examples that this skill may mirror when using fake/demo values:

- `egdev-dashboard/project/egdev/strategy`
- `egdev-dashboard/project/egdev/network/x`

### Promotion to repo artifact

Promote reusable X queue planning rules, approval checkpoints, and contract changes into repo artifacts when they become canonical, review-facing, or architecture-relevant.

## Safety rules

- Do not claim memory was written unless the runtime actually saved it after approval.
- Do not publish or schedule content from this contract alone.
- Do not put durable X queue planning under runtime Discord namespaces.
- Do not include private brand plans, secrets, or real customer data in repo examples.

## Demo example (fake)

```yaml
project: egdev
network: x
timeframe: 2026-W24
source_context:
  brand_namespace_key: egdev-dashboard/project/egdev/brand
  strategy_namespace_key: egdev-dashboard/project/egdev/strategy
  ledger_namespace_key: egdev-dashboard/project/egdev/content-ledger
  network_namespace_key: egdev-dashboard/project/egdev/network/x
planning_inputs:
  topics:
    - technical specificity in short-form posts
  cadence:
    items_per_week: 3
    preferred_publish_days:
      - monday
      - wednesday
      - friday
  tone:
    - direct
    - technical
  constraints:
    - no publishing without human approval
  known_assets:
    - asset://demo/x-thread-outline-002
planning_basis:
  confirmed_facts:
    - approved brand context prefers practical technical framing
  assumptions:
    - short threads will outperform generic single-line hooks
  variation_rules:
    - alternate between single-post and thread entries
  proposed_angles:
    - one queue item about reviewability discipline
queue_plan:
  status: draft-review
  entries:
    - id: x-queue-item-01-demo
      entry_type: thread
      working_title: reviewability thread demo
      objective: open a technical discussion without hype framing
      rationale:
        ties_to_topic: reinforces technical specificity
        brand_alignment: explain trade-offs before implementation
        ledger_reference: x-post-001-demo follow-up angle
      variation_note: longer thread to avoid repeating a prior single-post hook
      required_assets:
        - asset://demo/x-thread-outline-002
      approval_checkpoint:
        - approve the queue entry before drafting
approval:
  status: pending-human-approval
  checkpoints:
    - approve queue entries before drafting or publishing
memory_write_targets:
  project_strategy_namespace_key: egdev-dashboard/project/egdev/strategy
  network_namespace_key: egdev-dashboard/project/egdev/network/x
  write_mode: planned-only-until-approved
```

This example is fake/demo data only and must not be treated as a live editorial plan.
