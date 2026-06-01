# Discord topology discovery and reconciliation

This document defines the contract for discovering Discord categories/channels and reconciling that topology with OpenClaw planning artifacts.

It extends the static routing baseline and dynamic context namespace architecture. It does not provision namespaces, write Engram, or authorize durable writes.

## Quick path

1. Discover the Discord guild topology from the runtime event/API surface.
2. Keep real IDs private; commit only fake/demo placeholders.
3. Compare discovery with the last approved topology registry.
4. Classify changes as `create`, `update`, `archive`, or `needs-review`.
5. Keep runtime memory under ADR 0002: `egdev-dashboard/runtime/discord/<guild-id>/<channel-id>`.

## Scope boundary

| In scope | Out of scope |
|---|---|
| Guild/category/channel shape | Context namespace provisioning |
| Parent-child relationships | Skill creation or routing |
| Reserved `OpenClaw Global` detection | Engram writes |
| Reconciliation states and actions | Runtime Orchestrator behavior |
| Repo-safe topology fixtures | Gentle SDD invocation |

Any new runtime namespace family requires an ADR 0002 update first.

## Topology snapshot

A snapshot is the current discovered Discord layout. Runtime implementations may hold real IDs privately, but repo fixtures must use placeholders.

Required shape:

| Field | Meaning |
|---|---|
| `guild.ref` | Repo-safe guild placeholder. |
| `guild.visibility` | Whether the bot can see the guild. |
| `categories[].ref` | Repo-safe category placeholder. |
| `categories[].name` | Current category display name. |
| `categories[].normalized_name` | Lowercase kebab-case category name. |
| `categories[].reserved_role` | `openclaw-global` or `none`. |
| `categories[].visibility` | Bot visibility for the category. |
| `categories[].channels[].ref` | Repo-safe channel placeholder. |
| `categories[].channels[].normalized_name` | Lowercase kebab-case channel name. |
| `categories[].channels[].visibility` | Bot visibility for the channel. |

## Approved registry

The approved registry is the last operator-reviewed topology baseline. It must keep stable refs and previous parent/category metadata so rename and move states can be derived.

Required shape:

| Field | Meaning |
|---|---|
| `guild.ref` | Repo-safe guild placeholder. |
| `categories[].ref` | Stable category placeholder from the approved baseline. |
| `categories[].normalized_name` | Previously approved category name. |
| `categories[].channels[].ref` | Stable channel placeholder from the approved baseline. |
| `categories[].channels[].normalized_name` | Previously approved channel name. |
| `categories[].channels[].parent_ref` | Previously approved category parent for the channel. |

## Reconciliation states

| State | Meaning | Default action |
|---|---|---|
| `unchanged` | Same stable ID, parent, and normalized name. | `no-op` |
| `discovered` | Stable ID not present in the approved registry. | `create` draft |
| `renamed` | Same stable ID, changed display/normalized name. | `update` metadata |
| `moved` | Same channel ID, changed parent category. | `needs-review` |
| `missing` | Previously approved ID absent from latest snapshot. | `archive` candidate |
| `unmapped` | Visible but not approved or classifiable. | `needs-review` |
| `permission-limited` | Bot cannot see enough detail to classify safely. | `needs-review` |

Moves across categories and missing entities are sensitive. Never apply them destructively without operator review.

## Reconciliation output

Each result should be explainable and non-destructive:

| Field | Meaning |
|---|---|
| `entity_ref` | Repo-safe category/channel placeholder. |
| `entity_type` | `category` or `channel`. |
| `current_parent_ref` | Current category placeholder for a channel. |
| `previous_parent_ref` | Previous category placeholder when known. |
| `state` | One reconciliation state. |
| `recommended_action` | `no-op`, `create`, `update`, `archive`, or `needs-review`. |
| `reason` | Short human-readable explanation. |
| `safe_to_apply_automatically` | `true` only for no-op or low-risk metadata updates. |

## Reserved topology

`OpenClaw Global` is a reserved control category detected by normalized name, then anchored by stable runtime ID after operator approval.

Expected reserved channels:

- `identity`
- `writing-style`
- `operating-principles`
- `boundaries`
- `inheritance`
- `skills`

Missing reserved channels are `needs-review` until #69 defines provisioning behavior. This contract reports gaps; it does not create Discord channels.

## Safety rules

- Do not commit real Discord guild, category, channel, user, or message IDs.
- Do not commit Discord exports, transcripts, screenshots, or runtime state.
- Do not delete topology records automatically when a category/channel is missing.
- Do not treat a rename as a new identity when the stable ID matches.
- Do not auto-apply channel moves across categories.
- Do not let topology resolution authorize durable memory writes.

## Example flow

```text
latest Discord topology
  -> compare with approved topology registry
  -> classify each category/channel state
  -> emit reconciliation report
  -> operator reviews create/update/archive/needs-review actions
  -> later issues may provision context or skills from approved actions
```

## Related artifacts

| Artifact | Role |
|---|---|
| `docs/architecture/discord-dynamic-context-namespaces.md` | Parent architecture for category-scoped context and skills. |
| `docs/architecture/discord-channel-routing.md` | Static channel routing fallback. |
| `docs/architecture/channel-context-namespace-mapping.md` | Current channel-local runtime namespace resolver. |
| `docs/adr/0002-engram-namespace-contract.md` | Accepted runtime and durable namespace families. |
| `examples/discord-topology-reconciliation.fake.yaml` | Fake fixture for this contract. |
| `scripts/validate-discord-topology-reconciliation.sh` | Static validator for the fake fixture. |
