#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="egdev-dashboard"
BRAND_FIXTURE_PATH="${BRAND_CONTEXT_FIXTURE:-examples/brand-context.fake.yaml}"
LEDGER_FIXTURE_PATH="${CONTENT_LEDGER_FIXTURE:-examples/content-ledger.fake.yaml}"
STRATEGY_FIXTURE_PATH="${STRATEGY_PLAN_FIXTURE:-examples/strategy-plan.fake.yaml}"

BRAND_NAMESPACE="egdev-dashboard/project/egdev/brand"
BRAND_NETWORK_NAMESPACE="egdev-dashboard/project/egdev/network/linkedin"
LEDGER_NAMESPACE="egdev-dashboard/project/egdev/content-ledger"
LEDGER_NETWORK_NAMESPACE="egdev-dashboard/project/egdev/network/x"
STRATEGY_NAMESPACE="egdev-dashboard/project/egdev/strategy"
STRATEGY_NETWORK_NAMESPACE="egdev-dashboard/project/egdev/network/linkedin"

PROJECT_SLUG="egdev"
NETWORK_SLUG="linkedin"
LEDGER_CONTENT_ID="x-post-001-demo"
TIMEFRAME="2026-W23"
APPROVAL_STATUS="approved-for-demo-validation"
SCHEMA_VERSION="1"

BRAND_TITLE="fake brand context smoke"
BRAND_NETWORK_TITLE="fake linkedin brand overlay smoke"
LEDGER_TITLE="fake content ledger smoke"
LEDGER_NETWORK_TITLE="fake x content overlay smoke"
STRATEGY_TITLE="fake strategy planning smoke"
STRATEGY_NETWORK_TITLE="fake linkedin strategy overlay smoke"

tmp_files=()
cleanup_dir=""

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

add_tmp_file() {
  tmp_files+=("$1")
}

cleanup() {
  local file
  for file in "${tmp_files[@]}"; do
    rm -f "$file"
  done

  if [[ -n "$cleanup_dir" && "${KEEP_ENGRAM_DATA_DIR:-0}" != "1" ]]; then
    rm -rf "$cleanup_dir"
  fi
}
trap cleanup EXIT

require_cmd engram
require_cmd mktemp
require_cmd grep

validate_brand_fixture() {
  [[ -f "$BRAND_FIXTURE_PATH" ]] || fail "brand fixture not found: $BRAND_FIXTURE_PATH"
  grep -F "project_namespace_key: $BRAND_NAMESPACE" "$BRAND_FIXTURE_PATH" >/dev/null || fail "brand fixture does not declare expected project namespace: $BRAND_NAMESPACE"
  grep -F "network_namespace_key: $BRAND_NETWORK_NAMESPACE" "$BRAND_FIXTURE_PATH" >/dev/null || fail "brand fixture does not declare expected network namespace: $BRAND_NETWORK_NAMESPACE"
  grep -F "fixture_type: fake-demo" "$BRAND_FIXTURE_PATH" >/dev/null || fail "brand fixture must be marked fixture_type: fake-demo"
  grep -F "safe_for_repo: true" "$BRAND_FIXTURE_PATH" >/dev/null || fail "brand fixture must be marked safe_for_repo: true"
}

validate_ledger_fixture() {
  [[ -f "$LEDGER_FIXTURE_PATH" ]] || fail "content-ledger fixture not found: $LEDGER_FIXTURE_PATH"
  grep -F "schema_version: 1" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture does not declare expected schema_version: 1"
  grep -F "project: egdev" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture does not declare expected project slug: egdev"
  grep -F "network: x" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture does not declare expected network slug: x"
  grep -F "ledger_namespace_key: $LEDGER_NAMESPACE" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture does not declare expected ledger namespace: $LEDGER_NAMESPACE"
  grep -F "network_namespace_key: $LEDGER_NETWORK_NAMESPACE" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture does not declare expected network namespace: $LEDGER_NETWORK_NAMESPACE"
  grep -F "id: $LEDGER_CONTENT_ID" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture does not declare expected content identifier: $LEDGER_CONTENT_ID"
  grep -F "assets:" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture does not follow the content-ledger contract: missing assets"
  grep -F "fixture_type: fake-demo" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture must be marked fixture_type: fake-demo"
  grep -F "safe_for_repo: true" "$LEDGER_FIXTURE_PATH" >/dev/null || fail "content-ledger fixture must be marked safe_for_repo: true"
}

validate_strategy_fixture() {
  [[ -f "$STRATEGY_FIXTURE_PATH" ]] || fail "strategy fixture not found: $STRATEGY_FIXTURE_PATH"
  grep -F "schema_version: $SCHEMA_VERSION" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not declare expected schema_version: $SCHEMA_VERSION"
  grep -F "project: $PROJECT_SLUG" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not declare expected project slug: $PROJECT_SLUG"
  grep -F "network: $NETWORK_SLUG" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not declare expected network slug: $NETWORK_SLUG"
  grep -F "strategy_namespace_key: $STRATEGY_NAMESPACE" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not declare expected strategy namespace: $STRATEGY_NAMESPACE"
  grep -F "network_namespace_key: $STRATEGY_NETWORK_NAMESPACE" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not declare expected network namespace: $STRATEGY_NETWORK_NAMESPACE"
  grep -F "brand_namespace_key: $BRAND_NAMESPACE" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not reference expected brand namespace: $BRAND_NAMESPACE"
  grep -F "ledger_namespace_key: $LEDGER_NAMESPACE" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not reference expected ledger namespace: $LEDGER_NAMESPACE"
  grep -F -- "- $LEDGER_CONTENT_ID" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not reference expected ledger content identifier: $LEDGER_CONTENT_ID"
  grep -F "timeframe: $TIMEFRAME" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not declare expected timeframe: $TIMEFRAME"
  grep -F "strategy_slice:" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not follow the strategy-planner contract: missing strategy_slice"
  grep -F "out_of_scope:" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not follow the strategy-planner contract: missing out_of_scope"
  grep -F "approval_status: $APPROVAL_STATUS" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not declare expected approval status: $APPROVAL_STATUS"
  grep -F "approved_by: human-maintainer-for-issue-10" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture does not include the fake human approval record"
  grep -F "fixture_type: fake-demo" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture must be marked fixture_type: fake-demo"
  grep -F "safe_for_repo: true" "$STRATEGY_FIXTURE_PATH" >/dev/null || fail "strategy fixture must be marked safe_for_repo: true"
}

if [[ -z "${ENGRAM_DATA_DIR:-}" ]]; then
  cleanup_dir="$(mktemp -d)"
  export ENGRAM_DATA_DIR="$cleanup_dir"
fi

validate_brand_fixture
validate_ledger_fixture
validate_strategy_fixture

brand_fixture_payload="$(cat "$BRAND_FIXTURE_PATH")"
ledger_fixture_payload="$(cat "$LEDGER_FIXTURE_PATH")"
strategy_fixture_payload="$(cat "$STRATEGY_FIXTURE_PATH")"

brand_project_payload="$brand_fixture_payload

roundtrip_record:
  namespace: $BRAND_NAMESPACE
  scope: project-wide brand context
  validation: issue-10-local-cli-roundtrip
"

ledger_project_payload="$ledger_fixture_payload

roundtrip_record:
  namespace: $LEDGER_NAMESPACE
  scope: durable content ledger
  validation: issue-10-local-cli-roundtrip
"

strategy_project_payload="$strategy_fixture_payload

source_context_readback:
  brand_title: $BRAND_TITLE
  ledger_title: $LEDGER_TITLE
  ledger_content_id: $LEDGER_CONTENT_ID
roundtrip_record:
  namespace: $STRATEGY_NAMESPACE
  scope: cross-network strategy memory
  validation: issue-10-local-cli-roundtrip
"

strategy_network_payload="$strategy_fixture_payload

source_context_readback:
  brand_title: $BRAND_TITLE
  ledger_title: $LEDGER_TITLE
  ledger_content_id: $LEDGER_CONTENT_ID
roundtrip_record:
  namespace: $STRATEGY_NETWORK_NAMESPACE
  scope: linkedin planning overlay
  validation: issue-10-local-cli-roundtrip
"

save_memory() {
  local title="$1"
  local payload="$2"
  local topic="$3"
  local save_out save_err

  save_out="$(mktemp)"
  save_err="$(mktemp)"
  add_tmp_file "$save_out"
  add_tmp_file "$save_err"

  if ! engram save "$title" "$payload" \
    --project "$PROJECT_NAME" \
    --type pattern \
    --scope project \
    --topic "$topic" >"$save_out" 2>"$save_err"; then
    cat "$save_out" >&2 || true
    cat "$save_err" >&2 || true
    fail "engram save failed for topic: $topic"
  fi
}

search_namespace() {
  local query="$1"
  local expected_title="$2"
  local expected_fragment="$3"
  local output_file="$4"
  local search_err

  search_err="$(mktemp)"
  add_tmp_file "$search_err"

  if ! engram search "$query" --project "$PROJECT_NAME" --limit 5 >"$output_file" 2>"$search_err"; then
    cat "$search_err" >&2 || true
    fail "engram search failed for namespace query: $query"
  fi

  grep -F "$expected_title" "$output_file" >/dev/null || fail "search results for $query did not include expected title: $expected_title"
  grep -F "$query" "$output_file" >/dev/null || fail "search results for $query did not include expected fragment: $query"
  grep -F "$expected_fragment" "$output_file" >/dev/null || fail "search results for $query did not include expected fragment: $expected_fragment"
}

export_readback() {
  local expected_title="$1"
  local expected_topic="$2"
  local expected_fragment="$3"
  local export_file export_err

  export_file="$(mktemp)"
  export_err="$(mktemp)"
  add_tmp_file "$export_file"
  add_tmp_file "$export_err"

  if ! engram export "$export_file" >/dev/null 2>"$export_err"; then
    cat "$export_err" >&2 || true
    fail "engram export failed while verifying title: $expected_title"
  fi

  grep -F "\"title\": \"$expected_title\"" "$export_file" >/dev/null || fail "export readback did not include expected title: $expected_title"
  grep -F "\"topic_key\": \"$expected_topic\"" "$export_file" >/dev/null || fail "export readback did not include expected topic key: $expected_topic"
  grep -F "$expected_fragment" "$export_file" >/dev/null || fail "export readback did not include expected fragment: $expected_fragment"
}

save_memory "$BRAND_TITLE" "$brand_project_payload" "$BRAND_NAMESPACE"
save_memory "$LEDGER_TITLE" "$ledger_project_payload" "$LEDGER_NAMESPACE"

brand_search_output="$(mktemp)"
ledger_search_output="$(mktemp)"
add_tmp_file "$brand_search_output"
add_tmp_file "$ledger_search_output"

search_namespace "$BRAND_NAMESPACE" "$BRAND_TITLE" "$BRAND_NAMESPACE" "$brand_search_output"
search_namespace "$LEDGER_NAMESPACE" "$LEDGER_TITLE" "$LEDGER_CONTENT_ID" "$ledger_search_output"

save_memory "$STRATEGY_TITLE" "$strategy_project_payload" "$STRATEGY_NAMESPACE"
save_memory "$STRATEGY_NETWORK_TITLE" "$strategy_network_payload" "$STRATEGY_NETWORK_NAMESPACE"

strategy_search_output="$(mktemp)"
network_strategy_search_output="$(mktemp)"
add_tmp_file "$strategy_search_output"
add_tmp_file "$network_strategy_search_output"

search_namespace "$STRATEGY_NAMESPACE" "$STRATEGY_TITLE" "$STRATEGY_NAMESPACE" "$strategy_search_output"
search_namespace "$STRATEGY_NETWORK_NAMESPACE" "$STRATEGY_NETWORK_TITLE" "$STRATEGY_NETWORK_NAMESPACE" "$network_strategy_search_output"

export_readback "$STRATEGY_TITLE" "$STRATEGY_NAMESPACE" "approval_status: $APPROVAL_STATUS"
export_readback "$STRATEGY_NETWORK_TITLE" "$STRATEGY_NETWORK_NAMESPACE" "approval_status: $APPROVAL_STATUS"

echo "Validated fake strategy planning roundtrip in Engram."
echo "Brand namespace read: $BRAND_NAMESPACE"
echo "Ledger namespace read: $LEDGER_NAMESPACE"
echo "Strategy namespace written: $STRATEGY_NAMESPACE"
echo "Network strategy namespace written: $STRATEGY_NETWORK_NAMESPACE"
echo "Approval status: $APPROVAL_STATUS"
echo "ENGRAM_DATA_DIR: $ENGRAM_DATA_DIR"
if [[ -n "$cleanup_dir" ]]; then
  echo "Mode: disposable temp data dir"
else
  echo "Mode: using caller-provided ENGRAM_DATA_DIR"
fi

echo "Failure behavior:"
echo "- exits nonzero if engram, mktemp, or grep is missing"
echo "- exits nonzero if any fixture safety marker, namespace key, timeframe, or identifier is missing"
echo "- exits nonzero if source context save/search fails before strategy planning"
echo "- exits nonzero if strategy save/search fails or export readback misses expected titles, namespaces, or approval status"
