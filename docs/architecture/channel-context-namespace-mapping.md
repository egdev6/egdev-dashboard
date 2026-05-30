# Channel-context to namespace mapping

This document defines the deterministic resolver contract from Discord runtime channel context to Engram namespaces.

It is a mapping contract only. It does not prove live Discord bot routing, OpenClaw binding, or Engram Cloud sync.

## Quick path

1. Always derive runtime memory from raw Discord guild and channel IDs.
2. Normalize the channel display name and match it against the approved `<network-slug>-<project-slug>` route pattern.
3. Only when the route is matched may the runtime read durable project namespaces.
4. Unmapped channels stay in runtime-only fallback mode.
5. Route resolution does not authorize durable writes.

## Resolver inputs

| Field | Meaning |
|---|---|
| `guild_id` | Raw Discord guild ID from the runtime event. |
| `channel_id` | Raw Discord channel ID from the runtime event. |
| `normalized_channel_name` | Lowercase kebab-case channel display name after normalization. |
| `route_match` | Result of checking the approved route table/pattern. |

`project_slug` and `network_slug` are resolver outputs. They must be derived from the normalized channel name and approved route table, not supplied as trusted runtime inputs.

The approved route pattern for M4 is:

```text
<network-slug>-<project-slug>
```

See `docs/architecture/discord-channel-routing.md` for the allowed network slugs and naming rules.

## Resolver outputs

| Output | Meaning |
|---|---|
| `runtime_namespace` | Always `egdev-dashboard/runtime/discord/<guild-id>/<channel-id>`. |
| `resolved_route.project_slug` | Project slug derived from the approved route, or `none` for unmapped channels. |
| `resolved_route.network_slug` | Network slug derived from the approved route, or `none` for unmapped channels. |
| `durable_read_namespaces` | Approved project namespaces that the runtime may read after a successful route match. |
| `durable_write_candidates` | Namespaces that could receive durable writes later, still subject to human approval and workflow-specific rules. |
| `routing_status` | Resolver outcome such as `matched-route` or `unmapped-channel`. |

## Mapping rules

1. Read `guild_id` and `channel_id` from the runtime event.
2. Build runtime memory exactly as:

   ```text
   egdev-dashboard/runtime/discord/<guild-id>/<channel-id>
   ```

3. Normalize the channel display name to lowercase kebab-case.
4. Attempt an explicit route match against the approved pattern and supported network list.
5. If the route is matched, derive `resolved_route.project_slug` and `resolved_route.network_slug` from the approved route.
6. If both slugs are resolved, the runtime may read:

   ```text
   egdev-dashboard/project/<project-slug>/brand
   egdev-dashboard/project/<project-slug>/strategy
   egdev-dashboard/project/<project-slug>/content-ledger
   egdev-dashboard/project/<project-slug>/network/<network-slug>
   ```

7. Durable writes remain planned candidates only. A matched route does not authorize strategy, network, or content-ledger writes.
8. If the route is not matched, remain in runtime-only fallback mode.

## Matched route example

Fake/demo example:

| Field | Value |
|---|---|
| `guild_id` | `111111111111111111` |
| `channel_id` | `222222222222222222` |
| `normalized_channel_name` | `linkedin-egdev` |
| `route_match` | `matched` |
| `resolved_route.project_slug` | `egdev` |
| `resolved_route.network_slug` | `linkedin` |

Resolver result:

```text
routing_status: matched-route
runtime_namespace: egdev-dashboard/runtime/discord/111111111111111111/222222222222222222
resolved_route:
  project_slug: egdev
  network_slug: linkedin
durable_read_namespaces:
  brand_namespace_key: egdev-dashboard/project/egdev/brand
  strategy_namespace_key: egdev-dashboard/project/egdev/strategy
  content_ledger_namespace_key: egdev-dashboard/project/egdev/content-ledger
  network_namespace_key: egdev-dashboard/project/egdev/network/linkedin
durable_write_candidates:
  strategy_namespace_key: egdev-dashboard/project/egdev/strategy
  content_ledger_namespace_key: egdev-dashboard/project/egdev/content-ledger
  network_namespace_key: egdev-dashboard/project/egdev/network/linkedin
  write_mode: planned-only-until-approved
```

## Unmapped channel example

Fake/demo example:

| Field | Value |
|---|---|
| `guild_id` | `111111111111111111` |
| `channel_id` | `333333333333333333` |
| `normalized_channel_name` | `general` |
| `route_match` | `unmatched` |
| `resolved_route.project_slug` | `none` |
| `resolved_route.network_slug` | `none` |

Resolver result:

```text
routing_status: unmapped-channel
runtime_namespace: egdev-dashboard/runtime/discord/111111111111111111/333333333333333333
resolved_route:
  project_slug: none
  network_slug: none
durable_read_namespaces: none
durable_write_candidates:
  write_mode: runtime-only-fallback
  action: ask-human-for-route
```

Safe fallback rules:

- do not read durable brand, strategy, ledger, or network namespaces;
- do not write durable project namespaces;
- keep temporary notes channel-local under the runtime namespace only;
- ask a human operator to define or choose an approved route.

## Approval boundary

Route resolution only selects context. It does not approve actions.

Even for matched routes, still require explicit human approval before:

- writing project strategy memory;
- writing network-local planning memory;
- writing content-ledger entries;
- drafting final public copy;
- publishing or scheduling content.

## Privacy rules

- Keep real `guild_id` and `channel_id` values out of repo artifacts.
- Public examples must use placeholders or obvious fake/demo IDs only.
- Runtime namespaces always use raw IDs, never display channel names.
- Durable namespaces always use project and network slugs from ADR 0002.
