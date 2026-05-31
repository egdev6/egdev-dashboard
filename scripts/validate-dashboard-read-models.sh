#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DASHBOARD_READ_MODELS_FIXTURE:-examples/dashboard-read-models.fake.yaml}"
PROJECT_SLUG="egdev"
BRAND_NAMESPACE="egdev-dashboard/project/egdev/brand"
STRATEGY_NAMESPACE="egdev-dashboard/project/egdev/strategy"
CONTENT_LEDGER_NAMESPACE="egdev-dashboard/project/egdev/content-ledger"
LINKEDIN_NAMESPACE="egdev-dashboard/project/egdev/network/linkedin"
X_NAMESPACE="egdev-dashboard/project/egdev/network/x"
YOUTUBE_NAMESPACE="egdev-dashboard/project/egdev/network/youtube"
TWITCH_NAMESPACE="egdev-dashboard/project/egdev/network/twitch"
STACK_AND_FLOW_NAMESPACE="egdev-dashboard/project/egdev/network/stack-and-flow"

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

grep -F "schema_version: 1" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected schema_version: 1"
grep -F "project_slug: $PROJECT_SLUG" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected project_slug: $PROJECT_SLUG"
grep -F "slice_type: contract-first-read-models" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare contract-first slice type"
grep -F "live_server: false" "$FIXTURE_PATH" >/dev/null || fail "fixture must declare live_server: false"
grep -F "runtime_memory_adapter: false" "$FIXTURE_PATH" >/dev/null || fail "fixture must declare runtime_memory_adapter: false"
grep -F "brand_namespace_key: $BRAND_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected brand namespace"
grep -F "strategy_namespace_key: $STRATEGY_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected strategy namespace"
grep -F "content_ledger_namespace_key: $CONTENT_LEDGER_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected content-ledger namespace"
grep -F "linkedin: $LINKEDIN_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected LinkedIn namespace"
grep -F "x: $X_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected X namespace"
grep -F "youtube: $YOUTUBE_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected YouTube namespace"
grep -F "twitch: $TWITCH_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected Twitch namespace"
grep -F "stack-and-flow: $STACK_AND_FLOW_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected Stack and Flow namespace"

for group in project_overview network_overview strategy_summary content_ledger_summary analytics_snapshot_summary; do
  grep -F "$group:" "$FIXTURE_PATH" >/dev/null || fail "fixture is missing read model group: $group"
done

grep -F "required_project_slug: true" "$FIXTURE_PATH" >/dev/null || fail "fixture must require project_slug filtering"
grep -F "unknown_behavior: exclude-by-default" "$FIXTURE_PATH" >/dev/null || fail "fixture must exclude unknown network filters by default"
grep -F "unmapped_routes_behavior: exclude-by-default" "$FIXTURE_PATH" >/dev/null || fail "fixture must exclude unmapped routes by default"
grep -F "expose_secrets: false" "$FIXTURE_PATH" >/dev/null || fail "fixture must declare expose_secrets: false"
grep -F "expose_credentials: false" "$FIXTURE_PATH" >/dev/null || fail "fixture must declare expose_credentials: false"
grep -F "expose_raw_private_memory: false" "$FIXTURE_PATH" >/dev/null || fail "fixture must declare expose_raw_private_memory: false"
grep -F "expose_raw_discord_ids: false" "$FIXTURE_PATH" >/dev/null || fail "fixture must declare expose_raw_discord_ids: false"
grep -F "normalized_repo_safe_fields_only: true" "$FIXTURE_PATH" >/dev/null || fail "fixture must declare normalized_repo_safe_fields_only: true"
grep -F "fixture_type: fake-demo" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked fixture_type: fake-demo"
grep -F "safe_for_repo: true" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked safe_for_repo: true"
grep -F "privacy_reviewed: true" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked privacy_reviewed: true"

validate_allowed_networks() {
  awk '
    function mark(value) {
      if (value == "linkedin") { linkedin = 1; return }
      if (value == "x") { x = 1; return }
      if (value == "youtube") { youtube = 1; return }
      if (value == "twitch") { twitch = 1; return }
      if (value == "stack-and-flow") { stack = 1; return }
      printf("unexpected allowed network slug: %s\n", value) > "/dev/stderr"
      exit 1
    }

    /allowed_values:/ { in_allowed = 1; next }
    in_allowed && /^      - / {
      value = $2
      mark(value)
      count++
      next
    }
    in_allowed && !/^      - / { in_allowed = 0 }
    END {
      if (count != 5 || !linkedin || !x || !youtube || !twitch || !stack) {
        print "allowed network filter list must contain exactly linkedin, x, youtube, twitch, and stack-and-flow" > "/dev/stderr"
        exit 1
      }
    }
  ' "$FIXTURE_PATH" || fail "fixture has invalid optional network filter values"
}

validate_filter_examples() {
  awk '
    /^  - name: / {
      if ($3 == "project-linkedin-only") { linkedin = 1 }
      if ($3 == "project-x-only") { x = 1 }
      if ($3 == "project-youtube-only") { youtube = 1 }
      if ($3 == "unknown-network-excluded") { excluded = 1 }
    }
    END {
      if (!linkedin || !x || !youtube || !excluded) {
        print "fixture must include linkedin, x, youtube, and unknown-network filter examples" > "/dev/stderr"
        exit 1
      }
    }
  ' "$FIXTURE_PATH" || fail "fixture is missing required filter examples"
}

validate_network_summary_records() {
  for network in linkedin x youtube twitch stack-and-flow; do
    grep -F "    - network_slug: $network" "$FIXTURE_PATH" >/dev/null || fail "network_overview must include a $network record"
  done

  grep -F "      strategy_status: weekly-plan-demo-available" "$FIXTURE_PATH" >/dev/null || fail "linkedin network_overview record must include strategy status"
  grep -F "      latest_snapshot_window_end: 2026-06-07" "$FIXTURE_PATH" >/dev/null || fail "linkedin network_overview record must include latest snapshot window"
  grep -F "      strategy_status: queue-plan-demo-available" "$FIXTURE_PATH" >/dev/null || fail "x network_overview record must include strategy status"
  grep -F "      latest_snapshot_window_end: 2026-06-15" "$FIXTURE_PATH" >/dev/null || fail "x network_overview record must include latest snapshot window"

  analytics_available_count=$(grep -c "      analytics_snapshot_status: fake-demo-available" "$FIXTURE_PATH")
  [[ "$analytics_available_count" -eq 2 ]] || fail "network_overview must include fake analytics status for linkedin and x"

  analytics_unavailable_count=$(grep -c "      analytics_snapshot_status: unavailable" "$FIXTURE_PATH")
  [[ "$analytics_unavailable_count" -eq 3 ]] || fail "network_overview must mark youtube, twitch, and stack-and-flow analytics unavailable"
}

validate_analytics_summary_records() {
  grep -F "  analytics_snapshot_summary:" "$FIXTURE_PATH" >/dev/null || fail "fixture must include analytics_snapshot_summary"
  grep -F "      source_status: fake-demo-only" "$FIXTURE_PATH" >/dev/null || fail "analytics snapshot summaries must include fake-demo-only records"

  snapshot_available_count=$(grep -c "      snapshot_available: true" "$FIXTURE_PATH")
  [[ "$snapshot_available_count" -eq 2 ]] || fail "analytics_snapshot_summary must include available linkedin and x records"

  snapshot_unavailable_count=$(grep -c "      snapshot_available: false" "$FIXTURE_PATH")
  [[ "$snapshot_unavailable_count" -eq 3 ]] || fail "analytics_snapshot_summary must mark youtube, twitch, and stack-and-flow unavailable"

  record_count_count=$(grep -c "      record_count: 2" "$FIXTURE_PATH")
  [[ "$record_count_count" -eq 2 ]] || fail "analytics_snapshot_summary must include expected record counts for linkedin and x"
}

validate_allowed_networks
validate_filter_examples
validate_network_summary_records
validate_analytics_summary_records

if grep -F "egdev-dashboard/runtime/discord/" "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not expose runtime Discord namespaces"
fi

if grep -E '\b[0-9]{17,20}\b' "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not contain credential variable names"
fi

echo "Validated fake dashboard read model contracts."
echo "Fixture: $FIXTURE_PATH"
echo "Project: $PROJECT_SLUG"
echo "Brand namespace: $BRAND_NAMESPACE"
echo "Strategy namespace: $STRATEGY_NAMESPACE"
echo "Content-ledger namespace: $CONTENT_LEDGER_NAMESPACE"
echo "LinkedIn namespace: $LINKEDIN_NAMESPACE"
echo "X namespace: $X_NAMESPACE"
echo "YouTube namespace: $YOUTUBE_NAMESPACE"
echo "Twitch namespace: $TWITCH_NAMESPACE"
echo "Stack and Flow namespace: $STACK_AND_FLOW_NAMESPACE"
echo "Failure behavior:"
echo "- exits nonzero if contract status, namespace keys, or read model groups are missing"
echo "- exits nonzero if filter rules or allowed network values are invalid"
echo "- exits nonzero if privacy defaults or fake/safe markers are missing"
echo "- exits nonzero if runtime Discord namespaces, snowflake-like IDs, or credential variable names appear in the fixture"
