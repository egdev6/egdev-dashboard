# ADR 0002: Engram namespace contract for shared operational memory

- Status: Accepted
- Date: 2026-05-30

## Decision

`egdev-dashboard` uses stable Engram namespace families so Pi development work, OpenClaw runtime memory, and project-level social context do not overwrite each other.

The contract is:

- Development SDD memory lives under `egdev-dashboard/dev/sdd/<change-id>/<phase>`.
- Runtime Discord memory lives under `egdev-dashboard/runtime/discord/<guild-id>/<channel-id>`.
- Durable project memory lives under `egdev-dashboard/project/<project-slug>/...`.
- Repo artifacts remain canonical for planning, review, and reusable behavior.

## Naming rules

| Rule | Requirement |
|---|---|
| Root prefix | Always start with `egdev-dashboard`. |
| Segment format | Use lowercase kebab-case for slugs: `egdev`, `stack-and-flow`, `runtime-validation`. |
| External IDs | Keep platform IDs as raw ID strings when needed for routing: `<guild-id>`, `<channel-id>`. Do not replace them with display names. |
| Stable paths | Keep timestamps, status, and lifecycle details inside the stored value, not in the namespace path. |
| Predictable families | Reuse the same leaf families: `brand`, `strategy`, `content-ledger`, `network/<network-slug>`. |
| No secrets or PII | Do not put tokens, emails, private names, raw prompts with secrets, or private customer identifiers in namespace names. |
| No canonical-doc bypass | A namespace key is not a substitute for an ADR, spec, task list, or review-facing plan. Promote those to repo artifacts. |

## Namespace families

| Namespace family | Purpose | Notes |
|---|---|---|
| `egdev-dashboard/dev/sdd/<change-id>/<phase>` | Development-phase working memory | Used by Pi/el Gentleman for SDD summaries, phase outputs, and review-oriented working context before promotion. |
| `egdev-dashboard/runtime/discord/<guild-id>/<channel-id>` | Channel-local operational memory | Used by OpenClaw runtime for Discord-local context, operator summaries, and transient coordination. |
| `egdev-dashboard/project/<project-slug>/brand` | Durable brand context | Personality, voice, audience, positioning, and constraints for one project. |
| `egdev-dashboard/project/<project-slug>/strategy` | Durable strategy context | Cross-network planning rules, cadence, and reusable editorial decisions. |
| `egdev-dashboard/project/<project-slug>/content-ledger` | Durable publish-history memory | Published items, asset references, statuses, and follow-up links. |
| `egdev-dashboard/project/<project-slug>/network/<network-slug>` | Durable network-specific context | Network-local rules, queue state, and approved constraints for one network. |

## Canonical examples

```text
egdev-dashboard/dev/sdd/<change-id>/<phase>
egdev-dashboard/dev/sdd/openclaw-runtime-validation/proposal
egdev-dashboard/dev/sdd/openclaw-runtime-validation/spec
egdev-dashboard/dev/sdd/openclaw-runtime-validation/design
egdev-dashboard/dev/sdd/openclaw-runtime-validation/tasks
egdev-dashboard/dev/sdd/openclaw-runtime-validation/verify

egdev-dashboard/runtime/discord/<guild-id>/<channel-id>
egdev-dashboard/runtime/discord/123456789012345678/234567890123456789

egdev-dashboard/project/egdev/brand
egdev-dashboard/project/egdev/strategy
egdev-dashboard/project/egdev/content-ledger
egdev-dashboard/project/egdev/network/linkedin
egdev-dashboard/project/egdev/network/x
egdev-dashboard/project/egdev/network/stack-and-flow
egdev-dashboard/project/egdev/network/youtube
egdev-dashboard/project/egdev/network/twitch
```

## Separation rules

1. **Do not mix dev and runtime memory.**
   - Pi development SDD uses `dev/sdd/...`.
   - OpenClaw Discord operations use `runtime/discord/...`.
   - Runtime channel memory must not become the source of truth for repo planning.

2. **Project memory is stable and reusable.**
   - `brand`, `strategy`, `content-ledger`, and `network/<network-slug>` are durable project scopes.
   - Runtime Discord channels may read or summarize them, but should not create parallel naming schemes.

3. **Network state belongs under the project.**
   - LinkedIn, X, Stack and Flow, YouTube, and Twitch each use the same `network/<network-slug>` pattern.
   - Cross-network decisions belong in `strategy`, not in one network subtree.

4. **Discord IDs are routing context, not content labels.**
   - Use guild/channel IDs only for operational routing memory.
   - Durable brand or strategy context belongs under `project/...`, not under `runtime/discord/...`.

## Promotion rules

The following must be promoted from Engram into repo artifacts when they become durable, review-facing, or reusable:

- decisions that affect product behavior or team process;
- specs, proposals, designs, tasks, and verify summaries used for review;
- ADR-worthy architecture decisions;
- reusable skill behavior or contracts;
- public documentation and runbooks;
- review-facing implementation plans.

The following may remain in Engram unless they become durable repo knowledge:

- transient drafts and brainstorming;
- channel-local memory and short-lived operator context;
- analytics snapshots and raw performance notes;
- in-flight workflow summaries that are not yet approved;
- temporary coordination notes between runtime turns.

## Why

This keeps operational memory useful without allowing Engram to silently replace the repository as the canonical planning surface.

## Consequences

### Positive

- Development SDD memory and runtime Discord memory stay distinct.
- Project memory stays reusable across LinkedIn, X, Stack and Flow, YouTube, and Twitch.
- Promotion rules stay explicit for reviewers.

### Trade-offs

- Some useful runtime notes must be copied into repo artifacts before they are considered canonical.
- Consumers must reuse the approved namespace families instead of inventing ad hoc keys.
