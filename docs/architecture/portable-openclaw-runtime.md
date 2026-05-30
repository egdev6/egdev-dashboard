# Portable OpenClaw runtime

This document describes the intended M1 runtime shape for `egdev-dashboard`.

## Summary

OpenClaw is the operational entrypoint target. Pi/el Gentleman develops the repository. Both rely on the same versioned artifacts and namespace conventions.

## Containers

| Service | Role | Notes |
|---|---|---|
| `openclaw` | Discord-facing operational runtime | Intended to run the agent workspace, skills, and future routing logic after runtime validation |
| `engram` | Persistent memory backend | Intended to store project, network, brand, and content context after runtime validation |
| `buffer-sync` | Future analytics worker | Deferred until runtime and memory contracts are stable |
| `dashboard` | Future read-only UI | Deferred until data contracts exist |

## Mounted paths and volumes

| Path / volume | Purpose |
|---|---|
| `openclaw-workspace` | Runtime-local workspace state kept outside the tracked repository |
| `./openclaw/skills` | OpenClaw-visible skill packaging and project wiring |
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

The exact binding mechanism should be validated against OpenClaw's supported routing model before implementation.

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
- Docker image references and exact OpenClaw/Engram wiring remain placeholders until the runtime contract is confirmed.
- Loopback-only host ports are the default until runtime security assumptions are validated.

## Next step

Use this skeleton to validate Docker portability and the OpenClaw/Gentle-AI runtime contract before building product features.
