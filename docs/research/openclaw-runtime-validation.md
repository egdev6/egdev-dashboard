# OpenClaw runtime validation research

- Issue: [#1](https://github.com/egdev6/egdev-dashboard/issues/1)
- Date: 2026-05-30
- Status: Research and local Docker smoke validation complete

## Executive summary

OpenClaw is a suitable target for the `egdev-dashboard` operational runtime. Public docs and a local Docker smoke test confirm:

- the official `ghcr.io/openclaw/openclaw:latest` image exists and runs;
- OpenClaw can onboard a container-local workspace;
- OpenClaw discovers workspace `SKILL.md` skills;
- the Gateway starts in the container and exposes `/healthz` internally;
- OpenClaw documents Discord setup and routing/bindings.

The important boundary remains: **Gentle-AI/Pi SDD should be adapted into OpenClaw skills/workspace instructions, not assumed to run as native Pi `.pi` agents/chains inside OpenClaw.**

## Confirmed

### Docker setup

OpenClaw documents Docker as optional, with Docker Compose v2 requirements, a local setup script, and a pre-built image path using `OPENCLAW_IMAGE="ghcr.io/openclaw/openclaw:latest"`.

Sources:

- <https://docs.openclaw.ai/install/docker>
- <https://github.com/openclaw/openclaw/blob/main/docs/install/docker.md>

Local validation:

```text
Docker client/server: 29.4.0
Docker Compose: v5.1.2
Image: ghcr.io/openclaw/openclaw:latest
Image digest: sha256:95f4e860a1490e6e83f095d0bb1d2b5c7ac74e1cb62eedad08deb179e831a6de
Entrypoint: ["tini", "-s", "--"]
Cmd: ["node", "openclaw.mjs", "gateway"]
User: node
Workdir: /app
```

The image exposes the OpenClaw CLI through:

```bash
node openclaw.mjs --help
node openclaw.mjs gateway --help
node openclaw.mjs agents --help
node openclaw.mjs skills --help
```

### Agent workspaces

OpenClaw defines agent workspaces as the agent's working directory and context surface. Workspace files can contain instructions/persona, and agent state/sessions are separate from tracked project docs.

Sources:

- <https://docs.openclaw.ai/concepts/agent>
- <https://docs.openclaw.ai/concepts/agent-workspace>
- <https://docs.openclaw.ai/concepts/multi-agent>

Local validation:

```bash
node openclaw.mjs onboard \
  --non-interactive \
  --accept-risk \
  --mode local \
  --auth-choice skip \
  --skip-channels \
  --skip-daemon \
  --skip-health \
  --skip-ui \
  --skip-search \
  --no-install-daemon \
  --json
```

Result:

```text
Workspace OK: ~/.openclaw/workspace
Sessions OK: ~/.openclaw/agents/main/sessions
agents.defaults.workspace = /home/node/.openclaw/workspace
```

### Skill loading

OpenClaw uses AgentSkills-compatible directories containing `SKILL.md`. Public docs describe workspace and project skill loading, extra directories, bundled skills, binary gating, and per-agent visibility/allowlist settings.

Sources:

- <https://docs.openclaw.ai/tools/skills>
- <https://docs.openclaw.ai/tools/skills-config>
- <https://docs.openclaw.ai/tools/creating-skills>

Local validation:

A minimal workspace skill was created at:

```text
/home/node/.openclaw/workspace/skills/egdev-smoke/SKILL.md
```

Then OpenClaw was run with:

```bash
node openclaw.mjs skills list --json
```

Result excerpt:

```json
{
  "name": "egdev-smoke",
  "description": "Smoke skill for OpenClaw workspace loading validation.",
  "eligible": true,
  "modelVisible": true,
  "userInvocable": true,
  "commandVisible": true,
  "source": "openclaw-workspace",
  "bundled": false
}
```

Conclusion:

- OpenClaw can discover and expose workspace `SKILL.md` assets.
- Gentle-AI behavior can be packaged into OpenClaw-visible skills.
- Native Pi `.pi` agents/chains/subagent definitions are still **not** validated as direct OpenClaw inputs.

### Gateway startup and health

The Gateway starts from the GHCR image when auth is configured:

```bash
node openclaw.mjs gateway \
  --port 18789 \
  --bind lan \
  --auth token \
  --allow-unconfigured \
  --verbose
```

Observed logs:

```text
[gateway] http server listening
[gateway] ready
```

Health check from inside the running container:

```text
GET http://127.0.0.1:18789/healthz
200 {"ok":true,"status":"live"}
```

Security observation:

- `--auth none` with `--bind lan` is refused by OpenClaw.
- Token/password auth is required for LAN binding.
- This matches the project's loopback/auth-first stance.

WSL observation:

- Docker Desktop was reachable through the Windows `docker.exe` binary even though the Linux `docker` shim reported WSL integration unavailable.
- Host curl from this WSL session to the published Docker Desktop port did not succeed during the smoke test, but container-internal health succeeded. Issue #2 should validate host/browser access on the target machine.

### Discord routing

OpenClaw documents Discord setup through an application/bot token, message-content intent, gateway restart, pairing or allowlists, and multi-account configuration. Routing/bindings support deterministic assignment of inbound messages to agents.

Sources:

- <https://docs.openclaw.ai/channels/discord>
- <https://docs.openclaw.ai/channels/channel-routing>
- <https://docs.openclaw.ai/cli/agents>
- <https://docs.openclaw.ai/concepts/multi-agent>

Conclusion:

- Discord routing is supported at the OpenClaw level.
- `egdev-dashboard` still needs a product decision: one OpenClaw agent with channel-derived Engram namespaces vs multiple OpenClaw agents bound by account/channel/guild rules.

## Packaging decision

Initial conservative packaging model:

1. Keep Pi/el Gentleman as the development SDD harness.
2. Use OpenClaw as the containerized operational runtime.
3. Package project behavior as OpenClaw-visible `SKILL.md` assets and workspace instructions.
4. Keep native Pi `.pi` agents/chains out of the Docker contract until a future spike proves direct compatibility.
5. Treat Engram as an external memory dependency until a container-local client/tool contract is validated.
6. Promote any runtime-discovered decisions back into ADRs/OpenSpec/docs before implementation work depends on them.

## Required follow-up work

1. **Compose implementation**
   - Replace placeholder service shape with the validated OpenClaw image and command.
   - Use Gateway port `18789`, not the earlier placeholder port.
   - Preserve token/password auth and loopback-safe host publishing.
   - Validate host/browser access from the target PC.

2. **Engram access spike**
   - Confirm whether runtime skills call Engram through HTTP, CLI, MCP, or another bridge.
   - Document required credentials, scopes, and network topology.

3. **Discord routing spike**
   - Decide between one agent plus channel namespace mapping vs multiple agents/bindings.
   - Validate the chosen mapping with fake channels and no private brand data.

4. **Gentle-AI operational SDD adaptation**
   - Convert the smallest useful Gentle-AI behavior into an OpenClaw `SKILL.md`.
   - Validate invocation from an OpenClaw session before claiming Discord-driven operational SDD.

## Decision update

ADR 0001 should use this clarified rule:

> OpenClaw is confirmed as the target operational runtime shell and can load workspace `SKILL.md` assets. Gentle-AI/Pi SDD is not confirmed as a native OpenClaw runtime. Until proven otherwise, package Gentle-AI behavior as OpenClaw skills/workspace instructions and keep Pi-native `.pi` assets out of the Docker contract.
