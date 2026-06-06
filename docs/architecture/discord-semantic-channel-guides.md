# Discord Semantic Channel Guides

This contract defines a fake-first semantic channel guide catalog for planned Project Manager Discord scaffolding. It gives runtime scaffolding one canonical source for channel topics, starter/pinned guidance messages, example prompts, managed information, and non-goals before any live Discord category or channel creation is attempted.

This is a contract only. It does not prove live Discord scaffolding, live bot behavior, runtime enforcement, production credentials, prompt execution, durable writes, publishing, or scheduling. It also does not replace the existing `OpenClaw Global` reserved topology from `docs/architecture/discord-dynamic-context-namespaces.md` and `docs/architecture/discord-topology-reconciliation.md`.

## Quick path

1. Pick the guide scope: `global` or `project`.
2. Resolve the guide by `field_key` from the canonical catalog fixture.
3. Apply the catalog topic to the Discord channel topic field.
4. Post the starter message as the pin-ready guidance message.
5. Keep example prompts, managed information, and non-goals aligned with the same catalog entry.
6. Do not duplicate this copy in command handlers; runtime scaffolding should consume the catalog.

## Canonical catalog rules

| Rule | Requirement |
| --- | --- |
| Canonical source | `examples/discord-semantic-channel-guides.fake.yaml` is the reviewable source for Project Manager guide copy. |
| Topology compatibility | Existing `OpenClaw Global` reserved channels remain `identity`, `writing-style`, `operating-principles`, `boundaries`, `inheritance`, and `skills`; the `global-*` names below are planned Project Manager workspace guide surfaces, not replacements. |
| Scope separation | Global guides apply at workspace scope only. Project guides apply within one project category only. |
| Runtime consumption | Scaffolding and future command handlers resolve guide copy from the catalog by `scope` + `field_key`. |
| Topic length | Each guide defines one short Discord topic intended for the channel topic field. |
| Starter guidance | Each guide defines one longer starter/pinned message that can be posted and pinned. |
| Example prompts | Each guide includes example prompts that match the semantic field only. |
| Safety boundary | Guides stay fake-first and avoid live-readiness claims, real Discord IDs, secrets, or write bypasses. |

## Catalog schema

Each guide entry must define these fields:

| Field | Purpose |
| --- | --- |
| `field_key` | Stable semantic field such as `context` or `strategy`. |
| `scope` | `global` or `project`. |
| `channel_name` | The expected Discord channel name for scaffolding. |
| `topic` | Short Discord topic/description. |
| `starter_message` | Pin-ready starter guidance shown to users in the channel. |
| `example_prompts` | Representative prompts that fit the channel. |
| `managed_information` | What belongs in this channel. |
| `non_goals` | What should not be handled from this channel. |

Top-level catalog metadata must also declare:

- fake/demo safety markers;
- canonical consumption markers;
- source contracts for runtime scaffolding;
- topology compatibility markers for the existing `OpenClaw Global` reserved channels;
- no live/prod behavior claims.

## Global guide set

Global guides apply at workspace scope only and must not silently mutate one project from another. These guides are for the planned Project Manager workspace category from #134. They are compatible with, but do not rename or supersede, the existing `OpenClaw Global` governance category whose reserved channels remain `identity`, `writing-style`, `operating-principles`, `boundaries`, `inheritance`, and `skills`.

If a future implementation deploys both surfaces, topology reconciliation must map them explicitly by approved IDs and semantic metadata rather than inferring equivalence from names.

| Field key | Planned Project Manager channel | Primary use |
| --- | --- | --- |
| `context` | `global-context` | Shared workspace context, conventions, constraints, and quality rules. |
| `skills` | `global-skills` | Reusable global skills, defaults, and inheritance decisions. |
| `strategy` | `global-strategy` | Cross-project priorities, milestones, and direction. |
| `decisions` | `global-decisions` | Shared decisions, tradeoffs, and rationale. |
| `config` | `global-config` | Bot/workspace configuration notes and operator-visible settings. |

## Project guide set

Project guides apply within one project category only and must stay separate from global governance.

| Field key | Channel name | Primary use |
| --- | --- | --- |
| `context` | `context` | Project-specific context, assumptions, and boundaries. |
| `skills` | `skills` | Project-specific skills and approved overrides. |
| `strategy` | `strategy` | Project roadmap, slices, risks, and tradeoffs. |
| `tasks` | `tasks` | Actionable work items and implementation planning. |
| `decisions` | `decisions` | Project-local decisions and rationale. |
| `qa` | `qa` | Validation plans, manual checks, and release gates. |

## Runtime scaffolding consumption

Runtime scaffolding should treat the guide catalog as a lookup artifact, not as prose to retype.

Required consumption notes:

- resolve guides by `scope` + `field_key`;
- use `topic` for the Discord channel topic field;
- use `starter_message` as the pin-ready starter message;
- reuse `example_prompts`, `managed_information`, and `non_goals` when presenting help;
- do not duplicate starter/prompt copy in handlers or hardcode copy in multiple runtime paths.

## Non-goals

This contract does not:

- create live Discord categories or channels;
- implement runtime command handlers;
- prove live bot routing or prompt execution;
- bypass `skills/discord-approval-gate/SKILL.md` for write-like outcomes;
- introduce production credentials, real Discord IDs, raw transcripts, publishing, or scheduling.

## Validation checklist

- [ ] Global catalog entries exist for Project Manager fields `context`, `skills`, `strategy`, `decisions`, and `config` without replacing existing `OpenClaw Global` reserved channels.
- [ ] Project catalog entries exist for `context`, `skills`, `strategy`, `tasks`, `decisions`, and `qa`.
- [ ] Every guide entry defines `topic`, `starter_message`, `example_prompts`, `managed_information`, and `non_goals`.
- [ ] Global and project scopes stay clearly separated.
- [ ] Runtime scaffolding consumption points to this catalog instead of duplicating copy in handlers.
- [ ] No live/prod/write-ready claims or real Discord IDs are introduced.

## Related artifacts

| Artifact | Role |
| --- | --- |
| `examples/discord-semantic-channel-guides.fake.yaml` | Fake guide catalog consumed by scaffolding contracts. |
| `docs/architecture/discord-project-manager-global-init.md` | Fake `/project-manager init` contract that consumes the global guide entries. |
| `docs/architecture/discord-project-manager-project-create.md` | Fake `/project create` contract that consumes the project guide entries. |
| `examples/discord-project-manager-global-init.fake.yaml` | Fake init plan/result fixture for the global Project Manager category. |
| `examples/discord-project-manager-project-create.fake.yaml` | Fake project creation fixture for per-project categories. |
| `scripts/validate-discord-semantic-channel-guides.sh` | Static validator for this guide catalog. |
| `scripts/validate-discord-project-manager-global-init.sh` | Static validator for the global init contract and fixture. |
