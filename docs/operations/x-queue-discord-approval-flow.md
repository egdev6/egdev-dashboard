# X queue Discord approval flow

Use this runbook for the contract-only path from fake source ingestion to an approval-gated X queue proposal.

This runbook does not prove live Discord routing, runtime enforcement, Engram writes, Buffer activity, publishing, or scheduling.

## Quick path

1. Normalize fake source input into reviewable X queue candidates.
2. Show the queue proposal and approval prompt before any persistent write.
3. Keep runtime audit details under `discord-project-manager/runtime/discord/<guild-id>/<channel-id>` only after an explicit operator decision.

## Flow

| Step | Decision |
| --- | --- |
| Source ingestion | Accept fake/manual source input only for this contract slice. |
| Queue proposal | Produce proposal-only queue candidates for `discord-project-manager/project/egdev/network/x`. |
| Approval gate | Use `approve write`, `revise: <instruction>`, or `reject` exactly. |
| Runtime audit | Keep pre-approval audit fields in the response; persist only after decision. |
| Out of scope | No live Discord validation, Buffer activity, publishing, scheduling, or production credentials. |

## Approval prompt

Use the same response shape defined in `docs/operations/discord-approval-responses.md`.

```text
Proposed durable update
Route: egdev/x
Runtime context: discord-project-manager/runtime/discord/<guild-id>/<channel-id>
Target namespace: discord-project-manager/project/egdev/network/x
Runtime audit namespace: discord-project-manager/runtime/discord/<guild-id>/<channel-id>
Change summary: append approved X queue candidates from fake source ingestion
Risk boundary: no durable writes, workspace files, publishing, scheduling, or Buffer activity before approval

Reply with exactly one option:
- approve write
- revise: <instruction>
- reject
```

## Review checklist

- [ ] Source input is fake/demo and safe for repo review.
- [ ] Queue candidates stay proposal-only before approval.
- [ ] Target namespace is `discord-project-manager/project/egdev/network/x`.
- [ ] Runtime audit namespace uses `discord-project-manager/runtime/discord/<guild-id>/<channel-id>`.
- [ ] No durable memory writes or workspace file writes happen before approval.

## Local validation

```bash
bash scripts/validate-x-queue-source-ingestion.sh
bash scripts/validate-discord-approval-gate.sh
npx --yes yaml-lint examples/x-queue-source-ingestion.fake.yaml examples/x-queue-plan.fake.yaml examples/discord-approval-gate.fake.yaml
```
