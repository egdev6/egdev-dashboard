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
- `docs/architecture/discord-semantic-channel-guides.md` defines the canonical fake guide catalog for managed channel topics and starter/pinned prompts.
- `docs/architecture/discord-project-manager-global-init.md` defines the fake `/project-manager init` contract for creating the global Project Manager category and channels.
- `examples/discord-project-manager-global-init.fake.yaml` provides fake global init topology, permission, persistence, and idempotency data.
- `scripts/validate-discord-project-manager-global-init.sh` validates the global init contract and fixture.
- `docs/architecture/discord-context-skill-packs.md` defines the fake Context Pack and Skill Pack schemas for Discord prompt preparation.
- `docs/architecture/discord-runtime-orchestrator.md` defines the fake Runtime Orchestrator contract for Discord event envelopes, intent routing, and runner selection.
- `docs/architecture/discord-gentle-sdd-handoff.md` defines the fake handoff contract between OpenClaw Runtime Orchestrator and Gentle SDD.

Do not store live credentials, real guild/channel IDs, or exported runtime state here.
