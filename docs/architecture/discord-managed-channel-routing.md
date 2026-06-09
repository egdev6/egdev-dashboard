# Discord managed channel routing

This contract defines fake-first routing for messages that originate from bot-managed Discord Project Manager channels. It resolves prompts by persisted semantic metadata instead of inferring behavior from channel names.

This is a contract only. It does not prove live Discord event handling, live bot routing, runtime enforcement, prompt execution, durable writes, production credentials, publishing, or scheduling. Runtime implementations must keep real Discord IDs private and commit only fake/demo placeholders.

## Quick path

1. Receive a Discord message event from a managed channel.
2. Resolve the channel through the persisted semantic registry by private `guildId` + `channelId`.
3. Read the registry metadata for `scope`, `field_key`, `projectId` when applicable, category/channel IDs, guide ref, and allowed prompt operations.
4. Reject unmanaged channels or unsupported operations with a safe explanatory response.
5. Route global channels only to global workspace state.
6. Route project channels only to the matching project state.
7. Resolve effective skills through `docs/architecture/discord-scoped-skills-registry.md` when `field_key: skills` or a write-like/project operation needs skills.
8. Send write-like outcomes through `docs/architecture/discord-memory-gateway.md` and `skills/discord-approval-gate/SKILL.md` before durable persistence.
9. Emit safe audit output with fake refs in repo fixtures and private runtime IDs outside public artifacts.

## Scope boundary

| In scope | Out of scope |
| --- | --- |
| Semantic registry lookup contract | Live Discord event listener implementation |
| Global vs project routing boundaries | Channel/category creation (#134/#135) |
| Allowed operation checks | Shared status/repair preview flows (#138) |
| Scoped skills lookup for skills channels | Durable write execution |
| Safe unsupported-message responses | Prompt execution or runner output |
| Fake fixture and validator | Production/live Discord validation |

## Managed channel registry backend

Runtime implementations MUST persist managed channel metadata in a private runtime registry backend, not in repository files, Discord-visible channel names, screenshots, or chat transcripts.

For this slice, the backend contract is an implementation-neutral private registry store with these requirements:

| Requirement | Contract |
| --- | --- |
| Lookup key | `guildId + channelId` for message routing; `guildId + categoryId` for managed surface status. |
| Producers | `/project-manager init`, `/project create`, and approved repair apply flows. |
| Consumers | managed channel routing, status, repair preview, and post-repair verification. |
| Storage boundary | Private runtime storage only, e.g. an OpenClaw workspace registry or equivalent deployment-private store. |
| Repo representation | Fake/demo refs only; never real Discord IDs. |
| Missing backend behavior | Return `BACKEND_NOT_AVAILABLE`; do not infer success from channel display names. |
| Missing metadata behavior | Return `MISSING_METADATA` or `NAME_INFERENCE_ONLY`; do not silently pass. |

The registry backend owns semantic bindings. Discord channel topics and starter guidance are operator-facing copy, not the routing source of truth.

## Managed channel registry shape

Runtime implementations persist real IDs privately. Repo fixtures use fake refs only.

Required channel registry fields:

| Field | Meaning |
| --- | --- |
| `guild_ref` | Repo-safe guild placeholder in fixtures; private `guildId` at runtime. |
| `category_ref` | Repo-safe category placeholder in fixtures; private `categoryId` at runtime. |
| `channel_ref` | Repo-safe channel placeholder in fixtures; private `channelId` at runtime. |
| `scope` | `global` or `project`. |
| `project_ref` | Required for `scope: project`; absent or `none` for global. |
| `field_key` | Semantic field such as `context`, `skills`, `strategy`, `tasks`, `decisions`, `qa`, or `config`. |
| `guide_ref` | `global.<field>` or `project.<field>` from `docs/architecture/discord-semantic-channel-guides.md`. |
| `allowed_prompt_operations` | Bounded operation list such as `ask`, `summarize`, `propose_update`, `review`, or `generate`. |
| `state_target` | Logical state boundary such as `workspace-global-context` or `project:<projectSlug>:strategy`. |
| `idempotency_key` | Stable producer key such as `project-manager-global:<guildId>` or `project:<guildId>:<projectSlug>`. |
| `created_by_interaction` | Producer interaction or repair source that created the binding. |
| `updated_by_interaction` | Last approved interaction or repair source that refreshed the binding. |

The routing layer must not rely on display names once `channel_ref`/private `channelId` metadata exists. If no backend or binding exists, the safe outcome is `BACKEND_NOT_AVAILABLE`, `MISSING_METADATA`, or `NAME_INFERENCE_ONLY`, not `OK`. When `docs/architecture/discord-channel-scaffolding-status-repair.md` recreates a managed channel, runtime implementations must refresh the persisted private channel ID before routing resumes.

## Verification status vocabulary

Managed routing verification must be able to report these statuses without writing state:

| Status | Meaning |
| --- | --- |
| `OK` | Backend binding exists and resolves the expected scope, field, project, category, and channel by private IDs. |
| `BACKEND_NOT_AVAILABLE` | Runtime has no configured managed registry backend. |
| `MISSING_METADATA` | Backend exists, but a required binding or field is absent. |
| `NAME_INFERENCE_ONLY` | Runtime can only infer from display names; this is not accepted as managed routing success. |
| `WRONG_SCOPE` | Binding exists but has the wrong `scope`. |
| `WRONG_FIELD` | Binding exists but has the wrong `field_key`. |
| `WRONG_PROJECT` | Binding exists but has the wrong project binding. |
| `NEEDS_REPAIR_PREVIEW` | Drift can be corrected only through the two-phase repair preview/apply flow. |

## Routing outcomes

| Outcome | Required behavior |
| --- | --- |
| `global-context-route` | Route to global workspace context only; no project state reads/writes. |
| `global-skills-route` | Route to global skills governance and scoped skills registry only; write-like changes require approval. |
| `project-context-route` | Route to the matching project context only. |
| `project-skills-route` | Route to the matching project skill preferences/overrides only; respect #70 scoped skills rules. |
| `project-strategy-route` | Route to the matching project strategy only. |
| `unsupported-operation` | Return response-only clarification; do not mutate state. |
| `unmanaged-channel` | Return response-only fallback; do not hydrate durable state. |

## Persistence boundary

Routing chooses context and allowed operation. It does not approve persistence.

Write-like operations must:

1. classify as `approval-requested` or `reject` before durable persistence;
2. include `discord-approval-gate` in mandatory/effective skills where applicable;
3. show target namespace or registry artifact as a proposal only;
4. keep `write_executed: false` until exact `approve write` is handled by the approval gate.

## Unsupported response contract

Unsupported operations in managed channels must be explicit and safe:

```text
I can route this managed channel, but this operation is not allowed here.
Scope: <global|project>
Field: <field_key>
Allowed operations: <allowed list>
No state was changed.
```

Unmanaged channels use the broader routing fallback from `docs/operations/discord-routing.md` and must not silently hydrate global or project state.

## Safety rules

- Do not commit real guild, category, channel, user, project, or message IDs.
- Do not commit Discord exports, transcripts, screenshots, or runtime state.
- Do not claim live Discord routing from this contract.
- Do not store secrets, tokens, raw chat logs, or private exports in repo artifacts.
- Do not bypass `skills/discord-approval-gate/SKILL.md` for write-like outcomes.
- Do not infer scope or target state from channel names when persisted semantic metadata exists.

## Related artifacts

| Artifact | Role |
| --- | --- |
| `docs/architecture/discord-project-manager-global-init.md` | Produces global channel registry metadata for #134. |
| `docs/architecture/discord-project-manager-project-create.md` | Produces project channel registry metadata for #135. |
| `docs/architecture/discord-semantic-channel-guides.md` | Source of `guide_ref` semantics. |
| `docs/architecture/discord-scoped-skills-registry.md` | Source of scoped skill resolution rules. |
| `docs/architecture/discord-memory-gateway.md` | Writeback and hydration boundary. |
| `docs/architecture/discord-channel-scaffolding-status-repair.md` | Shared repair preview contract that refreshes managed channel metadata after recreation. |
| `examples/discord-managed-channel-routing.fake.yaml` | Fake routing registry and message scenarios. |
| `scripts/validate-discord-managed-channel-routing.sh` | Static validator for this contract and fixture. |
