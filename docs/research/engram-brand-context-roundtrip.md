# Engram brand-context roundtrip

This note records the fake-data validation for issue #8: persist brand-context memory in Engram, then read it back by project and network namespace.

## Quick path

1. Use fake data only from `examples/brand-context.fake.yaml`.
2. Run `scripts/validate-brand-context-memory.sh`.
3. Confirm both namespace strings are found in Engram search results.

## Namespaces validated

| Scope | Namespace key |
|---|---|
| Project-wide brand context | `egdev-dashboard/project/egdev/brand` |
| Network-local LinkedIn overlay | `egdev-dashboard/project/egdev/network/linkedin` |

These follow ADR 0002 in `docs/adr/0002-engram-namespace-contract.md`.

## Commands run

```bash
bash -n scripts/validate-brand-context-memory.sh
scripts/validate-brand-context-memory.sh
git diff --check
```

The script defaults to a disposable Engram data directory by creating a temporary `ENGRAM_DATA_DIR` when one is not already set.

## Expected output

A successful run prints lines like:

```text
Validated fake brand-context roundtrip in Engram.
Project namespace: egdev-dashboard/project/egdev/brand
Network namespace: egdev-dashboard/project/egdev/network/linkedin
ENGRAM_DATA_DIR: /tmp/tmp.<random>
Mode: disposable temp data dir
```

It also guarantees that both Engram searches returned the expected title and namespace string. The script reads `examples/brand-context.fake.yaml`, verifies its safety markers and namespace keys, and uses that fixture content as the source payload for both save operations.

## Failure behavior

The script exits nonzero with a helpful error when:

- `engram`, `mktemp`, or `grep` is not available on `PATH`;
- the fixture is missing, not marked fake/safe, or does not declare the expected namespace keys;
- `engram save` fails for the project namespace;
- `engram save` fails for the network namespace;
- `engram search` fails for either namespace query;
- search results do not contain the expected title or namespace string.

This is intentionally strict so issue #8 captures a real write/read validation instead of a best-effort smoke run.

## Why the data is safe

- The fixture file uses fake/demo values only.
- URLs use `example.invalid`.
- No real customer, creator, Discord, Buffer, or private brand data is included.
- The script uses a temporary `ENGRAM_DATA_DIR` by default, so it does not pollute existing local memory unless the caller explicitly overrides the directory.

## Limitations

This validates a **local CLI roundtrip only**.

It does **not** validate:

- OpenClaw skill invocation;
- Engram Cloud enrollment or sync;
- runtime Discord memory flows;
- automatic promotion from Engram into repo artifacts.

Those belong to later runtime and memory issues.
