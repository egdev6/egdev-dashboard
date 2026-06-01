#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_CONTEXT_PROVISIONING_FIXTURE:-examples/discord-context-provisioning.fake.yaml}"
DOC_PATH="docs/architecture/discord-context-namespace-provisioning.md"
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
[[ -f "$DOC_PATH" ]] || fail "provisioning contract doc not found: $DOC_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-context-namespace-provisioning" \
  "live_discord_connection: false" \
  "uses_real_discord_ids: false" \
  "runtime_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "provisioning_mode: draft" \
  "requires_operator_review: true" \
  "global_context_inherits: []" \
  "global_skill_inherits: []" \
  "durable_writes_enabled: false" \
  "approved_reconciliation_inputs:" \
  "provisioning_plan:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "entity_ref: category-demo-linkedin" \
  "entity_ref: category-demo-stack-flow" \
  "entity_ref: channel-demo-linkedin-drafts" \
  "entity_ref: channel-demo-stack-github" \
  "normalized_name: egdev-linkedin" \
  "normalized_name: stack-and-flow" \
  "parent_ref: category-demo-linkedin" \
  "parent_ref: category-demo-stack-flow"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing pilot coverage marker: $required"
done

for required in \
  "recommended_action: create-draft-category" \
  "recommended_action: create-draft-channel" \
  "recommended_action: preserve-artifact-paths" \
  "provisioning_status: blocked" \
  "stable_identity_preserved: true"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing provisioning behavior: $required"
done

for path in \
  "openclaw/provisioning/categories/category-demo-linkedin/metadata.yaml" \
  "openclaw/provisioning/categories/category-demo-linkedin/context.md" \
  "openclaw/provisioning/categories/category-demo-linkedin/inheritance.yaml" \
  "openclaw/provisioning/channels/channel-demo-linkedin-drafts/context.md" \
  "openclaw/provisioning/categories/category-demo-stack-flow/metadata.yaml" \
  "openclaw/provisioning/channels/channel-demo-stack-github/ledger.md"; do
  grep -F "$path" "$FIXTURE_PATH" >/dev/null || fail "fixture missing generated artifact path: $path"
done

if grep -F "recommended_action: delete" "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not recommend destructive delete actions"
fi

if grep -E 'discord-project-manager/runtime/discord/<guild-id>/<category-id>/<channel-id>|discord-project-manager/runtime/discord/[0-9]{17,20}' "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not introduce category IDs into runtime namespace paths or expose raw runtime namespaces"
fi

if grep -E '\b[0-9]{17,20}\b' "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not contain credential variable names"
fi

awk '
  function value() { return $NF }
  function finish_plan() {
    if (plan_is_category && plan_creates_category) {
      if (!category_has_context || !category_has_skill) {
        print "every category draft plan must declare empty global context and skill inheritance" > "/dev/stderr"
        exit 1
      }
    }
    plan_is_category = 0
    plan_creates_category = 0
    category_has_context = 0
    category_has_skill = 0
  }

  /approved_reconciliation_inputs:/ { in_inputs = 1; in_plan = 0; next }
  /provisioning_plan:/ { in_inputs = 0; in_plan = 1; next }
  /^metadata:/ { finish_plan(); in_plan = 0 }

  in_inputs && /entity_ref:/ { input_entity = value(); next }
  in_inputs && /operator_decision:/ {
    approved[input_entity] = (value() == "approved")
    next
  }

  in_plan && /plan_ref:/ {
    finish_plan()
    plan_ref = value()
    if (plan_ref == "block-moved-shared-github") {
      in_moved_plan = 1
    }
    next
  }
  in_plan && /entity_ref:/ { plan_entity = value(); next }
  in_plan && /entity_type: category/ { plan_is_category = 1; next }
  in_plan && /recommended_action: create-draft-category/ { plan_creates_category = 1 }
  in_plan && /recommended_action: create-draft-/ {
    if (!approved[plan_entity]) {
      printf("draft provisioning requires approved reconciliation input for %s\n", plan_entity) > "/dev/stderr"
      exit 1
    }
    next
  }
  in_plan && /global_context_inherits: \[\]/ { category_has_context = 1; next }
  in_plan && /global_skill_inherits: \[\]/ { category_has_skill = 1; next }
  in_moved_plan && /safe_to_apply_automatically: false/ { moved_safe = 1; in_moved_plan = 0; next }

  END {
    finish_plan()
    if (!moved_safe) {
      print "moved channel provisioning must be blocked" > "/dev/stderr"
      exit 1
    }
  }
' "$FIXTURE_PATH" || fail "fixture violates provisioning approval or safety defaults"

for required in "## Draft artifact layout" "## Safe defaults" "## Pilot examples" "$RUNTIME_NAMESPACE_CONTRACT"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "contract doc missing required marker: $required"
done

echo "Validated fake Discord context provisioning contract."
echo "Fixture: $FIXTURE_PATH"
echo "Contract doc: $DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
