# Roadmap completion baseline

The seeded `egdev-dashboard` roadmap is complete. Issues #8-#23 are closed, PRs #24-#49 have been merged, and milestones M1-M7 have no remaining open issues.

This document marks the repository baseline after the first contract-first implementation pass. It does **not** claim production readiness.

## Quick path

1. Treat `main` as the completed roadmap baseline.
2. Use this document to understand what is implemented versus still pending operational validation.
3. Start the next phase with runtime validation or a new approved roadmap slice.

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

## Recommended next phase

Choose one focused next phase before adding more feature work:

1. **Runtime validation**: run the Docker stack privately, validate OpenClaw startup, Engram health, workspace skill sync, and safe shutdown.
2. **Live Discord pilot**: after runtime validation, configure a private Discord test guild/channel with no durable writes until routing is confirmed.
3. **Dashboard/API stack decision**: decide whether the static dashboard remains enough or whether to introduce a real app/API surface.
4. **Analytics source decision**: identify an approved analytics source before attempting live LinkedIn/X metrics.

## Release note

A `v0.1.0` tag is appropriate after this completion note is merged. The tag should mean: "roadmap baseline complete; operational validation still pending."
