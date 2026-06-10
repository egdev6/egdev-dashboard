# OpenClaw Gentle orchestration validation

This report records the local runtime validation for issue #174. It checks whether the Dockerized OpenClaw runtime can see Gentle-AI, Engram MCP, repo skills, Gentle SDD workspace assets, and no-op orchestration behavior without using live Discord or production credentials.

This is a local/private validation report only. It does not prove public Discord readiness, production hosting, live social publishing, live analytics, or durable production writes.

## Evidence pack header

| Field | Value |
|---|---|
| Issue | #174 — OpenClaw Gentle orchestration and scoped skill resolution |
| Date (UTC) | 2026-06-10T10:10:05Z |
| Branch / commit | `test/174-openclaw-gentle-orchestration` / `4fa9654` |
| Environment | Local Docker Compose runtime |
| Runtime image | `discord-project-manager-openclaw:local` |
| Discord execution | Not used |
| Production credentials | Not used |
| Evidence policy | Sanitized command summaries only; no real Discord IDs, tokens, screenshots, raw transcripts, or private payloads |

## Commands run

```bash
docker compose down
docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
docker compose ps
curl -sS http://127.0.0.1:18080/health
docker compose exec -T openclaw node -e "fetch('http://127.0.0.1:18789/health').then(async r => { console.log(r.status, await r.text()) })"
docker compose exec -T openclaw sh -lc 'command -v gentle-ai; gentle-ai --version; command -v engram; engram --version; command -v openclaw; openclaw --version'
docker compose exec -T openclaw sh -lc 'find /home/node/.openclaw/workspace/skills -mindepth 2 -maxdepth 2 -type f -name SKILL.md | sort'
docker compose exec -T openclaw sh -lc 'find /home/node/.openclaw/workspace -path "*sdd*" -o -path "*gentle*" | sort | head -120'
docker compose exec -T openclaw openclaw mcp doctor
docker compose exec -T openclaw openclaw mcp probe
openclaw agent no-op prompts through the running gateway for SDD, content planning, write gating, and scoped skill resolution
```

## Runtime health results

| Check | Result | Evidence summary |
|---|---|---|
| Docker services | Pass | `postgres`, `engram`, and `openclaw` started; OpenClaw reported healthy. |
| Engram Cloud health | Pass | `http://127.0.0.1:18080/health` returned `{"service":"engram-cloud","status":"ok"}`. |
| OpenClaw gateway health | Pass | `http://127.0.0.1:18789/health` returned `200 {"ok":true,"status":"live"}`. |

## Runtime binary and MCP results

| Check | Result | Evidence summary |
|---|---|---|
| `gentle-ai` CLI | Pass | `/usr/local/bin/gentle-ai`, version `1.37.0`. |
| `engram` CLI | Pass | `/usr/local/bin/engram`, version output `engram dev`. |
| `openclaw` CLI | Pass | `/usr/local/bin/openclaw`, version `OpenClaw 2026.6.5`. |
| MCP doctor | Pass | `context7: ok`; `engram: ok`. |
| MCP probe | Pass | `context7: 2 tools`; `engram: 15 tools`. |

## Skill sync results

The runtime workspace contained the expected seven tracked project skills:

```text
skills/brand-context/SKILL.md
skills/content-ledger/SKILL.md
skills/discord-approval-gate/SKILL.md
skills/linkedin-weekly-planner/SKILL.md
skills/on-demand-brief-planner/SKILL.md
skills/strategy-planner/SKILL.md
skills/x-queue-planner/SKILL.md
```

OpenClaw `skills list --agent main --json` also reported these project skills as `source: openclaw-workspace`, `eligible: true`, `disabled: false`, `modelVisible: true`, and `commandVisible: true`.

## Gentle SDD workspace asset results

The OpenClaw workspace contained Gentle-AI SDD protocol assets under:

```text
/home/node/.openclaw/workspace/.openclaw/skills/_shared/sdd-phase-common.md
/home/node/.openclaw/workspace/.openclaw/skills/_shared/sdd-status-contract.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-apply/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-archive/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-design/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-explore/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-init/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-onboard/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-propose/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-spec/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-tasks/SKILL.md
/home/node/.openclaw/workspace/.openclaw/skills/sdd-verify/SKILL.md
```

This validates that Gentle-AI SDD protocol assets are installed into the OpenClaw workspace. It does not claim Pi subagents/chains run inside OpenClaw; the intended boundary remains a solo-agent/workspace-instructions Gentle SDD flow.

## No-op orchestration checks

These checks used `openclaw agent --json` with explicit no-write/no-memory/no-GitHub/no-Discord prompts and dedicated validation session keys.

| Scenario | Expected | Result | Sanitized response summary |
|---|---|---|---|
| SDD development request | `intent=sdd_dev_work`; `backend=gentle-sdd`; no writes | Pass | Returned `intent: sdd_dev_work`, `selected_backend_or_runner: gentle-sdd`, `writes_attempted: false`. |
| Content planning request | OpenClaw skill surface, not Gentle SDD; no writes | Pass | Returned `selected_backend_or_runner: OpenClaw skill surface`, `effective_skills: [linkedin-weekly-planner]`, `writes_attempted: false`. |
| Write-like memory request | Approval required; `discord-approval-gate` mandatory; no writes | Pass | Returned `effective_skills: [discord-approval-gate]`, `mandatory_skills: [discord-approval-gate]`, `approval_required: true`, `writes_attempted: false`. |
| Scoped skill resolution | Global/category/channel/disabled resolution; approval gate mandatory for write-like flow | Pass | Returned `effective_skills: [linkedin-weekly-planner, strategy-planner, discord-approval-gate]`, `excluded_skills: [brand-context]`, `approval_required: true`, `writes_attempted: false`. |

## Important limitation

The no-op agent responses are model-mediated checks through the OpenClaw gateway. They validate that the installed runtime prompt/skill surface can classify and report the intended boundaries. They do not prove a dedicated deterministic runtime API for scoped-skill resolution exists yet.

Two no-op responses reported a single `bash` tool call in OpenClaw metadata despite explicit no-write instructions. The final responses still reported `writes_attempted: false`, and no repository files changed, but this supports the need for #175 to define a cleaner OpenClaw-native orchestrator/skill surface and deterministic no-op resolver checks.

## Pass/fail summary

| Requirement | Status |
|---|---|
| `gentle-ai` and `engram` available inside OpenClaw runtime | Pass |
| Gentle-AI/OpenClaw workspace protocol assets installed | Pass |
| Tracked project skills synced into OpenClaw workspace | Pass |
| `sdd_dev_work` selects `gentle-sdd` boundary in no-op check | Pass |
| Content/planning intent selects OpenClaw skill surface | Pass |
| Write-like flow includes `discord-approval-gate` and no write before approval | Pass |
| Scoped skill resolution handles global/category/channel/disabled cases in no-op check | Pass |
| Deterministic non-model resolver API exists | Not proven |
| Public/private Discord runtime execution | Not tested |

## Recommendation

Use this evidence to proceed with #175. The next step should reset/refactor the active OpenClaw skill surface around a deterministic Runtime Orchestrator + scoped skill resolver model, while preserving Gentle-AI SDD assets as the `sdd_dev_work` backend boundary.
