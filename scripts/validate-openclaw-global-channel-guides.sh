#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${OPENCLAW_GLOBAL_CHANNEL_GUIDES_FIXTURE:-examples/openclaw-global-channel-guides.fake.yaml}"
DOC_PATH="docs/architecture/openclaw-global-channel-guides.md"
README_PATH="README.md"
PRIVATE_GUIDE_PATH="docs/operations/private-discord-manual-verification-guide.md"
ROUTING_DOC_PATH="docs/operations/discord-routing.md"
SAFE_SUITE_DOC_PATH="docs/operations/safe-validation-suite.md"
CONFIG_README_PATH="openclaw/config/README.md"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

require_cmd awk
require_cmd grep

for path in \
  "$FIXTURE_PATH" \
  "$DOC_PATH" \
  "$README_PATH" \
  "$PRIVATE_GUIDE_PATH" \
  "$ROUTING_DOC_PATH" \
  "$SAFE_SUITE_DOC_PATH" \
  "$CONFIG_README_PATH"; do
  [[ -f "$path" ]] || fail "required file not found: $path"
done

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: openclaw-global-channel-guides" \
  "live_discord_validation_proven: false" \
  "runtime_enforcement_proven: false" \
  "uses_real_discord_ids: false" \
  "raw_discord_chat_logs_included: false" \
  "discord_writes_executed: false" \
  "production_credentials: false" \
  "durable_memory_writes_allowed: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "canonical_catalog: true" \
  "proposal_first_required: true" \
  "approval_phrase: approve write" \
  "starter_messages_are_pin_ready: true" \
  "reserved_control_category: OpenClaw Global" \
  "control_channels_are_route_matched: false" \
  "project_manager_surface_separate: true" \
  "project_manager_global_channels:" \
  "control_guides:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "global-context" \
  "global-skills" \
  "global-strategy" \
  "global-decisions" \
  "global-config"; do
  grep -F "  - $required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing Project Manager global channel marker: $required"
done

for required in \
  "identity" \
  "writing-style" \
  "operating-principles" \
  "boundaries" \
  "inheritance" \
  "skills"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing reserved control channel: $required"
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing reserved control channel: $required"
done

awk '
  function flush_entry() {
    if (control_channel == "") {
      return
    }
    if (channel_name == "" || channel_name != control_channel) {
      print "channel_name must match control_channel for " control_channel > "/dev/stderr"
      exit 1
    }
    if (!topic_seen || topic_value == "" || !starter_seen || starter_lines < 2 || prompt_count < 2 || managed_count == 0 || non_goal_count == 0 || proposal_policy == "" || write_policy == "") {
      print "control guide missing required content for " control_channel > "/dev/stderr"
      exit 1
    }
    count++
    seen[control_channel] = 1
  }

  /^control_guides:$/ { next }
  /^  - control_channel:/ {
    flush_entry()
    control_channel = $3
    channel_name = ""
    topic_seen = 0
    topic_value = ""
    starter_seen = 0
    starter_lines = 0
    prompt_count = 0
    managed_count = 0
    non_goal_count = 0
    proposal_policy = ""
    write_policy = ""
    section = ""
    next
  }
  control_channel != "" && /^    channel_name:/ { channel_name = $2; next }
  control_channel != "" && /^    topic:/ {
    topic_seen = 1
    topic_value = $0
    sub(/^    topic:[[:space:]]*/, "", topic_value)
    if (topic_value ~ /^[[:space:]]*$/) {
      topic_value = ""
    }
    section = ""
    next
  }
  control_channel != "" && /^    starter_message: \|$/ { starter_seen = 1; section = "starter"; next }
  control_channel != "" && /^    example_prompts:$/ { section = "prompts"; next }
  control_channel != "" && /^    managed_information:$/ { section = "managed"; next }
  control_channel != "" && /^    non_goals:$/ { section = "non_goals"; next }
  control_channel != "" && /^    proposal_policy:/ { proposal_policy = $2; section = ""; next }
  control_channel != "" && /^    write_policy:/ { write_policy = $2; section = ""; next }
  control_channel != "" && /^    [a-z_]+:/ { section = ""; next }
  control_channel != "" && section == "starter" && /^      / { starter_lines++; next }
  control_channel != "" && section == "prompts" && /^      - / { prompt_count++; next }
  control_channel != "" && section == "managed" && /^      - / { managed_count++; next }
  control_channel != "" && section == "non_goals" && /^      - / { non_goal_count++; next }
  END {
    flush_entry()
    if (count != 6) {
      print "expected 6 control guides, found " count > "/dev/stderr"
      exit 1
    }
    split("identity writing-style operating-principles boundaries inheritance skills", required, " ")
    for (idx in required) {
      if (!(required[idx] in seen)) {
        print "missing required control guide " required[idx] > "/dev/stderr"
        exit 1
      }
    }
  }
' "$FIXTURE_PATH" || fail "fixture control guide structure is inconsistent"

for required in \
  "examples/openclaw-global-channel-guides.fake.yaml" \
  "approve write" \
  "proposal-first" \
  "Project Manager"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

for required in \
  "docs/architecture/openclaw-global-channel-guides.md" \
  "examples/openclaw-global-channel-guides.fake.yaml" \
  "approve write" \
  "structure" \
  "descriptive copy" \
  "Project Manager"; do
  grep -F "$required" "$README_PATH" >/dev/null || fail "README missing required marker: $required"
done

for required in \
  "docs/architecture/openclaw-global-channel-guides.md" \
  "examples/openclaw-global-channel-guides.fake.yaml" \
  "approve write" \
  "Project Manager"; do
  grep -F "$required" "$PRIVATE_GUIDE_PATH" >/dev/null || fail "private guide missing required marker: $required"
done

for pm_channel in \
  "global-context" \
  "global-skills" \
  "global-strategy" \
  "global-decisions" \
  "global-config"; do
  grep -F "$pm_channel" "$DOC_PATH" >/dev/null || fail "doc missing Project Manager global channel marker: $pm_channel"
  grep -F "$pm_channel" "$README_PATH" >/dev/null || fail "README missing Project Manager global channel marker: $pm_channel"
  grep -F "$pm_channel" "$PRIVATE_GUIDE_PATH" >/dev/null || fail "private guide missing Project Manager global channel marker: $pm_channel"
done

for required in \
  "docs/architecture/openclaw-global-channel-guides.md" \
  "examples/openclaw-global-channel-guides.fake.yaml" \
  "bash scripts/validate-openclaw-global-channel-guides.sh"; do
  grep -F "$required" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing required marker: $required"
done

grep -F "OpenClaw Global" "$SAFE_SUITE_DOC_PATH" >/dev/null || fail "safe validation suite doc missing OpenClaw Global guide coverage marker"

for required in \
  "docs/architecture/openclaw-global-channel-guides.md" \
  "examples/openclaw-global-channel-guides.fake.yaml" \
  "scripts/validate-openclaw-global-channel-guides.sh"; do
  grep -F "$required" "$CONFIG_README_PATH" >/dev/null || fail "config readme missing required marker: $required"
done

review_paths=(
  "$FIXTURE_PATH"
  "$DOC_PATH"
  "$README_PATH"
  "$PRIVATE_GUIDE_PATH"
  "$ROUTING_DOC_PATH"
  "$SAFE_SUITE_DOC_PATH"
  "$CONFIG_README_PATH"
)

sensitive_review_paths=(
  "$FIXTURE_PATH"
  "$DOC_PATH"
)

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

# Shared setup/runbook docs intentionally document operator environment variable names.
# Keep credential-name scanning focused on this new contract doc and fixture.
if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${sensitive_review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_validation_proven: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|raw_discord_chat_logs_included: true|discord_writes_executed: true|production_credentials: true|durable_memory_writes_allowed: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|uses production credentials|durable write executed' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, persistence, or unsafe write behavior"
fi

echo "Validated fake OpenClaw Global channel guides contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "README: $README_PATH"
echo "Private guide: $PRIVATE_GUIDE_PATH"
echo "Routing doc: $ROUTING_DOC_PATH"
echo "Safe suite doc: $SAFE_SUITE_DOC_PATH"
echo "Config README: $CONFIG_README_PATH"
