# Private Discord manual verification guide

Use this guide to organize **manual** operator verification for the planned Discord workflow in a **private non-production environment**.

This is a repo-safe preparation and test-organization guide only. It does **not** prove production readiness, public Discord readiness, live routing safety, durable write safety, or approval enforcement. The current repository baseline remains **internal fake-first/local only**.

## Quick path

1. Confirm the private/local runtime baseline is already green.
2. Prepare a private Discord topology with fake/demo names and no public surfaces.
3. Review global governance, routed channels, and fallback channels separately.
4. Run only no-op/manual checks until the runtime has a proven no-op observation path.
5. Capture sanitized evidence only and stop on any boundary breach.

## Safety boundary

| Topic | Rule |
|---|---|
| Repository baseline | Internal fake-first/local only |
| Live Discord execution | Gated; not proven by current repo evidence |
| Plugin behavior | Prerequisite only; not validated by this guide |
| Production/public usage | Out of scope |
| Durable writes | Never before explicit `approve write` and proven enforcement |
| Approval enforcement | Treat as a contract to verify, **not** as already safe runtime behavior |
| Evidence | Sanitized only; no real IDs, credentials, transcripts, or private payloads |

## Manual prerequisites and approvals

Complete these before any private Discord rehearsal:

| Requirement | Why it matters | Repo-safe rule |
|---|---|---|
| Private non-production guild | Prevents public/live spillover | Do not commit the real guild ID |
| Private non-production channels | Needed for matched and unmapped tests | Do not commit real channel IDs |
| Non-production credentials | Required for any future live-adjacent runtime hookup | Keep outside git and PR text |
| Private/local Docker runtime already validated | Discord checks must start from a known local runtime baseline | Reuse `docs/operations/runtime-pilot-checklist.md` and `docs/operations/qa-private-docker-runtime-smoke-walkthrough.md` |
| Explicit human approval | QA-07 remains gated | Record only the decision, not secrets |
| Proven no-op observation path | Routing must be verifiable without prompt execution or writes | Accept only resolver-only diagnostic, dry-run mode, or re-tested enforcement |

Manual user steps required before future execution: **yes**.

Required future manual prerequisites:

- provide a private non-production Discord guild;
- provide private non-production channels;
- provide non-production credentials outside the repo;
- explicitly approve the private Discord rehearsal;
- confirm a no-op resolver diagnostic, plugin/runtime dry-run mode, or re-tested enforcement path exists before any private message is sent.

## What is in scope vs out of scope

| Layer | In scope for this guide | Out of scope |
|---|---|---|
| Docs/planning | topology, naming, manual test organization, pass/fail expectations | claiming the Discord runtime already passed |
| Local/private runtime | startup, health, skill sync, safe shutdown | public hosting, production services |
| Private Discord-live-adjacent rehearsal | preparation, gating, manual checklists, sanitized evidence shape | unapproved plugin execution, prompt execution, durable writes, public Discord behavior |

## Start and stop the local environment

Use the runtime checklist as the source of truth. Start from a private/local shell only.

### Startup

```bash
docker compose config --quiet
docker compose --profile setup run --rm openclaw-setup
docker compose up -d postgres engram openclaw
docker compose ps
docker compose exec openclaw node -e "fetch('http://127.0.0.1:18789/healthz').then(async r => { console.log(r.status, await r.text()) })"
curl -sS http://127.0.0.1:18080/health
```

### Shutdown

```bash
docker compose down
docker compose ps
```

### Environment checklist

- [ ] `.env` is private and untracked.
- [ ] OpenClaw is healthy on loopback only.
- [ ] Engram is healthy on loopback only.
- [ ] Current tracked skills are present in the OpenClaw workspace.
- [ ] No `docker compose down -v` was used.
- [ ] No Discord plugin action is taken in this issue.

Use these docs together:

- `docs/operations/runtime-pilot-checklist.md`
- `docs/operations/private-docker-runtime-validation.md`
- `docs/operations/qa-private-docker-runtime-smoke-walkthrough.md`

## Discord topology to create manually

Use fake/demo names in docs and notes. Keep real guild/channel IDs outside the repo.

### A. Global governance/control category

`OpenClaw Global` is a reserved control category for governance, not a standard routed content channel set.

Suggested control channels:

| Channel | Purpose | Route-matched? |
|---|---|---|
| `identity` | stable project identity and positioning | no |
| `writing-style` | voice and reusable style guidance | no |
| `operating-principles` | review, quality, and collaboration rules | no |
| `boundaries` | privacy, safety, and no-go constraints | no |
| `inheritance` | explicit opt-in inheritance review | no |
| `skills` | scoped skill review and override discussion | no |

### B. Routed project/network channels

These are the channels that should follow the canonical routing contract:

```text
<network-slug>-<project-slug>
```

Suggested fake/demo routed channels:

| Channel | Expected durable network namespace |
|---|---|
| `linkedin-egdev` | `discord-project-manager/project/egdev/network/linkedin` |
| `x-egdev` | `discord-project-manager/project/egdev/network/x` |
| `youtube-egdev` | `discord-project-manager/project/egdev/network/youtube` |
| `twitch-egdev` | `discord-project-manager/project/egdev/network/twitch` |
| `stack-and-flow-egdev` | `discord-project-manager/project/egdev/network/stack-and-flow` |

Shared durable read candidates for a matched route remain:

- `discord-project-manager/project/egdev/brand`
- `discord-project-manager/project/egdev/strategy`
- `discord-project-manager/project/egdev/content-ledger`
- `discord-project-manager/project/egdev/network/<network-slug>`

### C. Workflow/control channels for human organization

These channels help operators review workflow intent, but they are **not** canonical route-matched project/network channels unless a narrower contract explicitly says so.

| Channel | Purpose | Route-matched? |
|---|---|---|
| `strategy-review` | category strategy proposal review | no |
| `content-ledger-review` | ledger candidate review | no |
| `approval-preview` | approval prompt contract review | no |
| `context-pack-review` | context pack / skill pack review | no |
| `brief-review` | multi-network brief review | no |
| `memory-context-review` | runtime-vs-durable namespace review | no |

### D. Intentional fallback channel

Create one unmapped channel such as:

- `general`
- `qa-unmapped-demo`

This channel must remain runtime-only and must **not** silently default to a project/network route.

## How to create categories and channels

Use the Discord UI manually. Keep notes sanitized.

### Create a global/control category

1. Create a private category named `OpenClaw Global`.
2. Add only governance/control channels such as `identity`, `writing-style`, `operating-principles`, `boundaries`, `inheritance`, and `skills`.
3. Do **not** treat these channels as canonical `<network-slug>-<project-slug>` routes.
4. Record only fake/demo channel names in repo-safe evidence.

### Create routed channels

1. Create a private category for routed work, for example `Egdev Routed`.
2. Add channels using lowercase kebab-case `<network-slug>-<project-slug>` names.
3. Keep the set small and intentional for rehearsal:
   - `linkedin-egdev`
   - `x-egdev`
   - one or two additional network examples only if needed
4. Confirm each channel name is deterministic and reviewable before any runtime test.

### Create workflow/control review channels

1. Create a separate private review category such as `Workflow Review`.
2. Add non-routed control channels like `strategy-review`, `content-ledger-review`, `approval-preview`, `brief-review`, and `memory-context-review`.
3. Use these for human workflow review, not as substitutes for canonical route-matched channels.

### Create the fallback channel

1. Add one intentionally unmapped channel such as `qa-unmapped-demo`.
2. Use it to verify runtime-only fallback behavior.
3. Do not pre-assign a guessed project or network to this channel.

## Global context management guide

Use `docs/operations/openclaw-global-brand-context-refresh.md` as the source contract.

### Global control areas to manage

| Control area | What to verify |
|---|---|
| `identity` | stable positioning and project identity stay explicit |
| `writing-style` | voice/tone guidance stays reviewable and bounded |
| `operating-principles` | review/quality rules are readable and reusable |
| `boundaries` | safety/privacy/publishing limits stay explicit |
| `inheritance` | opt-in inheritance rules are explicit and never automatic |

### Global context review checklist

- [ ] Control input uses fake/demo notes only.
- [ ] Inheritance is explicit opt-in only.
- [ ] Global updates remain draft/proposal until `approve write`.
- [ ] Rejected or revised drafts remain runtime-local/audit-only.
- [ ] No raw transcripts, real IDs, or private names appear in evidence.

### Global context operator flow

1. Review one control area at a time.
2. Draft a reviewable summary before any persistence.
3. Propose inheritance to specific categories/networks only.
4. Preview the derived Context Pack / Skill Pack effect.
5. Require exact `approve write` before any durable write.
6. If rollback is needed, revert to the prior approved global draft and record a sanitized note only.

## Base channel guide by purpose

Use this table to explain what each channel type is for and what “working correctly” means.

| Channel type | Example | What to verify | Expected safe outcome |
|---|---|---|---|
| Global governance | `identity` | control area is reviewable, explicit, and bounded | no automatic inheritance or hidden writes |
| Skills control | `skills` | effective skills and overrides are discussed explicitly | `discord-approval-gate` stays mandatory for write-like flows |
| Strategy review | `strategy-review` | proposal shows confirmed facts, assumptions, and missing context | remains proposal-only until approval |
| Ledger review | `content-ledger-review` | candidate uses allowed states only | no scheduling/publishing implied |
| Memory/context review | `memory-context-review` | runtime and durable namespaces stay separate | no durable write happens implicitly |
| Routed LinkedIn planning | `linkedin-egdev` | weekly plan candidate includes `missing_context` | planning only; no publishing or analytics claims |
| Routed X planning | `x-egdev` | queue/plan remains reviewable and approval-gated | no scheduling or Buffer activity |
| Brief review | `brief-review` or routed brief context | network-separated brief candidates stay bounded | no live fetching or durable write |
| Approval preview | `approval-preview` | response state stays `proposal` or `approval-requested` | exact `approve write` phrase required |
| Fallback testing | `qa-unmapped-demo` | unmapped route stays runtime-only | operator is asked to choose an approved route |

## Routing rules and namespace expectations

### Matched route expectation

For a routed channel such as `linkedin-egdev`:

- runtime namespace must still be:

  ```text
  discord-project-manager/runtime/discord/<guild-id>/<channel-id>
  ```

- durable read candidates may include:

  ```text
  discord-project-manager/project/egdev/brand
  discord-project-manager/project/egdev/strategy
  discord-project-manager/project/egdev/content-ledger
  discord-project-manager/project/egdev/network/linkedin
  ```

- durable writes remain approval-gated.

### Unmapped expectation

For `general` or `qa-unmapped-demo`:

- stay in runtime-only fallback mode;
- do not read durable project namespaces;
- do not write durable project namespaces or workspace files;
- ask the operator to choose or create an approved route.

### Skill/context layering expectation

When reviewing packs, expect these scopes when applicable:

- `runtime`
- `global`
- `category`
- `channel`
- `thread-session`
- `scoped-skill-context`

`discord-approval-gate` remains mandatory for write-like flows.

## Manual test matrix

Run only the tests that fit the currently approved boundary. If a test would require prompt execution, workspace writes, or durable writes before approval, stop and mark it blocked.

| Test ID | Area | Manual action | Expected result | Evidence |
|---|---|---|---|---|
| `DV-01` | Local runtime startup | Start the local/private runtime from the checklist | OpenClaw and Engram are healthy on loopback only | sanitized command output |
| `DV-02` | Global category setup | Create `OpenClaw Global` and control channels | governance/control surfaces are separate from routed channels | fake/demo topology note |
| `DV-03` | Routed channel setup | Create `linkedin-egdev` and `x-egdev` | routed channels follow `<network-slug>-<project-slug>` | fake/demo channel list |
| `DV-04` | Fallback setup | Create `qa-unmapped-demo` | one intentional unmapped channel exists | fake/demo channel list |
| `DV-05` | Global context review | Review one control area plus inheritance rule | inheritance is explicit opt-in only | sanitized checklist note |
| `DV-06` | Matched-route expectation | Using only a no-op resolver/dry-run path, inspect `linkedin-egdev` | routing status would be `matched-route`; durable reads are brand/strategy/ledger/network | sanitized route outcome |
| `DV-07` | Unmapped fallback | Using only a no-op resolver/dry-run path, inspect `qa-unmapped-demo` | routing status would be `unmapped-channel`; durable reads/writes remain none | sanitized fallback outcome |
| `DV-08` | Approval preview | Use a synthetic event or proven no-op preview for a write-like request | response state is `proposal` or `approval-requested`, never `approved-for-write` | sanitized approval excerpt |
| `DV-09` | Category context | Review one category-local context source for a routed network | category context is explicit, bounded to the route, and does not override global context silently | sanitized category-context checklist |
| `DV-10` | Skills and packs | Review effective skills for one matched route | `discord-approval-gate` is present and skill choices follow global -> category -> channel layering | sanitized skill-pack checklist |
| `DV-11` | Memory/context separation | Review runtime namespace and durable namespace targets for one planned action | runtime audit namespace stays separate from brand/strategy/ledger/network durable namespaces | sanitized namespace checklist |
| `DV-12` | Strategy contract | Review strategy output requirements in a strategy-oriented surface | confirmed facts, assumptions, and missing context stay separate | sanitized proposal checklist |
| `DV-13` | Ledger contract | Review ledger candidate shape and allowed states | only `draft`, `queued`, `published`, `archived` appear | sanitized ledger checklist |
| `DV-14` | LinkedIn planning contract | Review a LinkedIn weekly plan candidate | `planning_basis.missing_context` exists and planning stays review-only | sanitized candidate excerpt |
| `DV-15` | X/brief contract | Review brief or X planning candidate structure | network-separated planning stays bounded and approval-gated | sanitized candidate excerpt |
| `DV-16` | Evidence hygiene | Inspect captured notes/screenshots | no real IDs, secrets, transcripts, or raw logs are retained | sanitized evidence checklist |
| `DV-17` | Safe shutdown | Stop the local runtime | shutdown is clean and non-destructive | sanitized command output |

## Pass / fail matrix

| Area | Pass when | Fail when |
|---|---|---|
| Environment | local runtime starts, is healthy, and shuts down safely | runtime needs destructive cleanup or public surfaces |
| Topology | global/control, routed, and fallback channels are clearly separated | routed and control surfaces are blurred or guessed |
| Global context | inheritance is explicit and reviewable | inheritance is assumed or automatic |
| Category context | category-local context is explicit, scoped, and subordinate to approved inheritance | category context silently overrides global rules or leaks across routes |
| Skills and packs | effective skills are visible and `discord-approval-gate` stays mandatory | write-like flows omit the approval gate or hide skill overrides |
| Memory/context | runtime audit namespaces and durable target namespaces stay separate | runtime notes become durable memory or workspace files without approval |
| Routing | matched and unmapped expectations are reviewable through a no-op path | routing proof requires prompt execution or writes |
| Approval | `approve write` stays explicit and no-op boundaries are visible | approval is bypassed or silent writes appear |
| Workflow contracts | strategy, ledger, LinkedIn, X, and briefs stay bounded and fake-first | live execution, publishing, or durable writes are implied |
| Evidence | only sanitized notes are kept | real IDs, secrets, transcripts, or private payloads appear |

## Sanitized evidence checklist

- [ ] Use placeholders such as `<guild-id>` and `<channel-id>`.
- [ ] Keep real guild/channel IDs outside the repo.
- [ ] Do not commit credentials, tokens, or `.env` values.
- [ ] Do not commit Discord exports, full screenshots with secrets, or transcripts.
- [ ] Keep route outcomes, approval states, and namespace notes short and review-safe.
- [ ] Record whether a test was `pass`, `blocked`, or `not run`.

## Stop rules / abort conditions

Stop immediately if any of these appear:

- production credentials are required;
- the environment points at a public guild/channel;
- a routing check requires prompt execution or workspace writes;
- a write-like request causes durable writes before explicit approval;
- plugin setup is not reversible or is unclear;
- evidence would require raw transcripts, raw logs, secrets, or private payloads;
- the flow implies publishing, scheduling, Buffer activity, live analytics, or GitHub mutations.

## Known gaps / not yet proven

These remain **not yet proven** even after following this guide:

- live Discord plugin/runtime behavior;
- approval enforcement safety under real Discord traffic;
- durable write safety from Discord-originated requests;
- public Discord readiness;
- production credentials or production hosting readiness;
- live analytics, publishing, scheduling, or Buffer behavior.

Treat this guide as operator preparation for a **future gated rehearsal**, not as proof that the Discord runtime is already ready.

## Related references

- `docs/operations/qa-private-discord-routing-dry-run-plan.md`
- `docs/operations/discord-routing.md`
- `docs/operations/runtime-pilot-checklist.md`
- `docs/operations/discord-approval-responses.md`
- `docs/operations/openclaw-global-brand-context-refresh.md`
- `docs/operations/category-strategy-planning-flow.md`
- `docs/operations/content-ledger-utility-flow.md`
- `docs/operations/linkedin-weekly-planning-flow.md`
- `docs/operations/on-demand-brief-flow.md`
- `docs/architecture/discord-channel-routing.md`
- `docs/architecture/channel-context-namespace-mapping.md`
- `docs/architecture/discord-context-skill-packs.md`
- `docs/architecture/discord-scoped-skills-registry.md`
- `examples/discord-runtime-orchestrator.fake.yaml`

## Next step

If the team wants a private Discord rehearsal later, use this guide **together with** `docs/operations/qa-private-discord-routing-dry-run-plan.md` and keep QA-07 execution blocked until the private environment, explicit approval, and no-op observation path are all available.