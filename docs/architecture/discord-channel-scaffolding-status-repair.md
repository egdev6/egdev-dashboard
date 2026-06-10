# Discord channel scaffolding status and repair

This contract defines the fake-first `/project-manager status`, `/project-manager repair`, and `/project status` flows for detecting drift in managed Project Manager scaffolding and proposing safe repair actions.

This is a contract only. It does not prove live Discord status commands, live Discord repair writes, runtime enforcement, production credentials, prompt execution, durable writes, publishing, or scheduling. Runtime implementations must keep real Discord IDs private and commit only fake/demo placeholders.

## Quick path

1. Receive a status or repair interaction for one guild or one managed project.
2. Read the persisted semantic registry from the managed channel registry backend defined by `docs/architecture/discord-managed-channel-routing.md` and produced by `docs/architecture/discord-project-manager-global-init.md` and `docs/architecture/discord-project-manager-project-create.md`.
3. Discover current Discord categories and channels with the classification vocabulary from `docs/architecture/discord-topology-reconciliation.md`.
4. Match expected managed channels by persisted ID first; do not relink by name when persisted IDs are missing.
5. Report existing, missing, renamed, unsafe-missing-id, and unmanaged-extra results without writing state.
6. Build a repair preview that lists exactly which channels or metadata fields would be recreated or refreshed.
7. Run permission preflight before any repair apply attempt.
8. Require `skills/discord-approval-gate/SKILL.md` and exact `approve write` before any durable recreate or metadata refresh.
9. When repair recreates a channel, refresh the managed channel registry backend so `docs/architecture/discord-managed-channel-routing.md` follows the new private channel ID.
10. After repair apply, re-run status and managed routing verification; success requires `OK` from metadata/IDs, not display-name inference.

## Scope boundary

| In scope | Out of scope |
| --- | --- |
| Shared status contract for global and project scaffolding | Live Discord slash commands or runtime handlers |
| Shared repair preview contract for managed channels | Durable write execution |
| Missing, renamed, unmanaged-extra, and unsafe-missing-id reporting | Automatic relink by channel name |
| Permission preflight before repair apply | Production/live Discord validation |
| Safe retry continuation from partial create audit | Prompt execution or runner output |
| Fake fixture and validator | Publishing, scheduling, or private exports |

## Status command contract

Supported read-only interactions in this slice:

| Command | Purpose |
| --- | --- |
| `/project-manager status` | Report global Project Manager scaffolding health and drift. |
| `/project-manager repair` | Show repair preview for a global or project managed surface before approval. |
| `/project status` | Report one project category and its expected managed channels. |

Status output must be read-only and explainable.

Required status fields:

| Field | Meaning |
| --- | --- |
| `managed_surface` | `global` or `project`. |
| `expected_category_ref` | Repo-safe category placeholder; private category ID at runtime. |
| `existing_fields` | Managed channel fields whose persisted IDs still resolve. |
| `missing_fields` | Expected fields whose persisted IDs do not resolve. |
| `renamed_binding` | Optional ID-linked rename evidence for one resolved channel. |
| `unsafe_missing_id_fields` | Fields whose persisted ID is absent or unusable and therefore cannot be auto-relinked. |
| `unmanaged_channel_refs` | Extra visible channels inside a managed category that are not present in the persisted registry. |
| `status_result` | `no-op`, `needs-repair`, `renamed-linked`, `unsafe-missing-id`, or `unmanaged-present`. |
| `write_attempted` | Always `false` in status output. |

If the backend is unavailable, status must return `BACKEND_NOT_AVAILABLE` and no repair apply may proceed. If bindings are absent, status must report `unsafe-missing-id` or `MISSING_METADATA` rather than relinking by visible channel name.

## Reconciliation vocabulary

This slice reuses the safe discovery/reconciliation vocabulary from `docs/architecture/discord-topology-reconciliation.md`.

| Reused topology state | Meaning in managed scaffolding status |
| --- | --- |
| `unchanged` | Persisted managed channel ID still resolves in Discord; reported as an `existing_fields` entry. |
| `deleted-project` | Project binding is tombstoned by `docs/architecture/discord-project-manager-project-delete.md`; do not propose recreate-by-name repair. |
| `missing` | Persisted managed channel ID no longer resolves. |
| `renamed` | Persisted managed channel ID still resolves but the display name changed. |
| `unmapped` | Extra visible channel exists inside a managed category but is not in the persisted registry; reported as an unmanaged channel. |
| `permission-limited` | Repair apply is blocked because the bot cannot safely confirm required capabilities. |

`renamed` stays linked by ID. `unsafe-missing-id` is a stricter status than `missing`: the runtime cannot safely relink a channel when the persisted ID is absent, even if a same-named channel is visible. Operator-facing `status_result` values such as `no-op`, `needs-repair`, and `unmanaged-present` summarize these lower-level topology states; they do not replace the reconciliation vocabulary.

## Repair preview contract

Repair is always two-phase in this slice.

1. Status or repair preview compares the persisted registry with current topology and proposes exact actions.
2. Apply is out of scope for this fake-first contract, but any future apply step must require exact `approve write`.

Required repair preview fields:

| Field | Meaning |
| --- | --- |
| `status` | `no-op`, `approval-requested`, `needs-review`, `blocked-permissions`, `no-relink-required`, or `no-destructive-action`. |
| `proposed_actions` | Exact planned recreates or metadata updates; empty when nothing safe should happen. |
| `permission_preflight_status` | `ready` or `blocked-permissions`. |
| `permission_missing_capabilities` | Empty when ready; list of missing capabilities when blocked. |
| `approval_state` | `approval-requested` only when a displayed repair plan is eligible for apply; otherwise `not-requested`. |
| `write_executed` | Always `false` in this fake contract. |

Allowed repair preview actions in this slice:

| Action | Meaning |
| --- | --- |
| `recreate-channel` | Recreate a missing managed channel after approval. |
| `refresh-metadata` | Update persisted semantic metadata in the managed channel registry backend after recreation so routing points to the new channel ID. |
| `update-guide-copy` | Optional low-risk topic/starter guidance refresh for a renamed but still linked channel. |

## Permission preflight

Before any repair apply attempt, the runtime must verify enough capability to finish the planned operation without partial writes when possible.

| Capability | Required for |
| --- | --- |
| `manage_channels` | Recreating missing category/channel topology and setting topics. |
| `send_messages` | Reposting starter guidance messages after recreation. |
| `manage_messages_for_pin` | Re-pinning starter guidance when supported. |
| `view_channel` | Confirming recreated or reused channels remain visible. |

Permission failures must report `blocked-permissions` before partial repair whenever possible.

## Safety rules

- Do not commit real guild, category, channel, user, project, or message IDs.
- Do not commit Discord exports, transcripts, screenshots, or runtime state.
- Do not claim live Discord repair readiness from this contract.
- Do not auto-link a missing persisted channel ID from a same-named visible channel.
- Do not bypass `skills/discord-approval-gate/SKILL.md` for repair apply.
- Do not recreate or refresh metadata before exact `approve write`.
- Do not let unmanaged extra channels trigger destructive actions by default.
- Do not resurrect a tombstoned `deleted-project` from display-name matches; recreating a deleted project requires a fresh create flow.

## Related artifacts

| Artifact | Role |
| --- | --- |
| `docs/architecture/discord-project-manager-global-init.md` | Produces global managed scaffolding registry metadata for #134. |
| `docs/architecture/discord-project-manager-project-create.md` | Produces project managed scaffolding registry metadata and partial retry audit for #135. |
| `docs/architecture/discord-managed-channel-routing.md` | Consumes refreshed managed channel metadata after repair for #137. |
| `docs/architecture/discord-project-manager-project-delete.md` | Defines tombstone/delete expectations so deleted projects are not treated as live scaffolding. |
| `docs/architecture/discord-topology-reconciliation.md` | Supplies rename/missing/discovered/permission-limited vocabulary. |
| `examples/discord-channel-scaffolding-status-repair.fake.yaml` | Fake shared status and repair scenarios for #138. |
| `scripts/validate-discord-channel-scaffolding-status-repair.sh` | Static validator for this contract and fixture. |
