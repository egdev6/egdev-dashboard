---
name: scoped-skill-resolver
description: "Trigger: effective skills, skill pack, global/category/channel scope, disabled skill, skill override. Resolve skills before workflow execution."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Activation Contract

Use this skill when a Discord-originated request needs effective skill selection, skill-pack explanation, or global/category/channel inheritance resolution.

This skill is a resolver contract. It does not perform the workflow itself and does not persist registry changes.

## Resolution Order

Use the deterministic contract from `docs/architecture/discord-scoped-skills-registry.md`:

```text
effective_skills =
  selected global skills
  + category enabled skills
  + channel preferred skills
  - disabled skills
  + reviewed overrides
```

For write-like flows, add `discord-approval-gate` as mandatory even if a scoped registry draft omits it.

## Skill Classification

| Class | Skills | Rule |
| --- | --- | --- |
| Runtime core | `openclaw-runtime-orchestrator`, `scoped-skill-resolver`, `discord-approval-gate` | Always available to the runtime surface. |
| Scoped workflow | `brand-context`, `content-ledger`, `strategy-planner`, `linkedin-weekly-planner`, `x-queue-planner`, `on-demand-brief-planner` | Use only when selected by global/category/channel scope. |
| Preserved protocol | Gentle-AI SDD assets under `.openclaw/skills` | Use only through the `gentle-sdd` backend boundary. |

## Hard Rules

- Explain included and excluded skills.
- Keep disabled skills excluded unless a reviewed override explicitly re-enables them.
- Never let category/channel workflow skills become global defaults by being merely synced into the workspace.
- Keep `discord-approval-gate` mandatory for write-like outcomes.
- Registry updates are write-like and require `approve write` through `discord-approval-gate`.

## Output Contract

```text
scope_layers:
  global: [<skill>]
  category: [<skill>]
  channel: [<skill>]
  disabled: [<skill>]
effective_skills: [<skill>]
excluded_skills: [<skill>]
mandatory_skills: [discord-approval-gate] # for write-like flows
approval_required: <true|false>
writes_attempted: false
resolution_notes: <one sentence>
```

## References

- `docs/architecture/discord-scoped-skills-registry.md`
- `docs/architecture/discord-context-skill-packs.md`
- `openclaw/config/skill-inventory.yaml`
- `skills/discord-approval-gate/SKILL.md`
