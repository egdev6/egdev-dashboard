# Developer tooling

This repo keeps local checks close to CI so contributors catch issues before pushing.

## Tooling stack

| Tool | Purpose |
|---|---|
| Lefthook | Local `pre-commit`, `commit-msg`, and `pre-push` orchestration. |
| Commitlint | Conventional Commit message validation. |
| actionlint | GitHub Actions workflow validation. |
| shellcheck | Bash/static shell linting. |
| shfmt | Bash formatting check. |
| hadolint | Dockerfile linting. |
| yamllint | YAML linting. |
| markdownlint-cli2 | Markdown linting. |

Biome is intentionally deferred until this repository has a real JavaScript or TypeScript app/package surface. The current repo is mostly Markdown, YAML, Bash, Docker, OpenSpec, and skill contracts.

## Install hooks

Install the external tools with your package manager, then enable hooks:

```bash
lefthook install
```

Typical macOS/Linux package names:

```bash
brew install lefthook actionlint shellcheck shfmt hadolint yamllint
```

Node-based tools are invoked through pinned `npx` commands in hooks and CI, so no app scaffold or `package.json` is required for this repo yet.

## Hook behavior

| Hook | Checks |
|---|---|
| `pre-commit` | staged whitespace, shell syntax, actionlint, shellcheck, shfmt, markdownlint, yamllint, hadolint. |
| `commit-msg` | Commitlint with Conventional Commits. |
| `pre-push` | disposable local Engram memory roundtrips and `docker compose config`. |

The `pre-push` hook is intentionally heavier than `pre-commit`. It may require Docker and the `engram` CLI.

Use a normal Git bypass only for exceptional local recovery:

```bash
git commit --no-verify
LEFTHOOK=0 git push
```

If a bypass is used for a PR, record the reason in the PR body.

## Manual commands

```bash
git diff --check
actionlint
find scripts docker -type f -name "*.sh" -print0 | sort -z | xargs -0 -r bash -n
find scripts docker -type f -name "*.sh" -print0 | sort -z | xargs -0 -r shellcheck
shfmt -d -i 2 -ci scripts docker/openclaw/sync-skills.sh
yamllint .
npx --yes markdownlint-cli2@0.18.1 "**/*.md"
hadolint docker/openclaw/Dockerfile
```

Validate the current commit message file with:

```bash
npx --yes @commitlint/cli@19.8.1 --config .commitlintrc.json --edit .git/COMMIT_EDITMSG
```

## Commit message format

Use Conventional Commits:

```text
<type>(optional-scope): <subject>
```

Accepted examples:

```text
feat(memory): validate strategy planning roundtrip
ci: add foundation validation workflows
chore(tooling): add local dev hooks
docs(ops): document CI behavior
```

Allowed types are configured in `.commitlintrc.json`: `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style`, and `test`.
