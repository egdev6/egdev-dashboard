---
name: content-ledger
description: "Track what was published, where it was published, and what follow-up context should persist."
license: MIT
---

# Content Ledger

Use this skill to record and inspect publish-history metadata for a project and network.

## Inputs

- project slug
- network
- content identifier or title
- publish date
- asset references
- outcome notes

## Behavior

1. Normalize a content entry into a small ledger record.
2. Preserve enough metadata to compare later performance or avoid duplicates.
3. Mark unknown fields explicitly instead of fabricating them.
4. Prefer Engram-backed persistence when the runtime provides it.
5. Use the ADR 0002 namespace contract: durable ledger state belongs under `egdev-dashboard/project/<project-slug>/content-ledger`, with network-specific overlays under `.../network/<network-slug>` when needed.

## Output shape

- project
- network
- content entry
- publish status
- asset references
- next follow-up action

## Safety rules

- Do not store real credentials or private exports in git.
- Do not infer analytics that were not measured.
- Keep examples fake unless the data is intentionally public.

## Memory contract

Follow `docs/adr/0002-engram-namespace-contract.md` for namespace families and promotion rules. Retention, update semantics, and analytics linkage can evolve later without changing the namespace root.
