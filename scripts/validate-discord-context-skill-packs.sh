#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_CONTEXT_SKILL_PACKS_FIXTURE:-examples/discord-context-skill-packs.fake.yaml}"
DOC_PATH="docs/architecture/discord-context-skill-packs.md"
PARENT_DOC_PATH="docs/architecture/discord-dynamic-context-namespaces.md"
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
[[ -f "$CONFIG_README_PATH" ]] || fail "config readme not found: $CONFIG_README_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-context-skill-packs" \
  "live_generation: false" \
  "live_engram_calls: false" \
  "runtime_enforcement_proven: false" \
  "uses_real_discord_ids: false" \
  "raw_discord_chat_logs_included: false" \
  "durable_memory_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "runtime_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "writeback_out_of_scope: true" \
  "pack_kind: context-pack" \
  "pack_kind: skill-pack" \
  "truncation_behavior: summarize-tail" \
  "max_items: 5" \
  "max_chars_per_item: 240" \
  "max_chars_per_item: 120" \
  "name: egdev-linkedin-drafts" \
  "name: stack-and-flow-github" \
  "routing_status: matched-route" \
  "network_slug: linkedin" \
  "network_slug: stack-and-flow"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "discord-approval-gate" \
  "brand-context" \
  "linkedin-weekly-planner" \
  "content-ledger" \
  "strategy-planner" \
  "on-demand-brief-planner" \
  "x-queue-planner" \
  "category-disabled" \
  "channel-disabled" \
  "matched-route-context" \
  "mandatory-global-skill" \
  "global-inherited" \
  "thread-summary-available" \
  "egdev-linkedin" \
  "drafts" \
  "stack-and-flow" \
  "github"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing pack marker: $required"
done

for required in \
  "docs/architecture/discord-memory-gateway.md" \
  "docs/architecture/discord-scoped-skills-registry.md" \
  "skills/discord-approval-gate/SKILL.md"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing contract dependency: $required"
done

awk -v runtime="$RUNTIME_NAMESPACE_CONTRACT" '
  function finish_scenario() {
    if (scenario == "") {
      return
    }
    if (!context_runtime || !context_routing || !context_resolved || !skill_runtime) {
      printf("scenario %s must put runtime/route markers inside context_pack and runtime inside skill_pack\n", scenario) > "/dev/stderr"
      exit 1
    }
    if (scenario == "stack-and-flow-github" && (!stack_content_disabled || !stack_linkedin_disabled)) {
      print "stack-and-flow-github must explicitly exclude content-ledger/channel-disabled and linkedin-weekly-planner/category-disabled" > "/dev/stderr"
      exit 1
    }
  }

  /^  - name:/ {
    finish_scenario()
    scenario = $3
    in_context = 0
    in_skill = 0
    in_excluded = 0
    excluded_skill = ""
    context_runtime = 0
    context_routing = 0
    context_resolved = 0
    skill_runtime = 0
    stack_content_disabled = 0
    stack_linkedin_disabled = 0
    next
  }
  scenario != "" && /^    context_pack:/ { in_context = 1; in_skill = 0; in_excluded = 0; next }
  scenario != "" && /^    skill_pack:/ { in_context = 0; in_skill = 1; in_excluded = 0; next }
  in_context && index($0, "runtime_namespace: " runtime) { context_runtime = 1; next }
  in_context && /routing_status: matched-route/ { context_routing = 1; next }
  in_context && /resolved_route:/ { context_resolved = 1; next }
  in_skill && index($0, "runtime_namespace: " runtime) { skill_runtime = 1; next }
  scenario == "stack-and-flow-github" && in_skill && /^      excluded_skills:/ { in_excluded = 1; next }
  scenario == "stack-and-flow-github" && in_excluded && /skill_name:/ { excluded_skill = $NF; next }
  scenario == "stack-and-flow-github" && in_excluded && /exclusion_reason: channel-disabled/ && excluded_skill == "content-ledger" { stack_content_disabled = 1; next }
  scenario == "stack-and-flow-github" && in_excluded && /exclusion_reason: category-disabled/ && excluded_skill == "linkedin-weekly-planner" { stack_linkedin_disabled = 1; next }
  END { finish_scenario() }
' "$FIXTURE_PATH" || fail "fixture pack structure is inconsistent with documented schema"

for required in \
  "Pack inputs" \
  "Context Pack schema" \
  "Skill Pack schema" \
  "Provenance and exclusion rules" \
  "category-disabled" \
  "Size limits and truncation" \
  "Writeback boundary" \
  "docs/architecture/discord-memory-gateway.md" \
  "docs/architecture/discord-scoped-skills-registry.md" \
  "skills/discord-approval-gate/SKILL.md" \
  "discord-project-manager/runtime/discord/<guild-id>/<channel-id>" \
  "writeback proposals outside the packs"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "doc missing required pack marker: $required"
done

for required in \
  "#72 | Context Pack and Skill Pack schemas; see \`docs/architecture/discord-context-skill-packs.md\`. |" \
  "context pack -> skill pack -> intent -> runner"; do
  grep -F "$required" "$PARENT_DOC_PATH" >/dev/null || fail "parent doc missing pack reference: $required"
done

grep -F "docs/architecture/discord-context-skill-packs.md" "$CONFIG_README_PATH" >/dev/null || fail "config README missing context/skill packs reference"

review_paths=("$FIXTURE_PATH" "$DOC_PATH" "$PARENT_DOC_PATH" "$CONFIG_README_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_generation: true|live_engram_calls: true|runtime_enforcement_proven: true|uses_real_discord_ids: true|raw_discord_chat_logs_included: true|durable_memory_writes_allowed: true|workspace_file_writes_allowed: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|live Engram calls enabled|uses production credentials|production credentials enabled|prompt execution proven' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, production, persistence, publishing, scheduling, or prompt execution behavior"
fi

echo "Validated fake Discord context/skill packs contract."
echo "Fixture: $FIXTURE_PATH"
echo "Doc: $DOC_PATH"
echo "Parent doc: $PARENT_DOC_PATH"
echo "Config README: $CONFIG_README_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
