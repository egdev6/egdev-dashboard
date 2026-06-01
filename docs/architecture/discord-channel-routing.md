# Discord channel routing conventions

This document defines the M4 routing convention for Discord channels that reach the OpenClaw runtime.

It is a routing contract only. It does not validate a live Discord bot, OpenClaw channel binding, or Engram Cloud sync.

For the next dynamic category-scoped context model, see `docs/architecture/discord-dynamic-context-namespaces.md`. The static channel convention below remains a compatibility baseline and fallback.

## Goals

- Map Discord channels deterministically to project and network context.
- Keep runtime Discord memory separate from durable project memory.
- Avoid putting real guild or channel IDs in public repo artifacts.
- Provide safe fallback behavior for unknown channels.

## Channel naming convention

Use lowercase kebab-case channel names:

```text
<network-slug>-<project-slug>
```

Canonical examples:

| Discord channel name | Project | Network | Durable network namespace |
|---|---|---|---|
| `linkedin-egdev` | `egdev` | `linkedin` | `discord-project-manager/project/egdev/network/linkedin` |
| `x-egdev` | `egdev` | `x` | `discord-project-manager/project/egdev/network/x` |
| `youtube-egdev` | `egdev` | `youtube` | `discord-project-manager/project/egdev/network/youtube` |
| `twitch-egdev` | `egdev` | `twitch` | `discord-project-manager/project/egdev/network/twitch` |
| `stack-and-flow-egdev` | `egdev` | `stack-and-flow` | `discord-project-manager/project/egdev/network/stack-and-flow` |

Supported network slugs for M4 routing:

- `linkedin`
- `x`
- `youtube`
- `twitch`
- `stack-and-flow`

The project slug must use the same lowercase kebab-case convention as ADR 0002.

## Runtime and durable namespaces

Every routed Discord message has two different namespace families:

| Namespace family | Example | Purpose |
|---|---|---|
| Runtime channel memory | `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` | Channel-local operational context, summaries, and transient coordination. |
| Durable project memory | `discord-project-manager/project/egdev/network/linkedin` | Approved reusable project/network context. |

A channel name may determine which durable project/network context is relevant, but the channel-local runtime memory must still use the raw Discord IDs from ADR 0002.

Never use display channel names as runtime namespace IDs.

## Routing algorithm

1. Read the Discord guild ID, channel ID, and display channel name from the runtime event.
2. Always derive runtime memory as:

   ```text
   discord-project-manager/runtime/discord/<guild-id>/<channel-id>
   ```

3. Normalize the display channel name to lowercase kebab-case.
4. Match the normalized name against the explicit allowlist pattern:

   ```text
   <network-slug>-<project-slug>
   ```

5. If the network slug is supported and the project slug is known, route durable reads to:

   ```text
   discord-project-manager/project/<project-slug>/brand
   discord-project-manager/project/<project-slug>/strategy
   discord-project-manager/project/<project-slug>/content-ledger
   discord-project-manager/project/<project-slug>/network/<network-slug>
   ```

6. Durable writes remain approval-gated. Runtime channel routing alone does not authorize project memory writes.

## Unknown channel fallback

If the channel cannot be mapped deterministically:

1. Use only the runtime namespace:

   ```text
   discord-project-manager/runtime/discord/<guild-id>/<channel-id>
   ```

2. Do not read or write durable project namespaces.
3. Ask a human operator to choose the intended project/network mapping.
4. Keep any temporary notes channel-local until the mapping is approved and promoted to repo configuration or docs.

Unknown channels must not silently default to `egdev`, `linkedin`, or any other project/network.

## Privacy rules

- Real guild IDs and channel IDs are private by default.
- Public docs may use placeholders such as `<guild-id>` and `<channel-id>` or obvious fake/demo IDs such as repeated `111111111111111111` values.
- Channel display names are not secrets by themselves, but public examples must remain fake/demo.
- Do not commit Discord exports, transcripts, screenshots, or runtime state.

See `docs/security/data-handling.md` for the broader data handling rules.
