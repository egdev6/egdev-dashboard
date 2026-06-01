# Discord context namespace provisioning

This document defines how OpenClaw turns approved Discord topology reconciliation actions into draft context artifacts.

It builds on topology discovery. It does not read or write Engram, create Discord channels, or activate skills.

## Quick path

1. Start from an approved reconciliation action.
2. Provision only draft artifacts for `create` and safe `update` actions.
3. Preserve stable category/channel refs across renames.
4. Block moved, missing, unmapped, and permission-limited entities for operator review.
5. Do not inherit global context or global skills unless an approved inheritance rule exists.
6. Keep ADR 0002 runtime memory unchanged: `egdev-dashboard/runtime/discord/<guild-id>/<channel-id>`.

## Scope boundary

| In scope | Out of scope |
|---|---|
| Draft category context artifacts | Live Discord channel creation |
| Draft channel context artifacts | Engram writes or promotion |
| Metadata updates for renames | Skill activation/routing |
| Safe provisioning decisions | Runtime Orchestrator behavior |
| Fake fixtures and validation | Gentle SDD invocation |

## Provisioning inputs

Provisioning consumes the output from `docs/architecture/discord-topology-reconciliation.md` after operator review.

Required input fields:

| Field | Meaning |
|---|---|
| `entity_ref` | Stable category/channel placeholder or private runtime ID. |
| `entity_type` | `category` or `channel`. |
| `current_parent_ref` | Category parent for a channel. |
| `state` | Reconciliation state. |
| `recommended_action` | Reconciliation action. |
| `operator_decision` | `approved`, `rejected`, or `needs-review`. |

Only `operator_decision: approved` can produce draft artifacts.

## Draft artifact layout

Artifact paths in this repo must use fake refs. Runtime implementations may map those refs to private Discord IDs outside public artifacts.

Category draft:

```text
openclaw/provisioning/categories/<category-ref>/metadata.yaml
openclaw/provisioning/categories/<category-ref>/context.md
openclaw/provisioning/categories/<category-ref>/active-work.md
openclaw/provisioning/categories/<category-ref>/skills.yaml
openclaw/provisioning/categories/<category-ref>/inheritance.yaml
```

Channel draft:

```text
openclaw/provisioning/channels/<channel-ref>/metadata.yaml
openclaw/provisioning/channels/<channel-ref>/context.md
openclaw/provisioning/channels/<channel-ref>/ledger.md
openclaw/provisioning/channels/<channel-ref>/skills.yaml
```

These are planned/generated paths, not required committed files for every Discord category.

## Provisioning rules

| Input state/action | Provisioning result |
|---|---|
| `discovered` + `create` + approved category | Create draft category artifacts. |
| `discovered` + `create` + approved channel | Create draft channel artifacts linked to parent category. |
| `renamed` + `update` + approved | Update metadata only; preserve stable ref and existing artifact paths. |
| `unchanged` + `no-op` | No provisioning change. |
| `moved` + `needs-review` | Block provisioning until operator chooses context migration behavior. |
| `missing` + `archive` | Mark archive candidate; do not delete artifacts silently. |
| `unmapped` or `permission-limited` | Block provisioning and ask for review. |

## Safe defaults

New category drafts start with empty inheritance:

```yaml
global_context_inherits: []
global_skill_inherits: []
provisioning_mode: draft
requires_operator_review: true
```

The first useful draft is intentionally local-only. Later issues may define how the Memory Gateway and skill registry promote approved inheritance.

## Pilot examples

`egdev-linkedin` draft expectations:

- category context for LinkedIn strategy and audience;
- channel context for drafts/calendar/ledger work;
- no global inheritance until `identity`, `writing-style`, or `operating-principles` are explicitly approved.

`stack-and-flow` draft expectations:

- category context for community purpose, initiatives, and GitHub planning;
- channel context for initiatives/GitHub/LinkedIn coordination;
- no inherited writing-style by default.

## Safety rules

- Do not commit real Discord IDs or runtime exports.
- Do not use category IDs in ADR 0002 runtime namespace paths.
- Do not auto-inherit global context or global skills.
- Do not auto-migrate channel context across categories after a move.
- Do not delete artifacts when Discord entities are missing.
- Do not treat provisioning as approval for durable memory writes.

## Related artifacts

| Artifact | Role |
|---|---|
| `docs/architecture/discord-topology-reconciliation.md` | Source reconciliation contract. |
| `docs/architecture/discord-dynamic-context-namespaces.md` | Parent context/skill architecture. |
| `examples/discord-context-provisioning.fake.yaml` | Fake provisioning plan fixture. |
| `scripts/validate-discord-context-provisioning.sh` | Static validator for the fake fixture. |
