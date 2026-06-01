# Discord scoped skills registry

This contract defines a fake-first scoped skills registry for Discord control channels. It makes global, category, and channel skill selection reviewable before any durable registry write happens.

This is a contract only. It does not prove live Discord routing, runtime enforcement, real Engram writes, public Discord validation, Buffer activity, publishing, or scheduling.

## Quick path

1. Keep the registry fake-first and safe for repo review.
2. Resolve skills by scope: global, category, then channel.
3. Require `approve write` before persisting registry or override changes.
4. Keep runtime audit notes under `discord-project-manager/runtime/discord/<guild-id>/<channel-id>`.

## Registry shape

Use one scoped registry contract with three layers:

| Scope | Purpose | Required fields |
| --- | --- | --- |
| `global` | Reusable project-wide skill defaults | `control_channels`, `skills.enabled`, `skills.preferred`, `skills.disabled`, `overrides` |
| `category` | Category-local inherited skills and local additions | `category_ref`, `normalized_name`, `control_channel`, `inherits.global_skills`, `skills.*`, `overrides` |
| `channel` | Channel-local preferences and explicit disable rules | `channel_ref`, `parent_ref`, `preferred`, `disabled`, `overrides` |

Resolution order stays explicit:

```text
effective_skills =
  selected global skills
  + category enabled skills
  + channel preferred skills
  - disabled skills
  + reviewed overrides
```

## Control channels

Reserved control channels for this slice:

| Scope | Control channel | Role |
| --- | --- | --- |
| Global | `openclaw-global/skills` | Review global reusable skills and defaults. |
| Global | `openclaw-global/inheritance` | Review which categories inherit global skills. |
| Category | `<category>/skills` | Review category-local skills, preferences, and disable rules. |

Use safe placeholders only. Do not commit real Discord IDs, guild exports, or live runtime state.

## Approval-gated writes

Registry changes are write-like operations. Use `skills/discord-approval-gate/SKILL.md` before any persistence.

Required response contract:

```text
Proposed durable update
Route: <control-channel-scope>
Runtime context: discord-project-manager/runtime/discord/<guild-id>/<channel-id>
Target artifact: <registry path or reviewed future durable target>
Runtime audit namespace: discord-project-manager/runtime/discord/<guild-id>/<channel-id>
Change summary: <one-sentence summary>
Risk boundary: no registry write, workspace file write, or live runtime change before approval

Reply with exactly one option:
- approve write
- revise: <instruction>
- reject
```

For this first slice, `discord-approval-gate` is globally enabled and is not disabled by category or channel overrides.

## Existing skill mapping

| Skill | First-slice scoped expectation |
| --- | --- |
| `brand-context` | Global reusable baseline; inheritable by category. |
| `content-ledger` | Category or channel utility, not globally preferred by default. |
| `strategy-planner` | Global reusable planner for categories that need strategy guidance. |
| `linkedin-weekly-planner` | Category-local for `egdev-linkedin`. |
| `x-queue-planner` | Channel/category-local for X-specific work, not globally inherited by default. |
| `on-demand-brief-planner` | Category-local for `stack-and-flow` style workflows. |
| `discord-approval-gate` | Global mandatory gate for write-like intents. |

## Rollout slices

This issue defines the registry/control-channel contract only. Follow-up workflow issues remain separate rollout slices:

- #61 `feat(flow): define brand context refresh workflow`
- #62 `feat(flow): define content ledger update workflow`
- #63 `feat(flow): define strategy planning workflow`
- #64 `feat(flow): define LinkedIn weekly planning workflow`
- #65 `feat(flow): define on-demand brief workflow`

## Validation checklist

- [ ] Registry fixture uses fake/demo markers only.
- [ ] Global/category/channel scopes are all present.
- [ ] Control channels are placeholders, not real Discord IDs.
- [ ] Inheritance is explicit, never automatic.
- [ ] `discord-approval-gate` remains globally enabled.
- [ ] Runtime audit namespace is `discord-project-manager/runtime/discord/<guild-id>/<channel-id>`.
- [ ] No live Discord, public Discord, production credential, publishing, scheduling, or Buffer claims are introduced.
