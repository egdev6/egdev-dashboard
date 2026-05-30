# Portable OpenClaw runtime

This document describes the intended M1 runtime shape for `egdev-dashboard`.

## Summary

OpenClaw is the operational entrypoint target. Pi/el Gentleman develops the repository. Both rely on the same versioned artifacts and namespace conventions. Research in `docs/research/openclaw-runtime-validation.md` confirms OpenClaw's public Docker/workspace/skill/routing capabilities and a local Docker smoke test, while native Pi `.pi` asset execution inside OpenClaw remains unproven.

## Containers

| Service | Role | Notes |
|---|---|---|
| `openclaw-setup` | One-shot setup job | Runs non-interactive OpenClaw onboarding into the `openclaw-home` volume before the gateway starts, then syncs tracked skills into the workspace |
| `openclaw` | Discord-facing operational runtime | Uses a local `egdev-dashboard-openclaw:local` image built from `ghcr.io/openclaw/openclaw:latest`; runs `node openclaw.mjs gateway`, Gateway port `18789`, token auth, and `/healthz` |
| `postgres` | Engram Cloud database | Uses `postgres:16-alpine` with data in `engram-postgres` |
| `engram` | Persistent memory backend | Uses `ghcr.io/gentleman-programming/engram:latest` in Cloud mode; client enrollment/sync still needs a memory spike |
| `buffer-sync` | Future analytics worker | Deferred until runtime and memory contracts are stable |
| `dashboard` | Future read-only UI | Deferred until data contracts exist |

## Mounted paths and volumes

| Path / volume | Purpose |
|---|---|
| `openclaw-home` | OpenClaw config, workspace, sessions, and runtime state kept outside the tracked repository |
| `./skills` | Tracked OpenClaw-visible workspace skills, copied into the runtime image and synced to `/home/node/.openclaw/workspace/skills` |
| `./openclaw/config` | Runtime notes, examples, and future config fragments copied into the runtime image under `/opt/egdev-dashboard/openclaw-config` |
| `engram-postgres` | Persistent Engram Cloud Postgres data |

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
- OpenClaw image/command/health behavior is validated at smoke-test level and encoded in Compose.
- Engram Cloud image and Postgres strategy are encoded in Compose, but client enrollment/sync behavior remains for the memory spike.
- Loopback-only host ports are the default until runtime security assumptions are validated.

## Next step

Use this Compose foundation to validate host/browser access, Engram enrollment/sync, and Discord routing before building product features. See `docs/operations/docker-runtime.md` for local commands.
