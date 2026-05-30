---
name: brand-context
description: "Capture and summarize project brand context for a social channel without storing secrets in git."
license: MIT
---

# Brand Context

Use this skill to turn rough brand notes into a small, reusable context contract for one project and, when needed, one network.

This is an instruction contract only. It does **not** prove that Discord, Engram, or any publishing flow is already wired.

## Inputs

Required inputs:

- `project_slug`
- `network_slug` or a clear statement that the result is project-wide only
- `voice_notes`
- `audience_notes`
- `positioning_notes`
- `approved_constraints`

Optional inputs:

- `current_taglines`
- `approved_examples`
- `known_risks`
- `open_questions`

## Behavior

1. Ask for missing brand facts instead of inventing them.
2. Separate project-wide brand context from network-local adaptation.
3. Keep the summary short enough to review and revise manually.
4. Treat ambiguous claims as open questions, not facts.
5. Use only fake/demo values in repository-facing examples.
6. Follow ADR 0002 for all namespace references.

## Output shape

Return a YAML-like structure similar to this:

```yaml
project: <project-slug>
network: <network-slug-or-none>
brand_context:
  voice:
    - <trait>
  audience:
    - <segment>
  positioning:
    - <statement>
  do_guidance:
    - <approved behavior>
  avoid_guidance:
    - <disallowed behavior>
  approved_constraints:
    - <constraint>
open_questions:
  - <question>
```

## Memory behavior

### Read candidates

- `egdev-dashboard/project/<project-slug>/brand`
- `egdev-dashboard/project/<project-slug>/network/<network-slug>`
- approved repo artifacts when the brand contract was promoted previously

### Write candidates

- project-wide brand memory under `egdev-dashboard/project/<project-slug>/brand`
- network-local adaptation under `egdev-dashboard/project/<project-slug>/network/<network-slug>` when the distinction matters

### Approval gate

Do not write or overwrite durable brand memory until a human explicitly approves the summary.

### Namespace target

Use ADR 0002 exactly:

- `egdev-dashboard/project/<project-slug>/brand`
- `egdev-dashboard/project/<project-slug>/network/<network-slug>`

Canonical ADR examples that this skill may mirror when using fake/demo values:

- `egdev-dashboard/project/egdev/brand`
- `egdev-dashboard/project/egdev/network/linkedin`

### Promotion to repo artifact

Promote the result into repo artifacts when the brand contract becomes reusable, review-facing, or architecture-relevant. Engram memory is operational until promoted.

## Safety rules

- Do not store tokens, credentials, private customer names, or secrets in the skill output.
- Do not claim memory was updated unless the runtime actually saved it.
- Do not use runtime Discord namespaces for durable brand memory.
- Do not overwrite shared planning artifacts without approval.

## Demo example (fake)

```yaml
project: egdev
network: linkedin
brand_context:
  voice:
    - direct
    - technical
    - calm
  audience:
    - engineering leads
    - product-minded developers
  positioning:
    - practical AI-assisted development without hype
  do_guidance:
    - explain trade-offs before implementation
    - keep examples reviewable
  avoid_guidance:
    - fake certainty
    - growth-hack language
  approved_constraints:
    - english artifacts only
open_questions:
  - should linkedin posts optimize for hiring reach or technical depth first?
```

This example is fake/demo data only and must not be treated as real brand memory.
