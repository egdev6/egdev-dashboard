# OpenClaw Global channel guides

This contract defines a fake-first guide catalog for the reserved `OpenClaw Global` governance/control category. It gives one canonical source for Discord channel topics/descriptions and pin-ready starter guidance for the six reserved control channels before any live category creation, topic update, or starter-message post is attempted.

This is a contract only. It does not prove live Discord category creation, live bot behavior, runtime enforcement, production credentials, prompt execution, durable writes, publishing, or scheduling.

It is also distinct from the separate Project Manager managed global surface. `OpenClaw Global` keeps reserved governance/control channels such as `identity` and `boundaries`, while Project Manager uses managed `global-*` channels such as `global-context` and `global-skills`.

## Quick path

1. Create or review the reserved `OpenClaw Global` category only.
2. Resolve the guide entry by `control_channel` from `examples/openclaw-global-channel-guides.fake.yaml`.
3. Show the exact `topic` and `starter_message` as a proposal preview before any Discord write.
4. Require the exact approval phrase `approve write` before creating channels, updating channel topics, or posting starter guidance.
5. Apply the topic to the Discord channel topic field only after approval.
6. Post the starter message as the pin-ready first message only after approval.
7. Keep this control surface separate from Project Manager managed `global-context`, `global-skills`, `global-strategy`, `global-decisions`, and `global-config`.

## Canonical catalog rules

| Rule | Requirement |
| --- | --- |
| Canonical source | `examples/openclaw-global-channel-guides.fake.yaml` is the reviewable source for reserved control-channel copy. |
| Reserved topology only | The guide catalog covers exactly `identity`, `writing-style`, `operating-principles`, `boundaries`, `inheritance`, and `skills`. |
| Distinct from Project Manager | These guides do not define or replace Project Manager `global-*` managed channels. |
| Topic length | Each guide defines one short topic intended for the Discord channel topic field. |
| Starter guidance | Each guide defines one longer pin-ready starter message for the first guidance post. |
| Proposal-first flow | Channel creation, topic changes, and starter-message updates must be previewed before any Discord write. |
| Approval gate | The exact phrase `approve write` is required before any Discord channel write or copy update. |
| Route boundary | These control channels are governance surfaces, not route-matched managed Project Manager channels. |
| Safety boundary | Guides stay fake-first and avoid real Discord IDs, secrets, live/prod claims, or write-bypass instructions. |

## Catalog schema

Each guide entry must define these fields:

| Field | Purpose |
| --- | --- |
| `control_channel` | Stable reserved control-channel key. |
| `channel_name` | Expected Discord channel name. |
| `topic` | Short Discord topic/description. |
| `starter_message` | Pin-ready first guidance message. |
| `example_prompts` | Representative proposal-first prompts for that control area. |
| `managed_information` | What belongs in the channel. |
| `non_goals` | What must stay out of the channel. |
| `proposal_policy` | Proposal-preview rule for Discord-visible changes. |
| `write_policy` | Approval rule for channel creation/copy writes. |

Top-level catalog metadata must also declare:

- fake/demo safety markers;
- proposal-first and approval-gated markers;
- the reserved `OpenClaw Global` category name;
- the separate Project Manager managed global channels;
- no live/prod behavior claims.

## Reserved control guide set

Use the following topics and starter-guidance expectations for the six reserved channels:

| Channel | Topic | Starter guidance expectation |
| --- | --- | --- |
| `identity` | `Stable identity, positioning, and who this workspace is for.` | Explain who the operator/workspace is, what it does, and which identity statements may later be inherited only by explicit approval. |
| `writing-style` | `Voice, tone, and reusable writing guidance.` | Keep reusable tone, style constraints, and approved examples reviewable; do not treat draft notes as automatic global policy. |
| `operating-principles` | `Review rules, quality bars, and collaboration expectations.` | Capture cross-category working rules, quality expectations, and review principles that other categories may opt into explicitly. |
| `boundaries` | `Privacy, safety, publishing limits, and no-go constraints.` | Make privacy limits, disallowed actions, and publishing boundaries explicit before any richer runtime behavior is tested. |
| `inheritance` | `Explicit opt-in rules for what other categories inherit.` | Review which categories inherit which global context or skills and keep automatic inheritance disabled by default. |
| `skills` | `Global reusable skills, defaults, and override policy.` | Explain which reusable skills are globally available, which are defaults only, and how overrides stay reviewable and approval-gated. |

## Proposal-first operator flow

Use one proposal-first flow for both structure and descriptive copy:

1. Propose the `OpenClaw Global` category and the six reserved channels.
2. Propose the topic and starter guidance for one channel or a bounded batch of channels.
3. Preview the exact topic text and starter message that would be applied.
4. Allow `revise` or `reject` without creating channels, changing topics, or posting starter copy.
5. Require the exact phrase `approve write` before any Discord-visible change.
6. Keep channel-copy updates scoped to `OpenClaw Global`; do not create, rename, or imply equivalence with Project Manager `global-*` channels.

Example prompts:

- `Propose, but do not execute yet, the OpenClaw Global topic and starter guidance for identity and boundaries.`
- `Revise the writing-style starter guidance to emphasize concise technical tone, but do not write anything yet.`
- `approve write` followed by the exact approved copy scope.

Before `approve write`, do not perform live Discord/OpenClaw writes, durable memory writes, repo writes, GitHub mutations, publishing, scheduling, or Buffer activity.

## Distinction from Project Manager managed channels

Keep these surfaces separate:

| Surface | Channels | Role |
| --- | --- | --- |
| Reserved governance/control | `identity`, `writing-style`, `operating-principles`, `boundaries`, `inheritance`, `skills` | Root-level governance, inheritance review, and reusable skill policy. |
| Project Manager managed global | `global-context`, `global-skills`, `global-strategy`, `global-decisions`, `global-config` | Managed workspace scaffolding for Project Manager routing and operator-facing help. |

The reserved control copy from this contract is operator-facing guidance only. It must not replace the persisted semantic metadata contract for managed Project Manager routing.

## Non-goals

This contract does not:

- create live Discord categories or channels;
- implement runtime command handlers;
- prove live bot routing or prompt execution;
- bypass `skills/discord-approval-gate/SKILL.md` for write-like outcomes;
- introduce production credentials, real Discord IDs, raw transcripts, publishing, or scheduling;
- redefine Project Manager `global-*` channels.

## Validation checklist

- [ ] All six reserved control channels define a topic and starter guidance expectation.
- [ ] The catalog stays distinct from Project Manager managed `global-*` channels.
- [ ] Topic/starter guidance changes remain proposal-first and approval-gated.
- [ ] No real Discord IDs, secrets, live/prod claims, or write-bypass instructions are introduced.

## Related artifacts

| Artifact | Role |
| --- | --- |
| `examples/openclaw-global-channel-guides.fake.yaml` | Fake guide catalog consumed by review and validators. |
| `docs/operations/private-discord-manual-verification-guide.md` | Private operator guide that applies this control-channel copy contract. |
| `docs/operations/discord-routing.md` | Routing/operator runbook that distinguishes reserved control channels from managed Project Manager guides. |
| `docs/architecture/discord-semantic-channel-guides.md` | Canonical fake guide catalog for managed Project Manager `global-*` and project channels. |
| `scripts/validate-openclaw-global-channel-guides.sh` | Static validator for this guide catalog and related docs. |
