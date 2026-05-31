# egdev-dashboard

Intended portable OpenClaw workspace for running Gentle-AI-powered social-content operations with persistent Engram memory.

## What this repository is

`egdev-dashboard` is a public roadmap-baseline repo for a Docker-portable setup where:

- **Pi / el Gentleman** is the development SDD harness for repo work.
- **OpenClaw** is the intended operational runtime that receives Discord traffic.
- **Gentle-AI SDD inside OpenClaw** is a target runtime shape, but still pending validation.
- **Engram** is the intended persistent memory backend, but runtime wiring is still pending validation.

This repository is intentionally contract-first after the completed M1-M7 roadmap. It focuses on runtime boundaries, portable deployment, issue-first planning, skill scaffolding, fake fixtures, and static/read-only validation artifacts.

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

This is the completed **M1-M7 roadmap baseline**. See `docs/project/roadmap-completion.md` for the completion summary and remaining operational-validation limits.

Included now:

- Docker Compose foundation for OpenClaw, Engram Cloud, and Postgres
- SDD/OpenSpec project config
- ADRs and architecture notes
- Issue-first GitHub templates
- Backlog and roadmap
- Skill skeletons/contracts for brand context, content ledger, strategy planning, LinkedIn weekly planning, X queue planning, and on-demand brief workflows
- CI checks for repository hygiene, local Engram memory roundtrips, Docker smoke validation, developer tooling, commit messages, and secret scanning
- Buffer API research for read-only analytics scope and auth boundaries
- Fake LinkedIn and X analytics snapshot schemas and local validation without live Buffer dependency
- Contract-first dashboard/API read model docs, fake fixture, and local validation without a live server
- Static read-only dashboard overview artifact over the fake read models
- Roadmap completion baseline for M1-M7

Not included or not yet validated:

- Native Pi `.pi` agents/chains running directly inside OpenClaw
- Confirmed live Engram enrollment/sync behavior from OpenClaw skills
- Host/browser access validation on every target machine
- Fully validated live Discord routing and approval behavior; a private pilot confirmed the external Discord plugin prerequisite and found that write-like Discord requests still need stricter approval gating
- Live Buffer analytics integration; current public API research found no read-only LinkedIn/X analytics endpoint
- Live dashboard UI or API server implementation

## Quick start

1. Clone the repository.
2. Create `.env` from `.env.example` only if `.env` does not already exist.
3. Replace every `change-me-*` value before storing real memory.
4. Run OpenClaw setup once.
5. Start the foundation services.

```bash
git clone <repo-url>
cd egdev-dashboard
test -f .env || cp .env.example .env
# edit every change-me value before real use; never overwrite an existing .env blindly

docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
```

See `docs/operations/docker-runtime.md` for shutdown, volume, plugin, and health-check commands, `docs/operations/runtime-incident-runbook.md` for startup, failures, backup notes, and incident response, `docs/operations/ci.md` for automated checks, `docs/operations/dev-tooling.md` for local hooks and commit conventions, `docs/operations/discord-routing.md` for channel routing rules, `docs/operations/discord-approval-responses.md` for approval-oriented response patterns, and `docs/security/data-handling.md` before using real memory, Discord, or Buffer credentials.

### Discord pilot prerequisite

The base OpenClaw runtime image does not include the Discord channel plugin by default. Before live Discord route validation, install the external plugin and restart OpenClaw:

```bash
docker compose exec openclaw openclaw plugins install @openclaw/discord
docker compose restart openclaw
docker compose exec openclaw openclaw channels status --deep --probe
```

Only proceed when Discord appears in channel status. A configured bot token alone is not enough if the plugin is missing.

## Try it on another PC

Use a fresh clone and fresh local secrets on every machine. Do **not** copy `.env`, Docker volumes, private memory, raw logs, Discord IDs, or credentials between PCs unless you are deliberately doing a private migration.

```bash
git clone https://github.com/egdev6/egdev-dashboard.git
cd egdev-dashboard

test -f .env || cp .env.example .env
# edit every change-me value before storing real memory

docker compose config
docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
docker compose ps
```

If Docker is installed but the socket is permission-denied, use `sudo docker ...` for the pilot or fix local Docker permissions outside the repo.

Validate local health and skill sync:

```bash
docker compose exec openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) })"
curl -sS http://127.0.0.1:18080/health
docker compose exec openclaw sh -lc 'find /home/node/.openclaw/workspace/skills -maxdepth 3 -type f | sort'
```

Shut down without deleting volumes:

```bash
docker compose down
docker volume ls | grep 'egdev-dashboard' || true
```

This validates portability only. It does not configure live Discord, live Buffer analytics, durable Engram application sync, or production hosting.

## Development model

- Repo development happens through Pi/el Gentleman SDD.
- Operational Discord usage is intended to happen inside OpenClaw once validated.
- Canonical planning artifacts are OpenSpec changes, ADRs, `docs/architecture/`, `docs/project/`, `docs/process/`, `docs/security/`, skills, and GitHub issue/project metadata.
- Engram holds operational memory and summaries until something is promoted into the repo.
- Concurrent SDD writes to shared planning artifacts are not allowed; follow `docs/process/shared-artifact-serialization.md` for claim/release and recovery.

## Review guidance

Keep future changes within the configured 600-line review budget. Split larger runtime, dashboard, or live-integration work before review.

## Directory guide

- `openclaw/` — tracked config notes, placeholders, and runtime docs
- `skills/` — project-specific skill skeletons
- `docs/` — ADRs, architecture notes, and roadmap
- `openspec/` — project planning configuration
- `.github/` — issue-first workflow templates and CI workflows

## Next step

Use `docs/project/roadmap-completion.md` to start the next approved phase. The recommended next step is private runtime validation before live Discord, live Engram sync, live analytics, or a real dashboard/API stack.
