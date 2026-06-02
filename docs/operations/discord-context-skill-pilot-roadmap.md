# Discord context/skill pilot roadmap

This roadmap preserves the open Discord workflow issues while moving planning from channel-first flows to context/skill pilots. It is a docs-first migration guide after #70-#74, not a live runtime implementation plan.

## Quick path

1. Keep #57 as the private transport/routing validation anchor only.
2. Use #70-#74 as the contract foundation for every pilot below.
3. Reframe #61-#65 around `OpenClaw Global`, category-local context, Context Pack + Skill Pack resolution, and approval-gated writebacks.
4. Treat `docs/architecture/discord-channel-routing.md` as a baseline/fallback legacy reference for this roadmap, not the target routing model.

## Migration map

| Issue | Pilot role | Scope | Dependent contracts | First artifact |
|---|---|---|---|---|
| #57 | Private transport/routing anchor | Validate route resolution and approval boundaries without defining workflow semantics. | #57, #70, #71 | `docs/operations/discord-routing.md` |
| #61 | `OpenClaw Global` context refresh pilot | Identity, writing style, boundaries, inheritance, and global context refresh without duplicating the `brand-context` contract. | #70, #71, #72 | `docs/operations/openclaw-global-brand-context-refresh.md` |
| #62 | Ledger utility pilot | Category/channel ledger updates with `discord-approval-gate`; keep runtime notes separate from durable ledger entries. | #57, #70, #71, #72, #73, #74, #75 | `docs/operations/content-ledger-utility-flow.md` |
| #63 | Category strategy pilot | Strategy planning using approved global/category context, not an isolated fixed-channel flow. | #57, #61, #62, #70, #71, #72, #73, #74, #75 | `docs/operations/category-strategy-planning-flow.md` |
| #64 | `egdev-linkedin` operational pilot | LinkedIn-local planning using inherited globals plus resolved Context Pack + Skill Pack. | #57, #61, #62, #63, #70, #71, #72, #73, #74, #75 | `docs/operations/linkedin-weekly-planning-flow.md` |
| #65 | Multi-network brief pilot | On-demand brief work driven by pack resolution, intent, and approval policy instead of fixed channel-to-skill binding. | #57, #61, #62, #63, #64, #70, #71, #72, #73, #74, #75 | `docs/operations/on-demand-brief-flow.md` |

## Pilot order and success criteria

| Order | Issue | Success criteria |
|---|---|---|
| 1 | #57 | Private routing remains the transport anchor; no workflow ownership is added back into channel naming. |
| 2 | #61 | `OpenClaw Global` ownership is explicit, inherited context stays opt-in, and no new global durable writes bypass approval. |
| 3 | #62 | Ledger proposals stay approval-gated and durable ledger entries are not polluted with runtime-only notes. |
| 4 | #63 | Strategy planning consumes approved context and produces reviewable proposals without assuming a fixed Discord channel owns the strategy flow. |
| 5 | #64 | `egdev-linkedin` is documented as a category-local pilot using inherited globals plus LinkedIn-specific context and skills. |
| 6 | #65 | On-demand briefs are routed by resolved Context Pack + Skill Pack + intent, with Gentle SDD remaining optional backend-only where `sdd_dev_work` applies and all saves staying approval-gated. |

## Legacy baseline

Use `docs/architecture/discord-channel-routing.md` only as the M4 baseline/fallback for deterministic `<network-slug>-<project-slug>` channel routing.

For this roadmap, new work should prefer:

```text
category/channel origin -> context pack -> skill pack -> intent -> runner
```

Avoid reintroducing designs that assume one Discord channel permanently owns exactly one workflow or one skill.

## Non-goals

This roadmap does not:

- implement live Discord execution;
- provision runtime services or plugins;
- automate GitHub issue mutations;
- publish, schedule, or trigger Buffer activity;
- introduce production credentials or live durable writes;
- redefine the closed contracts from #70-#74.

## Review path

1. Review the migration map table first.
2. Confirm that #57 stays transport-only.
3. Confirm that #61-#65 now map to global/category/pack-based pilots.
4. Confirm that channel-first routing is treated as legacy/fallback, not the target model.

## Next step

Use this roadmap when updating or implementing #61-#65 so each slice stays aligned with:

- `docs/architecture/discord-dynamic-context-namespaces.md`
- `docs/architecture/discord-scoped-skills-registry.md`
- `docs/architecture/discord-context-skill-packs.md`
- `docs/architecture/discord-runtime-orchestrator.md`
- `docs/architecture/discord-gentle-sdd-handoff.md`
