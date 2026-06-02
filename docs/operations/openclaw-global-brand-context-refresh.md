# OpenClaw Global brand context refresh

This runbook defines the fake-first `OpenClaw Global` brand context refresh pilot for issue #61. It reuses `skills/brand-context/SKILL.md` as the summarization contract, routes any global governance writeback through `docs/architecture/discord-memory-gateway.md`, and keeps #57 as a transport/routing anchor only.

## Quick path

1. Capture fake, review-safe input for one or more `OpenClaw Global` control areas.
2. Draft the summary with `skills/brand-context/SKILL.md` before any write.
3. Show explicit inheritance proposals plus a derived Context Pack / Skill Pack preview.
4. Return a `confirmation-required` writeback proposal with the exact `approve write` gate.
5. Keep `revise` and `reject` outcomes runtime-local and audit-only.

## Control areas

| Control area | Purpose | Inheritance rule |
| --- | --- | --- |
| `identity` | Stable project identity and positioning. | Explicit opt-in only. |
| `writing-style` | Voice, tone, and reusable style guidance. | Explicit opt-in only. |
| `operating-principles` | Review, quality, and collaboration rules. | Explicit opt-in only. |
| `boundaries` | Privacy, safety, publishing, and no-go constraints. | Explicit opt-in only. |
| `inheritance` | Which categories/networks inherit global context and skills. | Must never be automatic. |

`OpenClaw Global` is a reserved control category, not a native Discord parent layer. Use `docs/architecture/discord-dynamic-context-namespaces.md` for the architecture contract.

## Allowed inputs and privacy boundary

Allowed fake/demo input may include:

- `voice_notes`
- `audience_notes`
- `positioning_notes`
- `approved_constraints`
- `boundaries`
- approved examples written with fake names and fake URLs

Do not include raw Discord transcripts, real guild/channel IDs, production credentials, private customer names, exports, or unsanitized logs. Follow `docs/security/data-handling.md` exactly.

## Draft-before-write flow

| Step | Decision |
| --- | --- |
| 1. Collect control input | Limit input to fake/demo notes for `identity`, `writing-style`, `operating-principles`, `boundaries`, or `inheritance`. |
| 2. Summarize | Use `skills/brand-context/SKILL.md` to produce a short reviewable draft. |
| 3. Propose inheritance | Show which categories/networks opt in to which global control areas. No automatic inheritance. |
| 4. Preview packs | Show a derived Context Pack / Skill Pack proposal with `brand-context` as `global-inherited` and `discord-approval-gate` as mandatory. |
| 5. Gate writeback | Route the proposal through `docs/architecture/discord-memory-gateway.md` as `confirmation-required`. |

Expected operator responses:

- `approve write`
- `revise: <instruction>`
- `reject`

Before `approve write`, do not perform live Engram writes, durable memory writes, repo writes, GitHub mutations, publishing, scheduling, or Buffer activity.

## Inheritance and writeback policy

Use explicit opt-in inheritance only. Example: `egdev-linkedin` may inherit `identity`, `writing-style`, and `operating-principles`, while category-local audience or campaign context stays outside the global refresh.

Global identity, style, principle, and boundary changes are governed as `discord/writeback/global-governance` proposals. The Memory Gateway must classify them as `confirmation-required`, show the runtime audit namespace `discord-project-manager/runtime/discord/<guild-id>/<channel-id>`, and require `skills/discord-approval-gate/SKILL.md` with the exact phrase `approve write` before persistence.

Rejected or revised drafts remain runtime-local/audit-only. They must not persist raw transcripts or durable brand memory.

## Non-goals

This pilot does not:

- implement live Discord execution;
- perform live Engram or other durable writes;
- provision runtime services or plugins;
- introduce GitHub mutations;
- persist raw transcripts;
- use production credentials;
- publish, schedule, or trigger Buffer activity.

## Related contracts

- #57 transport/routing anchor only
- #70 scoped Discord skills registry
- #71 Discord Memory Gateway
- #72 Discord Context Pack and Skill Pack schemas
- #75 context/skill pilot roadmap
- `skills/brand-context/SKILL.md`
- `skills/discord-approval-gate/SKILL.md`
- `docs/architecture/discord-context-skill-packs.md`
- `docs/security/data-handling.md`
