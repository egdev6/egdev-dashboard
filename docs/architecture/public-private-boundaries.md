# Public vs private boundaries

Use this repository as the public source of truth for code, docs, and planning. Keep runtime state and sensitive data out of git.

## Public in the repository

- `README.md`
- `openspec/`
- `docs/adr/`
- `docs/architecture/`
- `docs/project/`
- `skills/`
- GitHub issue and PR templates
- GitHub issues and GitHub Project metadata
- Sample env variable names in `.env.example`
- Fake fixtures created for tests or examples

## Private outside the repository

- `.env` with real tokens and URLs
- Discord bot credentials
- Engram access tokens and real memory content
- Buffer access tokens
- Docker volumes such as `openclaw-workspace`, `engram-data`, and `openclaw-data`
- Host-specific logs and exported memory snapshots

## Review rules

| Data type | Allowed in PRs? | Notes |
|---|---|---|
| Docs and schemas | Yes | Preferred for design and planning |
| Skill prompts without secrets | Yes | Keep them generic and reviewable |
| Real memory content | No | Store in Engram only |
| API tokens or URLs with secrets | No | Use `.env` or a secret manager |
| Generated operational state | No | Keep in volumes or ignored directories |

## Practical checklist

- Do not commit `.env`.
- Do not commit runtime dumps from OpenClaw or Engram.
- Do not use `openclaw/workspace/` for live runtime state; keep that in Docker volumes.
- Do not put private brand strategy in public markdown unless intentionally shareable.
- Prefer sanitized examples when documenting workflows.
- Keep private operational learnings in Engram if they should persist.

## Next step

When the first live project is onboarded, add a short data-handling runbook that references these rules.
