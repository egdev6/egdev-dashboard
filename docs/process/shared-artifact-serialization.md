# Shared-artifact serialization procedure

Use this procedure whenever Pi/el Gentleman and OpenClaw may both touch canonical planning artifacts.

## Decision

**Concurrent SDD writes to shared artifacts are disallowed.**

One session owns write access to a shared artifact path at a time. Other sessions may read, comment, or prepare notes, but they must not edit the same shared path until ownership is released.

## Definitions

| Term | Meaning |
|---|---|
| Shared artifact | Any canonical repo artifact: `openspec/`, `docs/adr/`, `docs/architecture/`, `docs/project/`, `docs/process/`, `docs/security/`, `skills/`, and GitHub issue/project metadata. |
| Session owner | The human-directed Pi or OpenClaw session currently allowed to write a shared artifact path. |
| Claim | A lightweight public note that a session owns one or more shared artifact paths for editing. |
| Release | A lightweight public note that the session is done writing those shared artifact paths. |
| Promotion | Moving durable, sanitized Engram memory into a canonical repo artifact under review. |

## Quick path

1. Pick the exact shared artifact paths you need to edit.
2. Claim them in the linked issue comment or PR description.
3. Edit only the claimed paths while you own them.
4. Release the claim when the diff is handed off, merged, or abandoned.
5. If useful runtime memory was created, promote a sanitized summary into the repo before others depend on it.

## Single-writer rule

- One session owns write access to one shared artifact path at a time.
- Ownership is path-based, not repo-wide. Different sessions may write different non-overlapping shared paths.
- If there is doubt about overlap, treat it as overlap and serialize.
- Reads, review comments, and issue discussion are always allowed.
- Writing the same ADR, spec, architecture doc, skill, or issue metadata from two sessions at once is not allowed.

## Claim and release mechanism

Use a low-tech claim. Do **not** add a lockfile.

Preferred claim location:

- the linked GitHub issue comment thread; or
- the active PR description/comment when the work is already in review.

A valid claim should include:

- session surface: `Pi` or `OpenClaw`;
- branch name;
- exact artifact paths;
- intended outcome;
- optional Engram continuity key if the session will leave runtime notes.

Example claim:

```text
Claiming shared artifacts
Surface: Pi
Branch: docs/sdd-artifact-serialization
Paths:
- docs/process/shared-artifact-serialization.md
- docs/adr/0001-runtime-boundary.md
Intent: document single-writer handoff procedure for issue #7
Optional Engram continuity: discord-project-manager/dev/sdd/shared-artifact-serialization/design
```

A release should include:

- final branch or PR reference;
- paths released;
- whether the work was merged, handed off, or abandoned;
- optional Engram summary location if continuity matters.

Example release:

```text
Releasing shared artifacts
Surface: Pi
Branch: docs/sdd-artifact-serialization
Paths:
- docs/process/shared-artifact-serialization.md
- docs/adr/0001-runtime-boundary.md
Status: handed off for review
PR: <link>
Optional Engram summary: discord-project-manager/dev/sdd/shared-artifact-serialization/verify
```

## Before editing shared artifacts

- [ ] Confirm the exact paths you need.
- [ ] Check the linked issue/PR for an active claim.
- [ ] If a claim exists on the same path, do not write; coordinate or wait.
- [ ] If no claim exists, add your claim before editing.
- [ ] Keep any runtime/private notes in Engram, not in public repo drafts.

## Before handoff or release

- [ ] Summarize what changed and which paths are now safe to edit.
- [ ] Note any unresolved risks, follow-ups, or intentionally deferred work.
- [ ] If Engram contains durable knowledge, promote a sanitized summary or link the repo artifact that now captures it.
- [ ] Release the claim in the issue/PR thread.

## Promotion flow from Engram to repo artifacts

Follow ADR 0002 promotion rules.

1. Identify the Engram memory that became durable, review-facing, or reusable.
2. Summarize it in small, sanitized form.
3. Remove secrets, private names, private IDs, raw prompts with secrets, and any data that belongs only in operational memory.
4. Choose the canonical target artifact:
   - `openspec/` for proposal/spec/design/tasks/verify artifacts;
   - `docs/adr/` for architecture decisions;
   - `docs/architecture/`, `docs/project/`, `docs/process/`, or `docs/security/` for reusable process/runtime/security docs;
   - `skills/` for reusable skill behavior/contracts;
   - GitHub issue/PR metadata for review-facing status and coordination.
5. Attach or reference the promoted summary in the linked issue or PR.
6. Review the promoted artifact normally.
7. Mark the Engram summary as promoted in the release note or handoff comment when useful.

## Optional Engram continuity

Engram is operational memory, not the canonical planning surface. Use it for continuity, not ownership.

Recommended continuity keys:

- `discord-project-manager/dev/sdd/<change-id>/<phase>` for Pi development summaries;
- `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` for channel-local OpenClaw runtime notes.

Do not treat an Engram note as a write lock. The repo claim/release note remains the source of truth for ownership.

## Recovery for accidental concurrent edits

If two sessions edited the same shared artifact path:

1. **Stop writes immediately.**
2. **Save local work** in each session (`git diff`, patch file, or branch) before resolving anything.
3. **Compare branches/diffs** and identify the intended source of truth.
4. **Choose one recovery path**:
   - manual merge into one branch;
   - cherry-pick one change onto the chosen source branch;
   - discard one diff only with explicit human approval.
5. **Run a fresh review** after reconciliation.
6. **Document the incident** in the linked issue/PR:
   - affected paths;
   - which branch became source of truth;
   - what was merged or discarded;
   - follow-up prevention note.
7. **Update Engram summaries** if a useful operational lesson should persist.

## What not to do

- Do not add repo lockfiles for ownership.
- Do not let two sessions edit the same ADR/spec/skill/doc at once.
- Do not use runtime Discord memory as the canonical plan.
- Do not promote raw operational memory without sanitizing it first.
