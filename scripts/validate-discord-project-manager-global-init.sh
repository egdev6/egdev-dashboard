#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_PROJECT_MANAGER_GLOBAL_INIT_FIXTURE:-examples/discord-project-manager-global-init.fake.yaml}"
DOC_PATH="docs/architecture/discord-project-manager-global-init.md"
GUIDE_DOC_PATH="docs/architecture/discord-semantic-channel-guides.md"
GUIDE_FIXTURE_PATH="examples/discord-semantic-channel-guides.fake.yaml"
ROUTING_DOC_PATH="docs/operations/discord-routing.md"
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
[[ -f "$GUIDE_DOC_PATH" ]] || fail "semantic guide doc not found: $GUIDE_DOC_PATH"
[[ -f "$GUIDE_FIXTURE_PATH" ]] || fail "semantic guide fixture not found: $GUIDE_FIXTURE_PATH"
[[ -f "$ROUTING_DOC_PATH" ]] || fail "routing runbook not found: $ROUTING_DOC_PATH"
[[ -f "$CONFIG_README_PATH" ]] || fail "config README not found: $CONFIG_README_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-project-manager-global-init" \
  "issue_ref: 134" \
  "live_discord_validation_proven: false" \
  "runtime_enforcement_proven: false" \
  "uses_real_discord_ids: false" \
  "raw_discord_chat_logs_included: false" \
  "durable_memory_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "registry_backend:" \
  "backend_ref: private-runtime-managed-channel-registry" \
  "storage_boundary: private-runtime-only" \
  "repo_representation: fake-demo-refs-only" \
  "consumer_contract: docs/architecture/discord-managed-channel-routing.md" \
  "status_repair_contract: docs/architecture/discord-channel-scaffolding-status-repair.md" \
  "backend_not_available_status: BACKEND_NOT_AVAILABLE" \
  "private_runtime_ids_required: true" \
  "display_name_inference_success_allowed: false" \
  "interaction_name: /project-manager init" \
  "interaction_kind: slash-command-or-equivalent" \
  "category_name: Project Manager" \
  "category_semantic_role: project-manager-global" \
  "idempotency_key_template: project-manager-global:<guild-id>" \
  "guide_catalog_ref: examples/discord-semantic-channel-guides.fake.yaml" \
  "guide_scope: global" \
  "live_write_claim: false" \
  "required_before_writes: true" \
  "partial_create_allowed_on_missing_permissions: false" \
  "existing_registry_before_first_run:" \
  "present: false" \
  "planned_topology:" \
  "first_run_result:" \
  "second_run_result:" \
  "permission_failure_results:" \
  "drift_boundary_result:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for capability in \
  "manage_channels" \
  "send_messages" \
  "manage_messages_for_pin" \
  "view_channel"; do
  grep -F "    - $capability" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required permission capability: $capability"
done

for field in context skills strategy decisions config; do
  grep -F "field_key: $field" "$FIXTURE_PATH" >/dev/null || fail "fixture missing global field: $field"
  grep -F "guide_ref: global.$field" "$FIXTURE_PATH" >/dev/null || fail "fixture missing guide ref for field: $field"
  grep -F "$field: channel-demo-global-$field" "$FIXTURE_PATH" >/dev/null || fail "fixture missing persisted registry channel for field: $field"
done

for channel in \
  "global-context" \
  "global-skills" \
  "global-strategy" \
  "global-decisions" \
  "global-config"; do
  grep -F "channel_name: $channel" "$FIXTURE_PATH" >/dev/null || fail "fixture missing planned channel: $channel"
  grep -F "channel_name: $channel" "$GUIDE_FIXTURE_PATH" >/dev/null || fail "semantic guide fixture missing matching global guide channel: $channel"
done

for required in \
  "status: created" \
  "writes_attempted_after_permission_preflight: true" \
  "topic_applied_from_catalog: true" \
  "starter_messages_posted: true" \
  "starter_messages_pin_ready: true" \
  "persisted_registry_after_run:" \
  "    guild_ref: guild-demo-project-manager" \
  "    category_ref: category-demo-project-manager-global" \
  "    category_semantic_role: project-manager-global" \
  "    scope: global" \
  "    idempotency_key_ref: project-manager-global:<guild-id>" \
  "    registry_backend_ref: private-runtime-managed-channel-registry" \
  "    created_by_interaction: /project-manager init" \
  "    updated_by_interaction: /project-manager init" \
  "    channels:" \
  "    persistence_private_runtime_ids: true" \
  "    persistence_repo_safe_refs_only: true" \
  "status: no-op" \
  "used_persisted_registry: true" \
  "duplicate_category_created: false" \
  "duplicate_channels_created: false" \
  "status: blocked-permissions" \
  "missing_capability: manage_channels" \
  "missing_capability: manage_messages_for_pin" \
  "writes_attempted_after_permission_preflight: false" \
  "status: needs-repair" \
  "repair_issue_ref: 138" \
  "duplicate_recreate_allowed_in_issue_134: false"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing init behavior marker: $required"
done

awk '
  function finish_channel() {
    if (!in_channel) {
      return
    }
    if (scope != "global") {
      print "planned channel must use scope global for " field_key > "/dev/stderr"
      exit 1
    }
    if (channel_ref == "" || channel_name == "" || guide_ref == "" || topic_source == "" || starter_source == "") {
      print "planned channel missing refs or guide sources for " field_key > "/dev/stderr"
      exit 1
    }
    if (pin_ready != "true") {
      print "planned channel must mark starter message as pin-ready for " field_key > "/dev/stderr"
      exit 1
    }
    if (semantic_scope != "global" || semantic_field != field_key) {
      print "semantic metadata mismatch for " field_key > "/dev/stderr"
      exit 1
    }
    if (op_count < 2) {
      print "planned channel must expose at least two allowed prompt operations for " field_key > "/dev/stderr"
      exit 1
    }
    count++
    fields[field_key] = 1
    in_channel = 0
  }

  /^  channels:$/ { in_channels = 1; next }
  /^first_run_result:$/ { finish_channel(); in_channels = 0; next }
  in_channels && /^    - field_key:/ {
    finish_channel()
    in_channel = 1
    field_key = $3
    scope = ""
    channel_ref = ""
    channel_name = ""
    guide_ref = ""
    topic_source = ""
    starter_source = ""
    pin_ready = ""
    semantic_scope = ""
    semantic_field = ""
    op_count = 0
    in_metadata = 0
    in_ops = 0
    next
  }
  in_channel && /^      scope:/ { scope = $2; next }
  in_channel && /^      channel_ref:/ { channel_ref = $2; next }
  in_channel && /^      channel_name:/ { channel_name = $2; next }
  in_channel && /^      guide_ref:/ { guide_ref = $2; next }
  in_channel && /^      topic_source:/ { topic_source = $2; next }
  in_channel && /^      starter_message_source:/ { starter_source = $2; next }
  in_channel && /^      pin_starter_message:/ { pin_ready = $2; next }
  in_channel && /^      semantic_metadata:$/ { in_metadata = 1; next }
  in_metadata && /^        scope:/ { semantic_scope = $2; next }
  in_metadata && /^        field_key:/ { semantic_field = $2; next }
  in_metadata && /^        allowed_prompt_operations:$/ { in_ops = 1; next }
  in_ops && /^          - / { op_count++; next }
  END {
    finish_channel()
    if (count != 5) {
      print "expected 5 planned global init channels, found " count > "/dev/stderr"
      exit 1
    }
    split("context skills strategy decisions config", required_fields, " ")
    for (idx in required_fields) {
      if (!(required_fields[idx] in fields)) {
        print "missing planned channel field " required_fields[idx] > "/dev/stderr"
        exit 1
      }
    }
  }
' "$FIXTURE_PATH" || fail "fixture planned topology is inconsistent with the init contract"

awk '
  function finish_permission() {
    if (!in_perm_entry) {
      return
    }
    if (perm_status != "blocked-permissions") {
      print "permission failure entry must use blocked-permissions status for " perm_missing > "/dev/stderr"
      exit 1
    }
    if (perm_writes != "false" || perm_dup_category != "false" || perm_dup_channels != "false") {
      print "permission failure entry must not attempt writes or duplicates for " perm_missing > "/dev/stderr"
      exit 1
    }
    if (perm_missing == "manage_channels") {
      manage_channels_failure = 1
    } else if (perm_missing == "manage_messages_for_pin") {
      pin_permission_failure = 1
    } else {
      print "unexpected permission failure capability " perm_missing > "/dev/stderr"
      exit 1
    }
    in_perm_entry = 0
  }

  /^first_run_result:$/ { section = "first"; next }
  /^second_run_result:$/ { section = "second"; in_persist = 0; in_persist_channels = 0; next }
  /^permission_failure_results:$/ { section = "permissions"; next }
  /^drift_boundary_result:$/ { finish_permission(); section = "drift"; next }
  /^metadata:$/ { finish_permission(); section = "metadata"; next }

  section == "first" && /^  persisted_registry_after_run:$/ {
    in_persist = 1
    in_persist_channels = 0
    next
  }
  in_persist && /^    guild_ref:/ { persisted_guild = $2; next }
  in_persist && /^    category_ref:/ { persisted_category = $2; next }
  in_persist && /^    category_semantic_role:/ { persisted_role = $2; next }
  in_persist && /^    scope:/ { persisted_scope = $2; next }
  in_persist && /^    idempotency_key_ref:/ { persisted_idempotency = $2; next }
  in_persist && /^    channels:$/ { in_persist_channels = 1; next }
  in_persist_channels && /^      context:/ { persisted_channels["context"] = $2; next }
  in_persist_channels && /^      skills:/ { persisted_channels["skills"] = $2; next }
  in_persist_channels && /^      strategy:/ { persisted_channels["strategy"] = $2; next }
  in_persist_channels && /^      decisions:/ { persisted_channels["decisions"] = $2; next }
  in_persist_channels && /^      config:/ { persisted_channels["config"] = $2; next }
  in_persist && /^    persistence_private_runtime_ids:/ { persisted_private_ids = $2; next }
  in_persist && /^    persistence_repo_safe_refs_only:/ { persisted_repo_safe = $2; next }

  section == "permissions" && /^  - status:/ {
    finish_permission()
    in_perm_entry = 1
    perm_status = $3
    perm_missing = ""
    perm_writes = ""
    perm_dup_category = ""
    perm_dup_channels = ""
    next
  }
  in_perm_entry && /^    missing_capability:/ { perm_missing = $2; next }
  in_perm_entry && /^    writes_attempted_after_permission_preflight:/ { perm_writes = $2; next }
  in_perm_entry && /^    duplicate_category_created:/ { perm_dup_category = $2; next }
  in_perm_entry && /^    duplicate_channels_created:/ { perm_dup_channels = $2; next }

  END {
    finish_permission()
    if (persisted_guild != "guild-demo-project-manager" || persisted_category != "category-demo-project-manager-global") {
      print "persisted registry must include guild and category refs inside first_run_result" > "/dev/stderr"
      exit 1
    }
    if (persisted_role != "project-manager-global" || persisted_scope != "global" || persisted_idempotency != "project-manager-global:<guild-id>") {
      print "persisted registry must include semantic role, global scope, and idempotency ref inside first_run_result" > "/dev/stderr"
      exit 1
    }
    split("context skills strategy decisions config", required_fields, " ")
    for (idx in required_fields) {
      field = required_fields[idx]
      expected = "channel-demo-global-" field
      if (persisted_channels[field] != expected) {
        print "persisted registry missing channel mapping for " field > "/dev/stderr"
        exit 1
      }
    }
    if (persisted_private_ids != "true" || persisted_repo_safe != "true") {
      print "persisted registry must declare private runtime IDs and repo-safe refs" > "/dev/stderr"
      exit 1
    }
    if (!manage_channels_failure || !pin_permission_failure) {
      print "permission failures must cover both manage_channels and manage_messages_for_pin" > "/dev/stderr"
      exit 1
    }
  }
' "$FIXTURE_PATH" || fail "fixture persisted registry or permission failures are inconsistent with the init contract"

for required in \
  "# Discord Project Manager global initialization" \
  "project-manager init" \
  "Project Manager" \
  "global-context" \
  "global-skills" \
  "global-strategy" \
  "global-decisions" \
  "global-config" \
  "manage_channels" \
  "send_messages" \
  "manage_messages_for_pin" \
  "Persisted category/channels still resolve" \
  "docs/architecture/discord-channel-scaffolding-status-repair.md" \
  "does not prove live Discord"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

for required in \
  "docs/architecture/discord-project-manager-global-init.md" \
  "examples/discord-project-manager-global-init.fake.yaml" \
  "scripts/validate-discord-project-manager-global-init.sh"; do
  grep -F "$required" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing global init reference: $required"
  grep -F "$required" "$CONFIG_README_PATH" >/dev/null || fail "config README missing global init reference: $required"
done

review_paths=(
  "$FIXTURE_PATH"
  "$DOC_PATH"
  "$GUIDE_DOC_PATH"
  "$GUIDE_FIXTURE_PATH"
  "$ROUTING_DOC_PATH"
  "$CONFIG_README_PATH"
)

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_validation_proven: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|raw_discord_chat_logs_included: true|durable_memory_writes_allowed: true|workspace_file_writes_allowed: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|uses production credentials|production credentials enabled|prompt execution proven|live write proven|live_write_claim: true' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, persistence, publishing, scheduling, or prompt execution behavior"
fi

echo "Validated fake Discord Project Manager global init contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Semantic guide fixture: $GUIDE_FIXTURE_PATH"
echo "Runbook: $ROUTING_DOC_PATH"
echo "Config README: $CONFIG_README_PATH"
