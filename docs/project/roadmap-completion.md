# Roadmap completion baseline

The seeded `discord-project-manager` roadmap is complete. Issues #8-#23 are closed, PRs #24-#49 have been merged, and milestones M1-M7 have no remaining open issues.

This document marks the repository baseline after the first contract-first implementation pass. It does **not** claim production readiness.

## Quick path

1. Treat `main` as the completed roadmap baseline.
2. Run the safe local verification suite first: `bash scripts/run-safe-validation-suite.sh` (see `docs/operations/safe-validation-suite.md`).
3. Use this document to understand what is implemented versus still pending operational validation.
4. Start the next phase with runtime validation or a new approved roadmap slice.
5. Use `docs/operations/qa-acceptance-matrix.md` to plan QA evidence after AGENT verification is complete.
6. Before any baseline tag or release note, execute or explicitly defer #132 using `docs/operations/private-discord-manual-verification-guide.md`.

## Milestone outcomes

| Milestone | Outcome | Status |
|---|---|---|
| M1 Foundation | Repo, ADRs, OpenSpec config, Docker foundation, issue templates, and runtime boundary docs | Complete |
| M2 Memory MVP | Engram namespace contract plus fake local memory roundtrip validation for brand, ledger, and strategy | Complete |
| M3 Content skills | Brand/context, content-ledger, strategy, LinkedIn weekly, X queue, and on-demand brief contracts | Complete |
| M4 Discord operations | Channel routing, namespace mapping, and approval-response contracts | Complete |
| M5 Buffer analytics | Buffer API scope research plus fake LinkedIn/X analytics snapshot contracts | Complete |
| M6 Dashboard | Contract-first read models plus static read-only dashboard overview | Complete |
| M7 Hardening | CI, local developer tooling, data rules, shared-artifact procedure, and runtime incident runbook | Complete |

## Baseline guarantees

The completed roadmap provides:

- a Docker Compose foundation for OpenClaw, Engram Cloud, and Postgres;
- public-safe repository contracts and fake fixtures;
- local validators for core memory, analytics, read-model, and dashboard contracts;
- documented Discord routing and approval semantics;
- documented data-handling, shared-artifact, CI, developer tooling, and incident-response practices;
- a static read-only dashboard artifact over fake read models.

## Known limits

The baseline intentionally does **not** include:

- production-grade hosting or high-availability operations;
- live Discord bot configuration;
- confirmed live OpenClaw-to-Engram enrollment/sync behavior;
- live Buffer analytics ingestion;
- real LinkedIn/X analytics or private project data;
- a live dashboard API/server or JavaScript app framework;
- automated backup/restore tooling.

## Pre-release manual Discord verification gate

Track the operator-facing Discord rehearsal in #132 and the documentation/scaffolding clarification in #146 before creating any baseline tag or release note.

Use `docs/operations/private-discord-manual-verification-guide.md` as the execution guide and keep evidence sanitized. The checklist in #132 covers:

- local/private runtime startup and non-destructive shutdown;
- private non-production guild, channels, credentials, and explicit execution approval;
- no-op resolver diagnostic, plugin/runtime dry-run mode, or re-tested enforcement path before any private Discord message;
- `OpenClaw Global` governance/control category and channels;
- routed project/network channels such as `linkedin-egdev` and `x-egdev`;
- Project Manager managed global and per-project category/channel scaffolding that stays distinct from the reserved `OpenClaw Global` governance surface;
- intentional unmapped fallback channel;
- global context, category context, skills/packs, memory/context separation, matched route, unmapped fallback, and approval-response tests;
- sanitized pass/fail/blocked evidence with no real IDs, credentials, raw logs, transcripts, private payloads, or sensitive screenshots.

Until #132 is executed and reviewed, treat Discord-live-adjacent readiness as **gated**. The repository may still be described as an internal fake-first/local baseline, but not as a validated private Discord runtime.

## Recommended next phase

Choose one focused next phase before adding more feature work:

1. **Manual Discord verification gate**: execute or explicitly defer #132 using the private Discord manual verification guide, with #146 documenting the current private control and Project Manager scaffolding expectations.
2. **Runtime validation**: run the Docker stack privately, validate OpenClaw startup, Engram health, workspace skill sync, and safe shutdown.
3. **Private Discord pilot**: after runtime validation and #132 approval prerequisites, configure a private Discord test guild/channel with no durable writes until routing and approval behavior are confirmed through a no-op observation path.
4. **Dashboard/API stack decision**: decide whether the static dashboard remains enough or whether to introduce a real app/API surface.
5. **Analytics source decision**: identify an approved analytics source before attempting live LinkedIn/X metrics.

## Release note

A `v0.1.0` tag is appropriate only after the release owner either executes #132 or explicitly defers it in the release notes. The tag should mean: "internal fake-first/local baseline complete; private Discord manual verification is tracked separately unless #132 is completed."
