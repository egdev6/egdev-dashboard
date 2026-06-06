# Discord Project Manager project creation

This contract defines the fake-first `/project create` flow for creating one Discord category per project with template-driven channels.

This is a contract only. It does not prove live Discord category/channel creation, live bot behavior, runtime enforcement, production credentials, prompt execution, durable writes, publishing, or scheduling. Runtime implementations must keep real Discord IDs private and commit only fake/demo placeholders.

## Quick path

1. Receive a project creation interaction such as `/project create` for one guild.
2. Collect project name, optional short description, and selected template.
3. Normalize the project name to a deterministic project slug.
4. Check duplicate project names/slugs before writes.
5. Check the bot can manage channels and post/pin starter guidance before attempting writes.
6. Resolve project guide entries from `examples/discord-semantic-channel-guides.fake.yaml`.
7. Create one category for the project; do not create nested categories.
8. Create the selected project channels under that category.
9. Apply each guide `topic` to the channel topic field and post the guide `starter_message` as pin-ready guidance.
10. Persist private Discord IDs outside repo artifacts with semantic metadata: `guildId`, `projectId`, `categoryId`, channel IDs, `scope: project`, and field keys.
11. If creation fails after a partial result, persist or emit enough safe audit metadata to retry or repair without guessing by name.

## Scope boundary

| In scope | Out of scope |
| --- | --- |
| Project category creation contract | Global Project Manager init (#134) |
| Minimal and complete templates | Custom button/select channel picking |
| Duplicate slug handling | Runtime prompt routing (#137) |
| Partial failure audit boundary | Full drift repair/status flows (#138) |
| Fake fixture and validator | Live Discord validation or production rollout |

## Interaction contract

Required interaction fields:

| Field | Meaning |
| --- | --- |
| `interaction_name` | `/project create` or equivalent UI action. |
| `guild_ref` | Repo-safe placeholder in fixtures; private `guildId` at runtime. |
| `requested_by_ref` | Repo-safe placeholder for the operator in fixtures. |
| `project_name` | User-provided display name. |
| `project_description` | Optional short description for operator context. |
| `selected_template` | `minimal` or `complete`. |
| `project_slug` | Deterministic slug derived from `project_name`. |
| `idempotency_key` | Stable key such as `project:<guildId>:<projectSlug>` stored privately. |
| `guide_catalog_ref` | `examples/discord-semantic-channel-guides.fake.yaml`. |

The flow must stop before writes when permissions are missing, when the slug already maps to a different project, or when the selected template is unsupported.

## Required permission preflight

Before category/channel creation, the bot must verify enough permissions for the planned operation.

| Capability | Required for |
| --- | --- |
| `manage_channels` | Creating the project category and channels, setting channel topics. |
| `send_messages` | Posting starter guidance messages. |
| `manage_messages_for_pin` | Pinning starter guidance messages when the runtime supports pinning. |
| `view_channel` | Confirming created/reused channels are visible after the operation. |

Permission failures return a review-safe response and must not partially create topology.

## Template contract

Project creation supports two templates in this slice.

| Template | Channels |
| --- | --- |
| `minimal` | `context`, `strategy`, `tasks` |
| `complete` | `context`, `skills`, `strategy`, `tasks`, `decisions`, `qa` |

A later custom mode may collect channels with buttons or selects, but this contract does not define custom selection behavior.

## Required topology

Each project gets one top-level Discord category. Discord does not support nested categories, so the project category must not be created inside the global Project Manager category.

Example complete topology:

```text
Project - Web App
  #context
  #skills
  #strategy
  #tasks
  #decisions
  #qa
```

Each channel uses the matching `scope: project` guide from `docs/architecture/discord-semantic-channel-guides.md`.

## Persistence contract

Runtime implementations persist real IDs privately. Repo fixtures must use fake refs only.

Minimum persisted registry shape:

```yaml
guildId: <private runtime guild id>
projectId: <private project id or slug>
projectSlug: <deterministic project slug>
categoryId: <private runtime category id>
scope: project
category_semantic_role: project-manager-project
selected_template: complete
channels:
  context: <private runtime channel id>
  skills: <private runtime channel id>
  strategy: <private runtime channel id>
  tasks: <private runtime channel id>
  decisions: <private runtime channel id>
  qa: <private runtime channel id>
created_by_interaction: /project create
idempotency_key: project:<guildId>:<projectSlug>
```

The public fake fixture represents the same shape with `guild-demo-*`, `project-demo-*`, `category-demo-*`, and `channel-demo-*` refs.

## Duplicate and failure handling

| State | Required behavior |
| --- | --- |
| Project slug is unused | Continue to permission preflight and create the selected category/channels. |
| Project slug already maps to the same persisted project | Return `duplicate-same-project` and ask whether to open/status the existing project; do not duplicate. |
| Project slug conflicts with a different project | Return `duplicate-name-review` and ask for a different name or maintainer decision. |
| Required permissions are missing | Stop with `blocked-permissions`; do not attempt writes. |
| Category is created but a channel create fails | Emit safe partial audit with created refs and missing fields; full repair belongs to #138. |
| Unsupported template is selected | Stop with `unsupported-template`; do not attempt writes. |

## Safety rules

- Do not commit real guild, category, channel, user, project, or message IDs.
- Do not commit Discord exports, transcripts, screenshots, or runtime state.
- Do not claim live Discord readiness from this contract.
- Do not store secrets, tokens, or private exports in repo artifacts.
- Do not bypass `skills/discord-approval-gate/SKILL.md` for later write-like outcomes.
- Do not create nested categories or infer behavior from channel names when persisted semantic metadata exists.

## Related artifacts

| Artifact | Role |
| --- | --- |
| `docs/architecture/discord-project-manager-global-init.md` | Conceptual prerequisite for the global workspace surface. |
| `docs/architecture/discord-semantic-channel-guides.md` | Source of canonical project topics and starter/pinned messages. |
| `docs/architecture/discord-managed-channel-routing.md` | Follow-up fake routing contract that consumes persisted project channel metadata. |
| `examples/discord-semantic-channel-guides.fake.yaml` | Fake guide catalog consumed by this project creation contract. |
| `examples/discord-project-manager-project-create.fake.yaml` | Fake project creation fixture. |
| `scripts/validate-discord-project-manager-project-create.sh` | Static validator for this contract and fixture. |
| `docs/architecture/discord-topology-reconciliation.md` | Existing safe topology discovery/reconciliation baseline. |
