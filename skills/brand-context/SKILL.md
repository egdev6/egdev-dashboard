---
name: brand-context
description: "Capture and summarize project brand context for a social channel without storing secrets in git."
license: MIT
---

# Brand Context

Use this skill to structure a project's public-facing brand context before deeper content planning exists.

## Inputs

- project slug
- network or channel
- brand voice notes
- audience notes
- positioning notes
- approved constraints

## Behavior

1. Ask for missing brand facts instead of inventing them.
2. Summarize the current brand context in a small, reviewable structure.
3. Prefer saving durable operational context to Engram when that runtime is available.
4. Use the ADR 0002 namespace contract: store project-wide brand memory under `egdev-dashboard/project/<project-slug>/brand` and network-specific context under `.../network/<network-slug>`.
5. Keep repository-facing examples sanitized and generic.

## Output shape

- project
- network
- voice
- audience
- positioning
- do / avoid guidance
- open questions

## Safety rules

- Do not expose tokens, credentials, or private customer data.
- Do not claim persistent memory was updated unless the runtime actually saved it.
- Do not overwrite shared planning artifacts without approval.

## Memory contract

Follow `docs/adr/0002-engram-namespace-contract.md` for namespace families and promotion rules. Keep serialization small and reviewable; do not invent extra namespace families for brand context.
