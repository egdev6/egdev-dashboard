# Discord dynamic context namespaces

This document defines the next Discord/OpenClaw routing model: Discord categories become dynamic context namespaces, channels keep local context, and scoped skills are resolved after context.

It extends the completed static channel-routing baseline from #14 and #15 and keeps #57 as the live Discord route validation anchor.

## Quick path

1. Keep Discord's physical model simple: `guild -> category -> channel`.
2. Treat `OpenClaw Global` as a reserved control category, not as a parent category.
3. Resolve context in layers: selected global context, category context, channel context, then thread/session context.
4. Resolve skills in layers: selected global skills, category skills, channel preferences/overrides.
5. Route work from `origin + context + skills + intent` to the right runner.
6. Keep durable writes approval-gated.

## Physical vs logical model

| Layer | Discord physical model | OpenClaw logical model |
|---|---|---|
| Guild | Server containing categories and channels | Runtime boundary and permission scope |
| Category | Flat group of channels | Category context namespace and optional skill namespace |
| Channel | Chat inside one category | Channel-local context, ledger, and routing signal |
| Thread/session | Conversation detail when available | Short-lived working context and summaries |
| Global | No real Discord parent layer | Reserved `OpenClaw Global` control category |

Discord does not support nested categories. Any global/category/channel layering is an OpenClaw resolver behavior, not a Discord hierarchy.

## Namespace principle

Use raw Discord IDs as stable runtime keys. Names and slugs are human-readable metadata only.

ADR 0002 remains the accepted runtime namespace contract:

```text
discord-project-manager/runtime/discord/<guild-id>/<channel-id>
```

Category scope is additive metadata and planned context provisioning, not a replacement for channel-local runtime memory. A future implementation may add category context artifacts or Engram topic keys, but any new namespace family must update ADR 0002 first.

The privacy rule stays unchanged: never commit real guild, category, or channel IDs to public repo artifacts.

## OpenClaw Global category contract

`OpenClaw Global` is a reserved category used to manage root-level context and reusable skills. It is not inherited automatically.

Required channels:

| Channel | Purpose | Write policy |
|---|---|---|
| `identity` | Who the operator/project is, what they do, and stable positioning. | Confirmation required before durable global update. |
| `writing-style` | Voice, tone, writing constraints, and reusable style examples. | Confirmation required before durable global update. |
| `operating-principles` | Cross-category working rules, collaboration principles, and quality bars. | Confirmation required before durable global update. |
| `boundaries` | Privacy, safety, publication, and no-go constraints. | Confirmation required before durable global update. |
| `inheritance` | Which categories inherit which global context and global skills. | Confirmation required. |
| `skills` | Global reusable skill definitions, defaults, and runner hints. | Confirmation required before activation. |

Global control messages are management input. They do not bypass repo artifacts, issue approval, or promotion rules from ADR 0001 and ADR 0002.

## Context resolution

For each Discord prompt, OpenClaw builds effective context in this order:

```text
effective_context =
  selected global context
  + category context
  + channel context
  + thread/session context
```

Rules:

1. No global context is inherited by default.
2. Category context belongs to the Discord category namespace.
3. Channel context belongs to the Discord channel namespace.
4. Thread/session context is temporary until summarized or promoted.
5. Durable writes remain approval-gated even when reads are allowed.

Example inheritance:

| Category | Inherited global context | Category-owned context |
|---|---|---|
| `egdev-linkedin` | `identity`, `writing-style`, `operating-principles` | LinkedIn strategy, audience, draft patterns, content calendar, publish ledger. |
| `stack-and-flow` | `identity`, `operating-principles` | Community purpose, initiatives, GitHub planning, member-facing communication, roadmap decisions. |

This prevents `egdev-linkedin` writing style context from silently becoming `stack-and-flow` community context.

## Skill resolution

Skills follow the same scope pattern as context:

```text
effective_skills =
  selected global skills
  + category skills
  + channel preferred skills
  - disabled skills/overrides
```

Rules:

1. Global skills are available only when inherited or explicitly selected.
2. Each category may define a reserved `skills` channel for category-local skill updates.
3. Channel-level skill preferences guide routing but should not hardcode one channel to one skill forever.
4. Skill updates that affect durable behavior require review before persistence.

This replaces fixed channel-to-skill routing with:

```text
Discord origin + resolved context + resolved skills + intent -> runner/action
```

## Follow-up boundaries

This document defines the architecture baseline only. It does not implement or normatively define the later runtime subsystems.

Follow-up issues own the detailed contracts:

| Follow-up | Owns |
|---|---|
| #68 | Discord topology discovery and reconciliation; see `docs/architecture/discord-topology-reconciliation.md`. |
| #69 | Dynamic context namespace provisioning; see `docs/architecture/discord-context-namespace-provisioning.md`. |
| #70 | Scoped skills registry and control channels; see `docs/architecture/discord-scoped-skills-registry.md`. |
| #71 | Memory Gateway / Engram access policy. |
| #72 | Context Pack and Skill Pack schemas; see `docs/architecture/discord-context-skill-packs.md`. |
| #73 | OpenClaw Discord Runtime Orchestrator; see `docs/architecture/discord-runtime-orchestrator.md`. |
| #74 | OpenClaw to Gentle SDD handoff; see `docs/architecture/discord-gentle-sdd-handoff.md`. |

Gentle SDD remains a specialized development/spec workflow boundary as described in ADR 0001; this architecture does not assume Pi-native `.pi` agents or chains run inside OpenClaw.

## Relationship to existing routing docs

| Existing artifact | Role in the new model |
|---|---|
| `docs/architecture/discord-channel-routing.md` | Static M4 baseline for deterministic `<network-slug>-<project-slug>` channels. |
| `docs/architecture/channel-context-namespace-mapping.md` | Existing resolver contract for channel-local runtime memory and durable project reads. |
| `docs/adr/0002-engram-namespace-contract.md` | Accepted separation rules for dev, runtime, and durable project memory. |
| #14 | Historical channel naming/routing convention ancestor. |
| #15 | Historical channel-to-Engram namespace mapping ancestor. |
| #57 | Live/private Discord route validation anchor. |

Dynamic category-scoped namespaces should extend these contracts instead of replacing the safety rules they established.

## Legacy behavior

The old channel-first model remains acceptable as a compatibility fallback:

```text
channel name -> project/network route -> durable read candidates
```

New work should prefer:

```text
category/channel origin -> context pack -> skill pack -> intent -> runner
```

Avoid new designs that assume a fixed channel always maps to exactly one skill or one flow.

## Checklist

- [ ] The category exists or is discovered from Discord topology.
- [ ] The category has a stable Discord ID in runtime state.
- [ ] The category has explicit global inheritance settings.
- [ ] The category has local context artifacts or Engram topic keys.
- [ ] The category has local skills or explicitly inherited global skills.
- [ ] The channel has local context and optional skill preferences.
- [ ] Durable writes require approval or an authorized control-channel policy.
