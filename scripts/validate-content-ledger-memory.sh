#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="egdev-dashboard"
FIXTURE_PATH="${CONTENT_LEDGER_FIXTURE:-examples/content-ledger.fake.yaml}"
LEDGER_NAMESPACE="egdev-dashboard/project/egdev/content-ledger"
NETWORK_NAMESPACE="egdev-dashboard/project/egdev/network/x"
PROJECT_SLUG="egdev"
NETWORK_SLUG="x"
CONTENT_ID="x-post-001-demo"
SCHEMA_VERSION="1"
LEDGER_TITLE="fake content ledger smoke"
NETWORK_TITLE="fake x content overlay smoke"

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

[[ -f "$FIXTURE_PATH" ]] || fail "fixture not found: $FIXTURE_PATH"
grep -F "schema_version: $SCHEMA_VERSION" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected schema_version: $SCHEMA_VERSION"
grep -F "project: $PROJECT_SLUG" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected project slug: $PROJECT_SLUG"
grep -F "network: $NETWORK_SLUG" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected network slug: $NETWORK_SLUG"
grep -F "ledger_namespace_key: $LEDGER_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected ledger namespace: $LEDGER_NAMESPACE"
grep -F "network_namespace_key: $NETWORK_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected network namespace: $NETWORK_NAMESPACE"
grep -F "id: $CONTENT_ID" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected content identifier: $CONTENT_ID"
grep -F "assets:" "$FIXTURE_PATH" >/dev/null || fail "fixture does not follow the content-ledger skill contract: missing assets"
grep -F "fixture_type: fake-demo" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked fixture_type: fake-demo"
grep -F "safe_for_repo: true" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked safe_for_repo: true"

if [[ -z "${ENGRAM_DATA_DIR:-}" ]]; then
  cleanup_dir="$(mktemp -d)"
  export ENGRAM_DATA_DIR="$cleanup_dir"
fi

fixture_payload="$(cat "$FIXTURE_PATH")"

ledger_payload="$fixture_payload

roundtrip_record:
  namespace: $LEDGER_NAMESPACE
  scope: durable content ledger
  validation: issue-9-local-cli-roundtrip
"

network_payload="$fixture_payload

roundtrip_record:
  namespace: $NETWORK_NAMESPACE
  scope: x network overlay
  validation: issue-9-local-cli-roundtrip
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
  local expected_content_id="$3"
  local output_file="$4"
  local search_err

  search_err="$(mktemp)"
  add_tmp_file "$search_err"

  if ! engram search "$query" --project "$PROJECT_NAME" --limit 5 >"$output_file" 2>"$search_err"; then
    cat "$search_err" >&2 || true
    fail "engram search failed for namespace query: $query"
  fi

  grep -F "$expected_title" "$output_file" >/dev/null || fail "search results for $query did not include expected title: $expected_title"
  grep -F "$query" "$output_file" >/dev/null || fail "search results for $query did not include the namespace string"
  grep -F "$expected_content_id" "$output_file" >/dev/null || fail "search results for $query did not include the content identifier: $expected_content_id"
}

save_memory "$LEDGER_TITLE" "$ledger_payload" "$LEDGER_NAMESPACE"
save_memory "$NETWORK_TITLE" "$network_payload" "$NETWORK_NAMESPACE"

ledger_search_output="$(mktemp)"
network_search_output="$(mktemp)"
add_tmp_file "$ledger_search_output"
add_tmp_file "$network_search_output"

search_namespace "$LEDGER_NAMESPACE" "$LEDGER_TITLE" "$CONTENT_ID" "$ledger_search_output"
search_namespace "$NETWORK_NAMESPACE" "$NETWORK_TITLE" "$CONTENT_ID" "$network_search_output"

echo "Validated fake content-ledger roundtrip in Engram."
echo "Fixture: $FIXTURE_PATH"
echo "Ledger namespace: $LEDGER_NAMESPACE"
echo "Network namespace: $NETWORK_NAMESPACE"
echo "Content identifier: $CONTENT_ID"
echo "Schema version: $SCHEMA_VERSION"
echo "ENGRAM_DATA_DIR: $ENGRAM_DATA_DIR"
if [[ -n "$cleanup_dir" ]]; then
  echo "Mode: disposable temp data dir"
else
  echo "Mode: using caller-provided ENGRAM_DATA_DIR"
fi

echo "Failure behavior:"
echo "- exits nonzero if engram, mktemp, or grep is missing"
echo "- exits nonzero if fixture schema/safety markers or identifiers are missing"
echo "- exits nonzero if save fails for either namespace"
echo "- exits nonzero if search fails or readback misses the expected title, namespace, or content identifier"
