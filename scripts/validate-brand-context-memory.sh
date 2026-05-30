#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="egdev-dashboard"
FIXTURE_PATH="${BRAND_CONTEXT_FIXTURE:-examples/brand-context.fake.yaml}"
PROJECT_NAMESPACE="egdev-dashboard/project/egdev/brand"
NETWORK_NAMESPACE="egdev-dashboard/project/egdev/network/linkedin"
PROJECT_TITLE="fake brand context smoke"
NETWORK_TITLE="fake linkedin brand overlay smoke"

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
grep -F "project_namespace_key: $PROJECT_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected project namespace: $PROJECT_NAMESPACE"
grep -F "network_namespace_key: $NETWORK_NAMESPACE" "$FIXTURE_PATH" >/dev/null || fail "fixture does not declare expected network namespace: $NETWORK_NAMESPACE"
grep -F "fixture_type: fake-demo" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked fixture_type: fake-demo"
grep -F "safe_for_repo: true" "$FIXTURE_PATH" >/dev/null || fail "fixture must be marked safe_for_repo: true"

if [[ -z "${ENGRAM_DATA_DIR:-}" ]]; then
  cleanup_dir="$(mktemp -d)"
  export ENGRAM_DATA_DIR="$cleanup_dir"
fi

fixture_payload="$(cat "$FIXTURE_PATH")"

project_payload="$fixture_payload

roundtrip_record:
  namespace: $PROJECT_NAMESPACE
  scope: project-wide brand context
  validation: issue-8-local-cli-roundtrip
"

network_payload="$fixture_payload

roundtrip_record:
  namespace: $NETWORK_NAMESPACE
  scope: linkedin network overlay
  validation: issue-8-local-cli-roundtrip
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
  local output_file="$3"
  local search_err

  search_err="$(mktemp)"
  add_tmp_file "$search_err"

  if ! engram search "$query" --project "$PROJECT_NAME" --limit 5 >"$output_file" 2>"$search_err"; then
    cat "$search_err" >&2 || true
    fail "engram search failed for namespace query: $query"
  fi

  grep -F "$expected_title" "$output_file" >/dev/null || fail "search results for $query did not include expected title: $expected_title"
  grep -F "$query" "$output_file" >/dev/null || fail "search results for $query did not include the namespace string"
}

save_memory "$PROJECT_TITLE" "$project_payload" "$PROJECT_NAMESPACE"
save_memory "$NETWORK_TITLE" "$network_payload" "$NETWORK_NAMESPACE"

project_search_output="$(mktemp)"
network_search_output="$(mktemp)"
add_tmp_file "$project_search_output"
add_tmp_file "$network_search_output"

search_namespace "$PROJECT_NAMESPACE" "$PROJECT_TITLE" "$project_search_output"
search_namespace "$NETWORK_NAMESPACE" "$NETWORK_TITLE" "$network_search_output"

echo "Validated fake brand-context roundtrip in Engram."
echo "Fixture: $FIXTURE_PATH"
echo "Project namespace: $PROJECT_NAMESPACE"
echo "Network namespace: $NETWORK_NAMESPACE"
echo "ENGRAM_DATA_DIR: $ENGRAM_DATA_DIR"
if [[ -n "$cleanup_dir" ]]; then
  echo "Mode: disposable temp data dir"
else
  echo "Mode: using caller-provided ENGRAM_DATA_DIR"
fi

echo "Failure behavior:"
echo "- exits nonzero if engram is missing"
echo "- exits nonzero if fixture safety markers or namespaces are missing"
echo "- exits nonzero if save fails for either namespace"
echo "- exits nonzero if search fails or readback misses the expected title/namespace"
