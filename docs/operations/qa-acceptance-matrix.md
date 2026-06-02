# QA acceptance matrix and evidence pack

Use this doc to run the QA track after AGENT verification is green. It gives QA a single matrix for what to test, who owns each check, which evidence already exists, and when to stop before work drifts into live or production behavior.

## Quick path

1. Reuse AGENT evidence from #102-#105 before asking QA to repeat anything.
2. Run QA issues in order: #106, #107, #108, #109, #110, #111, optional gated #112, then #113.
3. For each matrix row, capture only sanitized evidence and stop on any non-goal breach.

## Execution order

| Order | Issue | Owner | Purpose | Primary evidence |
|---|---|---|---|---|
| 1 | #102 AGENT-01 | `agent` | Safe local Stage 0-1 contract baseline | `docs/operations/safe-validation-suite.md` |
| 2 | #103 AGENT-02 | `agent` | CI coverage for all safe validators | `docs/operations/ci.md`, CI checks |
| 3 | #104 AGENT-03 | `agent` | Private Docker runtime health | `docs/operations/private-docker-runtime-validation.md` |
| 4 | #105 AGENT-04 | `agent` | OpenClaw skill sync plus local Engram roundtrips | `docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md` |
| 5 | #106 QA-01 | `QA+agent` | Accept the matrix and evidence pack format | This document |
| 6 | #107 QA-02 | `QA+agent` | Onboarding/docs walkthrough | `docs/operations/qa-onboarding-docs-walkthrough.md` |
| 7 | #108 QA-03 | `QA+agent` | Skills and fake workflow contract walkthrough | `docs/operations/qa-skills-workflow-contract-walkthrough.md` |
| 8 | #109 QA-04 | `QA+agent` | Memory and approval-gate walkthrough | `docs/operations/qa-memory-approval-gate-walkthrough.md` |
| 9 | #110 QA-05 | `QA+agent` | Dashboard and analytics read-only walkthrough | `docs/operations/qa-dashboard-analytics-readonly-walkthrough.md` |
| 10 | #111 QA-06 | `QA+agent` | Private Docker runtime smoke walkthrough | `docs/operations/qa-private-docker-runtime-smoke-walkthrough.md` |
| 11 | #112 QA-07 | `QA+agent` | Private Discord routing dry-run (execution gated) | `docs/operations/qa-private-discord-routing-dry-run-plan.md` |
| 12 | #113 QA-08 | `QA+agent` | Final regression report and release decision | Final regression report |

## Agent evidence to reuse first

| Source | What it already proves | Reuse in QA |
|---|---|---|
| `docs/operations/safe-validation-suite.md` | Safe validator baseline for docs, contracts, analytics, dashboard, memory, Discord, and X queue fixtures | Attach as baseline evidence before QA walkthroughs |
| `docs/operations/private-docker-runtime-validation.md` | Local Docker compose health, loopback bindings, sanitized startup/shutdown evidence | Reuse for QA runtime smoke planning |
| `docs/operations/openclaw-skill-sync-engram-roundtrip-validation.md` | Skill sync path/count/checksum proof and disposable Engram roundtrip proof | Reuse for QA memory/runtime checks |
| `docs/operations/discord-context-skill-pilot-roadmap.md` | Pilot order and scope for #57 and #61-#65 | Reuse for workflow-specific QA walkthroughs |

## Acceptance matrix

| Test case | Scope | Owner | Preconditions | Steps | Expected result | Evidence to capture | Pass / fail rule |
|---|---|---|---|---|---|---|---|
| `M1-FOUNDATION` | M1 Foundation: repo shape, docs, Docker foundation, issue workflow | `QA+agent` | `main` synced; AGENT #102 green | Review README/ops docs, repo layout, issue-first workflow, Docker entry docs | Repo explains setup and boundaries without implying production readiness | Linked docs reviewed, missing-link notes, baseline command references | **Pass** if docs are navigable and aligned; **fail** on stale setup/boundary guidance |
| `M2-MEMORY` | M2 Memory MVP contracts and local roundtrips | `QA+agent` | AGENT #102 and #105 evidence available | Review memory validator evidence, namespace contract, approval boundaries | Local fake/demo memory behavior is clear and separated from production durability | Memory evidence references, namespace notes, any ambiguity list | **Pass** if local/disposable scope is explicit; **fail** on production/durable overclaims |
| `M3-SKILLS` | M3 Content skills: brand, ledger, strategy, LinkedIn, X queue, on-demand brief | `QA+agent` | AGENT #102 green; pilot docs available | Walk each skill/runbook/fixture/validator pairing | Skills are reviewable, approval-gated where needed, and network scope is explicit | Skill-to-doc matrix, missing-context or approval observations | **Pass** if every skill maps cleanly to evidence; **fail** on mismatched skill/doc/fixture behavior |
| `M4-DISCORD-OPS` | M4 Discord routing, namespace mapping, approval responses | `QA+agent` | AGENT #102 green; no live Discord needed | Review routing/approval docs and private-transport boundaries | Discord work stays fake-first or private-only until later gated issues | Routing notes, approval response examples, namespace references | **Pass** if no public/live assumptions leak in; **fail** on channel-first ownership regressions or live claims |
| `M5-ANALYTICS` | M5 Buffer analytics research plus fake LinkedIn/X snapshots | `QA` | AGENT #102 green | Inspect analytics docs, fixtures, and read-only claims | Analytics remain fake/read-only with no live source dependence | Snapshot validator references, read-only notes, UI/report expectations | **Pass** if fake/read-only scope is clear; **fail** on live analytics or Buffer write claims |
| `M6-DASHBOARD` | M6 Dashboard read models and static overview | `QA` | AGENT #102 green | Review read models, static dashboard artifact, and overview docs | Dashboard remains static/read-only and repo-safe | Screenshot or note of static artifact, read-model references | **Pass** if dashboard is clearly static; **fail** on live API/server assumptions |
| `M7-HARDENING` | M7 CI, dev tooling, data rules, incident/runbook coverage | `QA+agent` | AGENT #102 and #103 green | Review CI docs, safe suite docs, data-handling and incident docs | Verification workflow is understandable and reproducible | CI check names, local reproduction notes, incident/runbook observations | **Pass** if hardening docs support review; **fail** on missing local reproduction or unsafe guidance |
| `P57-ROUTING` | #57 private transport/routing anchor | `QA+agent` | Pilot roadmap available; no live Discord | Review routing contract and approval boundary behavior | Transport stays transport-only; no workflow semantics leak back into channel naming | Routing artifact references, approval boundary notes | **Pass** if transport-only boundary holds; **fail** on workflow ownership in routing |
| `P61-GLOBAL-CONTEXT` | #61 OpenClaw Global context refresh pilot | `QA+agent` | Pilot docs available | Review inheritance, identity, boundaries, and approval expectations | Global context stays explicit, inherited, and approval-gated | Context source references, inheritance notes, approval evidence path | **Pass** if global context is explicit and bounded; **fail** on hidden inheritance or unsanctioned writes |
| `P62-LEDGER` | #62 content-ledger utility pilot | `QA+agent` | Pilot docs and validators available | Review ledger utility flow and durable-vs-runtime note separation | Runtime notes stay out of durable ledger state | Ledger state notes, approval examples, runtime/durable separation notes | **Pass** if durable states stay clean; **fail** on runtime noise inside ledger state |
| `P63-STRATEGY` | #63 category strategy planning pilot | `QA+agent` | Pilot docs and validators available | Review strategy flow with confirmed facts, assumptions, checkpoints, and out-of-scope | Strategy planning stays proposal-only and context-driven | Strategy slice notes, checkpoint evidence, out-of-scope confirmation | **Pass** if strategy remains reviewable/proposal-first; **fail** on fixed-channel or execution claims |
| `P64-LINKEDIN` | #64 LinkedIn weekly planning pilot | `QA+agent` | Pilot docs and validators available | Review LinkedIn-local planning inputs and expected output shape | LinkedIn planning consumes inherited context without claiming posting/scheduling | LinkedIn plan notes, dependency references, out-of-scope confirmation | **Pass** if planning-only boundary is clear; **fail** on live publishing or analytics claims |
| `P65-BRIEFS` | #65 multi-network on-demand brief pilot | `QA+agent` | Pilot docs and validators available | Review route -> pack -> intent -> brief candidate flow and approval-gated writeback | Briefs stay network-separated, reviewable, and non-live | Brief examples, writeback status notes, network split confirmation | **Pass** if brief outputs stay pack-based and approval-gated; **fail** on live fetching, live writes, or merged network semantics |

## Evidence pack template

Use one evidence pack per QA issue (#106-#113) and one final pack for #113.

### Evidence pack header

| Field | What to record |
|---|---|
| Issue | QA issue number and title |
| Test order | `QA-01` through `QA-08` |
| Owner | `QA`, `agent`, or `QA+agent` |
| Date (UTC) | Execution date/time |
| Branch / commit | Branch name and commit/PR if relevant |
| Environment | Local docs-only, local runtime, or private Discord dry-run |
| Preconditions used | Which AGENT artifacts or prior QA packs were reused |
| Status | `pass`, `pass-with-follow-up`, `fail`, `blocked`, or `skipped` |

### Evidence pack body

```markdown
## Scope
- What this QA issue validates
- What it explicitly does not validate

## Preconditions
- Prior issues/evidence used
- Any approvals or environment requirements

## Steps executed
1. ...
2. ...
3. ...

## Expected result
- ...

## Actual result
- ...

## Evidence captured
- Doc / artifact / PR / screenshot / sanitized command output
- Any reused AGENT evidence

## Pass / fail decision
- Status: pass | pass-with-follow-up | fail | blocked | skipped
- Why:

## Follow-up issues
- New issue number(s) if created
- Or `none`
```

## Final regression report template

Use this shape in #113:

| Section | Required content |
|---|---|
| Scope | Which AGENT and QA issues were included |
| Overall result | `pass`, `pass-with-follow-ups`, `blocked`, or `fail` |
| Completed evidence | Links to AGENT #102-#105 and QA #106-#112 evidence packs |
| Coverage summary | M1-M7 plus #57 and #61-#65 coverage status |
| Known limits | What still remains out of scope or unproven |
| Blocking defects | Any issue that must be fixed before release/regression sign-off |
| Follow-up list | New issues or deferred work |
| Release recommendation | `ready for internal baseline`, `needs follow-up`, or `not ready` |

## Stop rules

Stop the QA flow and mark the current issue `blocked` if any of these happen:

- a command or doc path requires production credentials;
- a step would touch public Discord or a non-private social/network surface;
- evidence includes secrets, tokens, private payloads, raw transcripts, or source dumps;
- a workflow attempts live writes, publishing, scheduling, Buffer activity, or GitHub mutations;
- runtime prompt execution becomes necessary for proof;
- the expected prior AGENT evidence is missing or contradictory.

## Shared non-goals

This QA plan does **not**:

- use production credentials;
- use public Discord;
- perform live writes;
- publish or schedule content;
- trigger Buffer activity;
- validate live analytics;
- persist raw transcripts or source dumps;
- execute runtime prompts;
- mutate GitHub state.

## Review path

1. Review the execution order table.
2. Review the acceptance matrix rows for your target issue.
3. Reuse AGENT evidence before creating new QA evidence.
4. Apply the evidence pack template and stop rules.

## Next step

After this matrix is approved, execute #107 next and use this document as the evidence pack source of truth for QA #107-#113.
