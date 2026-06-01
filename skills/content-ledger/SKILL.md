---
name: content-ledger
description: "Track what was published, where it was published, and what follow-up context should persist."
license: MIT
---

# Content Ledger

Use this skill to normalize publish-history facts for one project and one network without inventing analytics or storing private exports in git.

This is a skill contract, not a live analytics or publishing integration.

## Inputs

Required inputs:

- `project_slug`
- `network_slug`
- `content_id_or_title`
- `publish_status`
- `publish_date` or `unknown`
- `asset_references` or `none`

Optional inputs:

- `campaign`
- `source_link`
- `follow_up_notes`
- `measured_outcomes`

## Behavior

1. Normalize one content record at a time.
2. Preserve enough detail to avoid duplicates and support later analytics joins.
3. Mark unknown values explicitly instead of fabricating them.
4. Keep reusable ledger structure separate from network-local working notes.
5. Use only fake/demo values in repository-facing examples.
6. Follow ADR 0002 for all namespace references.

## Output shape

Return a YAML-like structure similar to this:

```yaml
project: <project-slug>
network: <network-slug>
content_entry:
  id: <stable-id-or-title>
  status: <draft|queued|published|archived>
  published_at: <date-or-unknown>
  assets:
    - <asset-reference>
  source_link: <url-or-none>
  measured_outcomes:
    - metric: <name>
      value: <value-or-unknown>
follow_up:
  action: <next-step>
  notes:
    - <note>
```

## Memory behavior

### Read candidates

- `discord-project-manager/project/<project-slug>/content-ledger`
- `discord-project-manager/project/<project-slug>/network/<network-slug>`
- approved repo artifacts that define ledger conventions or identifiers

### Write candidates

- durable ledger state under `discord-project-manager/project/<project-slug>/content-ledger`
- network-local overlays under `discord-project-manager/project/<project-slug>/network/<network-slug>` when queue state or temporary workflow notes are needed

### Approval gate

Do not write a new durable ledger entry or modify an existing one until a human confirms that the content identity and status are correct.

### Namespace target

Use ADR 0002 exactly:

- `discord-project-manager/project/<project-slug>/content-ledger`
- `discord-project-manager/project/<project-slug>/network/<network-slug>`

Canonical ADR examples that this skill may mirror when using fake/demo values:

- `discord-project-manager/project/egdev/content-ledger`
- `discord-project-manager/project/egdev/network/x`

### Promotion to repo artifact

Promote ledger conventions, identifier rules, and reusable workflow behavior into repo artifacts when they become review-facing or implementation-critical. Raw operational entries may remain in Engram until they are summarized.

## Safety rules

- Do not invent analytics that were not measured.
- Do not store credentials, private exports, or secrets in the ledger contract.
- Do not use `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` for durable publish history.
- Keep examples fake unless the source is intentionally public and approved.

## Demo example (fake)

```yaml
project: egdev
network: x
content_entry:
  id: x-post-001-demo
  status: published
  published_at: 2026-05-30
  assets:
    - asset://demo/cover-001
  source_link: https://example.invalid/posts/x-post-001-demo
  measured_outcomes:
    - metric: impressions
      value: unknown
follow_up:
  action: compare against future X queue posts after analytics validation
  notes:
    - fake demo entry for contract review only
```

This example is fake/demo data only and must not be treated as real publish history.
