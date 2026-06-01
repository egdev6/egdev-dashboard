#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_SCOPED_SKILLS_REGISTRY_FIXTURE:-examples/discord-scoped-skills-registry.fake.yaml}"
DOC_PATH="docs/architecture/discord-scoped-skills-registry.md"
PARENT_DOC_PATH="docs/architecture/discord-dynamic-context-namespaces.md"
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
[[ -f "$PARENT_DOC_PATH" ]] || fail "parent doc not found: $PARENT_DOC_PATH"
[[ -f "$CONFIG_README_PATH" ]] || fail "config readme not found: $CONFIG_README_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-scoped-skills-registry" \
  "live_discord_connection: false" \
  "uses_real_discord_ids: false" \
  "durable_memory_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "runtime_audit_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "skills: openclaw-global/skills" \
  "inheritance: openclaw-global/inheritance" \
  "normalized_name: egdev-linkedin" \
  "normalized_name: stack-and-flow" \
  "control_channel: egdev-linkedin/skills" \
  "control_channel: stack-and-flow/skills" \
  "channel_ref: channel-demo-linkedin-drafts" \
  "channel_ref: channel-demo-stack-github" \
  "mandatory_global_skill: discord-approval-gate" \
  "state: approval-requested" \
  "route: openclaw-global/skills" \
  "runtime_context: $RUNTIME_NAMESPACE_CONTRACT" \
  "runtime_audit_namespace: $RUNTIME_NAMESPACE_CONTRACT"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "brand-context" \
  "content-ledger" \
  "strategy-planner" \
  "linkedin-weekly-planner" \
  "x-queue-planner" \
  "on-demand-brief-planner" \
  "discord-approval-gate"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing project skill marker: $required"
done

for required in \
  "approve write" \
  "revise: <instruction>" \
  "reject"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing approval option: $required"
done

for required in \
  "selected global skills" \
  "category enabled skills" \
  "channel preferred skills" \
  "skills/discord-approval-gate/SKILL.md" \
  "$RUNTIME_NAMESPACE_CONTRACT" \
  "#61 \`feat(flow): define brand context refresh workflow\`" \
  "#65 \`feat(flow): define on-demand brief workflow\`"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required contract marker: $required"
done

for required in \
  "#70 | Scoped skills registry and control channels; see \`docs/architecture/discord-scoped-skills-registry.md\`. |" \
  "Resolve skills in layers"; do
  grep -F "$required" "$PARENT_DOC_PATH" >/dev/null || fail "parent doc missing scoped skills reference: $required"
done

grep -F "docs/architecture/discord-scoped-skills-registry.md" "$CONFIG_README_PATH" >/dev/null || fail "config README missing scoped skills contract reference"
grep -F -- "- discord-approval-gate" "$FIXTURE_PATH" >/dev/null || fail "fixture must enable discord-approval-gate"
grep -F "mandatory_global_skill: discord-approval-gate" "$FIXTURE_PATH" >/dev/null || fail "fixture must mark discord-approval-gate as mandatory"

review_paths=("$FIXTURE_PATH" "$DOC_PATH" "$PARENT_DOC_PATH" "$CONFIG_README_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_connection: true|durable_memory_writes_allowed: true|workspace_file_writes_allowed: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|uses production credentials|production credentials enabled' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, persistence, publishing, scheduling, or public Discord behavior"
fi

echo "Validated fake Discord scoped skills registry contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Parent doc: $PARENT_DOC_PATH"
echo "Config README: $CONFIG_README_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
