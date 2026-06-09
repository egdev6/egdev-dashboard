#!/usr/bin/env sh
set -eu

workspace="${OPENCLAW_WORKSPACE:-/home/node/.openclaw/workspace}"
source_dir="${DISCORD_PROJECT_MANAGER_SKILLS_SOURCE:-/opt/discord-project-manager/skills}"
target_dir="$workspace/skills"
gentle_enabled="${DISCORD_PROJECT_MANAGER_SYNC_GENTLE_AI:-1}"

mkdir -p "$target_dir"

if [ -d "$source_dir" ]; then
  cp -R "$source_dir"/. "$target_dir"/
fi

has_gentle_openclaw_core() {
  [ -f "$workspace/AGENTS.md" ] || return 1
  [ -f "$workspace/SOUL.md" ] || return 1
  [ -f "$workspace/.openclaw/skills/sdd-init/SKILL.md" ] || return 1
  grep -F 'gentle-ai:sdd-orchestrator' "$workspace/AGENTS.md" >/dev/null 2>&1 || return 1
  grep -F 'gentle-ai:engram-protocol' "$workspace/AGENTS.md" >/dev/null 2>&1 || return 1
  return 0
}

sync_gentle_ai_openclaw() {
  [ "$gentle_enabled" = "1" ] || return 0
  command -v gentle-ai >/dev/null 2>&1 || {
    echo "gentle-ai binary not found; skipping OpenClaw SDD sync" >&2
    return 0
  }
  [ -f /home/node/.openclaw/openclaw.json ] || {
    echo "OpenClaw config not found yet; skipping Gentle-AI OpenClaw sync" >&2
    return 0
  }

  if has_gentle_openclaw_core; then
    return 0
  fi

  echo "Syncing Gentle-AI SDD/Engram protocol into OpenClaw workspace..." >&2
  if ! gentle-ai install --agent openclaw --preset full-gentleman --scope=workspace >/tmp/gentle-ai-openclaw-sync.log 2>&1; then
    echo "gentle-ai install reported verification warnings; checking required OpenClaw files" >&2
  fi

  if ! has_gentle_openclaw_core; then
    echo "Gentle-AI OpenClaw sync did not produce required SDD/Engram files" >&2
    tail -120 /tmp/gentle-ai-openclaw-sync.log >&2 || true
    return 1
  fi
}

sync_gentle_ai_openclaw
