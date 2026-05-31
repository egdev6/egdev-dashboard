# Static dashboard overview

This document explains the dependency-free static dashboard overview for issue #21.

## Quick path

1. Open `dashboard/index.html` in a browser.
2. Compare the rendered summary against `examples/dashboard-read-models.fake.yaml`.
3. Run `scripts/validate-dashboard-overview.sh` to confirm the page stays read-only and repo-safe.

## Status

| Topic | Decision |
|---|---|
| Delivery mode | Static HTML artifact only |
| Runtime status | No live server or API adapter |
| Data source | Fake dashboard read model contract |
| Mutation support | None |
| Privacy default | Normalized public-safe summary fields only |

## What the page shows

The overview page intentionally stays small and reviewable.

It includes:

- the project `egdev`;
- the routed channels `linkedin-egdev`, `x-egdev`, `youtube-egdev`, `twitch-egdev`, and `stack-and-flow-egdev`;
- context, strategy, content ledger, and analytics summary taken from the fake read model contract;
- explicit analytics availability markers showing LinkedIn/X as `fake-demo available` and the other known networks as unavailable or not yet modeled;
- a safety panel listing the first-slice non-goals.

## What the page does not do

This slice does **not** add:

- package.json or app tooling;
- frameworks, builds, or hydration scripts;
- a live server;
- runtime memory reads;
- Engram adapters;
- forms, actions, mutation controls, or writes;
- raw Discord IDs;
- credentials or secrets;
- live Buffer calls.

## Review checklist

- [ ] The page clearly says it is static and read-only.
- [ ] All five approved channel and network names appear.
- [ ] LinkedIn and X analytics are marked fake-demo available.
- [ ] YouTube, Twitch, and Stack-and-Flow analytics are marked unavailable or not yet modeled.
- [ ] The page does not contain mutation controls or external assets.
- [ ] The page does not expose private memory, raw Discord IDs, or credentials.

## Validation

```bash
git diff --check
bash -n scripts/validate-dashboard-overview.sh
scripts/validate-dashboard-overview.sh
npx --yes markdownlint-cli2@0.18.1 "**/*.md"
```

The validator is local and static only. It checks for the expected channel/network names, read-only/privacy markers, and common forbidden patterns such as external HTTP(S) assets, forms, mutation-like browser APIs, and obvious credential variable names.

## Next step

If a future live dashboard is approved, it should build on the read model boundaries in `docs/architecture/dashboard-read-model-contracts.md` rather than bypassing them.
