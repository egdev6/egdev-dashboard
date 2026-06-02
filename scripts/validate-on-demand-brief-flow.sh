#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${ON_DEMAND_BRIEF_FLOW_FIXTURE:-examples/on-demand-brief-flow.fake.yaml}"
DOC_PATH="docs/operations/on-demand-brief-flow.md"
ROADMAP_PATH="docs/operations/discord-context-skill-pilot-roadmap.md"
ROUTING_DOC_PATH="docs/operations/discord-routing.md"
RUNTIME_NAMESPACE_CONTRACT="discord-project-manager/runtime/discord/<guild-id>/<channel-id>"
STRATEGY_NAMESPACE="discord-project-manager/project/egdev/strategy"
LEDGER_NAMESPACE="discord-project-manager/project/egdev/content-ledger"

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
  "contract: on-demand-brief-flow" \
  "live_source_fetching: false" \
  "live_discord_connection: false" \
  "live_openclaw_execution: false" \
  "live_engram_calls: false" \
  "live_analytics: false" \
  "durable_memory_writes_allowed: false" \
  "runtime_enforcement_proven: false" \
  "runtime_prompt_execution_enabled: false" \
  "github_mutations_enabled: false" \
  "uses_real_discord_ids: false" \
  "credential_material_included: false" \
  "raw_transcripts_included: false" \
  "raw_source_dumps_included: false" \
  "production_credentials: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "queue_execution_enabled: false" \
  "buffer_activity_enabled: false" \
  "public_channel_behavior_enabled: false" \
  "runtime_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "name: egdev-stack-and-flow-on-demand-briefs" \
  "classification: confirmation-required" \
  "approval_state: approval-requested" \
  "approval_phrase: approve write" \
  "write_executed: false"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "#57" \
  "#61" \
  "#62" \
  "#63" \
  "#64" \
  "#70" \
  "#71" \
  "#72" \
  "#73" \
  "#74" \
  "#75" \
  "skills/on-demand-brief-planner/SKILL.md" \
  "skills/discord-approval-gate/SKILL.md" \
  "docs/architecture/discord-context-skill-packs.md" \
  "docs/architecture/discord-memory-gateway.md" \
  "docs/architecture/discord-runtime-orchestrator.md" \
  "docs/architecture/discord-gentle-sdd-handoff.md" \
  "docs/operations/openclaw-global-brand-context-refresh.md" \
  "docs/operations/category-strategy-planning-flow.md" \
  "docs/operations/content-ledger-utility-flow.md" \
  "docs/operations/discord-approval-responses.md" \
  "docs/security/data-handling.md"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing dependency marker: $required"
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing dependency marker: $required"
done

for required in \
  "matched route" \
  "Context Pack" \
  "Skill Pack" \
  "intent classification" \
  "runtime_namespace" \
  "routing_status" \
  "resolved_route" \
  "effective_skills" \
  "mandatory_skills" \
  "confirmed_facts" \
  "assumptions" \
  "missing_context" \
  "format_rules" \
  "proposed_angles" \
  "approve write" \
  "revise: <instruction>" \
  "reject" \
  "runtime-local/audit-only" \
  "draft" \
  "queued" \
  "published" \
  "archived"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required marker: $required"
done

grep -F "| #65 |" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing #65 row"
grep -F "Multi-network brief pilot" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing #65 pilot marker"
grep -F "docs/operations/on-demand-brief-flow.md" "$ROADMAP_PATH" >/dev/null || fail "roadmap missing updated #65 first artifact"
grep -F "examples/on-demand-brief-flow.fake.yaml" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing on-demand brief fixture"
grep -F "bash scripts/validate-on-demand-brief-flow.sh" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing on-demand brief validator"

awk -v runtime="$RUNTIME_NAMESPACE_CONTRACT" -v strategy="$STRATEGY_NAMESPACE" -v ledger="$LEDGER_NAMESPACE" '
  function finish() {
    if (scenario == "") {
      return
    }
    if (has_runtime != 1 || has_matched_route != 1 || has_project != 1 || has_network != 1 || has_scope_summary != 1 || has_skill_gate != 1 || has_skill_brief != 1 || has_mandatory_gate != 1 || has_intent != 1 || has_global_context != 1 || has_strategy_summary != 1 || has_ledger_summary != 1 || has_category_context != 1 || has_no_dumps != 1 || has_source_context != 1 || has_brief_request != 1 || has_confirmed_facts != 1 || has_assumptions != 1 || has_missing_context != 1 || has_format_rules != 1 || has_proposed_angles != 1 || has_two_briefs != 1 || has_approval != 1 || has_memory_targets != 1 || has_strategy_target != 1 || has_ledger_target != 1 || has_confirm != 1 || has_approval_requested != 1 || has_approval_phrase != 1 || has_write_executed_false != 1 || has_runtime_audit != 1 || has_revise_runtime_local != 1 || has_reject_runtime_local != 1) {
      printf("scenario %s is missing required on-demand brief markers\n", scenario) > "/dev/stderr"
      exit 1
    }
    if (runtime_audit == strategy || runtime_audit == ledger) {
      print "runtime audit namespace must be separate from durable targets" > "/dev/stderr"
      exit 1
    }
  }

  /^scenario:/ { scenario = "single"; next }
  scenario != "" && /^  route_context:/ { section = "route"; next }
  scenario != "" && /^  pack_refs:/ { section = "packs"; next }
  scenario != "" && /^  input_context_summary:/ { section = "inputs"; next }
  scenario != "" && /^  brief_candidate:/ { section = "candidate"; next }
  scenario != "" && /^  writeback_proposal:/ { section = "writeback"; next }
  scenario != "" && /^  operator_responses:/ { section = "responses"; next }
  scenario != "" && /^    revise_response:/ { section = "revise"; next }
  scenario != "" && /^    reject_response:/ { section = "reject"; next }

  index($0, "runtime_namespace: " runtime) { has_runtime = 1; next }
  section == "route" && /routing_status: matched-route/ { has_matched_route = 1; next }
  section == "route" && /project_slug: egdev/ { has_project = 1; next }
  section == "route" && /network_slug: stack-and-flow/ { has_network = 1; next }
  section == "packs" && /^    scope_summary:/ { pack_mode = "scope"; next }
  section == "packs" && /^    effective_skills:/ { pack_mode = "effective"; next }
  section == "packs" && /^    mandatory_skills:/ { pack_mode = "mandatory"; next }
  section == "packs" && /^    intent_classification:/ { pack_mode = "intent"; next }
  section == "packs" && pack_mode == "scope" && /^      - global/ { scope_global = 1; next }
  section == "packs" && pack_mode == "scope" && /^      - category/ { scope_category = 1; next }
  section == "packs" && pack_mode == "scope" && /^      - channel/ { scope_channel = 1; next }
  section == "packs" && pack_mode == "scope" && /^      - thread-session/ { scope_thread = 1; next }
  section == "packs" && pack_mode == "scope" && /^      - scoped-skill-context/ { scope_skill = 1; if (scope_global && scope_category && scope_channel && scope_thread) { has_scope_summary = 1 } next }
  section == "packs" && pack_mode == "effective" && /^      - discord-approval-gate/ { has_skill_gate = 1; next }
  section == "packs" && pack_mode == "effective" && /^      - on-demand-brief-planner/ { has_skill_brief = 1; next }
  section == "packs" && pack_mode == "mandatory" && /^      - discord-approval-gate$/ { has_mandatory_gate = 1; next }
  section == "packs" && pack_mode == "intent" && /family: planning_content/ { has_intent = 1; next }
  section == "inputs" && /^    approved_global_context:/ { has_global_context = 1; next }
  section == "inputs" && /^    approved_strategy_summary:/ { has_strategy_summary = 1; next }
  section == "inputs" && /^    approved_content_ledger_summary:/ { has_ledger_summary = 1; next }
  section == "inputs" && /^    category_context:/ { has_category_context = 1; next }
  section == "inputs" && /no_source_dumps: true/ { has_no_dumps = 1; next }
  section == "candidate" && /^    source_context:/ { has_source_context = 1; next }
  section == "candidate" && /^    brief_request:/ { has_brief_request = 1; next }
  section == "candidate" && /^      confirmed_facts:/ { has_confirmed_facts = 1; next }
  section == "candidate" && /^      assumptions:/ { has_assumptions = 1; next }
  section == "candidate" && /^      missing_context:/ { has_missing_context = 1; next }
  section == "candidate" && /^      format_rules:/ { has_format_rules = 1; next }
  section == "candidate" && /^      proposed_angles:/ { has_proposed_angles = 1; next }
  section == "candidate" && /^      - network: youtube/ { brief_one = 1; if (brief_two) { has_two_briefs = 1 } next }
  section == "candidate" && /^      - network: stack-and-flow/ { brief_two = 1; if (brief_one) { has_two_briefs = 1 } next }
  section == "candidate" && /^    approval:/ { has_approval = 1; next }
  section == "candidate" && /^    memory_write_targets:/ { has_memory_targets = 1; next }
  section == "candidate" && /project_strategy_namespace_key: / { if ($NF == strategy) { has_strategy_target = 1 } next }
  section == "candidate" && /content_ledger_namespace_key: / { if ($NF == ledger) { has_ledger_target = 1 } next }
  section == "candidate" && /intended_status: draft/ { has_draft_state = 1; next }
  section == "writeback" && /classification: confirmation-required/ { has_confirm = 1; next }
  section == "writeback" && /approval_state: approval-requested/ { has_approval_requested = 1; next }
  section == "writeback" && /approval_phrase: approve write/ { has_approval_phrase = 1; next }
  section == "writeback" && /runtime_audit_namespace: / { runtime_audit = $NF; if (runtime_audit == runtime) { has_runtime_audit = 1 } next }
  section == "writeback" && /write_executed: false/ { has_write_executed_false = 1; next }
  section == "revise" && /persistence: runtime-local\/audit-only/ { has_revise_runtime_local = 1; next }
  section == "reject" && /persistence: runtime-local\/audit-only/ { has_reject_runtime_local = 1; next }

  END { finish() }
' "$FIXTURE_PATH" || fail "fixture scenario is inconsistent"

for state in draft queued published archived; do
  grep -F "$state" "$DOC_PATH" >/dev/null || fail "doc missing allowed ledger state: $state"
done

if awk '
  /intended_status:/ && $NF !~ /^(draft|queued|published|archived)$/ { bad = 1 }
  END { exit bad ? 0 : 1 }
' "$FIXTURE_PATH"; then
  fail "fixture ledger candidates must use only draft, queued, published, or archived"
fi

if grep -E 'raw_payload:|raw_transcript:|transcript_payload:|private_payload:|source_dump:' "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not expose raw transcripts, source dumps, or private payloads"
fi

review_paths=("$FIXTURE_PATH" "$DOC_PATH" "$ROADMAP_PATH" "$ROUTING_DOC_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_source_fetching: true|live_discord_connection: true|live_openclaw_execution: true|runtime_prompt_execution_enabled: true|github_mutations_enabled: true|live_engram_calls: true|live_analytics: true|durable_memory_writes_allowed: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|credential_material_included: true|raw_transcripts_included: true|raw_source_dumps_included: true|production_credentials: true|publishing_enabled: true|scheduling_enabled: true|queue_execution_enabled: true|buffer_activity_enabled: true|public_channel_behavior_enabled: true|live source fetching enabled|live Discord validated|live OpenClaw execution proven|live Engram writes enabled|live analytics enabled|durable write executed|raw transcript persisted|raw source dump persisted|publishing completed|scheduling completed|queue execution completed|Buffer activity enabled|runtime prompt execution proven|GitHub mutation executed|uses production credentials|public channel validation passed' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, durable, analytics, transcript, source-dump, credential, production, publishing, scheduling, queue, buffer, prompt, GitHub mutation, or public-channel behavior"
fi

echo "Validated fake on-demand brief flow contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Roadmap: $ROADMAP_PATH"
echo "Routing doc: $ROUTING_DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
