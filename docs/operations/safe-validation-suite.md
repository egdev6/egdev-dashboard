# Safe validation suite

Use this suite as the first verification step after the roadmap baseline is complete and before any Docker runtime, private Discord, or QA smoke work.

## Command

```bash
bash scripts/run-safe-validation-suite.sh
```

For CI-style validator-only reproduction after the hygiene/lint steps already passed:

```bash
SAFE_VALIDATION_SKIP_STAGE0=1 bash scripts/run-safe-validation-suite.sh
```

## What it does

The suite runs two safe local stages:

1. **Stage 0 — static hygiene**
   - `git diff --check`
   - `bash -n` over every `scripts/*.sh` and `docker/**/*.sh`
   - optional local lint tools when installed: `actionlint`, `shellcheck`, `shfmt`, `yamllint`, and `markdownlint-cli2`
2. **Stage 1 — safe validators**
   - discovers every `scripts/validate-*.sh`, sorted
   - runs each validator exactly once
   - stops on the first failing command and prints the failing step

Validator discovery is dynamic, so new fake-first validators are picked up automatically without editing this runner.

If `SAFE_VALIDATION_SKIP_STAGE0=1` is set, the suite skips the static hygiene/lint stage and only runs the safe validator stage. This is intended for CI jobs that already ran repo-wide whitespace, syntax, and lint checks earlier in the workflow.

## Coverage by feature area

Stage 1 covers the existing fake-first contract surfaces in this repo, including:

- Discord contracts and routing foundations
- approval-gated workflow pilots for brand context, content ledger, strategy, LinkedIn planning, on-demand briefs, and X queue ingestion
- local Engram memory roundtrip validators
- fake analytics snapshots
- dashboard read models and static overview artifacts

## Prerequisites

Required:

- `bash` with array and process-substitution support
- `git`
- standard POSIX utilities used by the underlying validators
- `engram` on `PATH` for the local memory roundtrip validators

Optional Stage 0 tools:

- `actionlint`
- `shellcheck`
- `shfmt`
- `yamllint`
- `markdownlint-cli2`

If `markdownlint-cli2` is not installed globally, you can opt into an `npx` fallback:

```bash
SAFE_VALIDATION_USE_NPX_MARKDOWNLINT=1 bash scripts/run-safe-validation-suite.sh
```

When markdown lint runs, the suite temporarily moves aside an untracked local `context.md` so repo-wide linting does not fail on that file. If `context.md` is tracked by Git, the suite leaves it in place.

## Non-goals

This suite does **not**:

- start Docker or validate private runtime health
- install or use the Discord plugin
- connect to live Discord
- require production credentials
- perform durable production writes
- publish, schedule, or trigger Buffer activity
- validate live analytics
- execute runtime prompts
- mutate GitHub state

## How this differs from later stages

This suite only proves the repo-safe fake-first baseline.

Use later stages for:

- private Docker runtime validation
- OpenClaw skill sync checks inside the runtime
- private Discord routing dry-runs
- QA/manual walkthroughs and release evidence

Those stages belong to the later verification issues and should only start after this safe suite is green.

## CI usage

GitHub Actions uses this suite in two parts:

1. `Repository contracts` keeps the repo-wide whitespace, syntax, formatting, YAML, Markdown, and commit-message checks.
2. `Safe validator suite` installs the local Engram CLI and runs `SAFE_VALIDATION_SKIP_STAGE0=1 bash scripts/run-safe-validation-suite.sh` so CI covers dashboard, analytics, planning-flow, memory, Discord, and X queue validators without duplicating the hygiene stage.

Local reproduction for the CI validator phase is the same command:

```bash
SAFE_VALIDATION_SKIP_STAGE0=1 bash scripts/run-safe-validation-suite.sh
```
