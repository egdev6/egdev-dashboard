# Discord routing runbook

Use this runbook when configuring or reviewing Discord channels for the OpenClaw runtime.

This is an operations contract only. It does not prove live Discord bot routing yet.

For pilot sequencing after #70-#74, use `docs/operations/discord-context-skill-pilot-roadmap.md`. The channel-first routing rules here remain a transport baseline/fallback, not the target workflow model.

## Quick path

1. Install the external OpenClaw Discord plugin before live validation.
2. Name channels with `<network-slug>-<project-slug>`.
3. Keep real guild and channel IDs outside the repo.
4. Route channel-local memory by raw Discord IDs.
5. Route durable project reads by approved project/network slugs.
6. Ask for human approval before durable project writes.
7. Load `skills/discord-approval-gate/SKILL.md` for Discord write-like intents before any persistence.
8. Use `docs/operations/discord-approval-responses.md` for approval prompts and audit trail requirements.
9. Use `docs/architecture/channel-context-namespace-mapping.md` and `examples/discord-channel-context.fake.yaml` as the resolver reference and fake fixture.
10. Use `docs/architecture/discord-topology-reconciliation.md` and `examples/discord-topology-reconciliation.fake.yaml` when validating category/channel discovery before provisioning.
11. Use `docs/architecture/discord-context-namespace-provisioning.md` and `examples/discord-context-provisioning.fake.yaml` when reviewing approved draft context artifacts.

## Naming examples

| Channel name | Reads durable context from |
|---|---|
| `linkedin-egdev` | `discord-project-manager/project/egdev/network/linkedin` |
| `x-egdev` | `discord-project-manager/project/egdev/network/x` |
| `youtube-egdev` | `discord-project-manager/project/egdev/network/youtube` |
| `twitch-egdev` | `discord-project-manager/project/egdev/network/twitch` |
| `stack-and-flow-egdev` | `discord-project-manager/project/egdev/network/stack-and-flow` |

All of these may also read shared project context:

```text
discord-project-manager/project/egdev/brand
discord-project-manager/project/egdev/strategy
discord-project-manager/project/egdev/content-ledger
```

The canonical resolver contract lives in `docs/architecture/channel-context-namespace-mapping.md`, and `examples/discord-channel-context.fake.yaml` provides fake matched/unmapped fixtures.

## Runtime prerequisite

Live Discord validation requires the external OpenClaw Discord plugin. If `docker compose exec openclaw openclaw config get plugins.entries.discord` reports `plugin not installed: discord`, install it before debugging bot tokens, guild IDs, or channel names:

```bash
docker compose exec openclaw openclaw plugins install @openclaw/discord
docker compose restart openclaw
```

A valid `channels.discord` config without this plugin leaves the bot offline and produces no useful Discord route validation.

## Routing checklist

For each Discord message:

- [ ] Capture runtime guild ID and channel ID from the event.
- [ ] Build runtime namespace as `discord-project-manager/runtime/discord/<guild-id>/<channel-id>`.
- [ ] Normalize the channel display name to lowercase kebab-case.
- [ ] Match the channel name to an allowed `<network-slug>-<project-slug>` route.
- [ ] If matched, read relevant durable project context.
- [ ] If unmatched, stay in runtime-only fallback mode.
- [ ] Require human approval before durable project memory or ledger writes.

## Unknown channel behavior

Unknown channels are safe by default:

- use response-only fallback unless the runtime provides explicitly non-durable scratch state;
- do not read project brand, strategy, ledger, or network memory;
- do not write durable project memory or workspace files;
- ask the operator to select or create an approved route;
- keep temporary notes out of persistent channel-local runtime memory until a route and write are approved.

Example response shape:

```text
I cannot map this channel to a project/network yet.
Current runtime context: discord-project-manager/runtime/discord/<guild-id>/<channel-id>
Choose an approved route before I read or write durable project memory.
```

## Approval boundary

Routing can select context. It cannot approve actions.

Still require explicit human approval before:

- writing project strategy memory;
- writing network-local planning memory;
- writing content-ledger entries;
- drafting final public copy;
- publishing or scheduling content.

Use `docs/operations/discord-approval-responses.md` for the response states, approval prompt shape, and runtime audit trail fields.

## Local validation

For this documentation-only routing slice, validate with:

```bash
git diff --check
npx --yes yaml-lint examples/discord-channel-context.fake.yaml examples/discord-topology-reconciliation.fake.yaml examples/discord-context-provisioning.fake.yaml examples/discord-approval-gate.fake.yaml examples/discord-runtime-orchestrator.fake.yaml examples/discord-gentle-sdd-handoff.fake.yaml examples/openclaw-global-brand-context-refresh.fake.yaml examples/content-ledger-utility-flow.fake.yaml examples/category-strategy-planning-flow.fake.yaml
bash scripts/validate-discord-topology-reconciliation.sh
bash scripts/validate-discord-context-provisioning.sh
bash scripts/validate-discord-approval-gate.sh
bash scripts/validate-discord-runtime-orchestrator.sh
bash scripts/validate-discord-gentle-sdd-handoff.sh
bash scripts/validate-openclaw-global-brand-context-refresh.sh
bash scripts/validate-content-ledger-utility-flow.sh
bash scripts/validate-category-strategy-planning-flow.sh
npx --yes markdownlint-cli2@0.18.1 "**/*.md"
```

Live validation belongs to a later Discord/OpenClaw runtime issue.
