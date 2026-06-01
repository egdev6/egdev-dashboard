#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_MEMORY_GATEWAY_FIXTURE:-examples/discord-memory-gateway.fake.yaml}"
DOC_PATH="docs/architecture/discord-memory-gateway.md"
CONFIG_README_PATH="openclaw/config/README.md"
RUNTIME_NAMESPACE_CONTRACT="discord-project-manager/runtime/discord/<guild-id>/<channel-id>"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

require_cmd grep
require_cmd awk

[[ -f "$FIXTURE_PATH" ]] || fail "fixture not found: $FIXTURE_PATH"
[[ -f "$DOC_PATH" ]] || fail "doc not found: $DOC_PATH"
[[ -f "$CONFIG_README_PATH" ]] || fail "config readme not found: $CONFIG_README_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-memory-gateway" \
  "live_discord_connection: false" \
  "live_engram_calls: false" \
  "uses_real_discord_ids: false" \
  "raw_discord_chat_logs_included: false" \
  "durable_memory_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "runtime_audit_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "runtime_read: allowed" \
  "raw_chat_log_persistence: forbidden" \
  "route_resolution: discord/context/route-resolution" \
  "hydration_summary: discord/context/hydration-summary" \
  "scoped_skills: discord/context/scoped-skills" \
  "strategy_writeback: discord/writeback/strategy-update" \
  "network_writeback: discord/writeback/network-update" \
  "content_ledger_writeback: discord/writeback/content-ledger-entry" \
  "global_governance_writeback: discord/writeback/global-governance" \
  "approval_audit: discord/audit/approval-decision" \
  "name: matched-route-x-queue-proposal" \
  "name: unmapped-channel-fallback" \
  "writeback_classification: confirmation-required" \
  "writeback_classification: reject" \
  'title: "docs(adr): define Engram namespace contract for shared operational memory"' \
  'title: "ops(runtime): validate first local OpenClaw Engram pilot"'; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "discord-approval-gate" \
  "x-queue-planner" \
  "discord-project-manager/project/egdev/brand" \
  "discord-project-manager/project/egdev/strategy" \
  "discord-project-manager/project/egdev/content-ledger" \
  "discord-project-manager/project/egdev/network/x" \
  "approve write" \
  "revise: <instruction>" \
  "reject"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing gateway marker: $required"
done

for required in \
  "Read hydration policy" \
  "Writeback policy" \
  "discord/context/route-resolution" \
  "discord/writeback/network-update" \
  "discord/writeback/global-governance" \
  "discord/audit/approval-decision" \
  "docs/architecture/discord-scoped-skills-registry.md" \
  "skills/discord-approval-gate/SKILL.md" \
  "#3 \`docs(adr): define Engram namespace contract for shared operational memory\`" \
  "#51 \`ops(runtime): validate first local OpenClaw Engram pilot\`" \
  "raw Discord transcripts or chat logs"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required gateway marker: $required"
done

grep -F "docs/architecture/discord-memory-gateway.md" "$CONFIG_README_PATH" >/dev/null || fail "config README missing memory gateway reference"

review_paths=("$FIXTURE_PATH" "$DOC_PATH" "$CONFIG_README_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_connection: true|live_engram_calls: true|raw_discord_chat_logs_included: true|durable_memory_writes_allowed: true|workspace_file_writes_allowed: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|live Engram calls enabled|uses production credentials|production credentials enabled' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, persistence, publishing, scheduling, or public Discord behavior"
fi

echo "Validated fake Discord memory gateway contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Config README: $CONFIG_README_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
