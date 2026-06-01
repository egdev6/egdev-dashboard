# OpenClaw skill packaging placeholder

This directory will hold the OpenClaw-facing packaging or linking needed to expose project skills inside the runtime.

Current runtime skill source:

- `skills/discord-approval-gate/SKILL.md` gates Discord write-like intents before persistent writes.
- `skills/*/SKILL.md` is copied into the OpenClaw workspace by `docker/openclaw/sync-skills.sh`.

Expected future contents:

- symlinks or copies to approved project skills
- runtime-specific wrappers if OpenClaw needs a different layout
- notes about how bundled Gentle-AI assets are loaded inside OpenClaw

Keep private prompts and secrets out of this directory.