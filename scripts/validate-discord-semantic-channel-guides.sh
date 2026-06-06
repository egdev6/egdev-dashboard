#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_SEMANTIC_CHANNEL_GUIDES_FIXTURE:-examples/discord-semantic-channel-guides.fake.yaml}"
DOC_PATH="docs/architecture/discord-semantic-channel-guides.md"
PACK_DOC_PATH="docs/architecture/discord-context-skill-packs.md"
ORCH_DOC_PATH="docs/architecture/discord-runtime-orchestrator.md"
RUNBOOK_PATH="docs/operations/discord-routing.md"
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

[[ -f "$FIXTURE_PATH" ]] || fail "fixture not found: $FIXTURE_PATH"
[[ -f "$DOC_PATH" ]] || fail "doc not found: $DOC_PATH"
[[ -f "$PACK_DOC_PATH" ]] || fail "pack doc not found: $PACK_DOC_PATH"
[[ -f "$ORCH_DOC_PATH" ]] || fail "orchestrator doc not found: $ORCH_DOC_PATH"
[[ -f "$RUNBOOK_PATH" ]] || fail "runbook not found: $RUNBOOK_PATH"
[[ -f "$CONFIG_README_PATH" ]] || fail "config readme not found: $CONFIG_README_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-semantic-channel-guides" \
  "live_discord_validation_proven: false" \
  "runtime_enforcement_proven: false" \
  "uses_real_discord_ids: false" \
  "raw_discord_chat_logs_included: false" \
  "durable_memory_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "canonical_catalog: true" \
  "duplicate_handler_copy_allowed: false" \
  "starter_messages_are_pin_ready: true" \
  "guide_lookup_key: scope-plus-field-key" \
  "channel_topic_source: topic" \
  "pinned_message_source: starter_message" \
  "handler_copy_duplication_allowed: false" \
  "topology_compatibility:" \
  "does_not_replace_openclaw_global_reserved_channels: true" \
  "openclaw_global_reserved_channels:" \
  "planned_project_manager_workspace_channels:" \
  "global_guides:" \
  "project_guides:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "docs/architecture/discord-context-skill-packs.md" \
  "docs/architecture/discord-runtime-orchestrator.md" \
  "docs/architecture/discord-dynamic-context-namespaces.md" \
  "docs/architecture/discord-topology-reconciliation.md"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing source contract: $required"
done

for required in \
  "field_key: context" \
  "field_key: skills" \
  "field_key: strategy" \
  "field_key: decisions" \
  "field_key: config" \
  "field_key: tasks" \
  "field_key: qa" \
  "channel_name: global-context" \
  "channel_name: global-skills" \
  "channel_name: global-strategy" \
  "channel_name: global-decisions" \
  "channel_name: global-config" \
  "topology_status: planned-project-manager-workspace-guide"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing guide marker: $required"
done

for required in \
  "identity" \
  "writing-style" \
  "operating-principles" \
  "boundaries" \
  "inheritance" \
  "skills"; do
  grep -F "    - $required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing OpenClaw Global reserved channel marker: $required"
done

awk '
  function flush_entry() {
    if (field_key == "") {
      return
    }
    if (scope == "") {
      print "guide entry missing scope for field_key " field_key > "/dev/stderr"
      exit 1
    }
    if (channel_name == "") {
      print "guide entry missing channel_name for field_key " field_key > "/dev/stderr"
      exit 1
    }
    if (!topic_seen || topic_value == "" || !starter_seen || starter_lines == 0 || prompt_count < 2 || managed_count == 0 || non_goal_count == 0) {
      print "guide entry missing required content for field_key " field_key > "/dev/stderr"
      exit 1
    }
    if (scope == "global") {
      global_count++
      global_fields[field_key] = 1
      if (channel_name !~ /^global-/) {
        print "global guide must use global- channel naming for field_key " field_key > "/dev/stderr"
        exit 1
      }
    } else if (scope == "project") {
      project_count++
      project_fields[field_key] = 1
      if (channel_name ~ /^global-/) {
        print "project guide must not use global- channel naming for field_key " field_key > "/dev/stderr"
        exit 1
      }
    } else {
      print "unsupported guide scope: " scope > "/dev/stderr"
      exit 1
    }
  }

  /^global_guides:$/ { catalog = "global"; next }
  /^project_guides:$/ { flush_entry(); catalog = "project"; field_key = ""; next }
  /^  - field_key:/ {
    flush_entry()
    field_key = $3
    scope = ""
    channel_name = ""
    topic_seen = 0
    topic_value = ""
    starter_seen = 0
    starter_lines = 0
    prompt_count = 0
    managed_count = 0
    non_goal_count = 0
    section = ""
    next
  }
  field_key != "" && /^    scope:/ { scope = $2; next }
  field_key != "" && /^    channel_name:/ { channel_name = $2; next }
  field_key != "" && /^    topic:/ {
    topic_seen = 1
    topic_value = $0
    sub(/^    topic:[[:space:]]*/, "", topic_value)
    if (topic_value ~ /^[[:space:]]*$/) {
      topic_value = ""
    }
    section = ""
    next
  }
  field_key != "" && /^    starter_message: \|$/ { starter_seen = 1; section = "starter"; next }
  field_key != "" && /^    example_prompts:$/ { section = "prompts"; next }
  field_key != "" && /^    managed_information:$/ { section = "managed"; next }
  field_key != "" && /^    non_goals:$/ { section = "non_goals"; next }
  field_key != "" && /^    [a-z_]+:/ { section = ""; next }
  field_key != "" && section == "starter" && /^      [^ -]/ { starter_lines++; next }
  field_key != "" && section == "prompts" && /^      - / { prompt_count++; next }
  field_key != "" && section == "managed" && /^      - / { managed_count++; next }
  field_key != "" && section == "non_goals" && /^      - / { non_goal_count++; next }
  END {
    flush_entry()
    if (global_count != 5) {
      print "expected 5 global guides, found " global_count > "/dev/stderr"
      exit 1
    }
    if (project_count != 6) {
      print "expected 6 project guides, found " project_count > "/dev/stderr"
      exit 1
    }
    split("context skills strategy decisions config", required_global, " ")
    for (idx in required_global) {
      if (!(required_global[idx] in global_fields)) {
        print "missing required global field_key " required_global[idx] > "/dev/stderr"
        exit 1
      }
    }
    split("context skills strategy tasks decisions qa", required_project, " ")
    for (idx in required_project) {
      if (!(required_project[idx] in project_fields)) {
        print "missing required project field_key " required_project[idx] > "/dev/stderr"
        exit 1
      }
    }
  }
' "$FIXTURE_PATH" || fail "fixture guide structure is inconsistent with documented schema"

for required in \
  "canonical source" \
  "reserved channels remain" \
  "Global guides apply at workspace scope only." \
  "Project guides apply within one project category only." \
  "Do not duplicate this copy in command handlers" \
  "topic" \
  "starter_message" \
  "example_prompts" \
  "managed_information" \
  "non_goals"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required guide marker: $required"
done

for required in \
  "docs/architecture/discord-semantic-channel-guides.md" \
  "channel guide ref"; do
  grep -F "$required" "$PACK_DOC_PATH" >/dev/null || fail "pack doc missing semantic guide reference: $required"
done

for required in \
  "docs/architecture/discord-semantic-channel-guides.md" \
  "channel guide ref" \
  "selected channel guide reference"; do
  grep -F "$required" "$ORCH_DOC_PATH" >/dev/null || fail "orchestrator doc missing semantic guide reference: $required"
done

for required in \
  "docs/architecture/discord-semantic-channel-guides.md" \
  "bash scripts/validate-discord-semantic-channel-guides.sh"; do
  grep -F "$required" "$RUNBOOK_PATH" >/dev/null || fail "runbook missing semantic guide validation reference: $required"
done

grep -F "docs/architecture/discord-semantic-channel-guides.md" "$CONFIG_README_PATH" >/dev/null || fail "config README missing semantic guide reference"

review_paths=(
  "$FIXTURE_PATH"
  "$DOC_PATH"
  "$PACK_DOC_PATH"
  "$ORCH_DOC_PATH"
  "$RUNBOOK_PATH"
  "$CONFIG_README_PATH"
)

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_validation_proven: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|raw_discord_chat_logs_included: true|durable_memory_writes_allowed: true|workspace_file_writes_allowed: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|uses production credentials|production credentials enabled|prompt execution proven' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, persistence, publishing, scheduling, or prompt execution behavior"
fi

echo "Validated fake Discord semantic channel guides contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Pack doc: $PACK_DOC_PATH"
echo "Orchestrator doc: $ORCH_DOC_PATH"
echo "Runbook: $RUNBOOK_PATH"
echo "Config README: $CONFIG_README_PATH"
