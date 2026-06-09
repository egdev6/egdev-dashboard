#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_MANAGED_CHANNEL_ROUTING_FIXTURE:-examples/discord-managed-channel-routing.fake.yaml}"
DOC_PATH="docs/architecture/discord-managed-channel-routing.md"
GLOBAL_INIT_DOC_PATH="docs/architecture/discord-project-manager-global-init.md"
PROJECT_CREATE_DOC_PATH="docs/architecture/discord-project-manager-project-create.md"
GUIDE_DOC_PATH="docs/architecture/discord-semantic-channel-guides.md"
SCOPED_SKILLS_DOC_PATH="docs/architecture/discord-scoped-skills-registry.md"
MEMORY_GATEWAY_DOC_PATH="docs/architecture/discord-memory-gateway.md"
ORCH_DOC_PATH="docs/architecture/discord-runtime-orchestrator.md"
PACK_DOC_PATH="docs/architecture/discord-context-skill-packs.md"
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

for path in "$FIXTURE_PATH" "$DOC_PATH" "$GLOBAL_INIT_DOC_PATH" "$PROJECT_CREATE_DOC_PATH" "$GUIDE_DOC_PATH" "$SCOPED_SKILLS_DOC_PATH" "$MEMORY_GATEWAY_DOC_PATH" "$ORCH_DOC_PATH" "$PACK_DOC_PATH" "$ROUTING_DOC_PATH" "$CONFIG_README_PATH"; do
  [[ -f "$path" ]] || fail "required file not found: $path"
done

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-managed-channel-routing" \
  "issue_ref: 137" \
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
  "backend_not_available_status: BACKEND_NOT_AVAILABLE" \
  "missing_metadata_status: MISSING_METADATA" \
  "name_inference_only_status: NAME_INFERENCE_ONLY" \
  "private_runtime_ids_required: true" \
  "display_name_inference_success_allowed: false" \
  "lookup_source: persisted-semantic-metadata" \
  "name_inference_allowed: false" \
  "unmanaged_channel_hydration_allowed: false" \
  "approval_gate_required_for_write_like: true" \
  "approval_gate_skill: discord-approval-gate" \
  "managed_channel_registry:" \
  "routing_scenarios:" \
  "audit_outputs:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "docs/architecture/discord-project-manager-global-init.md" \
  "docs/architecture/discord-project-manager-project-create.md" \
  "examples/discord-semantic-channel-guides.fake.yaml" \
  "docs/architecture/discord-scoped-skills-registry.md" \
  "docs/architecture/discord-memory-gateway.md"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing dependency marker: $required"
done

for scenario in \
  "route-global-context-summary" \
  "route-global-skills-update" \
  "route-project-context-summary" \
  "route-project-skills-review" \
  "route-project-strategy-generate" \
  "reject-unsupported-operation" \
  "reject-unmanaged-channel"; do
  grep -F "scenario_ref: $scenario" "$FIXTURE_PATH" >/dev/null || fail "fixture missing routing scenario: $scenario"
done

for route in \
  "global-context-route" \
  "global-skills-route" \
  "project-context-route" \
  "project-skills-route" \
  "project-strategy-route" \
  "unsupported-operation" \
  "unmanaged-channel"; do
  grep -F "route_result: $route" "$FIXTURE_PATH" >/dev/null || fail "fixture missing route result: $route"
done

for required in \
  "state_target: workspace-global-context" \
  "state_target: workspace-global-skills" \
  "state_target: project:web-app:context" \
  "state_target: project:web-app:skills" \
  "state_target: project:web-app:strategy" \
  "idempotency_key: project-manager-global:<guild-id>" \
  "idempotency_key: project:<guild-id>:web-app" \
  "created_by_interaction: /project-manager init" \
  "created_by_interaction: /project create" \
  "updated_by_interaction: /project-manager init" \
  "updated_by_interaction: /project create" \
  "scoped_skills_ref: registry.global" \
  "scoped_skills_ref: registry.project.web-app" \
  "mandatory_skill: discord-approval-gate" \
  "approval_phrase: approve write" \
  "write_executed: false" \
  "retained_raw_message: false" \
  "safe_fake_refs_only: true"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing routing behavior marker: $required"
done

awk '
  function finish_registry_channel() {
    if (!in_reg_channel) {
      return
    }
    if (channel_ref == "" || category_ref == "" || scope == "" || field_key == "" || guide_ref == "" || state_target == "") {
      print "managed registry channel missing required metadata for " channel_ref > "/dev/stderr"
      exit 1
    }
    if (scope == "global") {
      if (project_ref != "none") {
        print "global managed channel must not bind project_ref for " channel_ref > "/dev/stderr"
        exit 1
      }
      global_fields[field_key] = 1
    } else if (scope == "project") {
      if (project_ref != "project-demo-web-app" || project_slug != "web-app") {
        print "project managed channel must bind project ref and slug for " channel_ref > "/dev/stderr"
        exit 1
      }
      project_fields[field_key] = 1
    } else {
      print "unsupported managed channel scope " scope > "/dev/stderr"
      exit 1
    }
    if (op_count < 2) {
      print "managed channel must list at least two allowed operations for " channel_ref > "/dev/stderr"
      exit 1
    }
    registry_count++
    in_reg_channel = 0
  }

  /^routing_scenarios:$/ { finish_registry_channel(); section = "scenarios"; next }
  /^managed_channel_registry:$/ { section = "registry"; next }
  section == "registry" && /^    - channel_ref:/ {
    finish_registry_channel()
    in_reg_channel = 1
    channel_ref = $3
    category_ref = ""
    scope = ""
    project_ref = ""
    project_slug = ""
    field_key = ""
    guide_ref = ""
    state_target = ""
    op_count = 0
    in_ops = 0
    next
  }
  in_reg_channel && /^      category_ref:/ { category_ref = $2; next }
  in_reg_channel && /^      scope:/ { scope = $2; next }
  in_reg_channel && /^      project_ref:/ { project_ref = $2; next }
  in_reg_channel && /^      project_slug:/ { project_slug = $2; next }
  in_reg_channel && /^      field_key:/ { field_key = $2; next }
  in_reg_channel && /^      guide_ref:/ { guide_ref = $2; next }
  in_reg_channel && /^      state_target:/ { state_target = $2; next }
  in_reg_channel && /^      allowed_prompt_operations:$/ { in_ops = 1; next }
  in_reg_channel && in_ops && /^        - / { op_count++; next }
  END {
    finish_registry_channel()
    if (registry_count != 5) {
      print "expected 5 managed registry channels, found " registry_count > "/dev/stderr"
      exit 1
    }
    if (!("context" in global_fields) || !("skills" in global_fields)) {
      print "registry must include global context and global skills channels" > "/dev/stderr"
      exit 1
    }
    if (!("context" in project_fields) || !("skills" in project_fields) || !("strategy" in project_fields)) {
      print "registry must include project context, project skills, and project strategy channels" > "/dev/stderr"
      exit 1
    }
  }
' "$FIXTURE_PATH" || fail "managed channel registry is inconsistent with routing contract"

awk '
  function has_target(targets, target) {
    return index(targets, " " target " ") > 0
  }

  function finish_scenario() {
    if (!in_scenario) {
      return
    }
    scenario_audits[scenario_ref] = audit_ref
    if (scenario_ref == "route-global-context-summary") {
      if (route_result != "global-context-route" || scope != "global" || field != "context" || project != "none" || read_count != 1 || !has_target(read_targets, "workspace-global-context") || write_count != 0 || write_allowed != "false") {
        print "global context scenario routes outside global context boundary" > "/dev/stderr"
        exit 1
      }
      saw_global_context = 1
    } else if (scenario_ref == "route-global-skills-update") {
      if (route_result != "global-skills-route" || scope != "global" || field != "skills" || read_count != 2 || !has_target(read_targets, "workspace-global-skills") || !has_target(read_targets, "scoped-skills-registry-global") || write_count != 0 || proposed_write_target != "docs/architecture/discord-scoped-skills-registry.md" || approval_state != "approval-requested" || approval_skill != "discord-approval-gate" || approval_phrase != "approve write" || write_executed != "false") {
        print "global skills scenario must require exact approval gate before write and propose only the scoped skills registry target" > "/dev/stderr"
        exit 1
      }
      saw_global_skills = 1
    } else if (scenario_ref == "route-project-context-summary") {
      if (route_result != "project-context-route" || scope != "project" || field != "context" || project != "project-demo-web-app" || project_slug != "web-app" || read_count != 1 || !has_target(read_targets, "project:web-app:context") || write_count != 0 || write_allowed != "false") {
        print "project context scenario routes outside matching project boundary" > "/dev/stderr"
        exit 1
      }
      saw_project_context = 1
    } else if (scenario_ref == "route-project-skills-review") {
      if (route_result != "project-skills-route" || scope != "project" || field != "skills" || project != "project-demo-web-app" || read_count != 2 || !has_target(read_targets, "project:web-app:skills") || !has_target(read_targets, "scoped-skills-registry-project:web-app") || write_count != 0 || !effective_gate || write_allowed != "false") {
        print "project skills scenario must route to matching project skills with approval gate skill available" > "/dev/stderr"
        exit 1
      }
      saw_project_skills = 1
    } else if (scenario_ref == "route-project-strategy-generate") {
      if (route_result != "project-strategy-route" || scope != "project" || field != "strategy" || project != "project-demo-web-app" || read_count != 1 || !has_target(read_targets, "project:web-app:strategy") || write_count != 0 || write_allowed != "false") {
        print "project strategy scenario routes outside matching project strategy" > "/dev/stderr"
        exit 1
      }
      saw_project_strategy = 1
    } else if (scenario_ref == "reject-unsupported-operation") {
      if (route_result != "unsupported-operation" || requested_operation != "publish" || write_allowed != "false" || write_executed != "false" || read_count != 0 || write_count != 0 || safe_response !~ /Scope: project/ || safe_response !~ /Field: context/ || safe_response !~ /Allowed operations: ask, summarize, propose_update/ || safe_response !~ /No state was changed/) {
        print "unsupported operation scenario must explain scope, field, allowed operations, and reject safely without writes" > "/dev/stderr"
        exit 1
      }
      saw_unsupported = 1
    } else if (scenario_ref == "reject-unmanaged-channel") {
      if (route_status != "unmanaged-channel" || route_result != "unmanaged-channel" || scope != "none" || field != "none" || project != "none" || read_count != 0 || write_count != 0 || write_allowed != "false" || write_executed != "false" || safe_response == "") {
        print "unmanaged channel scenario must stay fallback-only without state access" > "/dev/stderr"
        exit 1
      }
      saw_unmanaged = 1
    }
    if (audit_ref == "") {
      print "scenario missing audit_ref: " scenario_ref > "/dev/stderr"
      exit 1
    }
    in_scenario = 0
  }

  /^audit_outputs:$/ { finish_scenario(); section = "audit"; next }
  /^routing_scenarios:$/ { section = "scenarios"; next }
  section == "scenarios" && /^  - scenario_ref:/ {
    finish_scenario()
    in_scenario = 1
    scenario_ref = $3
    route_status = ""
    route_result = ""
    requested_operation = ""
    scope = ""
    field = ""
    project = ""
    project_slug = ""
    read_targets = " "
    write_targets = " "
    read_count = 0
    write_count = 0
    write_allowed = ""
    proposed_write_target = ""
    approval_state = ""
    approval_skill = ""
    approval_phrase = ""
    write_executed = ""
    safe_response = ""
    audit_ref = ""
    effective_gate = 0
    in_state_read = 0
    in_state_write = 0
    in_effective_skills = 0
    next
  }
  in_scenario && /^    requested_operation:/ { requested_operation = $2; next }
  in_scenario && /^    route_status:/ { route_status = $2; next }
  in_scenario && /^    route_result:/ { route_result = $2; next }
  in_scenario && /^    resolved_scope:/ { scope = $2; next }
  in_scenario && /^    resolved_field_key:/ { field = $2; next }
  in_scenario && /^    resolved_project_ref:/ { project = $2; next }
  in_scenario && /^    resolved_project_slug:/ { project_slug = $2; next }
  in_scenario && /^    durable_write_allowed_before_approval:/ { write_allowed = $2; in_state_read = 0; in_state_write = 0; in_effective_skills = 0; next }
  in_scenario && /^    proposed_write_target:/ { proposed_write_target = $2; in_state_read = 0; in_state_write = 0; in_effective_skills = 0; next }
  in_scenario && /^    write_executed:/ { write_executed = $2; next }
  in_scenario && /^    safe_response:/ { safe_response = substr($0, index($0, ":") + 2); next }
  in_scenario && /^    audit_ref:/ { audit_ref = $2; next }
  in_scenario && /^    state_targets_read: \[\]$/ { in_state_read = 0; in_state_write = 0; next }
  in_scenario && /^    state_targets_read:$/ { in_state_read = 1; in_state_write = 0; in_effective_skills = 0; next }
  in_scenario && in_state_read && /^      - / { read_count++; read_targets = read_targets $2 " "; next }
  in_scenario && /^    state_targets_write: \[\]$/ { in_state_write = 0; in_state_read = 0; next }
  in_scenario && /^    state_targets_write:$/ { in_state_write = 1; in_state_read = 0; in_effective_skills = 0; next }
  in_scenario && in_state_write && /^      - / { write_count++; write_targets = write_targets $2 " "; next }
  in_scenario && /^    approval:$/ { in_state_read = 0; in_state_write = 0; in_effective_skills = 0; next }
  in_scenario && /^      state:/ { approval_state = $2; next }
  in_scenario && /^      mandatory_skill:/ { approval_skill = $2; next }
  in_scenario && /^      approval_phrase:/ { approval_phrase = substr($0, index($0, ":") + 2); next }
  in_scenario && /^      write_executed:/ { write_executed = $2; next }
  in_scenario && /^    effective_skills:$/ { in_effective_skills = 1; in_state_read = 0; in_state_write = 0; next }
  in_scenario && in_effective_skills && /^      - discord-approval-gate/ { effective_gate = 1; next }
  END {
    finish_scenario()
    if (!saw_global_context || !saw_global_skills || !saw_project_context || !saw_project_skills || !saw_project_strategy || !saw_unsupported || !saw_unmanaged) {
      print "routing scenarios must cover required global/project/unsupported cases" > "/dev/stderr"
      exit 1
    }
  }
' "$FIXTURE_PATH" || fail "routing scenarios are inconsistent with managed channel routing contract"
awk '
  /^routing_scenarios:$/ { section = "scenarios"; next }
  /^audit_outputs:$/ { section = "audit"; next }
  /^non_goals:$/ { section = "none"; next }
  section == "scenarios" && /^  - scenario_ref:/ { scenario_count++; current_scenario = $3; next }
  section == "scenarios" && /^    audit_ref:/ { scenario_audit[current_scenario] = $2; required_audits[$2] = 1; next }
  section == "audit" && /^  - audit_ref:/ { audit_count++; current_audit = $3; audits[current_audit] = 1; next }
  section == "audit" && /^    runtime_namespace:/ { audit_runtime[current_audit] = $2; next }
  section == "audit" && /^    retained_raw_message:/ { audit_raw[current_audit] = $2; next }
  section == "audit" && /^    safe_fake_refs_only:/ { audit_safe[current_audit] = $2; next }
  END {
    if (scenario_count != 7) {
      print "expected audit references for all seven routing scenarios" > "/dev/stderr"
      exit 1
    }
    if (audit_count != scenario_count) {
      print "expected one audit output per routing scenario" > "/dev/stderr"
      exit 1
    }
    for (audit in required_audits) {
      if (!(audit in audits)) {
        print "missing audit output for scenario audit_ref " audit > "/dev/stderr"
        exit 1
      }
    }
    for (audit in audits) {
      if (audit_runtime[audit] != "discord-project-manager/runtime/discord/<guild-id>/<channel-id>" || audit_raw[audit] != "false" || audit_safe[audit] != "true") {
        print "audit output must use runtime namespace, no raw messages, and safe fake refs for " audit > "/dev/stderr"
        exit 1
      }
    }
  }
' "$FIXTURE_PATH" || fail "audit outputs are inconsistent with managed routing safety contract"
for required in \
  "# Discord managed channel routing" \
  "persisted semantic metadata" \
  "global-context-route" \
  "global-skills-route" \
  "project-context-route" \
  "project-skills-route" \
  "project-strategy-route" \
  "unsupported-operation" \
  "unmanaged-channel" \
  "discord-scoped-skills-registry.md" \
  "discord-approval-gate" \
  "does not prove live Discord"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

for required in \
  "docs/architecture/discord-managed-channel-routing.md" \
  "examples/discord-managed-channel-routing.fake.yaml" \
  "scripts/validate-discord-managed-channel-routing.sh"; do
  grep -F "$required" "$ORCH_DOC_PATH" >/dev/null || fail "orchestrator doc missing managed routing reference: $required"
  grep -F "$required" "$PACK_DOC_PATH" >/dev/null || fail "pack doc missing managed routing reference: $required"
  grep -F "$required" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing managed routing reference: $required"
  grep -F "$required" "$CONFIG_README_PATH" >/dev/null || fail "config README missing managed routing reference: $required"
done

grep -F "docs/architecture/discord-managed-channel-routing.md" "$GLOBAL_INIT_DOC_PATH" >/dev/null || fail "global init doc missing managed routing reference"
grep -F "docs/architecture/discord-managed-channel-routing.md" "$PROJECT_CREATE_DOC_PATH" >/dev/null || fail "project create doc missing managed routing reference"

review_paths=(
  "$FIXTURE_PATH"
  "$DOC_PATH"
  "$GLOBAL_INIT_DOC_PATH"
  "$PROJECT_CREATE_DOC_PATH"
  "$GUIDE_DOC_PATH"
  "$SCOPED_SKILLS_DOC_PATH"
  "$MEMORY_GATEWAY_DOC_PATH"
  "$ORCH_DOC_PATH"
  "$PACK_DOC_PATH"
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
  fail "artifacts must not claim live, production, persistence, publishing, scheduling, prompt execution, or public Discord behavior"
fi

echo "Validated fake Discord managed channel routing contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
