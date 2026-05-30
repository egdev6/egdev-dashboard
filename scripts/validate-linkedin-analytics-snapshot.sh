#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${LINKEDIN_ANALYTICS_FIXTURE:-examples/linkedin-analytics-snapshot.fake.yaml}"
PROJECT_SLUG="egdev"
NETWORK_SLUG="linkedin"
CONTENT_LEDGER_NAMESPACE="egdev-dashboard/project/egdev/content-ledger"
LINKEDIN_NAMESPACE="egdev-dashboard/project/egdev/network/linkedin"
STRATEGY_NAMESPACE="egdev-dashboard/project/egdev/strategy"

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
grep -F "project: $PROJECT_SLUG" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected project slug: $PROJECT_SLUG"
grep -F "network: $NETWORK_SLUG" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected network slug: $NETWORK_SLUG"
grep -F "type: fake-manual-export" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare fake-manual-export source type"
grep -F "provider: buffer-compatible-placeholder" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected fake provider"
grep -F "live_buffer_api: false" "$FIXTURE_PATH" >/dev/null || fail "fixture must declare live_buffer_api: false"
grep -F "content_ledger_namespace_key: $CONTENT_LEDGER_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected content-ledger namespace"
grep -F "network_namespace_key: $LINKEDIN_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected LinkedIn namespace"
grep -F "strategy_namespace_key: $STRATEGY_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected strategy namespace"
validate_content_metric_records() {
  awk '
    function reset_record() {
      planning = 0
      ledger = 0
      status = 0
      impressions = 0
      reactions = 0
      comments = 0
      shares = 0
      clicks = 0
      engagement = 0
      followers = 0
    }

    function validate_record() {
      if (!in_record) {
        return
      }
      if (!planning || !ledger || !status || !impressions || !reactions || !comments || !shares || !clicks || !engagement || !followers) {
        printf("invalid content_metrics record near %s: missing required association/status/metric field\n", content_id) > "/dev/stderr"
        exit 1
      }
    }

    /^  - content_id:/ {
      validate_record()
      in_record = 1
      record_count++
      content_id = $0
      reset_record()
      next
    }

    /^normalization_notes:/ {
      validate_record()
      in_record = 0
    }

    in_record && /^    planning_reference_id:/ { planning = 1 }
    in_record && /^    content_ledger_entry_id:/ { ledger = 1 }
    in_record && /^    content_ledger_status:/ { status = 1 }
    in_record && /^      impressions:/ { impressions = 1 }
    in_record && /^      reactions:/ { reactions = 1 }
    in_record && /^      comments:/ { comments = 1 }
    in_record && /^      shares:/ { shares = 1 }
    in_record && /^      clicks:/ { clicks = 1 }
    in_record && /^      engagement_rate:/ { engagement = 1 }
    in_record && /^      followers_gained:/ { followers = 1 }

    END {
      validate_record()
      if (record_count < 1) {
        print "fixture must include at least one content_metrics record" > "/dev/stderr"
        exit 1
      }
    }
  ' "$FIXTURE_PATH" || fail "fixture has invalid content_metrics records"
}

validate_content_metric_records

grep -F "fixture_type: fake-demo" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked fixture_type: fake-demo"
grep -F "safe_for_repo: true" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked safe_for_repo: true"

if grep -E "BUFFER_[A-Z0-9_]+" "$FIXTURE_PATH" >/dev/null; then
  fail "fixture must not contain Buffer credential variable names"
fi

echo "Validated fake LinkedIn analytics snapshot schema."
echo "Fixture: $FIXTURE_PATH"
echo "Project: $PROJECT_SLUG"
echo "Network: $NETWORK_SLUG"
echo "Content-ledger namespace: $CONTENT_LEDGER_NAMESPACE"
echo "Network namespace: $LINKEDIN_NAMESPACE"
echo "Strategy namespace: $STRATEGY_NAMESPACE"
echo "Failure behavior:"
echo "- exits nonzero if the fixture is missing"
echo "- exits nonzero if fake/safe markers, source flags, or namespace keys are missing"
echo "- exits nonzero if content associations or required metric fields are missing"
echo "- exits nonzero if Buffer credential variable names appear in the fixture"
