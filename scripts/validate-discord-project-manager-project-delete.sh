#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_PROJECT_MANAGER_PROJECT_DELETE_FIXTURE:-examples/discord-project-manager-project-delete.fake.yaml}"
DOC_PATH="docs/architecture/discord-project-manager-project-delete.md"
CREATE_DOC_PATH="docs/architecture/discord-project-manager-project-create.md"
REPAIR_DOC_PATH="docs/architecture/discord-channel-scaffolding-status-repair.md"
ROUTING_DOC_PATH="docs/architecture/discord-managed-channel-routing.md"
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

for path in \
  "$FIXTURE_PATH" \
  "$DOC_PATH" \
  "$CREATE_DOC_PATH" \
  "$REPAIR_DOC_PATH" \
  "$ROUTING_DOC_PATH" \
  "$RUNBOOK_PATH" \
  "$CONFIG_README_PATH"; do
  [[ -f "$path" ]] || fail "required file not found: $path"
done

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-project-manager-project-delete" \
  "issue_ref: 145" \
  "live_discord_validation_proven: false" \
  "runtime_enforcement_proven: false" \
  "uses_real_discord_ids: false" \
  "raw_discord_chat_logs_included: false" \
  "durable_memory_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "backend_ref: private-runtime-managed-channel-registry" \
  "producer: /project delete" \
  "deleted_project_status: DELETED_PROJECT" \
  "display_name_inference_success_allowed: false" \
  "interaction_name: /project delete" \
  "target_lookup_source: persisted-semantic-metadata" \
  "category_name_inference_allowed: false" \
  "preview_required_before_apply: true" \
  "stronger_than_standard_write_confirmation: true" \
  "standard_write_confirmation_phrase: approve write" \
  "apply_requires_exact_approval_phrase_template: approve delete project <project-slug>" \
  "required_before_destructive_apply: true" \
  "partial_delete_allowed_on_missing_permissions: false" \
  "source_ref: examples/discord-project-manager-project-create.fake.yaml#first_run_result" \
  "delete_preview_scenarios:" \
  "post_delete_registry_state:" \
  "post_delete_verification_expectations:" \
  "partial_delete_audit:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for capability in manage_channels view_channel; do
  grep -F "    - $capability" "$FIXTURE_PATH" >/dev/null || fail "fixture missing permission capability: $capability"
done

for field in context skills strategy tasks decisions qa; do
  grep -F "      - $field" "$FIXTURE_PATH" >/dev/null || fail "fixture missing managed field marker: $field"
  grep -F "channel-demo-web-app-$field" "$FIXTURE_PATH" >/dev/null || fail "fixture missing managed channel ref for field: $field"
done

for scenario in \
  delete-project-intact-preview \
  delete-project-unmanaged-extra-blocked \
  delete-project-unsafe-missing-id-blocked \
  delete-project-permission-blocked \
  delete-project-already-deleted \
  delete-project-partial-failure-retry; do
  grep -F "  - scenario_ref: $scenario" "$FIXTURE_PATH" >/dev/null || fail "fixture missing delete scenario: $scenario"
  grep -F "audit-demo-$scenario" "$FIXTURE_PATH" >/dev/null || fail "fixture missing audit ref for scenario: $scenario"
done

for required in \
  "approve delete project web-app" \
  "approval_phrase: approve delete project web-app" \
  "mandatory_skill: discord-approval-gate" \
  "write_executed: false" \
  "post_delete_routing_status: DELETED_PROJECT" \
  "post_delete_status_result: deleted-project" \
  "managed_channel_registry_consumer_must_not_return_ok: true" \
  "auto_delete_by_name_attempted: false" \
  "status: partial-delete-needs-retry" \
  "safe_retry_token_ref: retry-delete-demo-web-app" \
  "tombstone_written: false" \
  "live_registry_bindings_remaining: true"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing safety/verification marker: $required"
done

awk '
  function finish_action() {
    if (in_actions && action != "") {
      action_count++
      if (action == "delete-channel") delete_channel_count++
      if (action == "delete-category") delete_category_count++
      if (action == "tombstone-project-binding") tombstone_count++
    }
    action = ""
  }

  function finish_scenario() {
    finish_action()
    if (scenario == "") return
    scenarios++
    seen[scenario] = 1

    if (command_ref != "/project delete" || project_ref != "project-demo-web-app" || project_slug != "web-app" || write_attempted != "false" || mandatory_skill != "discord-approval-gate" || write_executed != "false" || approval_phrase != "approve delete project web-app" || stronger != "true" || routing_status != "DELETED_PROJECT" || status_after != "deleted-project") {
      print "scenario has inconsistent common delete contract fields: " scenario > "/dev/stderr"
      exit 1
    }

    if (scenario == "delete-project-intact-preview") {
      if (status_result != "no-op" || preview_status != "approval-requested" || permission_status != "ready" || approval_state != "approval-requested" || existing_count != 6 || missing_count != 0 || unmanaged_count != 0 || unsafe_count != 0 || delete_channel_count != 6 || delete_category_count != 1 || tombstone_count != 1) {
        print "intact delete preview must list six managed channels, category delete, and tombstone action" > "/dev/stderr"
        exit 1
      }
    } else if (scenario == "delete-project-unmanaged-extra-blocked") {
      if (status_result != "unmanaged-present" || preview_status != "needs-review" || approval_state != "not-requested" || unmanaged_count != 1 || action_count != 0 || operator_message == "") {
        print "unmanaged extra delete scenario must block without proposed destructive actions" > "/dev/stderr"
        exit 1
      }
    } else if (scenario == "delete-project-unsafe-missing-id-blocked") {
      if (status_result != "unsafe-missing-id" || preview_status != "needs-review" || approval_state != "not-requested" || unsafe_count != 1 || missing_count != 1 || auto_delete_by_name != "false" || action_count != 0 || operator_message == "") {
        print "unsafe missing ID delete scenario must block name-based deletion" > "/dev/stderr"
        exit 1
      }
    } else if (scenario == "delete-project-permission-blocked") {
      if (preview_status != "blocked-permissions" || permission_status != "blocked-permissions" || approval_state != "not-requested" || missing_capability_count != 1 || action_count == 0 || operator_message == "") {
        print "permission-blocked delete scenario must show plan but stop before approval/apply" > "/dev/stderr"
        exit 1
      }
    } else if (scenario == "delete-project-already-deleted") {
      if (status_result != "deleted-project" || preview_status != "no-op" || approval_state != "not-requested" || existing_count != 0 || action_count != 0 || operator_message == "") {
        print "already-deleted scenario must be idempotent no-op" > "/dev/stderr"
        exit 1
      }
    } else if (scenario == "delete-project-partial-failure-retry") {
      if (status_result != "needs-retry" || preview_status != "approval-requested" || approval_state != "approval-requested" || retry_source != "partial-delete-audit" || safe_retry_token_ref != "retry-delete-demo-web-app" || delete_channel_count != 2 || delete_category_count != 1 || tombstone_count != 1) {
        print "partial-failure retry scenario must target only remaining persisted bindings" > "/dev/stderr"
        exit 1
      }
    } else {
      print "unexpected scenario: " scenario > "/dev/stderr"
      exit 1
    }

    command_ref = project_ref = project_slug = status_result = write_attempted = preview_status = permission_status = approval_state = approval_phrase = mandatory_skill = write_executed = stronger = routing_status = status_after = operator_message = retry_source = safe_retry_token_ref = auto_delete_by_name = ""
    existing_count = missing_count = unmanaged_count = unsafe_count = missing_capability_count = action_count = delete_channel_count = delete_category_count = tombstone_count = 0
    in_actions = in_missing_capabilities = 0
  }

  /^  - scenario_ref:/ { finish_scenario(); scenario = $3; next }
  scenario != "" && /^    command_ref:/ { command_ref = substr($0, index($0, ":") + 2); next }
  scenario != "" && /^    project_ref:/ { project_ref = $2; next }
  scenario != "" && /^    project_slug:/ { project_slug = $2; next }
  scenario != "" && /^    status_result:/ { status_result = $2; next }
  scenario != "" && /^    write_attempted:/ { write_attempted = $2; next }
  scenario != "" && /^    operator_message:/ { operator_message = substr($0, index($0, ":") + 2); next }
  scenario != "" && /^    auto_delete_by_name_attempted:/ { auto_delete_by_name = $2; next }
  scenario != "" && /^    existing_fields: \[\]$/ { existing_count = 0; next }
  scenario != "" && /^    missing_fields: \[\]$/ { missing_count = 0; next }
  scenario != "" && /^    unmanaged_channel_refs: \[\]$/ { unmanaged_count = 0; next }
  scenario != "" && /^    unsafe_missing_id_fields: \[\]$/ { unsafe_count = 0; next }
  scenario != "" && /^    existing_fields:$/ { section = "existing"; next }
  scenario != "" && /^    missing_fields:$/ { section = "missing"; next }
  scenario != "" && /^    unmanaged_channel_refs:$/ { section = "unmanaged"; next }
  scenario != "" && /^    unsafe_missing_id_fields:$/ { section = "unsafe"; next }
  scenario != "" && /^    [a-z_]+:/ && $1 !~ /^-/ { section = "" }
  scenario != "" && section == "existing" && /^      - / { existing_count++; next }
  scenario != "" && section == "missing" && /^      - / { missing_count++; next }
  scenario != "" && section == "unmanaged" && /^      - / { unmanaged_count++; next }
  scenario != "" && section == "unsafe" && /^      - / { unsafe_count++; next }

  scenario != "" && /^    delete_preview:$/ { in_preview = 1; next }
  in_preview && /^      status:/ { preview_status = $2; next }
  in_preview && /^      permission_preflight_status:/ { permission_status = $2; next }
  in_preview && /^      approval_state:/ { approval_state = $2; next }
  in_preview && /^      approval_phrase:/ { approval_phrase = substr($0, index($0, ":") + 2); next }
  in_preview && /^      stronger_than_standard_write_confirmation:/ { stronger = $2; next }
  in_preview && /^      mandatory_skill:/ { mandatory_skill = $2; next }
  in_preview && /^      write_executed:/ { write_executed = $2; next }
  in_preview && /^      post_delete_routing_status:/ { routing_status = $2; next }
  in_preview && /^      post_delete_status_result:/ { status_after = $2; next }
  in_preview && /^      retry_source:/ { retry_source = $2; next }
  in_preview && /^      safe_retry_token_ref:/ { safe_retry_token_ref = $2; next }
  in_preview && /^      permission_missing_capabilities: \[\]$/ { missing_capability_count = 0; in_missing_capabilities = 0; next }
  in_preview && /^      permission_missing_capabilities:$/ { in_missing_capabilities = 1; next }
  in_missing_capabilities && /^        - / { missing_capability_count++; next }
  in_preview && /^      proposed_actions: \[\]$/ { in_actions = 0; in_missing_capabilities = 0; action = ""; next }
  in_preview && /^      proposed_actions:$/ { in_actions = 1; in_missing_capabilities = 0; action = ""; next }
  in_actions && /^        - action:/ { finish_action(); action = $3; next }

  END {
    finish_scenario()
    if (scenarios != 6) {
      print "expected 6 delete scenarios, found " scenarios > "/dev/stderr"
      exit 1
    }
    split("delete-project-intact-preview delete-project-unmanaged-extra-blocked delete-project-unsafe-missing-id-blocked delete-project-permission-blocked delete-project-already-deleted delete-project-partial-failure-retry", required, " ")
    for (idx in required) {
      if (!(required[idx] in seen)) {
        print "missing required delete scenario " required[idx] > "/dev/stderr"
        exit 1
      }
    }
  }
' "$FIXTURE_PATH" || fail "project delete scenarios are inconsistent with the contract"

for required in \
  "# Discord Project Manager project delete" \
  "/project delete" \
  "persisted managed registry" \
  "not target by display name alone" \
  "two-phase" \
  "approve delete project <project-slug>" \
  "Generic" \
  "approve write" \
  "is not sufficient" \
  "DELETED_PROJECT" \
  "deleted-project" \
  "unmanaged extra channels, missing IDs, or ambiguous topology" \
  "scripts/validate-discord-project-manager-project-delete.sh"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

for required in \
  "docs/architecture/discord-project-manager-project-delete.md" \
  "examples/discord-project-manager-project-delete.fake.yaml" \
  "scripts/validate-discord-project-manager-project-delete.sh"; do
  grep -F "$required" "$RUNBOOK_PATH" >/dev/null || fail "routing runbook missing project-delete reference: $required"
  grep -F "$required" "$CONFIG_README_PATH" >/dev/null || fail "config README missing project-delete reference: $required"
done

grep -F "docs/architecture/discord-project-manager-project-delete.md" "$CREATE_DOC_PATH" >/dev/null || fail "project create doc missing project-delete lifecycle reference"
grep -F "docs/architecture/discord-project-manager-project-delete.md" "$REPAIR_DOC_PATH" >/dev/null || fail "status/repair doc missing project-delete lifecycle reference"
grep -F "docs/architecture/discord-project-manager-project-delete.md" "$ROUTING_DOC_PATH" >/dev/null || fail "managed routing doc missing project-delete lifecycle reference"
grep -F "DELETED_PROJECT" "$ROUTING_DOC_PATH" >/dev/null || fail "managed routing doc missing post-delete status vocabulary"
grep -F "deleted-project" "$REPAIR_DOC_PATH" >/dev/null || fail "status/repair doc missing deleted-project status vocabulary"

review_paths=(
  "$FIXTURE_PATH"
  "$DOC_PATH"
  "$CREATE_DOC_PATH"
  "$REPAIR_DOC_PATH"
  "$ROUTING_DOC_PATH"
  "$RUNBOOK_PATH"
  "$CONFIG_README_PATH"
)

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "$FIXTURE_PATH" "$DOC_PATH" >/dev/null; then
  fail "project-delete contract artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_validation_proven: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|raw_discord_chat_logs_included: true|durable_memory_writes_allowed: true|workspace_file_writes_allowed: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|uses production credentials' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, persistence, or unsafe destructive behavior"
fi

echo "Validated fake Discord Project Manager project delete contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Create doc: $CREATE_DOC_PATH"
echo "Status/repair doc: $REPAIR_DOC_PATH"
echo "Managed routing doc: $ROUTING_DOC_PATH"
echo "Runbook: $RUNBOOK_PATH"
echo "Config README: $CONFIG_README_PATH"
