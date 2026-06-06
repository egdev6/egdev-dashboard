#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_CHANNEL_SCAFFOLDING_STATUS_REPAIR_FIXTURE:-examples/discord-channel-scaffolding-status-repair.fake.yaml}"
DOC_PATH="docs/architecture/discord-channel-scaffolding-status-repair.md"
GLOBAL_INIT_DOC_PATH="docs/architecture/discord-project-manager-global-init.md"
PROJECT_CREATE_DOC_PATH="docs/architecture/discord-project-manager-project-create.md"
MANAGED_ROUTING_DOC_PATH="docs/architecture/discord-managed-channel-routing.md"
TOPOLOGY_DOC_PATH="docs/architecture/discord-topology-reconciliation.md"
GUIDE_FIXTURE_PATH="examples/discord-semantic-channel-guides.fake.yaml"
ROUTING_DOC_PATH="docs/operations/discord-routing.md"
CONFIG_README_PATH="openclaw/config/README.md"
RUNTIME_NAMESPACE_CONTRACT="discord-project-manager/runtime/discord/<guild-id>/<channel-id>"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

require_cmd awk
require_cmd grep

require_yaml_fragment_ref() {
  local ref="$1"
  local file="${ref%%#*}"
  local fragment="${ref#*#}"

  [[ "$file" != "$ref" ]] || fail "cross-file reference missing fragment: $ref"
  [[ -f "$file" ]] || fail "cross-file reference target file not found: $file"

  case "$fragment" in
    second_run_result | drift_boundary_result | managed_channel_registry | first_run_result | partial_failure_audit)
      grep -F "${fragment}:" "$file" >/dev/null || fail "cross-file reference fragment not found: $ref"
      ;;
    global.config.topic)
      grep -F "scope: global" "$file" >/dev/null || fail "global config topic ref missing global scope: $ref"
      grep -F "field_key: config" "$file" >/dev/null || fail "global config topic ref missing field key: $ref"
      grep -F "topic:" "$file" >/dev/null || fail "global config topic ref missing topic marker: $ref"
      ;;
    global.config.starter_message)
      grep -F "scope: global" "$file" >/dev/null || fail "global config starter ref missing global scope: $ref"
      grep -F "field_key: config" "$file" >/dev/null || fail "global config starter ref missing field key: $ref"
      grep -F "starter_message:" "$file" >/dev/null || fail "global config starter ref missing starter marker: $ref"
      ;;
    project.tasks.topic)
      grep -F "scope: project" "$file" >/dev/null || fail "project tasks topic ref missing project scope: $ref"
      grep -F "field_key: tasks" "$file" >/dev/null || fail "project tasks topic ref missing field key: $ref"
      grep -F "topic:" "$file" >/dev/null || fail "project tasks topic ref missing topic marker: $ref"
      ;;
    project.tasks.starter_message)
      grep -F "scope: project" "$file" >/dev/null || fail "project tasks starter ref missing project scope: $ref"
      grep -F "field_key: tasks" "$file" >/dev/null || fail "project tasks starter ref missing field key: $ref"
      grep -F "starter_message:" "$file" >/dev/null || fail "project tasks starter ref missing starter marker: $ref"
      ;;
    *)
      fail "unsupported cross-file reference fragment: $ref"
      ;;
  esac
}

for path in \
  "$FIXTURE_PATH" \
  "$DOC_PATH" \
  "$GLOBAL_INIT_DOC_PATH" \
  "$PROJECT_CREATE_DOC_PATH" \
  "$MANAGED_ROUTING_DOC_PATH" \
  "$TOPOLOGY_DOC_PATH" \
  "$GUIDE_FIXTURE_PATH" \
  "$ROUTING_DOC_PATH" \
  "$CONFIG_README_PATH"; do
  [[ -f "$path" ]] || fail "required file not found: $path"
done

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-channel-scaffolding-status-repair" \
  "issue_ref: 138" \
  "live_discord_validation_proven: false" \
  "runtime_enforcement_proven: false" \
  "uses_real_discord_ids: false" \
  "raw_discord_chat_logs_included: false" \
  "durable_memory_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "topology_lookup_source: persisted-semantic-metadata" \
  "name_relink_allowed_without_review: false" \
  "approval_gate_required_for_apply: true" \
  "approval_gate_skill: discord-approval-gate" \
  "repair_requires_preview_first: true" \
  "topology_reconciliation_contract: docs/architecture/discord-topology-reconciliation.md" \
  "managed_routing_contract: docs/architecture/discord-managed-channel-routing.md" \
  "guide_catalog_ref: examples/discord-semantic-channel-guides.fake.yaml" \
  "reports_existing_channels: true" \
  "reports_missing_channels: true" \
  "reports_unmanaged_channels: true" \
  "reports_unsafe_missing_ids: true" \
  "durable_write_allowed: false" \
  "preview_required_before_apply: true" \
  "apply_requires_exact_approval_phrase: approve write" \
  "permission_preflight_required: true" \
  "partial_apply_allowed_on_missing_permissions: false" \
  "metadata_refresh_required_on_recreate: true" \
  "status_and_repair_scenarios:" \
  "audit_outputs:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "docs/architecture/discord-project-manager-global-init.md" \
  "docs/architecture/discord-project-manager-project-create.md" \
  "docs/architecture/discord-managed-channel-routing.md" \
  "examples/discord-semantic-channel-guides.fake.yaml"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing dependency marker: $required"
done

while IFS= read -r ref; do
  require_yaml_fragment_ref "$ref"
done < <(awk '/(idempotency_source_ref|topic_source|starter_message_source):/ { print $2 }' "$FIXTURE_PATH")

for command in \
  "/project-manager status" \
  "/project-manager repair" \
  "/project status"; do
  grep -F "    - $command" "$FIXTURE_PATH" >/dev/null || fail "fixture missing supported command: $command"
done

for scenario in \
  "status-global-intact-rerun" \
  "repair-global-missing-config" \
  "status-project-renamed-linked" \
  "status-project-unsafe-missing-id" \
  "repair-project-partial-failure-retry" \
  "repair-project-permission-blocked" \
  "status-project-unmanaged-extra"; do
  grep -F "scenario_ref: $scenario" "$FIXTURE_PATH" >/dev/null || fail "fixture missing scenario: $scenario"
done

for required in \
  "approval_phrase: approve write" \
  "safe_retry_token_ref: retry-demo-web-app-create" \
  "auto_linked_by_name: false" \
  "linked_by_id: true" \
  "relink_by_name_attempted: false" \
  "metadata_refresh_required: true" \
  "metadata_refresh_required: false" \
  "refreshed_registry_field: channels.config" \
  "refreshed_registry_field: channels.tasks" \
  "refreshed_state_target: workspace-global-config" \
  "refreshed_state_target: project:web-app:tasks" \
  "permission_preflight_status: blocked-permissions" \
  "permission_missing_capabilities:" \
  "manage_messages_for_pin" \
  "runtime_namespace: discord-project-manager/runtime/discord/<guild-id>/<channel-id>" \
  "retained_raw_message: false" \
  "safe_fake_refs_only: true"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing repair behavior marker: $required"
done

awk '
  function has_value(values, value) {
    return index(values, " " value " ") > 0
  }

  function finish_action() {
    if (!in_action) {
      return
    }
    if (action_type == "" || action_field == "" || action_previous == "" || action_proposed == "" || action_refresh == "" || action_registry == "" || action_state_target == "") {
      print "repair action missing required fields for scenario " scenario_ref > "/dev/stderr"
      exit 1
    }
    action_count++
    if (scenario_ref == "repair-global-missing-config") {
      if (action_type != "recreate-channel" || action_field != "config" || action_previous != "channel-demo-global-config" || action_proposed != "channel-demo-global-config-recreated" || action_refresh != "true" || action_registry != "channels.config" || action_state_target != "workspace-global-config") {
        print "global missing config repair action is inconsistent" > "/dev/stderr"
        exit 1
      }
    } else if (scenario_ref == "status-project-renamed-linked") {
      if (action_type != "update-guide-copy" || action_field != "strategy" || action_previous != "channel-demo-web-app-strategy" || action_proposed != "channel-demo-web-app-strategy" || action_refresh != "false" || action_registry != "none" || action_state_target != "project:web-app:strategy") {
        print "renamed project status action is inconsistent" > "/dev/stderr"
        exit 1
      }
    } else if (scenario_ref == "repair-project-partial-failure-retry" || scenario_ref == "repair-project-permission-blocked") {
      if (action_type != "recreate-channel" || action_field != "tasks" || action_previous != "channel-demo-web-app-tasks" || action_proposed != "channel-demo-web-app-tasks-recreated" || action_refresh != "true" || action_registry != "channels.tasks" || action_state_target != "project:web-app:tasks") {
        print "project tasks repair action is inconsistent for scenario " scenario_ref > "/dev/stderr"
        exit 1
      }
    }
    in_action = 0
  }

  function finish_scenario() {
    if (!in_scenario) {
      return
    }
    finish_action()
    if (audit_ref == "") {
      print "scenario missing audit_ref: " scenario_ref > "/dev/stderr"
      exit 1
    }
    if (scenario_ref == "status-global-intact-rerun") {
      if (managed_surface != "global" || command_ref != "/project-manager status" || project_ref != "none" || project_slug != "none" || status_result != "no-op" || write_attempted != "false" || duplicate_category_created != "false" || duplicate_channels_created != "false" || existing_count != 5 || missing_count != 0 || unmanaged_count != 0 || unsafe_count != 0 || preview_status != "no-op" || permission_status != "ready" || permission_count != 0 || approval_state != "not-requested" || write_executed != "false" || action_count != 0 || !has_value(existing_fields, "context") || !has_value(existing_fields, "skills") || !has_value(existing_fields, "strategy") || !has_value(existing_fields, "decisions") || !has_value(existing_fields, "config")) {
        print "global intact rerun scenario must stay duplicate-free and no-op" > "/dev/stderr"
        exit 1
      }
      saw_global_noop = 1
    } else if (scenario_ref == "repair-global-missing-config") {
      if (managed_surface != "global" || command_ref != "/project-manager repair" || status_result != "needs-repair" || write_attempted != "false" || existing_count != 4 || missing_count != 1 || !has_value(missing_fields, "config") || unmanaged_count != 0 || unsafe_count != 0 || preview_status != "approval-requested" || permission_status != "ready" || permission_count != 0 || approval_state != "approval-requested" || approval_phrase != "approve write" || mandatory_skill != "discord-approval-gate" || write_executed != "false" || action_count != 1) {
        print "global missing config scenario must propose one approval-gated recreate with metadata refresh" > "/dev/stderr"
        exit 1
      }
      saw_global_missing = 1
    } else if (scenario_ref == "status-project-renamed-linked") {
      if (managed_surface != "project" || command_ref != "/project status" || project_ref != "project-demo-web-app" || project_slug != "web-app" || status_result != "renamed-linked" || write_attempted != "false" || existing_count != 6 || missing_count != 0 || unmanaged_count != 0 || unsafe_count != 0 || renamed_field != "strategy" || renamed_ref != "channel-demo-web-app-strategy" || linked_by_id != "true" || relink_by_name_attempted != "false" || preview_status != "no-relink-required" || approval_state != "not-requested" || write_executed != "false" || action_count != 1) {
        print "renamed project scenario must stay linked by ID without relink by name" > "/dev/stderr"
        exit 1
      }
      saw_renamed = 1
    } else if (scenario_ref == "status-project-unsafe-missing-id") {
      if (managed_surface != "project" || command_ref != "/project status" || project_ref != "project-demo-web-app" || project_slug != "web-app" || status_result != "unsafe-missing-id" || write_attempted != "false" || missing_count != 1 || !has_value(missing_fields, "tasks") || unsafe_count != 1 || !has_value(unsafe_fields, "tasks") || possible_name_match_ref != "channel-demo-web-app-tasks-unlinked" || auto_linked_by_name != "false" || preview_status != "needs-review" || approval_state != "not-requested" || write_executed != "false" || action_count != 0 || operator_message !~ /no relink was applied without review/) {
        print "unsafe missing ID scenario must refuse automatic relink by name" > "/dev/stderr"
        exit 1
      }
      saw_unsafe_missing = 1
    } else if (scenario_ref == "repair-project-partial-failure-retry") {
      if (managed_surface != "project" || command_ref != "/project-manager repair" || project_ref != "project-demo-web-app" || project_slug != "web-app" || status_result != "needs-repair" || write_attempted != "false" || existing_count != 2 || !has_value(existing_fields, "context") || !has_value(existing_fields, "strategy") || missing_count != 1 || !has_value(missing_fields, "tasks") || preview_status != "approval-requested" || permission_status != "ready" || permission_count != 0 || approval_state != "approval-requested" || approval_phrase != "approve write" || mandatory_skill != "discord-approval-gate" || write_executed != "false" || retry_source != "partial-failure-audit" || safe_retry_token_ref != "retry-demo-web-app-create" || action_count != 1) {
        print "partial failure retry scenario must reuse the safe retry token and approval gate" > "/dev/stderr"
        exit 1
      }
      saw_partial_retry = 1
    } else if (scenario_ref == "repair-project-permission-blocked") {
      if (managed_surface != "project" || command_ref != "/project-manager repair" || project_ref != "project-demo-web-app" || project_slug != "web-app" || status_result != "needs-repair" || write_attempted != "false" || missing_count != 1 || !has_value(missing_fields, "tasks") || preview_status != "blocked-permissions" || permission_status != "blocked-permissions" || permission_count != 1 || !has_value(permission_missing, "manage_messages_for_pin") || approval_state != "not-requested" || mandatory_skill != "discord-approval-gate" || write_executed != "false" || action_count != 1 || operator_message == "") {
        print "permission blocked repair scenario must stop before partial repair" > "/dev/stderr"
        exit 1
      }
      saw_permission_blocked = 1
    } else if (scenario_ref == "status-project-unmanaged-extra") {
      if (managed_surface != "project" || command_ref != "/project status" || project_ref != "project-demo-web-app" || project_slug != "web-app" || status_result != "unmanaged-present" || write_attempted != "false" || existing_count != 6 || missing_count != 0 || unmanaged_count != 1 || !has_value(unmanaged_channels, "channel-demo-web-app-random-notes") || unsafe_count != 0 || preview_status != "no-destructive-action" || approval_state != "not-requested" || write_executed != "false" || action_count != 0 || operator_message == "") {
        print "unmanaged extra scenario must report the extra channel without destructive action" > "/dev/stderr"
        exit 1
      }
      saw_unmanaged = 1
    }
    in_scenario = 0
  }

  /^audit_outputs:$/ {
    finish_scenario()
    section = "audit"
    next
  }
  /^status_and_repair_scenarios:$/ {
    section = "scenarios"
    next
  }
  section == "scenarios" && /^  - scenario_ref:/ {
    finish_scenario()
    in_scenario = 1
    scenario_ref = $3
    managed_surface = ""
    command_ref = ""
    expected_category_ref = ""
    project_ref = ""
    project_slug = ""
    status_result = ""
    duplicate_category_created = ""
    duplicate_channels_created = ""
    write_attempted = ""
    operator_message = ""
    existing_fields = " "
    missing_fields = " "
    unmanaged_channels = " "
    unsafe_fields = " "
    permission_missing = " "
    existing_count = 0
    missing_count = 0
    unmanaged_count = 0
    unsafe_count = 0
    permission_count = 0
    preview_status = ""
    permission_status = ""
    approval_state = ""
    approval_phrase = ""
    mandatory_skill = ""
    write_executed = ""
    retry_source = ""
    safe_retry_token_ref = ""
    possible_name_match_ref = ""
    auto_linked_by_name = ""
    renamed_field = ""
    renamed_ref = ""
    linked_by_id = ""
    relink_by_name_attempted = ""
    audit_ref = ""
    action_count = 0
    in_existing_fields = 0
    in_missing_fields = 0
    in_unmanaged_channels = 0
    in_unsafe_fields = 0
    in_permission_missing = 0
    in_renamed_binding = 0
    in_repair_preview = 0
    in_action = 0
    next
  }
  in_scenario && /^    managed_surface:/ { managed_surface = $2; next }
  in_scenario && /^    command_ref:/ { command_ref = substr($0, index($0, ":") + 2); next }
  in_scenario && /^    expected_category_ref:/ { expected_category_ref = $2; next }
  in_scenario && /^    project_ref:/ { project_ref = $2; next }
  in_scenario && /^    project_slug:/ { project_slug = $2; next }
  in_scenario && /^    status_result:/ { status_result = $2; next }
  in_scenario && /^    duplicate_category_created:/ { duplicate_category_created = $2; next }
  in_scenario && /^    duplicate_channels_created:/ { duplicate_channels_created = $2; next }
  in_scenario && /^    write_attempted:/ { write_attempted = $2; next }
  in_scenario && /^    operator_message:/ { operator_message = substr($0, index($0, ":") + 2); next }
  in_scenario && /^    possible_name_match_ref:/ { possible_name_match_ref = $2; next }
  in_scenario && /^    auto_linked_by_name:/ { auto_linked_by_name = $2; next }
  in_scenario && /^    audit_ref:/ { finish_action(); audit_ref = $2; next }

  in_scenario && /^    existing_fields: \[\]$/ {
    in_existing_fields = 0
    next
  }
  in_scenario && /^    existing_fields:$/ {
    in_existing_fields = 1
    in_missing_fields = 0
    in_unmanaged_channels = 0
    in_unsafe_fields = 0
    next
  }
  in_scenario && in_existing_fields && /^      - / {
    existing_count++
    existing_fields = existing_fields $2 " "
    next
  }

  in_scenario && /^    missing_fields: \[\]$/ {
    in_missing_fields = 0
    next
  }
  in_scenario && /^    missing_fields:$/ {
    in_missing_fields = 1
    in_existing_fields = 0
    in_unmanaged_channels = 0
    in_unsafe_fields = 0
    next
  }
  in_scenario && in_missing_fields && /^      - / {
    missing_count++
    missing_fields = missing_fields $2 " "
    next
  }

  in_scenario && /^    unmanaged_channel_refs: \[\]$/ {
    in_unmanaged_channels = 0
    next
  }
  in_scenario && /^    unmanaged_channel_refs:$/ {
    in_unmanaged_channels = 1
    in_existing_fields = 0
    in_missing_fields = 0
    in_unsafe_fields = 0
    next
  }
  in_scenario && in_unmanaged_channels && /^      - / {
    unmanaged_count++
    unmanaged_channels = unmanaged_channels $2 " "
    next
  }

  in_scenario && /^    unsafe_missing_id_fields: \[\]$/ {
    in_unsafe_fields = 0
    next
  }
  in_scenario && /^    unsafe_missing_id_fields:$/ {
    in_unsafe_fields = 1
    in_existing_fields = 0
    in_missing_fields = 0
    in_unmanaged_channels = 0
    next
  }
  in_scenario && in_unsafe_fields && /^      - / {
    unsafe_count++
    unsafe_fields = unsafe_fields $2 " "
    next
  }

  in_scenario && /^    renamed_binding:$/ {
    in_renamed_binding = 1
    next
  }
  in_renamed_binding && /^      field_key:/ { renamed_field = $2; next }
  in_renamed_binding && /^      channel_ref:/ { renamed_ref = $2; next }
  in_renamed_binding && /^      linked_by_id:/ { linked_by_id = $2; next }
  in_renamed_binding && /^      relink_by_name_attempted:/ { relink_by_name_attempted = $2; next }
  in_renamed_binding && /^    repair_preview:$/ { in_renamed_binding = 0 }

  in_scenario && /^    repair_preview:$/ {
    in_repair_preview = 1
    in_existing_fields = 0
    in_missing_fields = 0
    in_unmanaged_channels = 0
    in_unsafe_fields = 0
    next
  }
  in_repair_preview && /^      status:/ { finish_action(); preview_status = $2; next }
  in_repair_preview && /^      permission_preflight_status:/ { finish_action(); permission_status = $2; next }
  in_repair_preview && /^      permission_missing_capabilities: \[\]$/ {
    finish_action()
    in_permission_missing = 0
    next
  }
  in_repair_preview && /^      permission_missing_capabilities:$/ {
    finish_action()
    in_permission_missing = 1
    next
  }
  in_permission_missing && /^        - / {
    permission_count++
    permission_missing = permission_missing $2 " "
    next
  }
  in_repair_preview && /^      approval_state:/ { finish_action(); in_permission_missing = 0; approval_state = $2; next }
  in_repair_preview && /^      approval_phrase:/ { finish_action(); approval_phrase = substr($0, index($0, ":") + 2); next }
  in_repair_preview && /^      mandatory_skill:/ { finish_action(); mandatory_skill = $2; next }
  in_repair_preview && /^      write_executed:/ { finish_action(); write_executed = $2; next }
  in_repair_preview && /^      retry_source:/ { finish_action(); retry_source = $2; next }
  in_repair_preview && /^      safe_retry_token_ref:/ { finish_action(); safe_retry_token_ref = $2; next }
  in_repair_preview && /^      proposed_actions: \[\]$/ {
    finish_action()
    next
  }
  in_repair_preview && /^      proposed_actions:$/ {
    finish_action()
    next
  }
  in_repair_preview && /^        - action:/ {
    finish_action()
    in_action = 1
    action_type = $3
    action_field = ""
    action_previous = ""
    action_proposed = ""
    action_refresh = ""
    action_registry = ""
    action_state_target = ""
    next
  }
  in_action && /^          field_key:/ { action_field = $2; next }
  in_action && /^          previous_channel_ref:/ { action_previous = $2; next }
  in_action && /^          proposed_channel_ref:/ { action_proposed = $2; next }
  in_action && /^          metadata_refresh_required:/ { action_refresh = $2; next }
  in_action && /^          refreshed_registry_field:/ { action_registry = $2; next }
  in_action && /^          refreshed_state_target:/ { action_state_target = $2; next }

  /^audit_outputs:$/ { next }
  section == "audit" && /^  - audit_ref:/ {
    audit_count++
    current_audit = $3
    audits[current_audit] = 1
    next
  }
  section == "audit" && /^    runtime_namespace:/ { audit_runtime[current_audit] = $2; next }
  section == "audit" && /^    retained_raw_message:/ { audit_raw[current_audit] = $2; next }
  section == "audit" && /^    safe_fake_refs_only:/ { audit_safe[current_audit] = $2; next }

  END {
    finish_scenario()
    if (!saw_global_noop || !saw_global_missing || !saw_renamed || !saw_unsafe_missing || !saw_partial_retry || !saw_permission_blocked || !saw_unmanaged) {
      print "status and repair scenarios must cover required no-op, missing, renamed, unsafe ID, retry, permission, and unmanaged cases" > "/dev/stderr"
      exit 1
    }
    if (audit_count != 7) {
      print "expected one audit output for each of the seven scenarios" > "/dev/stderr"
      exit 1
    }
    split("audit-demo-status-global-intact-rerun audit-demo-repair-global-missing-config audit-demo-status-project-renamed-linked audit-demo-status-project-unsafe-missing-id audit-demo-repair-project-partial-failure-retry audit-demo-repair-project-permission-blocked audit-demo-status-project-unmanaged-extra", required_audits, " ")
    for (idx in required_audits) {
      audit = required_audits[idx]
      if (!(audit in audits)) {
        print "missing audit output " audit > "/dev/stderr"
        exit 1
      }
      if (audit_runtime[audit] != "discord-project-manager/runtime/discord/<guild-id>/<channel-id>" || audit_raw[audit] != "false" || audit_safe[audit] != "true") {
        print "audit output must use the runtime namespace contract with safe fake refs for " audit > "/dev/stderr"
        exit 1
      }
    }
  }
' "$FIXTURE_PATH" || fail "status and repair scenarios are inconsistent with the contract"

for required in \
  "# Discord channel scaffolding status and repair" \
  "/project-manager status" \
  "/project-manager repair" \
  "/project status" \
  "approve write" \
  "unsafe-missing-id" \
  "renamed-linked" \
  "unmanaged extra" \
  "does not prove live Discord"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

for required in \
  "docs/architecture/discord-channel-scaffolding-status-repair.md" \
  "examples/discord-channel-scaffolding-status-repair.fake.yaml" \
  "scripts/validate-discord-channel-scaffolding-status-repair.sh"; do
  grep -F "$required" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing status/repair reference: $required"
  grep -F "$required" "$CONFIG_README_PATH" >/dev/null || fail "config README missing status/repair reference: $required"
done

grep -F "docs/architecture/discord-channel-scaffolding-status-repair.md" "$GLOBAL_INIT_DOC_PATH" >/dev/null || fail "global init doc missing status/repair reference"
grep -F "docs/architecture/discord-channel-scaffolding-status-repair.md" "$PROJECT_CREATE_DOC_PATH" >/dev/null || fail "project create doc missing status/repair reference"
grep -F "docs/architecture/discord-channel-scaffolding-status-repair.md" "$MANAGED_ROUTING_DOC_PATH" >/dev/null || fail "managed routing doc missing status/repair reference"
grep -F "docs/architecture/discord-channel-scaffolding-status-repair.md" "$TOPOLOGY_DOC_PATH" >/dev/null || fail "topology reconciliation doc missing status/repair reference"

review_paths=(
  "$FIXTURE_PATH"
  "$DOC_PATH"
  "$GLOBAL_INIT_DOC_PATH"
  "$PROJECT_CREATE_DOC_PATH"
  "$MANAGED_ROUTING_DOC_PATH"
  "$TOPOLOGY_DOC_PATH"
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

if grep -E 'live_discord_validation_proven: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|raw_discord_chat_logs_included: true|durable_memory_writes_allowed: true|workspace_file_writes_allowed: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|uses production credentials|production credentials enabled|prompt execution proven|live write proven' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, persistence, publishing, scheduling, or prompt execution behavior"
fi

echo "Validated fake Discord channel scaffolding status/repair contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
