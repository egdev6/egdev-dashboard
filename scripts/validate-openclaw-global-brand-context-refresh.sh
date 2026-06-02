#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${OPENCLAW_GLOBAL_BRAND_CONTEXT_FIXTURE:-examples/openclaw-global-brand-context-refresh.fake.yaml}"
DOC_PATH="docs/operations/openclaw-global-brand-context-refresh.md"
ROADMAP_PATH="docs/operations/discord-context-skill-pilot-roadmap.md"
ROUTING_DOC_PATH="docs/operations/discord-routing.md"
RUNTIME_NAMESPACE_CONTRACT="discord-project-manager/runtime/discord/<guild-id>/<channel-id>"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

for path in "$FIXTURE_PATH" "$DOC_PATH" "$ROADMAP_PATH" "$ROUTING_DOC_PATH"; do
  [[ -f "$path" ]] || die "required file not found: $path"
done

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: openclaw-global-brand-context-refresh" \
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
  "name: openclaw-global-egdev-linkedin-refresh" \
  "approval_phrase: approve write" \
  "classification: confirmation-required" \
  "write_executed: false"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || die "fixture missing required marker: $required"
done

for required in \
  "#57" \
  "#70" \
  "#71" \
  "#72" \
  "#75" \
  "skills/brand-context/SKILL.md" \
  "skills/discord-approval-gate/SKILL.md" \
  "docs/architecture/discord-memory-gateway.md" \
  "docs/architecture/discord-context-skill-packs.md" \
  "docs/security/data-handling.md"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || die "doc missing dependency marker: $required"
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || die "fixture missing dependency marker: $required"
done

for required in \
  "OpenClaw Global" \
  "approve write" \
  "confirmation-required" \
  "runtime-local/audit-only" \
  "No automatic inheritance" \
  "skills/brand-context/SKILL.md" \
  "docs/security/data-handling.md"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || die "doc missing required marker: $required"
done

grep -F '| #61 | `OpenClaw Global` context refresh pilot | Identity, writing style, boundaries, inheritance, and global context refresh without duplicating the `brand-context` contract. | #70, #71, #72 | `docs/operations/openclaw-global-brand-context-refresh.md` |' "$ROADMAP_PATH" >/dev/null || die "roadmap missing updated #61 first artifact"
grep -F 'examples/openclaw-global-brand-context-refresh.fake.yaml' "$ROUTING_DOC_PATH" >/dev/null || die "routing doc missing OpenClaw Global fixture"
grep -F 'bash scripts/validate-openclaw-global-brand-context-refresh.sh' "$ROUTING_DOC_PATH" >/dev/null || die "routing doc missing OpenClaw Global validator"

for control_area in identity writing-style operating-principles boundaries inheritance; do
  grep -F "$control_area" "$DOC_PATH" >/dev/null || die "doc missing control area: $control_area"
  grep -F "$control_area" "$FIXTURE_PATH" >/dev/null || die "fixture missing control area: $control_area"
done

if grep -E 'brand-context-refresh\.SKILL|skill_name: brand-context-refresh|parallel brand contract' "$FIXTURE_PATH" "$DOC_PATH" >/dev/null; then
  die "artifacts must reuse brand-context instead of inventing a parallel skill contract"
fi

awk -v runtime="$RUNTIME_NAMESPACE_CONTRACT" '
  function finish_scenario() {
    if (scenario == "") {
      return
    }
    if (has_runtime != 1 || has_reserved_category != 1 || has_control_channel != 1 || has_transport_anchor != 1 || has_summary_contract != 1 || has_voice_input != 1 || has_audience_input != 1 || has_positioning_input != 1 || has_constraints_input != 1 || has_boundaries_input != 1 || has_private_boundary != 1 || has_explicit_inheritance != 1 || has_auto_false != 1 || has_target_category != 1 || has_context_pack_route != 1 || has_brand_context_inherited != 1 || has_gate_mandatory != 1 || has_writeback_confirm != 1 || has_approval_phrase != 1 || has_write_executed_false != 1 || has_runtime_local_revised != 1 || has_runtime_local_rejected != 1) {
      printf("scenario %s is missing required global refresh markers\n", scenario) > "/dev/stderr"
      exit 1
    }
  }

  /^  - name:/ {
    finish_scenario()
    scenario = $3
    section = "scenario"
    has_runtime = has_reserved_category = has_control_channel = has_transport_anchor = 0
    has_summary_contract = has_voice_input = has_audience_input = has_positioning_input = has_constraints_input = has_boundaries_input = has_private_boundary = 0
    has_explicit_inheritance = has_auto_false = has_target_category = 0
    has_context_pack_route = has_brand_context_inherited = has_gate_mandatory = 0
    has_writeback_confirm = has_approval_phrase = has_write_executed_false = 0
    has_runtime_local_revised = has_runtime_local_rejected = 0
    context_route_status = pending_brand_context = 0
    next
  }
  scenario != "" && /^    control_origin:/ { section = "control_origin"; next }
  scenario != "" && /^    allowed_inputs:/ { section = "allowed_inputs"; next }
  scenario != "" && /^    private_inputs_forbidden:/ { section = "private_inputs"; next }
  scenario != "" && /^    draft_summary:/ { section = "draft_summary"; next }
  scenario != "" && /^    inheritance_proposal:/ { section = "inheritance"; next }
  scenario != "" && /^    derived_pack_proposal:/ { section = "derived_pack"; next }
  scenario != "" && /^      context_pack:/ { section = "context_pack"; next }
  scenario != "" && /^      skill_pack:/ { section = "skill_pack"; next }
  scenario != "" && /^    writeback_proposal:/ { section = "writeback"; next }
  scenario != "" && /^    revised_response:/ { section = "revised"; next }
  scenario != "" && /^    rejected_response:/ { section = "rejected"; next }

  scenario != "" && index($0, "runtime_namespace: " runtime) { has_runtime = 1; next }
  scenario != "" && /summarization_contract: skills\/brand-context\/SKILL.md/ { has_summary_contract = 1; next }
  section == "control_origin" && /reserved_category: OpenClaw Global/ { has_reserved_category = 1; next }
  section == "control_origin" && /control_channel: inheritance/ { has_control_channel = 1; next }
  section == "control_origin" && /transport_anchor:/ { has_transport_anchor = 1; next }
  section == "allowed_inputs" && /voice_notes:/ { has_voice_input = 1; next }
  section == "allowed_inputs" && /audience_notes:/ { has_audience_input = 1; next }
  section == "allowed_inputs" && /positioning_notes:/ { has_positioning_input = 1; next }
  section == "allowed_inputs" && /approved_constraints:/ { has_constraints_input = 1; next }
  section == "allowed_inputs" && /boundaries:/ { has_boundaries_input = 1; next }
  section == "private_inputs" && /^      - / { has_private_boundary = 1; next }
  section == "inheritance" && /mode: explicit-opt-in/ { has_explicit_inheritance = 1; next }
  section == "inheritance" && /automatic_inheritance: false/ { has_auto_false = 1; next }
  section == "inheritance" && /target_category: egdev-linkedin/ { has_target_category = 1; next }
  section == "context_pack" && /routing_status: matched-route/ { context_route_status = 1; next }
  section == "context_pack" && /network_slug: linkedin/ && context_route_status == 1 { has_context_pack_route = 1; next }
  section == "skill_pack" && /- discord-approval-gate/ { has_gate_mandatory = 1; next }
  section == "skill_pack" && /skill_name: brand-context/ { pending_brand_context = 1; next }
  section == "skill_pack" && /inclusion_reason: global-inherited/ && pending_brand_context == 1 { has_brand_context_inherited = 1; pending_brand_context = 0; next }
  section == "writeback" && /classification: confirmation-required/ { has_writeback_confirm = 1; next }
  section == "writeback" && /approval_phrase: approve write/ { has_approval_phrase = 1; next }
  section == "writeback" && /write_executed: false/ { has_write_executed_false = 1; next }
  section == "revised" && /persistence: runtime-local\/audit-only/ { has_runtime_local_revised = 1; next }
  section == "rejected" && /persistence: runtime-local\/audit-only/ { has_runtime_local_rejected = 1; next }

  END { finish_scenario() }
' "$FIXTURE_PATH" || die "fixture scenarios are inconsistent"

review_paths=("$FIXTURE_PATH" "$DOC_PATH" "$ROADMAP_PATH" "$ROUTING_DOC_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  die "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  die "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_connection: true|live_engram_calls: true|durable_memory_writes_allowed: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|credential_material_included: true|raw_transcripts_included: true|production_credentials: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|live Discord validated|live Engram writes enabled|durable write executed|raw transcript persisted|GitHub mutation executed|uses production credentials|Buffer activity enabled' "${review_paths[@]}" >/dev/null; then
  die "artifacts must not claim live, durable, transcript, credential, production, publishing, or mutation behavior"
fi

echo "Validated fake OpenClaw Global brand context refresh contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Roadmap: $ROADMAP_PATH"
echo "Routing doc: $ROUTING_DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
