<img width="1536" height="1024" alt="project manager" src="https://github.com/user-attachments/assets/ba59f190-c8e0-4be0-bd6e-aa69f4f7f415" />

# discord-project-manager

<div align="center">

[![Version][version-shield]][releases-url]
[![Issues][issues-shield]][issues-url]
[![Stars][stars-shield]][stars-url]

</div>

Portable Discord-first project operations cockpit for turning ideas into issues, specs, context, and AI-assisted workflows. `discord-project-manager` combines OpenClaw runtime experiments, Gentle-AI SDD practices, and Engram-backed memory in one repo so planning, coordination, and future automation share the same baseline.

## What this project is

`discord-project-manager` is a **planning-first and runtime-baseline repository** for a future Discord-driven workflow where:

- **Discord** is the human-facing entry point for requests, approvals, and coordination.
- **OpenClaw** is the operational runtime being shaped and validated.
- **Gentle-AI / el Gentleman** provides the repo-side SDD workflow for specs, tasks, and implementation discipline.
- **Engram** is the persistent memory layer for durable operational context.

Today, the repo is best understood as a strong foundation for the system, not as a finished SaaS product. It documents the architecture, keeps the planning artifacts in version control, and makes the local runtime easier to validate and evolve.

## What it helps with

Instead of scattering context across chat, docs, and ad-hoc scripts, this project aims to centralize the operational model for:

- planning issues and OpenSpec changes from a shared source of truth;
- organizing project and network context before automation grows;
- validating how Discord, OpenClaw, and persistent memory should interact;
- preparing a future dashboard or read-model layer without inventing it blindly.

## Technology stack

<div align="center">

![Discord](https://img.shields.io/badge/Discord-entry%20point-5865F2?style=for-the-badge&logo=discord&logoColor=white)
![OpenClaw](https://img.shields.io/badge/OpenClaw-runtime-111827?style=for-the-badge&logo=docker&logoColor=white)
![Gentle-AI](https://img.shields.io/badge/Gentle--AI-SDD%20workflow-7C3AED?style=for-the-badge)
![Engram](https://img.shields.io/badge/Engram-persistent%20memory-0EA5E9?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-portable%20services-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Postgres](https://img.shields.io/badge/Postgres-storage-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![OpenSpec](https://img.shields.io/badge/OpenSpec-planning%20artifacts-16A34A?style=for-the-badge)

</div>

## Architecture at a glance

```text
Discord
  -> OpenClaw gateway and workspace
  -> Gentle-AI-oriented skills, chains, and planning flows
  -> Engram memory for durable operational context
  -> Future read models, dashboards, and reporting surfaces
```

The repo keeps the planning artifacts, runtime notes, skill contracts, and validation fixtures together so the architecture can evolve intentionally instead of through one-off experiments.

## Quick start

```bash
git clone https://github.com/egdev6/discord-project-manager.git
cd discord-project-manager
test -f .env || cp .env.example .env
# replace every change-me value before storing real memory
# existing pre-rename .env files should use discord-project-manager for project/image/namespace values

docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
```

After the services are up, validate health and skill sync:

```bash
docker compose exec openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) })"
curl -sS http://127.0.0.1:18080/health
docker compose exec openclaw sh -lc 'find /home/node/.openclaw/workspace/skills -maxdepth 3 -type f | sort'
```

## Current status and scope

This repository is currently a **baseline for planning, validation, and runtime shaping**.

Included now:

- Docker Compose foundation for OpenClaw, Engram Cloud, and Postgres
- OpenSpec configuration and repo-level planning structure
- architecture notes, ADRs, process docs, and validation scripts
- issue-first GitHub workflow foundations
- project skill contracts for content and planning operations
- fake fixtures and static validation for future read models

Not finished yet:

- a mature production dashboard or API service;
- fully validated live Discord routing on every target environment;
- confirmed end-to-end Engram behavior for all planned workflows;
- complete productization of the AI-agent operating model inside OpenClaw.

## Project docs

Start with the shortest path that matches your goal:

- **Roadmap baseline:** [`docs/project/roadmap-completion.md`](./docs/project/roadmap-completion.md)
- **Backlog and issue framing:** [`docs/project/backlog.md`](./docs/project/backlog.md)
- **Runtime model:** [`docs/architecture/portable-openclaw-runtime.md`](./docs/architecture/portable-openclaw-runtime.md)
- **Operational Docker guidance:** [`docs/operations/docker-runtime.md`](./docs/operations/docker-runtime.md)
- **Security and data handling:** [`docs/security/data-handling.md`](./docs/security/data-handling.md)
- **Shared artifact rules:** [`docs/process/shared-artifact-serialization.md`](./docs/process/shared-artifact-serialization.md)

## Working model

The intended split is simple:

| Surface | Role |
| --- | --- |
| GitHub + OpenSpec | Canonical planning, specs, backlog, and reviewable changes |
| OpenClaw | Discord-facing operational runtime |
| Gentle-AI / el Gentleman | Structured development and documentation workflow |
| Engram | Persistent operational memory until promoted into repo artifacts |

That separation keeps the repository useful even before the live operational loop is fully validated.

## Next step

Use the backlog and roadmap artifacts to decide the next approved slice, then validate the corresponding runtime or memory contract before expanding into bigger dashboard or automation work.

---

<div align="center">

**If this direction resonates, star the repo and use it as the planning baseline for the next Discord-driven workflow iteration.**

</div>

<!-- MARKDOWN LINKS & IMAGES -->
[version-shield]: https://img.shields.io/badge/version-pre--release-7C3AED?style=for-the-badge
[issues-shield]: https://img.shields.io/github/issues/egdev6/discord-project-manager?style=for-the-badge
[stars-shield]: https://img.shields.io/github/stars/egdev6/discord-project-manager?style=for-the-badge
[releases-url]: ./docs/project/roadmap-completion.md
[issues-url]: https://github.com/egdev6/discord-project-manager/issues
[stars-url]: https://github.com/egdev6/discord-project-manager/stargazers
