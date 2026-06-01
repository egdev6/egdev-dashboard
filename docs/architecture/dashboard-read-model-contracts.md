# Dashboard read model contracts

This document defines the contract-first dashboard/API read models for issue #20.

This slice does **not** add a live server, package manager surface, API framework, or runtime memory adapter. It defines a reviewable public contract only.

## Quick path

1. Read `examples/dashboard-read-models.fake.yaml` for the fake normalized output shape.
2. Run `scripts/validate-dashboard-read-models.sh`.
3. Treat the result as a future read-only API surface, not a live implementation.

## Status

| Topic | Decision |
|---|---|
| Delivery mode | Contract-first docs + fake fixture + local validator |
| Runtime status | No live server in this slice |
| Mutation support | None |
| Data sources | Validated repo contracts and approved namespace families |
| Safety default | Normalized repo-safe summary fields only |

## Source namespaces

These read models summarize durable project namespaces from ADR 0002:

| Namespace | Purpose |
|---|---|
| `discord-project-manager/project/<project-slug>/brand` | Brand and audience context used for project-level summary fields |
| `discord-project-manager/project/<project-slug>/strategy` | Cross-network strategy summary fields |
| `discord-project-manager/project/<project-slug>/content-ledger` | Content status and publish-history summary fields |
| `discord-project-manager/project/<project-slug>/network/<network-slug>` | Network-level routing and planning overlays |

Runtime Discord memory stays outside this slice:

```text
discord-project-manager/runtime/discord/<guild-id>/<channel-id>
```

Unknown or unmapped runtime routes are excluded by default. This read-model contract only summarizes resolved project/network context.

## Read model boundaries

| Read model | Purpose | Source namespaces | Safe output focus |
|---|---|---|---|
| `project_overview` | One project-level summary | `brand`, `strategy`, `content-ledger`, approved network namespaces | project slug, known networks, summary status, safe counts |
| `network_overview` | One summary row per approved known network | `network/<network-slug>`, `content-ledger`, analytics snapshot contracts when present | network slug, routing status, content counts, analytics availability |
| `strategy_summary` | Project strategy snapshot for dashboard reads | `strategy` plus approved network overlays when needed | timeframe, approval state, counts, coverage |
| `content_ledger_summary` | Safe ledger totals and join status | `content-ledger` plus approved network overlays | status counts, known coverage, joinability notes |
| `analytics_snapshot_summary` | Safe analytics availability summary | normalized LinkedIn/X analytics snapshot contracts when present | availability, window dates, record counts, fake-source or unavailable status |

### Project overview

`project_overview` is the top-level read model for a single project. It may summarize:

- known network slugs;
- whether brand, strategy, ledger, and analytics contracts are available;
- safe aggregate counts;
- project-safe notes explaining demo coverage.

It must not expose raw memory payloads, secrets, or operational Discord identifiers.

### Network overview

`network_overview` is a filtered list of approved network summaries under the selected project.

Each entry may include:

- `network_slug`;
- route status for approved project/network mapping;
- safe content counts by status;
- latest known strategy or planning coverage;
- analytics snapshot availability and latest fake window.

### Strategy summary

`strategy_summary` exposes only normalized dashboard-safe fields, such as:

- active timeframe;
- approval status;
- goals, assumptions, review-checkpoint, and out-of-scope counts;
- which networks currently have strategy/planning coverage.

It must not expose raw draft strategy text, private notes, or approval transcripts by default.

### Content ledger summary

`content_ledger_summary` exposes safe status totals and coverage notes. It may include join status between ledger entries and analytics snapshot contracts, but it must not expose raw private asset paths, unpublished copy, or operational notes by default.

### Analytics snapshot summary

`analytics_snapshot_summary` summarizes whether normalized analytics snapshots are available for each approved network.

Safe fields include:

- `network_slug`;
- snapshot availability;
- latest snapshot window;
- normalized record counts;
- source status such as `fake-demo-only`.

It must not expose live provider tokens, raw provider payloads, or undocumented API details.

## Filtering rules

The future API surface uses deterministic filtering:

| Filter | Rule |
|---|---|
| `project_slug` | Required. Read models are always scoped to one approved project. |
| `network_slug` | Optional. When present, it must match a known approved network for the selected project. |
| Unknown network | Excluded by default. Do not silently expand to all networks. |
| Unmapped runtime route | Excluded by default. Runtime-only channels do not appear in dashboard reads until a route is resolved. |

For this repo slice, the demo project is `egdev`. The known network slugs follow the existing Discord routing contract: `linkedin`, `x`, `youtube`, `twitch`, and `stack-and-flow`. Analytics snapshot contracts currently exist only for `linkedin` and `x`; the other known networks are included as route-only summaries until future contracts are approved.

## Privacy and default exposure rules

Dashboard/API read models default to public-safe, normalized fields only.

Allowed by default:

- project and network slugs;
- approved namespace keys;
- safe counts and status summaries;
- fake/demo analytics availability;
- summary booleans and coverage markers.

Not allowed by default:

- secrets or credential values;
- raw private Engram memory;
- raw Discord guild/channel IDs;
- runtime transcripts or operator notes;
- unpublished private copy, private assets, or raw provider payloads.

If a future operational surface needs Discord IDs or private details, that must be documented separately as an approval-gated operational contract, not added silently to these public read models.

## Non-goals

This slice does **not** implement:

- mutation endpoints;
- publishing or scheduling;
- live Buffer calls;
- raw Engram browsing;
- runtime memory adapters;
- a dashboard UI or API server.

## Fixture and validation

Use:

- `examples/dashboard-read-models.fake.yaml`
- `scripts/validate-dashboard-read-models.sh`

Validation is intentionally local and static:

- no network access;
- no credentials;
- no runtime memory reads;
- no Engram writes.
