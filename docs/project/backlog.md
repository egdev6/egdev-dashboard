# discord-project-manager backlog

GitHub tracking:

- Repository: <https://github.com/egdev6/discord-project-manager>
- Project: <https://github.com/users/egdev6/projects/3>
- Initial issues: <https://github.com/egdev6/discord-project-manager/issues>

This backlog is optimized for the current intended architecture of `discord-project-manager`:

- OpenClaw is the dockerized runtime target.
- Pi/el Gentleman is the repo-development SDD harness.
- Gentle-AI SDD may run inside OpenClaw for operations, pending runtime validation.
- Canonical shared-planning artifacts are `openspec/`, `docs/adr/`, `docs/architecture/`, `docs/project/`, `skills/`, and GitHub issues/project metadata.
- Engram summaries are operational memory until promoted into a repo artifact.

## Phases

| Phase | Goal | Exit criteria |
|---|---|---|
| M1 Foundation | Validate portable runtime boundaries | Docker skeleton, ADRs, issue templates, and runtime validation issue set exist |
| M2 Memory MVP | Prove Engram-backed context persistence | Namespaces are defined and at least one persistent skill contract is validated |
| M3 Content skills | Model reusable content workflows | Brand, ledger, and strategy skills have stable inputs and outputs |
| M4 Discord operations | Bind runtime behavior to channel conventions | Discord routing and channel-to-project mapping are documented and tested |
| M5 Buffer analytics | Ingest read-only performance data | Buffer access and normalized snapshots are available |
| M6 Dashboard | Expose read models for humans | Read-only dashboard or API exists over validated contracts |
| M7 Hardening | Make the repo maintainable for public growth | CI, data-handling guidance, and operational runbooks exist |

## Initial issues

### M1 Foundation

1. **research(runtime): verify Gentle-AI SDD inside dockerized OpenClaw**
   - Labels: `type:research`, `area:runtime`, `priority:p0`, `status:needs-review`
   - Done when: the team confirms how OpenClaw loads project skills, where Gentle-AI assets live, and how Docker should package them.

2. **feat(repo): add portable Docker foundation for OpenClaw and Engram**
   - Labels: `type:infra`, `area:runtime`, `priority:p0`, `status:needs-review`
   - Depends on: #1
   - Done when: confirmed images or Dockerfiles replace placeholders and the baseline compose flow is documented.

3. **docs(adr): define Engram namespace contract for shared operational memory**
   - Labels: `type:docs`, `area:memory`, `priority:p0`, `status:needs-review`
   - Depends on: #1
   - Done when: project, network, and operational namespaces are approved.

4. **feat(skills): scaffold project skills for brand context, content ledger, and strategy planning**
   - Labels: `type:feature`, `area:skills`, `priority:p0`, `status:needs-review`
   - Depends on: #3
   - Done when: skill contracts are reviewable and safe to evolve without private data.

5. **docs(process): create GitHub Project fields and views for M1-M7 tracking**
   - Labels: `type:docs`, `area:process`, `priority:p1`, `status:needs-review`
   - Done when: status, milestone, area, risk, and size views are defined.

6. **docs(security): define secrets, retention, export, and public/private data rules before live memory use**
   - Labels: `type:docs`, `area:security`, `priority:p0`, `status:needs-review`
   - Depends on: #2, #3
   - Done when: the team has an approved rule set for what can live in git, Docker volumes, and Engram before onboarding real projects.

7. **docs(process): define shared-artifact serialization procedure for Pi and OpenClaw SDD**
   - Labels: `type:docs`, `area:process`, `priority:p0`, `status:needs-review`
   - Depends on: #1
   - Done when: concurrent SDD writes are disallowed procedurally and there is a documented handoff rule for shared artifact edits.

### M2 Memory MVP

8. **feat(memory): validate persistent brand-context writes in Engram**
9. **feat(memory): validate content-ledger reads and writes through a stable contract**
10. **feat(workflow): prove a strategy planning roundtrip using persistent context**

### M3 Content skills

11. **feat(skill): define LinkedIn weekly planning inputs and outputs**
12. **feat(skill): define X queue planning inputs and outputs**
13. **feat(skill): define on-demand brief workflow for YouTube, Twitch, and Stack and Flow**

### M4 Discord operations

14. **feat(runtime): define channel naming and routing conventions**
15. **feat(runtime): map channel context to Engram namespaces**
16. **feat(runtime): document approval-oriented Discord responses**

### M5 Buffer analytics

17. **research(buffer): validate read-only analytics scope and auth model**
18. **feat(buffer): ingest LinkedIn snapshots**
19. **feat(buffer): ingest X snapshots**

### M6 Dashboard

20. **feat(api): expose read models over validated memory contracts**
21. **feat(ui): build minimal project and network overview**

### M7 Hardening

22. **feat(ci): add lint and docs validation for foundation changes**
23. **docs(ops): add runtime and incident runbook**

## Suggested GitHub Project fields

- `Status`: Backlog / Ready / In Progress / In Review / Blocked / Done
- `Milestone`: M1-M7
- `Priority`: p0 / p1 / p2
- `Area`: runtime / memory / skills / process / security / analytics / dashboard / docs
- `Size`: XS / S / M / L
- `Risk`: low / medium / high

## Recommended review rule

If a planned change exceeds the 600-line review budget, split it before implementation. Future runtime, dashboard, or live-integration work should stay reviewable by default.
