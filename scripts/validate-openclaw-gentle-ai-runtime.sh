#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

require_cmd grep

DOCKERFILE_PATH="docker/openclaw/Dockerfile"
SYNC_SCRIPT_PATH="docker/openclaw/sync-skills.sh"
RUNTIME_DOC_PATH="docs/operations/docker-runtime.md"
COMPOSE_PATH="docker-compose.yml"

[[ -f "$DOCKERFILE_PATH" ]] || fail "missing Dockerfile: $DOCKERFILE_PATH"
[[ -f "$SYNC_SCRIPT_PATH" ]] || fail "missing sync script: $SYNC_SCRIPT_PATH"
[[ -f "$RUNTIME_DOC_PATH" ]] || fail "missing runtime docs: $RUNTIME_DOC_PATH"
[[ -f "$COMPOSE_PATH" ]] || fail "missing Compose file: $COMPOSE_PATH"

bash -n "$SYNC_SCRIPT_PATH" || fail "sync script has invalid shell syntax"

grep -F "GENTLE_AI_VERSION" "$DOCKERFILE_PATH" >/dev/null || fail "Dockerfile does not pin Gentle-AI version"
grep -F "/usr/local/bin/gentle-ai" "$DOCKERFILE_PATH" >/dev/null || fail "Dockerfile does not install gentle-ai into /usr/local/bin"
grep -F "ENGRAM_IMAGE" "$DOCKERFILE_PATH" >/dev/null || fail "Dockerfile does not define Engram image source"
grep -F "/usr/local/bin/engram" "$DOCKERFILE_PATH" >/dev/null || fail "Dockerfile does not install engram into /usr/local/bin"
grep -F "ENGRAM_DATA_DIR" "$COMPOSE_PATH" >/dev/null || fail "Compose does not persist OpenClaw Engram data under the OpenClaw volume"
grep -F "gentle-ai install --agent openclaw" "$SYNC_SCRIPT_PATH" >/dev/null || fail "sync script does not run Gentle-AI OpenClaw install"
grep -F "gentle-ai:sdd-orchestrator" "$SYNC_SCRIPT_PATH" >/dev/null || fail "sync script does not verify SDD orchestrator marker"
grep -F "gentle-ai:engram-protocol" "$SYNC_SCRIPT_PATH" >/dev/null || fail "sync script does not verify Engram protocol marker"
grep -F "validate-openclaw-gentle-ai-runtime.sh" "$RUNTIME_DOC_PATH" >/dev/null || fail "runtime docs do not mention Gentle-AI validation command"

if [[ "${OPENCLAW_GENTLE_RUNTIME:-0}" != "1" ]]; then
  echo "Validated OpenClaw Gentle-AI packaging contract (repo/static mode)."
  echo "Set OPENCLAW_GENTLE_RUNTIME=1 to verify the running Docker runtime."
  exit 0
fi

require_cmd docker

docker compose exec -T openclaw sh -lc '
  set -eu
  command -v gentle-ai >/dev/null
  command -v engram >/dev/null
  gentle-ai --version
  engram version
  test -f /home/node/.openclaw/workspace/AGENTS.md
  test -f /home/node/.openclaw/workspace/SOUL.md
  test -f /home/node/.openclaw/workspace/.openclaw/skills/sdd-init/SKILL.md
  grep -F "gentle-ai:sdd-orchestrator" /home/node/.openclaw/workspace/AGENTS.md >/dev/null
  grep -F "gentle-ai:engram-protocol" /home/node/.openclaw/workspace/AGENTS.md >/dev/null
  openclaw mcp list | grep -F "engram" >/dev/null
  openclaw mcp doctor | grep -F "engram: ok" >/dev/null
  openclaw mcp probe | grep -F "engram:" >/dev/null
  node -e "fetch(process.env.ENGRAM_CLOUD_URL + \"/health\").then(async r=>{ if(!r.ok) process.exit(1); console.log(await r.text()) }).catch(()=>process.exit(1))"
  marker="openclaw-engram-cli-smoke-$(date -u +%Y%m%dT%H%M%S)"
  engram save "OpenClaw Engram CLI smoke" "Fake runtime smoke marker ${marker}" --project discord-project-manager --type discovery --scope project >/dev/null
  engram search "${marker}" --project discord-project-manager --limit 5 | grep -F "${marker}" >/dev/null
' >/tmp/openclaw-gentle-runtime-check.txt

if grep -E '[0-9]{17,20}|ghp_|gho_|github_pat_|DISCORD_BOT_TOKEN=|OPENAI_API_KEY=|ANTHROPIC_API_KEY=' /tmp/openclaw-gentle-runtime-check.txt >/dev/null; then
  fail "runtime validation output contains private-looking values"
fi

echo "Validated OpenClaw Gentle-AI runtime integration."
