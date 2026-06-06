# Discord Runtime Orchestrator

This contract defines a fake-first OpenClaw Runtime Orchestrator for Discord-originated flows. It makes intent classification, runner selection, permission gates, and execution metadata reviewable before any live Discord routing, prompt execution, or durable write happens.

This is a contract only. It does not prove live Discord/OpenClaw runtime behavior, live Engram calls, prompt execution, Gentle SDD execution, GitHub mutations, production credentials, Buffer activity, publishing, or scheduling.

## Quick path

1. Start from a fake Discord event envelope and resolved origin metadata.
2. Resolve managed Project Manager channels through `docs/architecture/discord-managed-channel-routing.md` when persisted semantic metadata exists.
3. Resolve a channel guide ref from `docs/architecture/discord-semantic-channel-guides.md` for the current semantic channel scope.
4. Reference a Context Pack and Skill Pack for the current turn.
5. Classify intent and choose an explainable runner/backend.
6. Route any write-like result back through Memory Gateway policy and `discord-approval-gate`.

## Orchestrator pipeline

```text
Discord event envelope
-> origin resolution
-> managed channel route
-> channel guide ref
-> context pack ref
-> skill pack ref
-> intent classification
-> runner selection
-> permission/confirmation gate
-> execution metadata
-> writeback policy
```

## Contract dependencies

The orchestrator depends on:

- `docs/architecture/channel-context-namespace-mapping.md` for origin resolution, `runtime_namespace`, `routing_status`, and `resolved_route`;
- `docs/architecture/discord-managed-channel-routing.md`, `examples/discord-managed-channel-routing.fake.yaml`, and `scripts/validate-discord-managed-channel-routing.sh` for persisted semantic metadata routing of managed Project Manager channels;
- `docs/architecture/discord-semantic-channel-guides.md` for canonical channel topics and starter/pinned guidance copy;
- `docs/architecture/discord-memory-gateway.md` for hydration and writeback policy;
- `docs/architecture/discord-context-skill-packs.md` for prompt-pack references;
- `docs/architecture/discord-scoped-skills-registry.md` for `effective_skills`;
- `skills/discord-approval-gate/SKILL.md` for confirmation-required writes;
- `docs/adr/0001-runtime-boundary.md` for the boundary that keeps Gentle SDD as a backend, not the primary Discord runtime.

## Event envelope schema

| Field | Purpose |
| --- | --- |
| `origin_kind` | Source surface such as `discord-channel` or future control channel types. |
| `runtime_namespace` | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>`. |
| `routing_status` | `matched-route` or `unmapped-channel`. |
| `resolved_route` | Approved `project_slug` and `network_slug`, or `none`. |
| `normalized_channel_name` | Reviewable fake channel-name evidence. |
| `user_role` | Minimal fake operator role or capability hint. |

## Intent families

First-slice intent families are intentionally small:

| Family | Meaning | Default gate |
| --- | --- | --- |
| `planning_content` | Planning or content-shaping work that stays proposal-only in this slice. | `summary-only` |
| `sdd_dev_work` | Development/spec-heavy work that may be delegated to a Gentle SDD backend. | `summary-only` |
| `clarification_needed` | Ambiguous or unmapped input that must ask for route or intent clarification. | `needs-route` |

Future families may include `context_update`, `skill_update`, `memory_query`, or `github_operation`, but they are not modeled beyond mention in this first slice.

## Runner selection

Runner routing must stay configurable and explainable.

| Runner kind | Backend | Use when |
| --- | --- | --- |
| `content-planner` | `openclaw-skill-surface` | Context and skills point to bounded planning/content work. |
| `development-orchestrator` | `gentle-sdd` | Intent is `sdd_dev_work` and the runtime only models a delegated backend selection. |
| `clarification` | `response-only` | Route or intent is ambiguous and no durable read/write should continue. |

Gentle SDD is one runner/backend for `sdd_dev_work`. It is not the primary Discord orchestrator. The next contract for this backend is `docs/architecture/discord-gentle-sdd-handoff.md`.

## Permission and confirmation gates

The orchestrator must separate runner selection from persistence permission.

| Gate state | Meaning |
| --- | --- |
| `summary-only` | No approval needed; no writeback executes. |
| `approval-requested` | A write-like proposal needs the exact `approve write` confirmation path. |
| `needs-route` | No durable reads or writes until route/intent is clarified. |

Write-like outcomes must return through `docs/architecture/discord-memory-gateway.md` and use `skills/discord-approval-gate/SKILL.md` before any persistence.

## Execution metadata

Each orchestrated turn should leave reviewable metadata for the contract:

- origin envelope summary;
- selected managed channel route reference when persisted semantic metadata is available;
- selected channel guide reference;
- selected context pack reference;
- selected skill pack reference;
- intent family and confidence;
- selected runner/backend;
- permission gate state;
- prompt execution state (`none` in this slice);
- writeback policy classification.

## Historical anchors

This slice builds on historical runtime/orchestration anchors:

- #1 `research(runtime): verify Gentle-AI SDD inside dockerized OpenClaw`
- #7 `docs(process): define shared-artifact serialization procedure for Pi and OpenClaw SDD`
- #51 `ops(runtime): validate first local OpenClaw Engram pilot`
- #57 `ops(discord): validate private Discord route pilot`

## Non-goals

This contract does not:

- implement live Discord event handling;
- execute prompts or runners;
- execute Gentle SDD work from Discord;
- perform GitHub mutations;
- perform live Engram calls;
- bypass Memory Gateway writeback policy or `discord-approval-gate`;
- prove public Discord behavior, Buffer activity, publishing, or scheduling.

## Validation checklist

- [ ] Fixture uses fake/demo markers only.
- [ ] All scenarios carry `runtime_namespace` and route status.
- [ ] `sdd_dev_work` routes to `backend: gentle-sdd` only.
- [ ] Clarification fallback stays `response-only` and `reject` for writeback.
- [ ] Prompt execution remains `none` in every scenario.
- [ ] No raw Discord IDs, credential env names, live/prod claims, or GitHub mutation claims are introduced.
