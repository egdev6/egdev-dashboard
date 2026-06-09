#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_PROJECT_MANAGER_PROJECT_CREATE_FIXTURE:-examples/discord-project-manager-project-create.fake.yaml}"
DOC_PATH="docs/architecture/discord-project-manager-project-create.md"
GLOBAL_INIT_DOC_PATH="docs/architecture/discord-project-manager-global-init.md"
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
[[ -f "$GLOBAL_INIT_DOC_PATH" ]] || fail "global init doc not found: $GLOBAL_INIT_DOC_PATH"
[[ -f "$GUIDE_DOC_PATH" ]] || fail "semantic guide doc not found: $GUIDE_DOC_PATH"
[[ -f "$GUIDE_FIXTURE_PATH" ]] || fail "semantic guide fixture not found: $GUIDE_FIXTURE_PATH"
[[ -f "$ROUTING_DOC_PATH" ]] || fail "routing runbook not found: $ROUTING_DOC_PATH"
[[ -f "$CONFIG_README_PATH" ]] || fail "config README not found: $CONFIG_README_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-project-manager-project-create" \
  "issue_ref: 135" \
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
  "interaction_name: /project create" \
  "interaction_kind: slash-command-or-equivalent" \
  "category_name_template: Project - <project-name>" \
  "category_semantic_role: project-manager-project" \
  "idempotency_key_template: project:<guild-id>:<project-slug>" \
  "guide_catalog_ref: examples/discord-semantic-channel-guides.fake.yaml" \
  "guide_scope: project" \
  "live_write_claim: false" \
  "required_before_writes: true" \
  "partial_create_allowed_on_missing_permissions: false" \
  "template_definitions:" \
  "minimal:" \
  "complete:" \
  "project_create_request:" \
  "planned_topology:" \
  "first_run_result:" \
  "minimal_template_result:" \
  "duplicate_name_results:" \
  "permission_failure_results:" \
  "partial_failure_audit:" \
  "unsupported_template_result:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "project_name" \
  "selected_template"; do
  grep -F "    - $required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required input marker: $required"
done

grep -F "    - project_description" "$FIXTURE_PATH" >/dev/null || fail "fixture missing optional project_description marker"

for capability in \
  "manage_channels" \
  "send_messages" \
  "manage_messages_for_pin" \
  "view_channel"; do
  grep -F "    - $capability" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required permission capability: $capability"
done

for field in context skills strategy tasks decisions qa; do
  grep -F "field_key: $field" "$FIXTURE_PATH" >/dev/null || fail "fixture missing project field: $field"
  grep -F "guide_ref: project.$field" "$FIXTURE_PATH" >/dev/null || fail "fixture missing guide ref for project field: $field"
  grep -F "$field: channel-demo-web-app-$field" "$FIXTURE_PATH" >/dev/null || fail "fixture missing persisted registry channel for field: $field"
  grep -F "channel_name: $field" "$GUIDE_FIXTURE_PATH" >/dev/null || fail "semantic guide fixture missing matching project guide channel: $field"
done

for required in \
  "project_name: Web App" \
  "project_description: Fake demo project for contract validation." \
  "project_slug: web-app" \
  "selected_template: complete" \
  "category_name: Project - Web App" \
  "nested_under_global_category: false" \
  "status: created" \
  "writes_attempted_after_permission_preflight: true" \
  "nested_category_created: false" \
  "topic_applied_from_catalog: true" \
  "starter_messages_posted: true" \
  "starter_messages_pin_ready: true" \
  "persisted_registry_after_run:" \
  "registry_backend_ref: private-runtime-managed-channel-registry" \
  "created_by_interaction: /project create" \
  "updated_by_interaction: /project create" \
  "status: duplicate-same-project" \
  "status: duplicate-name-review" \
  "status: blocked-permissions" \
  "missing_capability: manage_channels" \
  "missing_capability: manage_messages_for_pin" \
  "status: partial-failure-needs-repair" \
  "safe_retry_token_ref: retry-demo-web-app-create" \
  "repair_issue_ref: 138" \
  "duplicate_recreate_allowed_in_issue_135: false" \
  "status: unsupported-template"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing project create behavior marker: $required"
done

awk '
  /^command_contract:$/ { section = "command"; command_mode = ""; next }
  /^permission_preflight:$/ { section = "permissions"; command_mode = ""; next }
  /^template_definitions:$/ { section = "templates"; template = ""; mode = ""; command_mode = ""; next }
  /^project_create_request:$/ { section = "request"; command_mode = ""; next }

  section == "command" && /^  supported_templates:$/ { command_mode = "supported_templates"; next }
  section == "command" && /^  [a-z_]+:/ { command_mode = ""; next }
  section == "command" && command_mode == "supported_templates" && /^    - / {
    supported_count++
    if ($2 == "minimal") {
      supported_minimal = 1
    } else if ($2 == "complete") {
      supported_complete = 1
    } else {
      print "unsupported template listed in command contract: " $2 > "/dev/stderr"
      exit 1
    }
    next
  }

  section == "templates" && /^  minimal:$/ { template = "minimal"; next }
  section == "templates" && /^  complete:$/ { template = "complete"; next }
  section == "templates" && /^    channel_fields:$/ { mode = "fields"; next }
  section == "templates" && mode == "fields" && /^      - / {
    template_fields[template ":" $2] = 1
    template_counts[template]++
    next
  }

  END {
    if (!supported_minimal || !supported_complete || supported_count != 2) {
      print "command contract must support exactly minimal and complete templates" > "/dev/stderr"
      exit 1
    }
    split("context strategy tasks", minimal_required, " ")
    for (idx in minimal_required) {
      if (!("minimal:" minimal_required[idx] in template_fields)) {
        print "minimal template missing field " minimal_required[idx] > "/dev/stderr"
        exit 1
      }
    }
    if (template_counts["minimal"] != 3 || ("minimal:skills" in template_fields) || ("minimal:decisions" in template_fields) || ("minimal:qa" in template_fields)) {
      print "minimal template must contain only context, strategy, and tasks" > "/dev/stderr"
      exit 1
    }
    split("context skills strategy tasks decisions qa", complete_required, " ")
    for (idx in complete_required) {
      if (!("complete:" complete_required[idx] in template_fields)) {
        print "complete template missing field " complete_required[idx] > "/dev/stderr"
        exit 1
      }
    }
    if (template_counts["complete"] != 6) {
      print "complete template must contain exactly six required fields" > "/dev/stderr"
      exit 1
    }
  }
' "$FIXTURE_PATH" || fail "fixture template definitions are inconsistent with the project create contract"

awk '
  function finish_channel() {
    if (!in_channel) {
      return
    }
    if (scope != "project") {
      print "planned channel must use scope project for " field_key > "/dev/stderr"
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
    if (semantic_scope != "project" || semantic_project != "project-demo-web-app" || semantic_slug != "web-app" || semantic_field != field_key) {
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

  /^  channels:$/ && section == "topology" { in_channels = 1; next }
  /^first_run_result:$/ { finish_channel(); in_channels = 0; section = "first"; next }
  /^planned_topology:$/ { section = "topology"; next }
  section == "topology" && /^    - field_key:/ {
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
    semantic_project = ""
    semantic_slug = ""
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
  in_metadata && /^        project_ref:/ { semantic_project = $2; next }
  in_metadata && /^        project_slug:/ { semantic_slug = $2; next }
  in_metadata && /^        field_key:/ { semantic_field = $2; next }
  in_metadata && /^        allowed_prompt_operations:$/ { in_ops = 1; next }
  in_ops && /^          - / { op_count++; next }
  END {
    finish_channel()
    if (count != 6) {
      print "expected 6 planned complete-template project channels, found " count > "/dev/stderr"
      exit 1
    }
    split("context skills strategy tasks decisions qa", required_fields, " ")
    for (idx in required_fields) {
      if (!(required_fields[idx] in fields)) {
        print "missing planned channel field " required_fields[idx] > "/dev/stderr"
        exit 1
      }
    }
  }
' "$FIXTURE_PATH" || fail "fixture planned topology is inconsistent with the project create contract"

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

  function finish_duplicate() {
    if (!in_dup_entry) {
      return
    }
    if (dup_status == "duplicate-same-project") {
      if (dup_project != "project-demo-web-app" || dup_category != "false" || dup_channels != "false") {
        print "duplicate-same-project must bind project ref and no duplicate flags" > "/dev/stderr"
        exit 1
      }
      duplicate_same = 1
    } else if (dup_status == "duplicate-name-review") {
      if (dup_conflict == "" || dup_category != "false" || dup_channels != "false") {
        print "duplicate-name-review must bind conflicting project ref and no duplicate flags" > "/dev/stderr"
        exit 1
      }
      duplicate_review = 1
    } else {
      print "unexpected duplicate status " dup_status > "/dev/stderr"
      exit 1
    }
    in_dup_entry = 0
  }

  /^first_run_result:$/ { section = "first"; next }
  /^minimal_template_result:$/ { section = "minimal"; in_persist = 0; in_persist_channels = 0; next }
  /^duplicate_name_results:$/ { section = "duplicates"; next }
  /^permission_failure_results:$/ { finish_duplicate(); section = "permissions"; next }
  /^partial_failure_audit:$/ { finish_permission(); section = "partial"; next }
  /^unsupported_template_result:$/ { section = "unsupported"; next }
  /^metadata:$/ { section = "metadata"; next }

  section == "first" && /^  persisted_registry_after_run:$/ {
    in_persist = 1
    in_persist_channels = 0
    next
  }
  in_persist && /^    guild_ref:/ { persisted_guild = $2; next }
  in_persist && /^    project_ref:/ { persisted_project = $2; next }
  in_persist && /^    project_slug:/ { persisted_slug = $2; next }
  in_persist && /^    category_ref:/ { persisted_category = $2; next }
  in_persist && /^    category_semantic_role:/ { persisted_role = $2; next }
  in_persist && /^    selected_template:/ { persisted_template = $2; next }
  in_persist && /^    scope:/ { persisted_scope = $2; next }
  in_persist && /^    idempotency_key_ref:/ { persisted_idempotency = $2; next }
  in_persist && /^    channels:$/ { in_persist_channels = 1; next }
  in_persist_channels && /^      context:/ { persisted_channels["context"] = $2; next }
  in_persist_channels && /^      skills:/ { persisted_channels["skills"] = $2; next }
  in_persist_channels && /^      strategy:/ { persisted_channels["strategy"] = $2; next }
  in_persist_channels && /^      tasks:/ { persisted_channels["tasks"] = $2; next }
  in_persist_channels && /^      decisions:/ { persisted_channels["decisions"] = $2; next }
  in_persist_channels && /^      qa:/ { persisted_channels["qa"] = $2; next }
  in_persist && /^    persistence_private_runtime_ids:/ { persisted_private_ids = $2; next }
  in_persist && /^    persistence_repo_safe_refs_only:/ { persisted_repo_safe = $2; next }

  section == "minimal" && /^  selected_template:/ { minimal_template = $2; next }
  section == "minimal" && /^  category_ref:/ { minimal_category = $2; next }
  section == "minimal" && /^  channel_fields:$/ { minimal_mode = "fields"; next }
  section == "minimal" && /^  omitted_fields:$/ { minimal_mode = "omitted"; next }
  section == "minimal" && minimal_mode == "fields" && /^    - / { minimal_fields[$2] = 1; next }
  section == "minimal" && minimal_mode == "omitted" && /^    - / { minimal_omitted[$2] = 1; next }

  section == "duplicates" && /^  - status:/ {
    finish_duplicate()
    in_dup_entry = 1
    dup_status = $3
    dup_project = ""
    dup_conflict = ""
    dup_category = ""
    dup_channels = ""
    next
  }
  in_dup_entry && /^    persisted_project_ref:/ { dup_project = $2; next }
  in_dup_entry && /^    conflicting_project_ref:/ { dup_conflict = $2; next }
  in_dup_entry && /^    duplicate_category_created:/ { dup_category = $2; next }
  in_dup_entry && /^    duplicate_channels_created:/ { dup_channels = $2; next }

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

  section == "partial" && /^  status:/ { partial_status = $2; next }
  section == "partial" && /^  created_category_ref:/ { partial_category = $2; next }
  section == "partial" && /^  created_channel_refs:$/ { partial_mode = "created_channels"; next }
  section == "partial" && /^  missing_channel_fields:$/ { partial_mode = "missing_fields"; next }
  section == "partial" && partial_mode == "created_channels" && /^    - / { partial_created_channels[$2] = 1; partial_created_count++; next }
  section == "partial" && partial_mode == "missing_fields" && /^    - / { partial_missing_fields[$2] = 1; partial_missing_count++; next }
  section == "partial" && /^  safe_retry_token_ref:/ { partial_mode = ""; partial_retry = $2; next }
  section == "partial" && /^  repair_issue_ref:/ { partial_repair = $2; next }
  section == "partial" && /^  duplicate_recreate_allowed_in_issue_135:/ { partial_duplicate = $2; next }

  section == "unsupported" && /^  status:/ { unsupported_status = $2; next }
  section == "unsupported" && /^  selected_template:/ { unsupported_template = $2; next }
  section == "unsupported" && /^  writes_attempted_after_permission_preflight:/ { unsupported_writes = $2; next }

  END {
    finish_duplicate()
    finish_permission()
    if (persisted_guild != "guild-demo-project-manager" || persisted_project != "project-demo-web-app" || persisted_slug != "web-app" || persisted_category != "category-demo-project-web-app") {
      print "persisted registry must include guild, project, slug, and category refs inside first_run_result" > "/dev/stderr"
      exit 1
    }
    if (persisted_role != "project-manager-project" || persisted_scope != "project" || persisted_template != "complete" || persisted_idempotency != "project:<guild-id>:web-app") {
      print "persisted registry must include project role, project scope, selected template, and idempotency ref inside first_run_result" > "/dev/stderr"
      exit 1
    }
    split("context skills strategy tasks decisions qa", required_fields, " ")
    for (idx in required_fields) {
      field = required_fields[idx]
      expected = "channel-demo-web-app-" field
      if (persisted_channels[field] != expected) {
        print "persisted registry missing channel mapping for " field > "/dev/stderr"
        exit 1
      }
    }
    if (persisted_private_ids != "true" || persisted_repo_safe != "true") {
      print "persisted registry must declare private runtime IDs and repo-safe refs" > "/dev/stderr"
      exit 1
    }
    if (minimal_template != "minimal" || minimal_category == "" || !("context" in minimal_fields) || !("strategy" in minimal_fields) || !("tasks" in minimal_fields) || !("skills" in minimal_omitted) || !("decisions" in minimal_omitted) || !("qa" in minimal_omitted)) {
      print "minimal template result must include context/strategy/tasks and omit skills/decisions/qa" > "/dev/stderr"
      exit 1
    }
    if (!duplicate_same || !duplicate_review) {
      print "duplicate handling must cover same-project and conflicting-project cases" > "/dev/stderr"
      exit 1
    }
    if (!manage_channels_failure || !pin_permission_failure) {
      print "permission failures must cover both manage_channels and manage_messages_for_pin" > "/dev/stderr"
      exit 1
    }
    if (partial_status != "partial-failure-needs-repair" || partial_category == "" || partial_retry == "" || partial_repair != "138" || partial_duplicate != "false") {
      print "partial failure audit must include category ref, retry token, repair issue, and no duplicate recreate" > "/dev/stderr"
      exit 1
    }
    if (partial_created_count == 0 || partial_missing_count == 0 || !("tasks" in partial_missing_fields)) {
      print "partial failure audit must include created channel refs and missing channel fields for safe repair" > "/dev/stderr"
      exit 1
    }
    if (unsupported_status != "unsupported-template" || unsupported_template != "custom" || unsupported_writes != "false") {
      print "unsupported template result must stop before writes" > "/dev/stderr"
      exit 1
    }
  }
' "$FIXTURE_PATH" || fail "fixture result blocks are inconsistent with the project create contract"

for required in \
  "# Discord Project Manager project creation" \
  "project create" \
  "Project - Web App" \
  "one top-level Discord category" \
  "minimal" \
  "complete" \
  "context" \
  "skills" \
  "strategy" \
  "tasks" \
  "decisions" \
  "qa" \
  "manage_channels" \
  "manage_messages_for_pin" \
  "projectSlug" \
  "Duplicate and failure handling" \
  "docs/architecture/discord-channel-scaffolding-status-repair.md" \
  "does not prove live Discord"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

for required in \
  "docs/architecture/discord-project-manager-project-create.md" \
  "examples/discord-project-manager-project-create.fake.yaml" \
  "scripts/validate-discord-project-manager-project-create.sh"; do
  grep -F "$required" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing project create reference: $required"
  grep -F "$required" "$CONFIG_README_PATH" >/dev/null || fail "config README missing project create reference: $required"
done

grep -F "docs/architecture/discord-project-manager-project-create.md" "$GUIDE_DOC_PATH" >/dev/null || fail "semantic guide doc missing project create reference"
grep -F "docs/architecture/discord-project-manager-project-create.md" "$GLOBAL_INIT_DOC_PATH" >/dev/null || fail "global init doc missing project create reference"

review_paths=(
  "$FIXTURE_PATH"
  "$DOC_PATH"
  "$GLOBAL_INIT_DOC_PATH"
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

echo "Validated fake Discord Project Manager project create contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Semantic guide fixture: $GUIDE_FIXTURE_PATH"
echo "Runbook: $ROUTING_DOC_PATH"
echo "Config README: $CONFIG_README_PATH"
