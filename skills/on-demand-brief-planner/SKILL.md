---
name: on-demand-brief-planner
description: "Define a reviewable on-demand brief workflow for YouTube, Twitch, and Stack and Flow from approved context and a user prompt."
license: MIT
---

# On-Demand Brief Planner

Use this skill to turn approved project context and an explicit user prompt into small reviewable briefs for YouTube, Twitch, and Stack and Flow before any drafting, publishing, scheduling, or durable memory write happens.

This skill defines a planning contract only. It does **not** publish, schedule, sync to Buffer, route Discord traffic, or claim that memory or ledger writes are already wired.

## Inputs

Required inputs:

- `project_slug`
- `request_id`
- `requested_networks` from `youtube`, `twitch`, and `stack-and-flow`
- `user_prompt`
- `goal`
- `audience`
- `constraints`
- `known_assets` or `none`

Optional inputs:

- `timeframe`
- `brand_context_summary`
- `recent_ledger_summary`
- `desired_cta`
- `review_preferences`
- `source_context`

## Behavior

1. Start from approved brand context, strategy context, and recent ledger context when they are available.
2. Support one or more requested networks from `youtube`, `twitch`, and `stack-and-flow` in the same brief request.
3. Separate confirmed facts, assumptions, format rules, and proposed angles before writing network briefs.
4. Keep each brief small enough for human review before drafting, publishing, scheduling, or memory updates.
5. Treat durable memory and ledger writes as planned targets until a human approves the brief set.
6. Use only fake/demo values in repository-facing examples.
7. Follow ADR 0002 for all namespace references.

## Output shape

Return a YAML-like structure similar to this:

```yaml
schema_version: 1
project: <project-slug>
supported_networks:
  - youtube
  - twitch
  - stack-and-flow
request_id: <stable-request-id>
timeframe: <timeframe-or-request-window>
source_context:
  brand_namespace_key: <brand namespace>
  strategy_namespace_key: <strategy namespace>
  ledger_namespace_key: <content ledger namespace>
  network_namespace_keys:
    youtube: <youtube namespace>
    twitch: <twitch namespace>
    stack-and-flow: <stack-and-flow namespace>
brief_request:
  user_prompt: <user prompt>
  goal: <why these briefs exist>
  audience:
    primary:
      - <audience segment>
  desired_networks:
    - <network>
  constraints:
    - <constraint>
  known_assets:
    - <asset>
planning_basis:
  confirmed_facts:
    - <approved fact from source context>
  assumptions:
    - <planning assumption to review>
  format_rules:
    - <network-specific brief rule>
  proposed_angles:
    - <angle under consideration>
briefs:
  - network: <youtube|twitch|stack-and-flow>
    status: <draft-review|approved-for-demo-validation>
    brief_goal: <network-local goal>
    audience: <audience summary>
    outline:
      - <outline section>
    required_assets:
      - <asset>
    call_to_action: <cta>
    rationale:
      prompt_alignment: <prompt linkage>
      brand_alignment: <approved context>
      ledger_reference: <content history cue or none>
    approval_checkpoint:
      - <human review step>
approval:
  status: <pending-human-approval|approved-for-demo-validation>
  checkpoints:
    - <approval rule>
memory_write_targets:
  project_strategy_namespace_key: <strategy namespace>
  content_ledger_namespace_key: <content-ledger namespace>
  network_namespace_keys:
    youtube: <youtube namespace>
    twitch: <twitch namespace>
    stack-and-flow: <stack-and-flow namespace>
  write_mode: <planned-only-until-approved>
  ledger_candidates:
    - network: <network>
      candidate_id: <brief-or-entry-id>
      intended_status: <draft|queued>
      save_after: <human approval plus status confirmation>
```

## Memory behavior

### Read candidates

- `discord-project-manager/project/<project-slug>/brand`
- `discord-project-manager/project/<project-slug>/strategy`
- `discord-project-manager/project/<project-slug>/content-ledger`
- `discord-project-manager/project/<project-slug>/network/youtube`
- `discord-project-manager/project/<project-slug>/network/twitch`
- `discord-project-manager/project/<project-slug>/network/stack-and-flow`

### Write candidates

- reusable cross-network brief rules under `discord-project-manager/project/<project-slug>/strategy`
- approved network-local brief summaries under `discord-project-manager/project/<project-slug>/network/<network-slug>`
- approved brief ledger candidates under `discord-project-manager/project/<project-slug>/content-ledger` using the content-ledger status contract (`draft` before publishing/scheduling, `queued` only after scheduling approval)

### Approval gate

Do not write or revise durable brief memory or ledger entries until a human approves the brief set and confirms the ledger status. Approved briefs that are not scheduled should map to `draft`; scheduled items may map to `queued` only after scheduling approval.

### Namespace target

Use ADR 0002 exactly:

- `discord-project-manager/project/<project-slug>/strategy`
- `discord-project-manager/project/<project-slug>/content-ledger`
- `discord-project-manager/project/<project-slug>/network/youtube`
- `discord-project-manager/project/<project-slug>/network/twitch`
- `discord-project-manager/project/<project-slug>/network/stack-and-flow`

Canonical ADR examples that this skill may mirror when using fake/demo values:

- `discord-project-manager/project/egdev/strategy`
- `discord-project-manager/project/egdev/content-ledger`
- `discord-project-manager/project/egdev/network/youtube`
- `discord-project-manager/project/egdev/network/twitch`
- `discord-project-manager/project/egdev/network/stack-and-flow`

### Promotion to repo artifact

Promote reusable brief workflow rules, approval checkpoints, and contract changes into repo artifacts when they become canonical, review-facing, or architecture-relevant.

## Safety rules

- Do not claim memory or ledger entries were written unless the runtime actually saved them after approval.
- Do not publish or schedule content from this contract alone.
- Do not put durable brief planning under runtime Discord namespaces.
- Do not include private brand plans, secrets, or real customer data in repo examples.

## Demo example (fake)

```yaml
schema_version: 1
project: egdev
supported_networks:
  - youtube
  - twitch
  - stack-and-flow
request_id: brief-request-001-demo
timeframe: 2026-W24
source_context:
  brand_namespace_key: discord-project-manager/project/egdev/brand
  strategy_namespace_key: discord-project-manager/project/egdev/strategy
  ledger_namespace_key: discord-project-manager/project/egdev/content-ledger
  network_namespace_keys:
    youtube: discord-project-manager/project/egdev/network/youtube
    twitch: discord-project-manager/project/egdev/network/twitch
    stack-and-flow: discord-project-manager/project/egdev/network/stack-and-flow
brief_request:
  user_prompt: turn one reviewability theme into a video brief, a live brief, and a compact short-form brief
  goal: define reusable on-demand briefs from approved fake context
  audience:
    primary:
      - engineering leads
  desired_networks:
    - youtube
    - twitch
    - stack-and-flow
  constraints:
    - english artifacts only
    - no publishing without human approval
  known_assets:
    - asset://demo/brief-outline-01
planning_basis:
  confirmed_facts:
    - approved brand context prefers practical technical framing
  assumptions:
    - the same theme can be adapted across long-form, live, and compact formats without repeating the same hook
  format_rules:
    - youtube brief should support a longer explanatory outline
    - twitch brief should leave room for live interaction and Q&A
    - stack-and-flow brief should stay compact and clip-friendly
  proposed_angles:
    - reviewability as a product discipline
briefs:
  - network: youtube
    status: draft-review
    brief_goal: explain one technical workflow lesson in long-form detail
    audience: engineering leads evaluating AI-assisted development workflows
    outline:
      - opener with the core trade-off
      - implementation lesson
      - reviewability checklist
    required_assets:
      - asset://demo/brief-outline-01
    call_to_action: invite viewers to compare their own review workflow constraints
    rationale:
      prompt_alignment: expands the user prompt into a longer explanatory format
      brand_alignment: explains trade-offs before implementation
      ledger_reference: x-post-001-demo follow-up angle
    approval_checkpoint:
      - approve the YouTube brief before scripting
approval:
  status: pending-human-approval
  checkpoints:
    - approve all briefs before drafting, publishing, scheduling, or durable memory writes
memory_write_targets:
  project_strategy_namespace_key: discord-project-manager/project/egdev/strategy
  content_ledger_namespace_key: discord-project-manager/project/egdev/content-ledger
  network_namespace_keys:
    youtube: discord-project-manager/project/egdev/network/youtube
    twitch: discord-project-manager/project/egdev/network/twitch
    stack-and-flow: discord-project-manager/project/egdev/network/stack-and-flow
  write_mode: planned-only-until-approved
  ledger_candidates:
    - network: youtube
      candidate_id: youtube-brief-001-demo
      intended_status: draft
      save_after: human approval plus draft status confirmation
```

This example is fake/demo data only and must not be treated as a live editorial plan.
