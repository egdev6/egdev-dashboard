# Engram content-ledger roundtrip

This note records the fake-data validation for issue #9: persist content-ledger memory in Engram, then read it back by durable ledger namespace and network overlay namespace.

## Quick path

1. Use fake data only from `examples/content-ledger.fake.yaml`.
2. Run `scripts/validate-content-ledger-memory.sh`.
3. Confirm both namespace strings and the expected content identifier are found in Engram search results.

## Namespaces and identifiers validated

| Scope | Key or identifier |
|---|---|
| Durable ledger namespace | `egdev-dashboard/project/egdev/content-ledger` |
| Network-local X overlay | `egdev-dashboard/project/egdev/network/x` |
| Project slug | `egdev` |
| Network slug | `x` |
| Content identifier | `x-post-001-demo` |
| Schema version | `1` |

These follow ADR 0002 in `docs/adr/0002-engram-namespace-contract.md`.

## Commands run

```bash
bash -n scripts/validate-content-ledger-memory.sh
scripts/validate-content-ledger-memory.sh
git diff --check
```

The script defaults to a disposable Engram data directory by creating a temporary `ENGRAM_DATA_DIR` when one is not already set.

## Expected output

A successful run prints lines like:

```text
Validated fake content-ledger roundtrip in Engram.
Fixture: examples/content-ledger.fake.yaml
Ledger namespace: egdev-dashboard/project/egdev/content-ledger
Network namespace: egdev-dashboard/project/egdev/network/x
Content identifier: x-post-001-demo
Schema version: 1
ENGRAM_DATA_DIR: /tmp/tmp.<random>
Mode: disposable temp data dir
```

It also guarantees that both Engram searches returned the expected save title, namespace string, and content identifier. The script reads `examples/content-ledger.fake.yaml`, verifies its schema/safety markers and identifiers, and uses that fixture content as the source payload for both save operations.

## Failure behavior

The script exits nonzero with a helpful error when:

- `engram`, `mktemp`, or `grep` is not available on `PATH`;
- the fixture is missing, not marked fake/safe, or does not declare the expected schema version, namespace keys, project/network identifiers, or content identifier;
- `engram save` fails for the durable ledger namespace;
- `engram save` fails for the X network overlay namespace;
- `engram search` fails for either namespace query;
- search results do not contain the expected title, namespace string, or content identifier.

This is intentionally strict so issue #9 captures a real write/read validation instead of a best-effort smoke run.

## Schema contract

The fixture follows the `content-ledger` skill contract:

- `content_entry.id` is the stable content identifier;
- `content_entry.assets` contains asset references;
- `project`, `network`, `ledger_namespace_key`, and `network_namespace_key` identify where the entry belongs.

The validation script is a strict fixture smoke test. It checks these expected strings for the fake fixture; it is not a general YAML schema validator.

## Migration and versioning expectations

The fixture starts at `schema_version: 1`.

Rules for future evolution:

- additive fields may be introduced without rewriting older entries;
- breaking schema changes should increment `schema_version` and document the migration plan before changing validators or runtime writers;
- do not destructively rewrite durable ledger memory without explicit human approval;
- if migration logic becomes reusable or review-facing, promote it into repo artifacts before operational workflows depend on it.

## Why the data is safe

- The fixture file uses fake/demo values only.
- URLs use `example.invalid`.
- Metrics use `unknown` or clearly fake values.
- No real customer, creator, Discord, Buffer, or private publish-history data is included.
- The script uses a temporary `ENGRAM_DATA_DIR` by default, so it does not pollute existing local memory unless the caller explicitly overrides the directory.

## Limitations

This validates a **local CLI roundtrip only**.

It does **not** validate:

- OpenClaw skill invocation;
- Engram Cloud enrollment or sync;
- runtime Discord memory flows;
- automatic promotion from Engram into repo artifacts.

Those belong to later runtime and memory issues.
