# egdev-dashboard

Intended portable OpenClaw workspace for running Gentle-AI-powered social-content operations with persistent Engram memory.

## What this repository is

`egdev-dashboard` is a public M1 foundation repo for a Docker-portable setup where:

- **Pi / el Gentleman** is the development SDD harness for repo work.
- **OpenClaw** is the intended operational runtime that receives Discord traffic.
- **Gentle-AI SDD inside OpenClaw** is a target runtime shape, but still pending validation.
- **Engram** is the intended persistent memory backend, but runtime wiring is still pending validation.

This repository is intentionally light on implementation in M1. It focuses on runtime boundaries, portable deployment, issue-first planning, and skill scaffolding.

## Intended architecture at a glance

```text
Discord
  -> OpenClaw Gateway (pending validation)
  -> OpenClaw workspace with Gentle-AI skills/chains (pending validation)
  -> Engram memory + future Buffer integration (pending validation)
```

## Canonical planning artifacts

Canonical shared-planning artifacts live in this repo:

- `openspec/`
- `docs/adr/`
- `docs/architecture/`
- `docs/project/`
- `docs/process/`
- `docs/security/`
- `skills/`
- GitHub issues and GitHub Project metadata

Engram summaries are **operational memory**, not canonical planning artifacts, unless they are later promoted into a versioned repo artifact.

## Current status

This is the **M1 foundation skeleton**.

Included now:

- Docker Compose foundation for OpenClaw, Engram Cloud, and Postgres
- SDD/OpenSpec project config
- ADRs and architecture notes
- Issue-first GitHub templates
- Backlog and roadmap
- Skill skeletons/contracts for brand context, content ledger, strategy planning, LinkedIn weekly planning, X queue planning, and on-demand brief workflows
- CI checks for repository hygiene, local Engram memory roundtrips, Docker smoke validation, developer tooling, commit messages, and secret scanning

Not included or not yet validated:

- Native Pi `.pi` agents/chains running directly inside OpenClaw
- Confirmed live Engram enrollment/sync behavior from OpenClaw skills
- Host/browser access validation on every target machine
- Live Discord bot configuration
- Buffer analytics integration
- Dashboard or API implementation

## Quick start

1. Clone the repository.
2. Copy `.env.example` to `.env`.
3. Replace every `change-me-*` value before storing real memory.
4. Run OpenClaw setup once.
5. Start the foundation services.

```bash
git clone <repo-url>
cd egdev-dashboard
cp .env.example .env
# edit every change-me value before real use

docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
```

See `docs/operations/docker-runtime.md` for shutdown, volume, and health-check commands, `docs/operations/ci.md` for automated checks, `docs/operations/dev-tooling.md` for local hooks and commit conventions, `docs/operations/discord-routing.md` for channel routing rules, and `docs/security/data-handling.md` before using real memory, Discord, or Buffer credentials.

## Development model

- Repo development happens through Pi/el Gentleman SDD.
- Operational Discord usage is intended to happen inside OpenClaw once validated.
- Canonical planning artifacts are OpenSpec changes, ADRs, `docs/architecture/`, `docs/project/`, `docs/process/`, `docs/security/`, skills, and GitHub issue/project metadata.
- Engram holds operational memory and summaries until something is promoted into the repo.
- Concurrent SDD writes to shared planning artifacts are not allowed; follow `docs/process/shared-artifact-serialization.md` for claim/release and recovery.

## Review guidance

The current M1 foundation skeleton is larger than the configured 600-line review budget. If submitted for review, it should be split into at least two PRs.

## Directory guide

- `openclaw/` — tracked config notes, placeholders, and runtime docs
- `skills/` — project-specific skill skeletons
- `docs/` — ADRs, architecture notes, and roadmap
- `openspec/` — project planning configuration
- `.github/` — issue-first workflow templates and CI workflows

## Next step

Use the backlog in `docs/project/backlog.md` to create the first approved issues, starting with runtime validation, data-handling rules, and Docker portability.
