#!/usr/bin/env bash
set -euo pipefail

HTML_PATH="${DASHBOARD_OVERVIEW_HTML:-dashboard/index.html}"
DOC_PATH="${DASHBOARD_OVERVIEW_DOC:-docs/operations/dashboard-overview.md}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

require_cmd grep

[[ -f "$HTML_PATH" ]] || fail "dashboard HTML not found: $HTML_PATH"
[[ -f "$DOC_PATH" ]] || fail "dashboard operations doc not found: $DOC_PATH"

grep -F "Static demo / read-only slice" "$HTML_PATH" >/dev/null || fail "dashboard must declare static read-only slice"
grep -F "contract-first dashboard read models" "$HTML_PATH" >/dev/null || fail "dashboard must reference dashboard read models"
grep -F "This page is a dependency-free static overview" "$HTML_PATH" >/dev/null || fail "dashboard must explain static overview behavior"
grep -F "No writes or mutation controls are included in this first slice." "$HTML_PATH" >/dev/null || fail "dashboard must include no-mutation marker"
grep -F "No credentials, secrets, or tokens are embedded here." "$HTML_PATH" >/dev/null || fail "dashboard must include no-credentials marker"
grep -F "No raw Discord IDs or runtime transcripts are shown." "$HTML_PATH" >/dev/null || fail "dashboard must include no raw Discord IDs marker"
grep -F "No live Buffer calls or provider payloads are used." "$HTML_PATH" >/dev/null || fail "dashboard must include no live Buffer calls marker"
grep -F "No runtime memory reads are performed." "$HTML_PATH" >/dev/null || fail "dashboard must include no runtime memory reads marker"

for route in linkedin-egdev x-egdev youtube-egdev twitch-egdev stack-and-flow-egdev; do
  grep -F "$route" "$HTML_PATH" >/dev/null || fail "dashboard must include routed channel: $route"
done

for network in linkedin x youtube twitch stack-and-flow; do
  grep -F ">$network<" "$HTML_PATH" >/dev/null || fail "dashboard must include network name: $network"
done

grep -F "linkedin: fake-demo-only, 2 records" "$HTML_PATH" >/dev/null || fail "dashboard must include LinkedIn analytics summary"
grep -F "x: fake-demo-only, 2 records" "$HTML_PATH" >/dev/null || fail "dashboard must include X analytics summary"
grep -F "youtube: unavailable, 0 records" "$HTML_PATH" >/dev/null || fail "dashboard must include YouTube unavailable analytics summary"
grep -F "twitch: unavailable, 0 records" "$HTML_PATH" >/dev/null || fail "dashboard must include Twitch unavailable analytics summary"
grep -F "stack-and-flow: unavailable, 0 records" "$HTML_PATH" >/dev/null || fail "dashboard must include Stack-and-Flow unavailable analytics summary"

grep -F "Static HTML artifact only" "$DOC_PATH" >/dev/null || fail "operations doc must describe static HTML delivery"

if grep -E 'https?://' "$HTML_PATH" >/dev/null; then
  fail "dashboard must not reference external HTTP(S) assets or links"
fi

if grep -E '<form\b|\baction=|\bmethod=|\bPOST\b|fetch\(|XMLHttpRequest|localStorage' "$HTML_PATH" >/dev/null; then
  fail "dashboard must not include forms or mutation-like browser APIs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "$HTML_PATH" >/dev/null; then
  fail "dashboard must not contain credential variable names"
fi

echo "Validated static dashboard overview."
echo "HTML: $HTML_PATH"
echo "Doc: $DOC_PATH"
echo "Failure behavior:"
echo "- exits nonzero if the HTML or operations doc is missing"
echo "- exits nonzero if routed channel names, network names, analytics summaries, or safety markers are missing"
echo "- exits nonzero if external HTTP(S) assets, forms, mutation-like browser APIs, or obvious credential variable names appear"
