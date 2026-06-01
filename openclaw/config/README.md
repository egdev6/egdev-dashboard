# OpenClaw config placeholder

This directory is reserved for example config fragments, runtime notes, and local setup guidance related to OpenClaw.

Expected future contents:

- validated routing examples
- environment notes for Docker deployment
- references to confirmed image tags or Dockerfiles

Current routing references:

- `skills/discord-approval-gate/SKILL.md` defines the runtime approval gate for Discord write-like intents.
- `docs/architecture/discord-channel-routing.md` defines channel naming and namespace mapping.
- `docs/architecture/channel-context-namespace-mapping.md` defines resolver inputs, outputs, and fallback status.
- `docs/operations/discord-routing.md` defines the operator runbook and fallback behavior.
- `docs/operations/discord-approval-responses.md` defines approval prompts and audit trail requirements.
- `docs/architecture/discord-topology-reconciliation.md` defines category/channel discovery and safe reconciliation states.
- `examples/discord-topology-reconciliation.fake.yaml` provides fake topology reconciliation data for validator-driven review.
- `docs/architecture/discord-context-namespace-provisioning.md` defines draft context artifact provisioning from approved topology actions.
- `examples/discord-context-provisioning.fake.yaml` provides fake provisioning plans for validator-driven review.
- `docs/architecture/discord-scoped-skills-registry.md` defines the fake scoped skills registry and control-channel contract.
- `docs/architecture/discord-memory-gateway.md` defines the fake Memory Gateway / Context Broker contract for Discord flows.

Do not store live credentials, real guild/channel IDs, or exported runtime state here.
