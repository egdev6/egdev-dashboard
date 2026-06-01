#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_TOPOLOGY_FIXTURE:-examples/discord-topology-reconciliation.fake.yaml}"
DOC_PATH="docs/architecture/discord-topology-reconciliation.md"
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
[[ -f "$DOC_PATH" ]] || fail "topology contract doc not found: $DOC_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-topology-reconciliation" \
  "live_discord_connection: false" \
  "uses_real_discord_ids: false" \
  "runtime_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "latest_topology_snapshot:" \
  "approved_topology_registry:" \
  "reconciliation_results:" \
  "normalized_name: openclaw-global" \
  "reserved_role: openclaw-global"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for channel in identity writing-style operating-principles boundaries inheritance skills; do
  grep -F "normalized_name: $channel" "$FIXTURE_PATH" >/dev/null || fail "fixture missing reserved global channel: $channel"
done

for state in unchanged discovered renamed moved missing unmapped permission-limited; do
  grep -F "state: $state" "$FIXTURE_PATH" >/dev/null || fail "fixture missing reconciliation state: $state"
done

for action in no-op create update archive needs-review; do
  grep -F "recommended_action: $action" "$FIXTURE_PATH" >/dev/null || fail "fixture missing recommended action: $action"
done

for required in \
  "entity_ref: category-demo-new-community" \
  "entity_ref: channel-demo-stack-linkedin" \
  "parent_ref: category-demo-linkedin" \
  "parent_ref: category-demo-stack-flow" \
  "normalized_name: ideas"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing registry/coverage marker: $required"
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
  /state: moved/ { moved = 1 }
  moved && /recommended_action: needs-review/ { moved_action = 1 }
  moved && /safe_to_apply_automatically: false/ { moved_safe = 1; moved = 0 }
  /state: missing/ { missing = 1 }
  missing && /recommended_action: archive/ { missing_action = 1 }
  missing && /safe_to_apply_automatically: false/ { missing_safe = 1; missing = 0 }
  /state: permission-limited/ { limited = 1 }
  limited && /recommended_action: needs-review/ { limited_action = 1 }
  limited && /safe_to_apply_automatically: false/ { limited_safe = 1; limited = 0 }
  /entity_type: category/ { category = 1 }
  category && /state: discovered/ { discovered_category = 1; category = 0 }
  /entity_type: channel/ { channel = 1 }
  channel && /state: discovered/ { discovered_channel = 1; channel = 0 }
  END {
    if (!moved_action || !moved_safe || !missing_action || !missing_safe || !limited_action || !limited_safe) {
      print "moved/missing/permission-limited states must use safe non-destructive actions" > "/dev/stderr"
      exit 1
    }
    if (!discovered_category || !discovered_channel) {
      print "fixture must include discovered category and discovered channel examples" > "/dev/stderr"
      exit 1
    }
  }
' "$FIXTURE_PATH" || fail "fixture allows unsafe reconciliation state"

for required in "## Approved registry" "## Reconciliation states" "## Safety rules" "$RUNTIME_NAMESPACE_CONTRACT"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "contract doc missing required marker: $required"
done

echo "Validated fake Discord topology reconciliation contract."
echo "Fixture: $FIXTURE_PATH"
echo "Contract doc: $DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
