#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_RUNTIME_ORCHESTRATOR_FIXTURE:-examples/discord-runtime-orchestrator.fake.yaml}"
DOC_PATH="docs/architecture/discord-runtime-orchestrator.md"
PARENT_DOC_PATH="docs/architecture/discord-dynamic-context-namespaces.md"
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

require_cmd grep
require_cmd awk

[[ -f "$FIXTURE_PATH" ]] || fail "fixture not found: $FIXTURE_PATH"
[[ -f "$DOC_PATH" ]] || fail "doc not found: $DOC_PATH"
[[ -f "$PARENT_DOC_PATH" ]] || fail "parent doc not found: $PARENT_DOC_PATH"
[[ -f "$ROUTING_DOC_PATH" ]] || fail "routing doc not found: $ROUTING_DOC_PATH"
[[ -f "$CONFIG_README_PATH" ]] || fail "config readme not found: $CONFIG_README_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-runtime-orchestrator" \
  "live_discord_connection: false" \
  "live_engram_calls: false" \
  "live_prompt_execution: false" \
  "runtime_enforcement_proven: false" \
  "uses_real_discord_ids: false" \
  "workspace_file_writes_allowed: false" \
  "github_mutations_enabled: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "runtime_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "name: planning-content-flow" \
  "name: sdd-dev-work-flow" \
  "name: clarification-fallback" \
  "family: planning_content" \
  "family: sdd_dev_work" \
  "family: clarification_needed" \
  "prompt_execution: none"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "docs/architecture/channel-context-namespace-mapping.md" \
  "docs/architecture/discord-memory-gateway.md" \
  "docs/architecture/discord-context-skill-packs.md" \
  "docs/architecture/discord-scoped-skills-registry.md" \
  "docs/adr/0001-runtime-boundary.md" \
  "skills/discord-approval-gate/SKILL.md"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing dependency marker: $required"
done

for required in \
  "Orchestrator pipeline" \
  "Event envelope schema" \
  "Intent families" \
  "Runner selection" \
  "Permission and confirmation gates" \
  "Execution metadata" \
  "docs/architecture/channel-context-namespace-mapping.md" \
  "docs/architecture/discord-memory-gateway.md" \
  "docs/architecture/discord-context-skill-packs.md" \
  "docs/architecture/discord-scoped-skills-registry.md" \
  "skills/discord-approval-gate/SKILL.md" \
  "docs/adr/0001-runtime-boundary.md" \
  "Gentle SDD is one runner/backend for \`sdd_dev_work\`" \
  "GitHub mutations"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required orchestrator marker: $required"
done

for required in \
  "#73 | OpenClaw Discord Runtime Orchestrator; see \`docs/architecture/discord-runtime-orchestrator.md\`. |" \
  "context pack -> skill pack -> intent -> runner"; do
  grep -F "$required" "$PARENT_DOC_PATH" >/dev/null || fail "parent doc missing orchestrator reference: $required"
done

grep -F "bash scripts/validate-discord-runtime-orchestrator.sh" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing orchestrator validator"
grep -F "examples/discord-runtime-orchestrator.fake.yaml" "$ROUTING_DOC_PATH" >/dev/null || fail "routing doc missing orchestrator fixture"
grep -F "docs/architecture/discord-runtime-orchestrator.md" "$CONFIG_README_PATH" >/dev/null || fail "config README missing orchestrator reference"

awk -v runtime="$RUNTIME_NAMESPACE_CONTRACT" '
  function finish_scenario() {
    if (scenario == "") {
      return
    }
    if (has_runtime != 2 || has_route != 2 || !has_intent || !has_runner || !has_gate || !has_exec || !has_prompt_none || !has_writeback) {
      printf("scenario %s is missing required orchestrator sections or runtime/route/execution markers\n", scenario) > "/dev/stderr"
      exit 1
    }
    if (scenario == "planning-content-flow") {
      if (intent != "planning_content" || backend != "openclaw-skill-surface" || runner != "content-planner" || gate_state != "summary-only" || approval_needed != "false" || writeback_class != "draft") {
        print "planning-content-flow contract markers are inconsistent" > "/dev/stderr"
        exit 1
      }
    }
    if (scenario == "sdd-dev-work-flow") {
      if (intent != "sdd_dev_work" || backend != "gentle-sdd" || runner != "development-orchestrator" || backend_mode != "delegated-contract-only" || prompt_execution != "none" || writeback_class != "reject") {
        print "sdd-dev-work-flow must be routed to gentle-sdd as delegated contract-only with no execution" > "/dev/stderr"
        exit 1
      }
    }
    if (scenario == "clarification-fallback") {
      if (intent != "clarification_needed" || backend != "response-only" || runner != "clarification" || gate_state != "needs-route" || writeback_class != "reject") {
        print "clarification-fallback must stay response-only with needs-route and reject writeback" > "/dev/stderr"
        exit 1
      }
    }
  }

  /^  - name:/ {
    finish_scenario()
    scenario = $3
    has_runtime = has_resolved_route = has_network_slug = has_route = has_intent = has_runner = has_gate = has_exec = has_prompt_none = has_writeback = 0
    intent = backend = runner = gate_state = approval_needed = writeback_class = backend_mode = prompt_execution = route_status = ""
    section = "scenario"
    next
  }
  scenario != "" && /^    event_envelope:/ { section = "event"; next }
  scenario != "" && /^    pack_refs:/ { section = "pack"; next }
  scenario != "" && /^    intent_classification:/ { section = "intent"; has_intent = 1; next }
  scenario != "" && /^    runner_selection:/ { section = "runner"; has_runner = 1; next }
  scenario != "" && /^    permission_gate:/ { section = "gate"; has_gate = 1; next }
  scenario != "" && /^    execution_metadata:/ { section = "exec"; has_exec = 1; next }
  scenario != "" && /^    writeback_policy:/ { section = "writeback"; has_writeback = 1; next }

  section == "event" && index($0, "runtime_namespace: " runtime) { has_runtime = 2; next }
  section == "event" && /routing_status:/ { route_status = $NF; next }
  section == "event" && /resolved_route:/ { has_resolved_route = 1; next }
  section == "event" && /network_slug:/ && route_status != "" { has_network_slug = 1; if (has_resolved_route) { has_route = 2 } next }
  section == "intent" && /family:/ { intent = $NF; next }
  section == "runner" && /runner_kind:/ { runner = $NF; next }
  section == "runner" && /backend:/ { backend = $NF; next }
  section == "runner" && /backend_mode:/ { backend_mode = $NF; next }
  section == "gate" && /state:/ { gate_state = $NF; next }
  section == "gate" && /approval_needed:/ { approval_needed = $NF; next }
  section == "exec" && /prompt_execution:/ { prompt_execution = $NF; if (prompt_execution == "none") { has_prompt_none = 1 } next }
  section == "writeback" && /classification:/ { writeback_class = $NF; next }

  END { finish_scenario() }
' "$FIXTURE_PATH" || fail "fixture orchestrator scenarios are inconsistent"

review_paths=("$FIXTURE_PATH" "$DOC_PATH" "$PARENT_DOC_PATH" "$ROUTING_DOC_PATH" "$CONFIG_README_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_connection: true|live_engram_calls: true|live_prompt_execution: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|workspace_file_writes_allowed: true|github_mutations_enabled: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|live Engram calls enabled|prompt execution proven|sdd execution proven|GitHub mutation executed|uses production credentials|production credentials enabled' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, mutation, persistence, publishing, scheduling, or prompt execution behavior"
fi

echo "Validated fake Discord runtime orchestrator contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Parent doc: $PARENT_DOC_PATH"
echo "Routing doc: $ROUTING_DOC_PATH"
echo "Config README: $CONFIG_README_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
