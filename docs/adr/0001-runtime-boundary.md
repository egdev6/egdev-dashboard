# ADR 0001: Pi development SDD vs OpenClaw operational SDD boundary

- Status: Accepted
- Date: 2026-05-30

## Decision

`discord-project-manager` uses two SDD surfaces with different responsibilities:

- **Pi / el Gentleman** is the development harness for repository planning, implementation, review, and change management.
- **OpenClaw** is the dockerized operational runtime target that serves Discord-driven workflows. Public docs and local smoke validation support Docker, workspaces, `SKILL.md` skills, Gateway health, Discord setup, and routing as target capabilities.
- **Gentle-AI SDD inside OpenClaw** is an adaptation target, not a confirmed native Pi runtime. Package Gentle-AI behavior as OpenClaw `SKILL.md` assets and workspace instructions; do not assume Pi-native `.pi` agents/chains run inside OpenClaw unless a future spike proves direct compatibility.

## Rules

1. Canonical planning artifacts live in the repo:
   - `openspec/`
   - `docs/adr/`
   - `docs/architecture/`
   - `docs/project/`
   - `docs/process/`
   - `docs/security/`
   - `skills/`
   - GitHub issues and GitHub Project metadata
2. Live session context is **not** shared automatically between Pi and OpenClaw.
3. Shared understanding is synchronized through versioned artifacts and agreed Engram namespaces.
4. Engram summaries are operational memory until promoted into a canonical repo artifact.
5. Concurrent writes to shared SDD artifacts are not allowed. Use `docs/process/shared-artifact-serialization.md` for the single-writer claim/release procedure.
6. GitHub issues and project tracking follow an issue-first approval workflow.

## Why

This keeps development reproducible, reviewable, and portable while still allowing OpenClaw to operate in Discord with persistent memory.

## Consequences

### Positive

- Clear boundary between product development and runtime operations
- Portable setup for another PC through Docker Compose
- Repository remains the reviewable source of truth
- Engram can store operational memory without replacing versioned planning artifacts

### Trade-offs

- Runtime and development sessions must coordinate through artifacts instead of assuming a shared live context
- Operational SDD changes that affect shared artifacts must be serialized through the documented single-writer procedure
- Initial setup requires explicit namespace and routing conventions
- Gentle-AI/Pi SDD assets may need adaptation into OpenClaw skills instead of direct reuse

## Follow-up

- Implement the compose service shape from the validated OpenClaw image, command, and Gateway port.
- Define Engram namespaces before implementing persistent skills.
- Validate Engram access and Discord routing before promising full Discord-driven operational SDD.
- Keep future ADRs small and specific when runtime assumptions change.
