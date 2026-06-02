---
name: linkedin-weekly-planner
description: "Define a reviewable weekly LinkedIn planning slice from approved context, cadence, and known assets."
license: MIT
---

# LinkedIn Weekly Planner

Use this skill to turn approved project context into a small LinkedIn weekly plan that humans can review before any drafting, publishing, or durable memory write happens.

This skill defines a planning contract only. It does **not** publish, schedule, sync to Buffer, route Discord traffic, or claim that memory writes are already wired.

## Inputs

Required inputs:

- `project_slug`
- `network_slug: linkedin`
- `timeframe`
- `goals`
- `cadence`
- `constraints`
- `known_assets` or `none`

Optional inputs:

- `brand_context_summary`
- `recent_ledger_summary`
- `weekly_theme`
- `audience_focus`
- `review_preferences`
- `source_context`

## Behavior

1. Start from approved brand context and recent ledger context when they are available.
2. Keep weekly planning separate from cross-network strategy rules.
3. Separate confirmed facts, assumptions, and proposed post angles.
4. Keep each weekly post idea small enough for human review.
5. Treat memory writes as planned targets until a human approves them.
6. Use only fake/demo values in repository-facing examples.
7. Follow ADR 0002 for all namespace references.

## Output shape

Return a YAML-like structure similar to this:

```yaml
project: <project-slug>
network: linkedin
timeframe: <timeframe>
source_context:
  brand_namespace_key: <brand namespace>
  strategy_namespace_key: <strategy namespace>
  ledger_namespace_key: <content ledger namespace>
  network_namespace_key: <linkedin namespace>
planning_inputs:
  goals:
    - <goal>
  cadence:
    posts_per_week: <count>
    preferred_publish_days:
      - <day>
  constraints:
    - <constraint>
  known_assets:
    - <asset>
planning_basis:
  confirmed_facts:
    - <approved fact from source context>
  assumptions:
    - <planning assumption to review>
  proposed_angles:
    - <post angle under consideration>
weekly_plan:
  posts:
    - id: <stable-demo-id>
      working_title: <title>
      objective: <why this post exists>
      rationale:
        ties_to_goal: <goal linkage>
        brand_alignment: <approved context>
        ledger_reference: <content history cue or none>
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
  network_namespace_key: <linkedin namespace>
  write_mode: <planned-only-until-approved>
out_of_scope:
  - <explicit non-goal>
```

## Memory behavior

### Read candidates

- `discord-project-manager/project/<project-slug>/brand`
- `discord-project-manager/project/<project-slug>/strategy`
- `discord-project-manager/project/<project-slug>/content-ledger`
- `discord-project-manager/project/<project-slug>/network/linkedin`

### Write candidates

- reusable cross-network planning rules under `discord-project-manager/project/<project-slug>/strategy`
- approved LinkedIn-local weekly planning context under `discord-project-manager/project/<project-slug>/network/linkedin`

### Approval gate

Do not write or revise durable LinkedIn weekly planning memory until a human approves the weekly plan.

### Namespace target

Use ADR 0002 exactly:

- `discord-project-manager/project/<project-slug>/strategy`
- `discord-project-manager/project/<project-slug>/network/linkedin`

Canonical ADR examples that this skill may mirror when using fake/demo values:

- `discord-project-manager/project/egdev/strategy`
- `discord-project-manager/project/egdev/network/linkedin`

### Promotion to repo artifact

Promote reusable LinkedIn planning rules, approval checkpoints, and contract changes into repo artifacts when they become canonical, review-facing, or architecture-relevant.

## Safety rules

- Do not claim memory was written unless the runtime actually saved it after approval.
- Do not publish or schedule content from this contract alone.
- Do not put durable LinkedIn planning under runtime Discord namespaces.
- Do not include private brand plans, secrets, or real customer data in repo examples.

## Demo example (fake)

```yaml
project: egdev
network: linkedin
timeframe: 2026-W24
source_context:
  brand_namespace_key: discord-project-manager/project/egdev/brand
  strategy_namespace_key: discord-project-manager/project/egdev/strategy
  ledger_namespace_key: discord-project-manager/project/egdev/content-ledger
  network_namespace_key: discord-project-manager/project/egdev/network/linkedin
planning_inputs:
  goals:
    - test whether weekly implementation trade-off posts increase qualified technical replies
  cadence:
    posts_per_week: 2
    preferred_publish_days:
      - tuesday
      - thursday
  constraints:
    - english artifacts only
    - no publishing without human approval
  known_assets:
    - asset://demo/linkedin-outline-03
planning_basis:
  confirmed_facts:
    - approved brand context prefers implementation trade-off breakdowns
  assumptions:
    - engineering leads will respond to compact operational lessons
  proposed_angles:
    - single reviewable trade-off memo
weekly_plan:
  posts:
    - id: linkedin-weekly-post-01-demo
      working_title: trade-off memo demo
      objective: open a technical discussion with engineering leads
      rationale:
        ties_to_goal: supports weekly technical-depth testing
        brand_alignment: explain trade-offs before implementation
        ledger_reference: x-post-001-demo inspired follow-up angle
      required_assets:
        - asset://demo/linkedin-outline-03
      approval_checkpoint:
        - approve the weekly angle before drafting
approval:
  status: pending-human-approval
  checkpoints:
    - approve durable memory writes before saving planning state
memory_write_targets:
  project_strategy_namespace_key: discord-project-manager/project/egdev/strategy
  network_namespace_key: discord-project-manager/project/egdev/network/linkedin
  write_mode: planned-only-until-approved
out_of_scope:
  - final copy generation
  - live LinkedIn publishing
  - scheduling or Buffer activity
```

This example is fake/demo data only and must not be treated as a live editorial plan.
