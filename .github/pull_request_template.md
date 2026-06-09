## Summary

<!-- What does this PR change? Keep it reviewable and scoped to one approved issue/work unit. -->

## Linked issue

- Closes #<!-- issue number -->
- [ ] Linked issue has `status:approved`
- [ ] If there is no linked approved issue, this is a trivial docs/process-only exemption and the reason is explained below:

<!-- Exemption reason, if any. -->

## Target branch

- [ ] Feature/fix/docs work targets `develop`
- [ ] Release promotion or urgent hotfix targets `main`
- [ ] Other target branch rationale is explained below

<!-- Target branch rationale, especially for PRs to main. -->

## Review path

1. Review the linked issue and acceptance criteria.
2. Review the smallest work unit first.
3. Verify docs/config changes before implementation details.
4. Check private runtime/evidence hygiene before merge.

## Validation evidence

- [ ] Relevant docs updated or not needed
- [ ] Runtime/config assumptions called out explicitly or not applicable
- [ ] Safe validation commands recorded below
- [ ] Docker/OpenClaw validation recorded if runtime files changed
- [ ] Manual/private verification summarized with sanitized evidence only, if applicable

```bash
# commands run
```

## Security and private data hygiene

- [ ] No secrets committed
- [ ] No real Discord IDs committed or pasted into GitHub evidence
- [ ] No credentials, screenshots, raw logs, transcripts, or private payloads included
- [ ] Any private runtime evidence is summarized with placeholders only
- [ ] Generated files, fixtures, and docs are repo-safe

## Release impact

- [ ] Changelog/release notes updated or not needed
- [ ] Installation/configuration docs updated or not affected
- [ ] Smoke/rehearsal impact noted or not affected
- [ ] Known limitations updated or not affected

## Out of scope

<!-- Explicitly list what this PR does not do. -->
