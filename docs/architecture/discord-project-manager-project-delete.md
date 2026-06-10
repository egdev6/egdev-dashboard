# Discord Project Manager project delete

This contract defines the fake-first `/project delete` flow for safely deleting one managed Project Manager project category and its managed channels.

This is a contract only. It does not prove live Discord category/channel deletion, live bot behavior, runtime enforcement, production credentials, prompt execution, durable writes, publishing, or scheduling. Runtime implementations must keep real Discord IDs private and commit only fake/demo placeholders.

## Quick path

1. Receive a project deletion interaction such as `/project delete` for one guild.
2. Resolve the target project from the persisted managed channel registry backend produced by `docs/architecture/discord-project-manager-project-create.md`; do not target by display name alone.
3. Verify the persisted category/channel bindings, current topology state, and any unmanaged or unsafe drift before proposing deletion.
4. Build a read-only preview that lists the exact managed category, managed channels, and registry updates that would be deleted or tombstoned.
5. Run permission preflight before any destructive apply attempt.
6. Require `skills/discord-approval-gate/SKILL.md` and a stronger explicit confirmation phrase than normal write-like flows before destructive apply.
7. After approved delete apply, remove live bindings or tombstone the project in the managed registry so routing and status/repair no longer treat the project as live scaffolding.
8. If deletion succeeds only in part, emit a safe partial-delete audit and require an approval-gated retry preview instead of guessing by name.

## Scope boundary

| In scope | Out of scope |
| --- | --- |
| Managed Project Manager project delete contract | Global Project Manager category delete |
| Preview-first delete of one project category and its managed channels | Live Discord deletion handlers |
| Persisted-metadata-first targeting | Display-name-only delete targeting |
| Registry tombstone/remove expectations after delete | Durable write execution in public artifacts |
| Partial-delete audit and retry preview boundary | Production/live Discord validation |
| Fake fixture and validator | Publishing, scheduling, or private exports |

## Interaction contract

Required interaction fields:

| Field | Meaning |
| --- | --- |
| `interaction_name` | `/project delete` or equivalent UI action. |
| `guild_ref` | Repo-safe placeholder in fixtures; private `guildId` at runtime. |
| `requested_by_ref` | Repo-safe placeholder for the operator in fixtures. |
| `project_slug` | Deterministic project slug used to resolve the managed registry entry. |
| `project_ref` | Optional explicit project ref when the runtime already resolved it safely. |
| `delete_reason` | Optional short reason kept in safe audit/tombstone metadata. |
| `registry_backend_ref` | `private-runtime-managed-channel-registry`. |
| `idempotency_key` | Stable key such as `project-delete:<guildId>:<projectSlug>` stored privately. |

The flow must stop before destructive apply when the managed registry backend is unavailable, when the project binding cannot be resolved from persisted metadata, or when unmanaged extra channels, missing IDs, or ambiguous topology make automatic destructive apply unsafe.

## Required permission preflight

Before destructive apply, the bot must verify enough permission to finish the planned operation without partial writes when possible.

| Capability | Required for |
| --- | --- |
| `manage_channels` | Deleting the managed project category and managed channels. |
| `view_channel` | Verifying that the targeted managed bindings still resolve before apply and no longer resolve after apply. |

Permission failures return a review-safe response and must not partially delete topology.

## Delete targeting contract

Deletion targets the persisted managed registry entry first. Discord-visible names are review hints only.

Required targeting rules:

- resolve the project by persisted semantic metadata/IDs from `docs/architecture/discord-managed-channel-routing.md`;
- treat the managed registry as the source of truth for the category ref, managed field keys, and managed channel refs;
- do not infer delete success from a matching visible category or channel name when persisted IDs are missing;
- stop with manual review when an unmanaged extra channel is visible inside the managed category;
- stop with manual review when a required persisted ID is absent or ambiguous.

## Preview and apply contract

Delete is always two-phase in this slice.

1. Preview compares persisted project bindings with current topology and lists the exact destructive plan.
2. Apply is out of scope for this fake-first contract, but any future apply step must require exact approval for the same displayed plan.

Required preview fields:

| Field | Meaning |
| --- | --- |
| `status` | `approval-requested`, `needs-review`, `blocked-permissions`, `no-op`, or `no-destructive-action`. |
| `category_ref_to_delete` | Repo-safe category placeholder targeted by persisted metadata. |
| `managed_channel_refs_to_delete` | Exact managed channel refs targeted by persisted metadata. |
| `registry_update_mode` | `tombstone-project-binding` or `remove-live-binding-and-tombstone`. |
| `cleared_registry_channel_fields` | Managed field keys whose live bindings would be removed from routing. |
| `lifecycle_state_after_apply` | `deleted`. |
| `post_delete_routing_status` | Expected managed-routing verification result after apply, e.g. `DELETED_PROJECT`. |
| `post_delete_status_result` | Expected project status result after apply, e.g. `deleted-project`. |
| `permission_preflight_status` | `ready` or `blocked-permissions`. |
| `permission_missing_capabilities` | Empty when ready; list of missing capabilities when blocked. |
| `approval_state` | `approval-requested` only when the displayed delete plan is eligible for apply; otherwise `not-requested`. |
| `approval_phrase` | Stronger exact confirmation phrase for destructive apply. |
| `write_executed` | Always `false` in this fake contract. |
| `proposed_actions` | Exact planned deletes/tombstone updates; empty when nothing safe should happen. |

### Stronger explicit confirmation

Normal write-like flows use exact `approve write`. Destructive project deletion must use a stronger project-scoped confirmation phrase.

Required rule for this slice:

```text
approve delete project <project-slug>
```

For example:

```text
approve delete project web-app
```

Generic `approve write` is not sufficient for project deletion apply.

## Partial-delete and retry boundary

If a future destructive apply deletes only part of the managed surface, the runtime must emit safe retry metadata instead of guessing by name.

Minimum partial-delete audit shape:

- project ref and project slug;
- category ref;
- deleted managed channel refs;
- remaining managed channel fields still requiring delete;
- safe retry token;
- whether the registry tombstone was written;
- whether live bindings still remain.

A retry preview must target the remaining persisted bindings only and must require the same stronger delete confirmation phrase before any further destructive apply.

## Post-delete verification expectations

After approved apply, the deleted project must not remain as live managed scaffolding.

Required expectations:

- managed routing verification must not return `OK` for deleted project channels;
- `docs/architecture/discord-managed-channel-routing.md` should report `DELETED_PROJECT` or another explicit non-live status for deleted project bindings;
- `docs/architecture/discord-channel-scaffolding-status-repair.md` should report `deleted-project` or another explicit non-live status instead of proposing recreate-by-name behavior;
- repair preview must not silently resurrect a deleted project from display-name matches;
- recreating the project later requires a fresh create flow, not silent repair of a deleted tombstone.

## Safety rules

- Do not commit real guild, category, channel, user, project, or message IDs.
- Do not commit Discord exports, transcripts, screenshots, or runtime state.
- Do not claim live Discord deletion readiness from this contract.
- Do not delete a managed project from display-name inference alone.
- Do not bypass `skills/discord-approval-gate/SKILL.md` for delete apply.
- Do not allow unmanaged extra channels, missing IDs, or ambiguous topology to auto-delete by default.
- Do not treat generic `approve write` as sufficient confirmation for project deletion.

## Related artifacts

| Artifact | Role |
| --- | --- |
| `docs/architecture/discord-project-manager-project-create.md` | Produces the persisted project registry metadata that this delete contract targets. |
| `docs/architecture/discord-managed-channel-routing.md` | Consumes the registry state that must stop routing deleted projects as live scaffolding. |
| `docs/architecture/discord-channel-scaffolding-status-repair.md` | Defines post-delete non-live status/repair expectations for deleted managed projects. |
| `docs/architecture/discord-topology-reconciliation.md` | Supplies missing/unmapped/permission-limited vocabulary used during delete safety review. |
| `examples/discord-project-manager-project-delete.fake.yaml` | Fake project delete fixture. |
| `scripts/validate-discord-project-manager-project-delete.sh` | Static validator for this contract and fixture. |
