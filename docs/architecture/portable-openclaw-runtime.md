# Portable OpenClaw runtime

This document describes the intended M1 runtime shape for `egdev-dashboard`.

## Summary

OpenClaw is the operational entrypoint target. Pi/el Gentleman develops the repository. Both rely on the same versioned artifacts and namespace conventions. Research in `docs/research/openclaw-runtime-validation.md` confirms OpenClaw's public Docker/workspace/skill/routing capabilities and a local Docker smoke test, while native Pi `.pi` asset execution inside OpenClaw remains unproven.

## Containers

| Service | Role | Notes |
|---|---|---|
| `openclaw` | Discord-facing operational runtime | Intended to run the agent workspace, skills, and future routing logic. Local smoke validation confirmed `ghcr.io/openclaw/openclaw:latest`, `node openclaw.mjs gateway`, Gateway port `18789`, token auth, and `/healthz`. |
| `engram` | Persistent memory backend | Intended to store project, network, brand, and content context after runtime validation |
| `buffer-sync` | Future analytics worker | Deferred until runtime and memory contracts are stable |
| `dashboard` | Future read-only UI | Deferred until data contracts exist |

## Mounted paths and volumes

| Path / volume | Purpose |
|---|---|
| `openclaw-workspace` | Runtime-local workspace state kept outside the tracked repository |
| `./openclaw/skills` | Tracked seed directory for OpenClaw-visible skill packaging and project wiring |
| `./openclaw/config` | Runtime notes, examples, and future config fragments |
| `openclaw-data` | Runtime state that should survive container restarts |
| `engram-data` | Persistent memory state |

## Discord routing model

Suggested convention:

```text
#linkedin-egdev -> project: egdev, network: linkedin
#x-egdev        -> project: egdev, network: x
#youtube-egdev  -> project: egdev, network: youtube
```

OpenClaw documents routing/bindings, including Discord surfaces. This repo still needs a spike to choose between one agent with channel-derived namespaces and multiple agents bound by account/channel/guild rules.

## Engram namespace model

Recommended namespace prefixes:

```text
egdev-dashboard/dev/sdd/*
egdev-dashboard/runtime/discord/*
egdev-dashboard/project/<project-slug>/brand
egdev-dashboard/project/<project-slug>/strategy
egdev-dashboard/project/<project-slug>/content-ledger
egdev-dashboard/project/<project-slug>/network/<network-slug>
```

## Boundaries

- Planning artifacts stay in git.
- Operational memory stays in Engram until promoted into a repo artifact.
- Secrets stay in `.env` or host-specific secret stores.
- OpenClaw image/command/health behavior is validated at smoke-test level; compose implementation still belongs to issue #2.
- Engram wiring remains placeholder until the memory access path is confirmed.
- Loopback-only host ports are the default until runtime security assumptions are validated.

## Next step

Use this skeleton to implement the validated OpenClaw gateway shape, then validate Engram access and Discord routing before building product features.
