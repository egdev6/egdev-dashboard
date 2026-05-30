# LinkedIn analytics snapshot schema

This note defines the contract-first fake LinkedIn analytics snapshot for issue #18.

## Quick path

1. Use `examples/linkedin-analytics-snapshot.fake.yaml` as the fake snapshot source.
2. Run `scripts/validate-linkedin-analytics-snapshot.sh`.
3. Confirm the snapshot stays fake/demo-only and does not claim live Buffer analytics ingestion.

## Why this path is fake-first

Issue #17 established that the reviewed public Buffer API docs do not expose read-only LinkedIn analytics metrics.

Because of that, this issue uses a fake snapshot contract instead of live Buffer calls. The goal is to define a stable normalization surface now, so later work can plug in an approved source without changing the public repo to depend on live credentials or undocumented API behavior.

## Normalized schema

| Field group | Purpose |
|---|---|
| `source` | States that the snapshot comes from a fake manual-export placeholder path and that `live_buffer_api: false`. |
| `snapshot_window` / `captured_at` | Defines when the snapshot claims to summarize performance. |
| `namespace_keys` | Anchors the snapshot to `content-ledger`, `network/linkedin`, and `strategy` namespaces. |
| `content_metrics` | Lists one normalized record per LinkedIn content item. |
| `normalization_notes` | Explains assumptions, joins, and formula boundaries. |
| `limitations` | Explicitly states what the fixture does not validate. |
| `metadata` | Marks the file `fake-demo` and `safe_for_repo`. |

Each `content_metrics` entry includes:

- `content_id`
- `planning_reference_id`
- `content_ledger_entry_id`
- `content_ledger_status`
- `source_link`
- `published_at`
- normalized metric fields:
  - `impressions`
  - `reactions`
  - `comments`
  - `shares`
  - `clicks`
  - `engagement_rate`
  - `followers_gained`

## Association model

The snapshot associates metrics with project/network/content-ledger state in three ways:

1. Global namespace keys point to:

   ```text
   egdev-dashboard/project/egdev/content-ledger
   egdev-dashboard/project/egdev/network/linkedin
   egdev-dashboard/project/egdev/strategy
   ```

2. Each item has a stable `content_ledger_entry_id` for later ledger joins.
3. Each item also keeps `planning_reference_id` so analytics can be traced back to the fake weekly planning slice when needed.

This gives later ingestion work a stable join surface without pretending that live LinkedIn analytics are already available.

## Validation

```bash
git diff --check
bash -n scripts/validate-linkedin-analytics-snapshot.sh
scripts/validate-linkedin-analytics-snapshot.sh
npx --yes yaml-lint examples/linkedin-analytics-snapshot.fake.yaml
npx --yes markdownlint-cli2@0.18.1 "**/*.md"
```

The validation script is intentionally local and static:

- no Engram writes;
- no Buffer API calls;
- no credentials;
- no network access.

## Limitations

This snapshot schema does **not** validate:

- live Buffer API analytics ingestion;
- LinkedIn OAuth or Buffer credentials;
- publishing or scheduling;
- real audience metrics;
- dashboard or reporting reads.

It is a fake/demo normalization contract only.
