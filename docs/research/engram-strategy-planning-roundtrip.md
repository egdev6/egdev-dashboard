# Engram strategy-planning roundtrip

This note records the fake-data validation for issue #10: read persisted brand and content-ledger context from Engram, validate a preauthored structured strategy fixture, and persist both project strategy and LinkedIn planning overlays back to Engram after an explicit fake approval marker.

## Quick path

1. Use fake data only from:
   - `examples/brand-context.fake.yaml`
   - `examples/content-ledger.fake.yaml`
   - `examples/strategy-plan.fake.yaml`
2. Run `scripts/validate-strategy-planning-memory.sh`.
3. Confirm the brand and ledger namespaces are read back before the strategy records are written.
4. Confirm both strategy namespaces are searchable by namespace and exported back with `approval_status: approved-for-demo-validation`.

## Source context namespaces read

| Source | Namespace key |
|---|---|
| Project-wide brand context | `egdev-dashboard/project/egdev/brand` |
| Durable content ledger | `egdev-dashboard/project/egdev/content-ledger` |

The strategy fixture also references:

- `egdev-dashboard/project/egdev/brand`
- `egdev-dashboard/project/egdev/content-ledger`
- recent ledger content id `x-post-001-demo`

These follow ADR 0002 in `docs/adr/0002-engram-namespace-contract.md`.

## Strategy namespaces written

| Scope | Namespace key |
|---|---|
| Cross-network strategy memory | `egdev-dashboard/project/egdev/strategy` |
| LinkedIn planning overlay | `egdev-dashboard/project/egdev/network/linkedin` |

## Structured strategy result validated

The fake fixture follows the `strategy-planner` skill contract with:

- `schema_version: 1`
- `project: egdev`
- `network: linkedin`
- `timeframe: 2026-W23`
- `strategy_slice.goals`
- `strategy_slice.assumptions`
- `strategy_slice.planned_items`
- `strategy_slice.review_checkpoints`
- `strategy_slice.out_of_scope`
- `approval_status: approved-for-demo-validation`

This is a fixture-driven smoke test. The script reads the brand and content-ledger fixtures first, persists them to Engram, verifies they can be searched back, then persists the strategy result and LinkedIn overlay using the strategy fixture as the source payload. It does not claim LLM generation from source context; it proves the memory workflow can gate strategy persistence on verified source context.

## Human approval points

Human approval remains mandatory:

- The fixture uses `approval_status: approved-for-demo-validation` and an `approval_record` scoped only to issue #10 fake local CLI validation.
- This approval marker authorizes writing the fake strategy fixture to disposable local Engram memory only.
- It does not approve real brand strategy, publishing, scheduling, Buffer actions, or Discord runtime behavior.
- Runtime Discord memory is not treated as approval for durable strategy writes.

## Commands run

```bash
bash -n scripts/validate-strategy-planning-memory.sh
scripts/validate-strategy-planning-memory.sh
git diff --check
```

The script defaults to a disposable Engram data directory by creating a temporary `ENGRAM_DATA_DIR` when one is not already set.

## Expected output

A successful run prints lines like:

```text
Validated fake strategy planning roundtrip in Engram.
Brand namespace read: egdev-dashboard/project/egdev/brand
Ledger namespace read: egdev-dashboard/project/egdev/content-ledger
Strategy namespace written: egdev-dashboard/project/egdev/strategy
Network strategy namespace written: egdev-dashboard/project/egdev/network/linkedin
Approval status: approved-for-demo-validation
ENGRAM_DATA_DIR: /tmp/tmp.<random>
Mode: disposable temp data dir
```

It also guarantees that:

- brand context was searchable before strategy planning continued;
- ledger context was searchable before strategy planning continued;
- the strategy result was searchable by `egdev-dashboard/project/egdev/strategy`;
- the LinkedIn overlay was searchable by `egdev-dashboard/project/egdev/network/linkedin`;
- an Engram export contained both strategy records with the expected save title, topic key, and `approval_status: approved-for-demo-validation`.

## Failure behavior

The script exits nonzero with a helpful error when:

- `engram`, `mktemp`, or `grep` is not available on `PATH`;
- the brand, content-ledger, or strategy fixture is missing or not marked fake/safe;
- any required namespace key, timeframe, ledger content id, or approval status marker is missing from the fixtures;
- brand context save/search fails before strategy planning;
- content-ledger save/search fails before strategy planning;
- strategy save/search fails for either strategy namespace;
- Engram export fails during strategy readback;
- search or export readback does not contain the expected title, namespace string, topic key, or approval status.

This is intentionally strict so issue #10 captures a real local write/read workflow instead of a best-effort smoke run.

## Why the data is safe

- All fixture files use fake/demo values only.
- URLs use `example.invalid`.
- No real customer, creator, Discord, Buffer, or private strategy data is included.
- The strategy fixture approval record is explicitly scoped to fake local CLI validation and does not authorize an approved or live plan.
- The script uses a temporary `ENGRAM_DATA_DIR` by default, so it does not pollute existing local memory unless the caller explicitly overrides the directory.

## Limitations

This validates a **local CLI roundtrip only**.

It does **not** validate:

- OpenClaw skill invocation;
- Engram Cloud enrollment or sync;
- runtime Discord memory flows;
- Buffer analytics;
- content publishing or scheduling.

Those belong to later runtime and memory issues.
