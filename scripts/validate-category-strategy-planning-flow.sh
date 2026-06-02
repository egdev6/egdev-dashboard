#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${CATEGORY_STRATEGY_PLANNING_FIXTURE:-examples/category-strategy-planning-flow.fake.yaml}"
DOC_PATH="docs/operations/category-strategy-planning-flow.md"
ROADMAP_PATH="docs/operations/discord-context-skill-pilot-roadmap.md"
ROUTING_DOC_PATH="docs/operations/discord-routing.md"
RUNTIME_NAMESPACE_CONTRACT="discord-project-manager/runtime/discord/<guild-id>/<channel-id>"
TARGET_NAMESPACE="discord-project-manager/project/egdev/network/linkedin"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

for path in "$FIXTURE_PATH" "$DOC_PATH" "$ROADMAP_PATH" "$ROUTING_DOC_PATH"; do
  [[ -f "$path" ]] || fail "required file not found: $path"
done

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: category-strategy-planning-flow" \
  "live_discord_connection: false" \
  "live_engram_calls: false" \
  "live_analytics: false" \
  "durable_memory_writes_allowed: false" \
  "runtime_enforcement_proven: false" \
  "runtime_prompt_execution_enabled: false" \
  "uses_real_discord_ids: false" \
  "credential_material_included: false" \
  "raw_transcripts_included: false" \
  "production_credentials: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "runtime_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "name: egdev-linkedin-category-strategy" \
  "approval_phrase: approve write" \
  "classification: confirmation-required" \
  "approval_state: approval-requested" \
  "write_executed: false"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "#57" \
  "#61" \
  "#62" \
  "#70" \
  "#71" \
  "#72" \
  "#73" \
  "#74" \
  "#75" \
  "skills/strategy-planner/SKILL.md" \
  "skills/discord-approval-gate/SKILL.md" \
  "docs/architecture/discord-memory-gateway.md" \
  "docs/architecture/discord-context-skill-packs.md" \
  "docs/architecture/dashboard-read-model-contracts.md" \
  "docs/operations/openclaw-global-brand-context-refresh.md" \
  "docs/operations/content-ledger-utility-flow.md" \
  "docs/operations/discord-approval-responses.md" \
  "docs/security/data-handling.md"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing dependency marker: $required"
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing dependency marker: $required"
done

for required in \
  "category strategy pilot" \
  "approve write" \
  "revise: <instruction>" \
  "reject" \
  "confirmation-required" \
  "runtime-local/audit-only" \
  "strategy_slice" \
  "goals" \
  "assumptions" \
  "planned_items" \
  "review_checkpoints" \
  "out_of_scope" \
  "confirmed facts" \
  "missing context" \
  "global" \
  "category" \
  "channel" \
  "thread-session" \
  "scoped-skill-context" \
  "live analytics" \
  "docs/security/data-handling.md"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

grep -F "| #63 |" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing #63 row"
grep -F "Category strategy pilot" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing #63 pilot marker"
grep -F "docs/operations/category-strategy-planning-flow.md" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing updated #63 first artifact"
grep -F "examples/category-strategy-planning-flow.fake.yaml" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing category strategy fixture"
grep -F "bash scripts/validate-category-strategy-planning-flow.sh" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing category strategy validator"

awk -v runtime="$RUNTIME_NAMESPACE_CONTRACT" -v target="$TARGET_NAMESPACE" '
  function finish() {
    if (scenario == "") {
      return
    }
    if (has_runtime != 1 || has_matched_route != 1 || has_project != 1 || has_network != 1 || has_global_context != 1 || has_ledger_context != 1 || has_read_model_summary != 1 || has_counts_only != 1 || has_facts != 1 || has_assumptions != 1 || has_missing_context != 1 || has_strategy_slice != 1 || has_goal != 1 || has_planned_item != 1 || has_review_checkpoint != 1 || has_out_of_scope != 1 || has_skill_gate != 1 || has_skill_strategy != 1 || has_confirm != 1 || has_approval_requested != 1 || has_approval_phrase != 1 || has_write_executed_false != 1 || has_target_namespace != 1 || has_runtime_audit != 1 || has_revise_runtime_local != 1 || has_reject_runtime_local != 1) {
      printf("scenario %s is missing required category strategy markers\n", scenario) > "/dev/stderr"
      exit 1
    }
    if (runtime_audit == target_namespace) {
      print "runtime audit namespace must be separate from durable target" > "/dev/stderr"
      exit 1
    }
  }

  /^scenario:/ { scenario = "single"; next }
  scenario != "" && /^  route_context:/ { section = "route"; next }
  scenario != "" && /^  pack_refs:/ { section = "packs"; next }
  scenario != "" && /^  input_context_summary:/ { section = "inputs"; next }
  scenario != "" && /^  strategy_proposal:/ { section = "proposal"; next }
  scenario != "" && /^  writeback_proposal:/ { section = "writeback"; next }
  scenario != "" && /^  operator_responses:/ { section = "responses"; next }
  scenario != "" && /^    revise_response:/ { section = "revise"; next }
  scenario != "" && /^    reject_response:/ { section = "reject"; next }

  index($0, "runtime_namespace: " runtime) { has_runtime = 1; next }
  section == "route" && /routing_status: matched-route/ { has_matched_route = 1; next }
  section == "route" && /project_slug: egdev/ { has_project = 1; next }
  section == "route" && /network_slug: linkedin/ { has_network = 1; next }
  section == "packs" && /^      - discord-approval-gate/ { has_skill_gate = 1; next }
  section == "packs" && /^      - strategy-planner/ { has_skill_strategy = 1; next }
  section == "inputs" && /^    approved_global_context:/ { has_global_context = 1; next }
  section == "inputs" && /^    content_ledger_context:/ { has_ledger_context = 1; next }
  section == "inputs" && /^    optional_read_model_summary:/ { has_read_model_summary = 1; next }
  section == "inputs" && /approval_status:/ { has_counts_only = 1; next }
  section == "inputs" && /goals_count:/ { has_counts_only = 1; next }
  section == "inputs" && /record_count:/ { has_counts_only = 1; next }
  section == "inputs" && /^      confirmed_facts:/ { has_facts = 1; next }
  section == "inputs" && /^    assumptions:/ { has_assumptions = 1; next }
  section == "inputs" && /^    missing_context:/ { has_missing_context = 1; next }
  section == "proposal" && /^    strategy_slice:/ { has_strategy_slice = 1; next }
  section == "proposal" && /^      goals:/ && has_strategy_slice == 1 { has_goal = 1; next }
  section == "proposal" && /^      assumptions:/ && has_strategy_slice == 1 { next }
  section == "proposal" && /^      planned_items:/ && has_strategy_slice == 1 { has_planned_item = 1; next }
  section == "proposal" && /^      review_checkpoints:/ && has_strategy_slice == 1 { has_review_checkpoint = 1; next }
  section == "proposal" && /^      out_of_scope:/ && has_strategy_slice == 1 { has_out_of_scope = 1; next }
  section == "writeback" && /classification: confirmation-required/ { has_confirm = 1; next }
  section == "writeback" && /approval_state: approval-requested/ { has_approval_requested = 1; next }
  section == "writeback" && /approval_phrase: approve write/ { has_approval_phrase = 1; next }
  section == "writeback" && /target_namespace: / { target_namespace = $NF; if (target_namespace == target) { has_target_namespace = 1 } next }
  section == "writeback" && /runtime_audit_namespace: / { runtime_audit = $NF; if (runtime_audit == runtime) { has_runtime_audit = 1 } next }
  section == "writeback" && /write_executed: false/ { has_write_executed_false = 1; next }
  section == "revise" && /persistence: runtime-local\/audit-only/ { has_revise_runtime_local = 1; next }
  section == "reject" && /persistence: runtime-local\/audit-only/ { has_reject_runtime_local = 1; next }

  END { finish() }
' "$FIXTURE_PATH" || fail "fixture scenario is inconsistent"

if grep -E 'raw_payload:|raw_transcript:|transcript_payload:|private_payload:' "$FIXTURE_PATH" >/dev/null; then
  fail "fixture read-model summary must not expose raw transcripts or private payloads"
fi

review_paths=("$FIXTURE_PATH" "$DOC_PATH" "$ROADMAP_PATH" "$ROUTING_DOC_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_connection: true|live_engram_calls: true|live_analytics: true|durable_memory_writes_allowed: true|runtime_enforcement_proven: true|runtime_prompt_execution_enabled: true|uses_real_discord_ids: true|credential_material_included: true|raw_transcripts_included: true|production_credentials: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|live Discord validated|live Engram writes enabled|live analytics enabled|durable write executed|raw transcript persisted|publishing completed|scheduling completed|Buffer activity enabled|runtime prompt execution proven|uses production credentials' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, durable, analytics, transcript, credential, production, publishing, scheduling, buffer, or prompt execution behavior"
fi

echo "Validated fake category strategy planning flow contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Roadmap: $ROADMAP_PATH"
echo "Routing doc: $ROUTING_DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
