#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${CONTENT_LEDGER_UTILITY_FIXTURE:-examples/content-ledger-utility-flow.fake.yaml}"
DOC_PATH="docs/operations/content-ledger-utility-flow.md"
ROADMAP_PATH="docs/operations/discord-context-skill-pilot-roadmap.md"
ROUTING_DOC_PATH="docs/operations/discord-routing.md"
RUNTIME_NAMESPACE_CONTRACT="discord-project-manager/runtime/discord/<guild-id>/<channel-id>"
DURABLE_NAMESPACE="discord-project-manager/project/egdev/content-ledger"
NETWORK_OVERLAY_NAMESPACE="discord-project-manager/project/egdev/network/linkedin"

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
  "contract: content-ledger-utility-flow" \
  "live_discord_connection: false" \
  "live_engram_calls: false" \
  "durable_memory_writes_allowed: false" \
  "runtime_enforcement_proven: false" \
  "uses_real_discord_ids: false" \
  "credential_material_included: false" \
  "raw_transcripts_included: false" \
  "production_credentials: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "runtime_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "name: egdev-linkedin-ledger-candidate" \
  "approval_phrase: approve write" \
  "classification: confirmation-required" \
  "write_executed: false"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "#57" \
  "#70" \
  "#71" \
  "#72" \
  "#73" \
  "#74" \
  "#75" \
  "skills/content-ledger/SKILL.md" \
  "skills/discord-approval-gate/SKILL.md" \
  "docs/architecture/discord-memory-gateway.md" \
  "docs/architecture/discord-context-skill-packs.md" \
  "docs/operations/discord-approval-responses.md" \
  "docs/security/data-handling.md"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing dependency marker: $required"
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing dependency marker: $required"
done

for required in \
  "category/channel utility skill" \
  "approve write" \
  "revise: <instruction>" \
  "reject" \
  "confirmation-required" \
  "runtime-local/audit-only" \
  "draft" \
  "queued" \
  "published" \
  "archived" \
  "docs/security/data-handling.md"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

grep -F "| #62 |" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing #62 row"
grep -F "Ledger utility pilot" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing ledger utility marker"
grep -F "docs/operations/content-ledger-utility-flow.md" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing updated #62 first artifact"
grep -F "examples/content-ledger-utility-flow.fake.yaml" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing ledger utility fixture"
grep -F "bash scripts/validate-content-ledger-utility-flow.sh" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing ledger utility validator"

awk -v runtime="$RUNTIME_NAMESPACE_CONTRACT" -v durable="$DURABLE_NAMESPACE" -v overlay="$NETWORK_OVERLAY_NAMESPACE" '
  function finish() {
    if (scenario == "") {
      return
    }
    if (has_runtime != 1 || has_matched_route != 1 || has_project != 1 || has_network != 1 || has_content_id != 1 || has_status != 1 || has_published_at != 1 || has_assets != 1 || has_source_link != 1 || has_follow_up != 1 || has_summary != 1 || has_no_op_boundaries != 1 || has_durable_target != 1 || has_overlay_target != 1 || has_runtime_audit != 1 || has_duplicate_result != 1 || has_operator_escalation != 1 || has_confirm != 1 || has_approval_phrase != 1 || has_write_executed_false != 1 || has_planned_only != 1 || has_runtime_local_revised != 1 || has_runtime_local_rejected != 1 || has_skill_gate != 1 || has_skill_ledger != 1) {
      printf("scenario %s is missing required ledger utility markers\n", scenario) > "/dev/stderr"
      exit 1
    }
    if (runtime_audit == durable_target || runtime_audit == overlay_target) {
      print "runtime audit namespace must be separate from durable targets" > "/dev/stderr"
      exit 1
    }
  }

  /^scenario:/ { scenario = "single"; has_no_op_boundaries = has_planned_only = 0; next }
  scenario != "" && /^  route_context:/ { section = "route"; next }
  scenario != "" && /^  pack_refs:/ { section = "packs"; next }
  scenario != "" && /^  ledger_candidate:/ { section = "candidate"; next }
  scenario != "" && /^  ledger_state_notes:/ { section = "state_notes"; next }
  scenario != "" && /^  duplicate_conflict_review:/ { section = "duplicate"; next }
  scenario != "" && /^  writeback_proposal:/ { section = "writeback"; next }
  scenario != "" && /^  operator_responses:/ { section = "responses"; next }
  scenario != "" && /^    revise_response:/ { section = "revise"; next }
  scenario != "" && /^    reject_response:/ { section = "reject"; next }

  index($0, "runtime_namespace: " runtime) { has_runtime = 1; next }
  section == "route" && /routing_status: matched-route/ { has_matched_route = 1; next }
  section == "packs" && /^      - discord-approval-gate/ { has_skill_gate = 1; next }
  section == "packs" && /^      - content-ledger/ { has_skill_ledger = 1; next }
  section == "candidate" && /project: egdev/ { has_project = 1; next }
  section == "candidate" && /network: linkedin/ { has_network = 1; next }
  section == "candidate" && /id: linkedin-post-001-demo/ { has_content_id = 1; next }
  section == "candidate" && /status: draft/ { has_status = 1; next }
  section == "candidate" && /published_at: unknown/ { has_published_at = 1; next }
  section == "candidate" && /^      assets:/ { has_assets = 1; next }
  section == "candidate" && /source_link: none/ { has_source_link = 1; next }
  section == "candidate" && /^    follow_up:/ { has_follow_up = 1; next }
  section == "candidate" && /proposal_summary:/ { has_summary = 1; next }
  section == "candidate" && /durable: / { durable_target = $NF; if (durable_target == durable) { has_durable_target = 1 } next }
  section == "candidate" && /approved_overlay: / { overlay_target = $NF; if (overlay_target == overlay) { has_overlay_target = 1 } next }
  section == "candidate" && /runtime_audit: / { runtime_audit = $NF; if (runtime_audit == runtime) { has_runtime_audit = 1 } next }
  section == "candidate" && /^    no_op_boundaries:/ { has_no_op_boundaries = 1; next }
  section == "duplicate" && /result: operator-escalation-required/ { has_duplicate_result = 1; next }
  section == "duplicate" && /operator_question:/ { has_operator_escalation = 1; next }
  section == "writeback" && /classification: confirmation-required/ { has_confirm = 1; next }
  section == "writeback" && /approval_phrase: approve write/ { has_approval_phrase = 1; next }
  section == "writeback" && /write_executed: false/ { has_write_executed_false = 1; next }
  section == "writeback" && /durable_write_target_planned_only: true/ { has_planned_only = 1; next }
  section == "revise" && /persistence: runtime-local\/audit-only/ { has_runtime_local_revised = 1; next }
  section == "reject" && /persistence: runtime-local\/audit-only/ { has_runtime_local_rejected = 1; next }

  END { finish() }
' "$FIXTURE_PATH" || fail "fixture scenario is inconsistent"

for state in draft queued published archived; do
  grep -F -- "- $state" "$FIXTURE_PATH" >/dev/null || fail "fixture missing valid ledger state: $state"
done

if awk '
  /^valid_ledger_states:/ { in_states = 1; next }
  in_states && /^approval_gate_responses:/ { in_states = 0 }
  in_states && /^  - (approved|scheduled|rejected)$/ { print; found = 1 }
  END { exit found ? 0 : 1 }
' "$FIXTURE_PATH"; then
  fail "fixture must not use approved, scheduled, or rejected as durable ledger states"
fi

review_paths=("$FIXTURE_PATH" "$DOC_PATH" "$ROADMAP_PATH" "$ROUTING_DOC_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_connection: true|live_engram_calls: true|durable_memory_writes_allowed: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|credential_material_included: true|raw_transcripts_included: true|production_credentials: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|live Discord validated|live Engram writes enabled|durable write executed|raw transcript persisted|publishing completed|scheduling completed|Buffer activity enabled|uses production credentials' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, durable, transcript, credential, production, publishing, scheduling, or buffer behavior"
fi

echo "Validated fake content-ledger utility flow contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Roadmap: $ROADMAP_PATH"
echo "Routing doc: $ROUTING_DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
