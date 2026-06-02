# CI foundation

This repository uses lightweight GitHub Actions checks to protect public repo contracts before runtime deployment exists.

## Workflows

| Workflow | File | Purpose |
|---|---|---|
| CI | `.github/workflows/ci.yml` | Repository hygiene, workflow linting, shell linting/format checks, YAML/Markdown linting, commit message linting, and the safe validator suite with a pinned Engram CLI. |
| Docker smoke | `.github/workflows/docker.yml` | Lints the OpenClaw Dockerfile, validates Docker Compose rendering, and builds the OpenClaw runtime image. |
| Security scan | `.github/workflows/security.yml` | Runs Gitleaks to catch accidentally committed secrets. |

All workflows run on pull requests to `main`, pushes to `main`, and manual `workflow_dispatch`.

## Local equivalent

Run the main checks before opening a PR:

```bash
git diff --check
actionlint
find scripts docker -type f -name "*.sh" -print0 | sort -z | while IFS= read -r -d '' script; do bash -n "$script"; done
find scripts docker -type f -name "*.sh" -print0 | sort -z | xargs -0 -r shellcheck
shfmt -d -i 2 -ci scripts docker/openclaw/sync-skills.sh
yamllint .
npx --yes markdownlint-cli2@0.18.1 "**/*.md"
npx --yes @commitlint/cli@19.8.1 --config .commitlintrc.json --last
```

For the complete safe validator suite, use the shared runner. It discovers every `scripts/validate-*.sh`, including memory, Discord, dashboard, analytics, planning-flow, and X queue validators:

```bash
bash scripts/run-safe-validation-suite.sh
```

For CI-style validator-only reproduction after local hygiene already passed:

```bash
SAFE_VALIDATION_SKIP_STAGE0=1 bash scripts/run-safe-validation-suite.sh
```

Memory validators create a disposable `ENGRAM_DATA_DIR` by default.

For Docker validation:

```bash
hadolint docker/openclaw/Dockerfile
docker compose config
docker build --pull --file docker/openclaw/Dockerfile --tag discord-project-manager-openclaw:ci .
```

## Boundaries

Local hook setup is documented in `docs/operations/dev-tooling.md`.

These checks do not deploy services or publish images. They also do not validate:

- OpenClaw live Discord routing;
- Engram Cloud enrollment or sync;
- Buffer analytics;
- production secrets or hosted infrastructure.

Those belong to later runtime and deployment work.
