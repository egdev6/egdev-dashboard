# Discord Project Manager global initialization

This contract defines the fake-first `/project-manager init` flow for creating the planned Project Manager workspace category and its global channels.

This is a contract only. It does not prove live Discord category/channel creation, live bot behavior, runtime enforcement, production credentials, prompt execution, durable writes, publishing, or scheduling. Runtime implementations must keep real Discord IDs private and commit only fake/demo placeholders.

## Quick path

1. Receive an init interaction such as `/project-manager init` for one guild.
2. Check the bot can manage channels and post/pin the starter guidance before attempting writes.
3. Resolve global guide entries from `examples/discord-semantic-channel-guides.fake.yaml`.
4. Create or reuse one `Project Manager` category.
5. Create or reuse `global-context`, `global-skills`, `global-strategy`, `global-decisions`, and `global-config` under that category.
6. Apply each guide `topic` to the channel topic field and post the guide `starter_message` as pin-ready guidance.
7. Persist private Discord IDs outside repo artifacts with semantic metadata: `guildId`, `categoryId`, channel IDs, `scope: global`, and field keys.
8. Re-running init must reconcile by persisted IDs and semantic fields instead of duplicating categories or channels.

## Scope boundary

| In scope | Out of scope |
| --- | --- |
| Global Project Manager category init contract | Per-project category creation (#135) |
| Required global channel list | Runtime prompt routing (#137) |
| Permission preflight requirements | Shared status/repair preview flows (#138) |
| Idempotent create-or-reuse behavior | Live Discord validation or production rollout |
| Fake fixture and validator | Durable memory writes or skill activation |

## Interaction contract

The command or equivalent interaction should collect no project-specific input. It initializes only the global workspace surface.

Required interaction fields:

| Field | Meaning |
| --- | --- |
| `interaction_name` | `/project-manager init` or equivalent UI action. |
| `guild_ref` | Repo-safe placeholder in fixtures; private `guildId` at runtime. |
| `requested_by_ref` | Repo-safe placeholder for the operator in fixtures. |
| `idempotency_key` | Stable key such as `project-manager-global:<guildId>` stored privately. |
| `guide_catalog_ref` | `examples/discord-semantic-channel-guides.fake.yaml`. |

The flow must stop before writes when permissions are missing or when existing persisted IDs point to inaccessible entities.

## Required permission preflight

Before category/channel creation, the bot must verify it has enough permissions for the planned operation.

| Capability | Required for |
| --- | --- |
| `manage_channels` | Creating/reusing category and channel topology, setting channel topics. |
| `send_messages` | Posting starter guidance messages. |
| `manage_messages_for_pin` | Pinning starter guidance messages when the runtime supports pinning. |
| `view_channel` | Confirming created/reused channels are visible after the operation. |

Permission failures return a review-safe response and must not partially create topology.

## Required topology

The initialized global Project Manager surface is separate from the existing `OpenClaw Global` reserved topology. It uses planned Project Manager `global-*` guide channels from `docs/architecture/discord-semantic-channel-guides.md`.

| Semantic field | Channel name | Guide source |
| --- | --- | --- |
| `context` | `global-context` | global guide `field_key: context` |
| `skills` | `global-skills` | global guide `field_key: skills` |
| `strategy` | `global-strategy` | global guide `field_key: strategy` |
| `decisions` | `global-decisions` | global guide `field_key: decisions` |
| `config` | `global-config` | global guide `field_key: config` |

## Persistence contract

Runtime implementations persist real IDs privately. Repo fixtures must use fake refs only.

Minimum persisted registry shape:

```yaml
guildId: <private runtime guild id>
categoryId: <private runtime category id>
scope: global
category_semantic_role: project-manager-global
channels:
  context: <private runtime channel id>
  skills: <private runtime channel id>
  strategy: <private runtime channel id>
  decisions: <private runtime channel id>
  config: <private runtime channel id>
created_by_interaction: /project-manager init
idempotency_key: project-manager-global:<guildId>
```

The public fake fixture represents the same shape with `guild-demo-*`, `category-demo-*`, and `channel-demo-*` refs.

## Idempotency rules

| State | Required behavior |
| --- | --- |
| No persisted registry exists | Create the category and required channels, then persist semantic metadata. |
| Persisted category/channels still resolve | Reuse them and report `no-op`; do not duplicate. |
| Category exists but one required channel is missing | Stop with `needs-repair`; use `docs/architecture/discord-channel-scaffolding-status-repair.md` for shared repair preview behavior. |
| Required permissions are missing | Stop with `blocked-permissions`; do not attempt writes. |
| A channel was renamed but ID still resolves | Preserve the ID and semantic field; use `docs/architecture/discord-channel-scaffolding-status-repair.md` for rename status/repair follow-up. |

Issue #134 proves duplicate-safe init behavior for the happy path and simple re-run. Shared drift status and repair preview now live in `docs/architecture/discord-channel-scaffolding-status-repair.md`.

## Safety rules

- Do not commit real guild, category, channel, user, or message IDs.
- Do not commit Discord exports, transcripts, screenshots, or runtime state.
- Do not claim live Discord readiness from this contract.
- Do not store secrets, tokens, or private exports in repo artifacts.
- Do not bypass `skills/discord-approval-gate/SKILL.md` for later write-like outcomes.
- Do not infer behavior from channel names when persisted semantic metadata exists.

## Related artifacts

| Artifact | Role |
| --- | --- |
| `docs/architecture/discord-semantic-channel-guides.md` | Source of canonical topics and starter/pinned messages. |
| `examples/discord-semantic-channel-guides.fake.yaml` | Fake guide catalog consumed by this init contract. |
| `examples/discord-project-manager-global-init.fake.yaml` | Fake init plan/result fixture. |
| `scripts/validate-discord-project-manager-global-init.sh` | Static validator for this contract and fixture. |
| `docs/architecture/discord-project-manager-project-create.md` | Follow-up fake project category creation contract. |
| `docs/architecture/discord-managed-channel-routing.md` | Follow-up fake routing contract that consumes persisted global channel metadata. |
| `docs/architecture/discord-topology-reconciliation.md` | Existing safe topology discovery/reconciliation baseline. |
| `docs/architecture/discord-channel-scaffolding-status-repair.md` | Shared status and repair preview contract for missing or renamed managed scaffolding. |
