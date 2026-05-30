# Discord routing runbook

Use this runbook when configuring or reviewing Discord channels for the OpenClaw runtime.

This is an operations contract only. It does not prove live Discord bot routing yet.

## Quick path

1. Name channels with `<network-slug>-<project-slug>`.
2. Keep real guild and channel IDs outside the repo.
3. Route channel-local memory by raw Discord IDs.
4. Route durable project reads by approved project/network slugs.
5. Ask for human approval before durable project writes.

## Naming examples

| Channel name | Reads durable context from |
|---|---|
| `linkedin-egdev` | `egdev-dashboard/project/egdev/network/linkedin` |
| `x-egdev` | `egdev-dashboard/project/egdev/network/x` |
| `youtube-egdev` | `egdev-dashboard/project/egdev/network/youtube` |
| `twitch-egdev` | `egdev-dashboard/project/egdev/network/twitch` |
| `stack-and-flow-egdev` | `egdev-dashboard/project/egdev/network/stack-and-flow` |

All of these may also read shared project context:

```text
egdev-dashboard/project/egdev/brand
egdev-dashboard/project/egdev/strategy
egdev-dashboard/project/egdev/content-ledger
```

## Routing checklist

For each Discord message:

- [ ] Capture runtime guild ID and channel ID from the event.
- [ ] Build runtime namespace as `egdev-dashboard/runtime/discord/<guild-id>/<channel-id>`.
- [ ] Normalize the channel display name to lowercase kebab-case.
- [ ] Match the channel name to an allowed `<network-slug>-<project-slug>` route.
- [ ] If matched, read relevant durable project context.
- [ ] If unmatched, stay in runtime-only fallback mode.
- [ ] Require human approval before durable project memory or ledger writes.

## Unknown channel behavior

Unknown channels are safe by default:

- use runtime Discord memory only;
- do not read project brand, strategy, ledger, or network memory;
- do not write durable project memory;
- ask the operator to select or create an approved route;
- keep temporary notes in channel-local runtime memory until approved.

Example response shape:

```text
I cannot map this channel to a project/network yet.
Current runtime context: egdev-dashboard/runtime/discord/<guild-id>/<channel-id>
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

## Local validation

For this documentation-only routing slice, validate with:

```bash
git diff --check
npx --yes markdownlint-cli2@0.18.1 "**/*.md"
```

Live validation belongs to a later Discord/OpenClaw runtime issue.
