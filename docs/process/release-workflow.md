# Release workflow

This project uses a develop-to-main workflow for stable releases.

The goal is to keep feature integration moving without treating every merged feature as a stable release. `main` should stay release-ready; `develop` is where approved work is integrated before promotion.

## Branch responsibilities

| Branch | Purpose | Allowed work |
| --- | --- | --- |
| `develop` | Integration branch for approved work | Feature, docs, CI, runtime, and test PRs linked to approved issues |
| `main` | Stable released code | Release promotion PRs, tagged releases, and urgent hotfixes |
| `feature/*`, `docs/*`, `ci/*`, `fix/*` | Short-lived work branches | One approved issue or one tightly scoped work unit |
| `release/*` | Optional release hardening branch | Release-candidate fixes, changelog/release note finalization, smoke-test fixes |
| `hotfix/*` | Urgent stable fix branch | Critical fixes from `main`, then back-merged to `develop` |

## Normal feature flow

Use this for most work.

1. Create or select a GitHub issue.
2. Wait for `status:approved` before implementation.
3. Branch from `develop`:

   ```bash
   git switch develop
   git pull --ff-only
   git switch -c feature/<issue>-short-name
   ```

4. Implement the smallest reviewable slice.
5. Run the relevant local validation commands.
6. Open a PR targeting `develop`.
7. Merge only after required checks pass and review concerns are resolved.

Feature PRs should not target `main` directly unless they are explicitly part of an approved hotfix or release-promotion flow.

## Release flow

Use this when `develop` is ready to become a stable release.

1. Confirm the release milestone/project is complete or explicitly scoped.
2. Confirm all required checks pass on `develop`.
3. Prepare release notes and update `CHANGELOG.md` when present.
4. Either:
   - open a direct release PR from `develop` to `main`; or
   - create a `release/vX.Y.Z-rc.N` branch for final hardening, then PR that branch to `main`.
5. Run the release checklist and any first-run smoke validation.
6. Merge to `main` only when release checks pass.
7. Tag the release from `main`.
8. Publish GitHub release notes.

`main` should represent the code users can install from release documentation. Do not use `main` as a general integration branch.

## When to use a release-candidate branch

A release-candidate branch is optional. Use it when at least one of these is true:

- multiple features landed in `develop` and need final stabilization together;
- installation/configuration docs need a clean rehearsal before release;
- release notes, changelog, or version metadata need review without blocking ongoing `develop` work;
- final smoke testing finds release-only fixes;
- the release has higher user impact or operational risk.

Keep release-candidate branches short-lived. Only merge fixes needed for that release.

## Hotfix flow

Use this for urgent fixes to already released code.

1. Branch from `main`:

   ```bash
   git switch main
   git pull --ff-only
   git switch -c hotfix/<issue>-short-name
   ```

2. Link the hotfix to an approved issue or an explicit emergency maintainer decision.
3. Implement the minimal fix.
4. Open a PR targeting `main`.
5. After merge and release/tag, back-merge or cherry-pick the fix into `develop`.

Hotfixes should not become a bypass for normal feature work.

## Required checks by target branch

The exact GitHub branch-protection configuration is handled separately, but the policy is:

### PRs targeting `develop`

Required checks cover:

- `Repository contracts`: whitespace, shell syntax, GitHub Actions lint, shell lint/formatting, YAML lint, Markdown lint, commit message lint, and repo-safe evidence hygiene via `scripts/validate-repo-safe-evidence.sh`;
- `Safe validator suite`: fake-first repository validators via `scripts/run-safe-validation-suite.sh`;
- `Compose config and OpenClaw image build`: Docker Compose configuration, Dockerfile lint, and OpenClaw image build;
- `Gitleaks secret scan`: secret scanning.

These checks must not require private Discord credentials or private runtime data.

### PRs targeting `main`

Release-promotion or hotfix PRs to `main` require everything from `develop`, plus release-specific review evidence such as:

- changelog or release notes update when user-visible behavior changes;
- release checklist completion;
- installation/configuration docs acknowledgement;
- confirmation that no private Discord IDs, tokens, screenshots, raw logs, transcripts, or private payloads are included.

## Changelog and release notes

Use the changelog and release notes to explain what changed from the user's point of view.

For feature and fix PRs:

- note whether user-facing behavior changed;
- update `CHANGELOG.md` when the project has one and the change is release-relevant;
- otherwise document why the change is internal-only.

For release PRs to `main`:

- summarize completed issues/PRs;
- list known limitations;
- call out installation, configuration, migration, and rollback notes;
- include any private-runtime safety notes using sanitized language only.

## Private data policy

No release workflow step should require committing or posting private runtime evidence.

Do not include real Discord IDs, tokens, credentials, screenshots, raw logs, transcripts, or private payloads in public GitHub issues, PRs, docs, fixtures, or release notes. Use sanitized summaries and fake-first validation wherever possible.

Run the repo-safe evidence guard before opening PRs that touch docs, examples, scripts, or templates:

```bash
bash scripts/validate-repo-safe-evidence.sh
```

## Current first-stable-release order

The first stable release readiness track starts with process and automation:

1. define this release workflow;
2. align issue and PR templates with the workflow;
3. harden CI and merge checks;
4. finish installation/configuration/usage documentation;
5. run a clean first-run rehearsal before release promotion.
