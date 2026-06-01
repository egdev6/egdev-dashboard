#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${DISCORD_APPROVAL_GATE_FIXTURE:-examples/discord-approval-gate.fake.yaml}"
SKILL_PATH="skills/discord-approval-gate/SKILL.md"
DOC_PATH="docs/operations/discord-approval-responses.md"
RUNTIME_NAMESPACE_CONTRACT="discord-project-manager/runtime/discord/<guild-id>/<channel-id>"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

require_cmd grep

[[ -f "$FIXTURE_PATH" ]] || fail "fixture not found: $FIXTURE_PATH"
[[ -f "$SKILL_PATH" ]] || fail "skill not found: $SKILL_PATH"
[[ -f "$DOC_PATH" ]] || fail "approval response doc not found: $DOC_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: discord-approval-gate" \
  "live_discord_connection: false" \
  "uses_real_discord_ids: false" \
  "runtime_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "approval_phrase: approve write" \
  "state: approval-requested" \
  "persistent_writes_allowed: false" \
  "durable_project_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "audit_trail_mode: response-local-until-decision"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing approval gate marker: $required"
done

for required in \
  "save" \
  "write" \
  "update" \
  "remember" \
  "store" \
  "queue" \
  "ledger" \
  "publish" \
  "schedule"; do
  grep -F "  - $required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing write-like term: $required"
done

for required in \
  "name: matched-route-save-request" \
  "name: matched-route-reject" \
  "name: unmapped-route-write-request" \
  "writes_before_approval: false" \
  "writes_after_reject: false" \
  "durable_reads_allowed: false"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing scenario coverage: $required"
done

for required in \
  'Before explicit approval, do not call file, memory, ledger, queue, publishing, scheduling, or workspace persistence tools.' \
  'Accept only the exact phrase `approve write` as approval.' \
  'Keep the pre-approval audit trail in the response' \
  "$RUNTIME_NAMESPACE_CONTRACT"; do
  grep -F "$required" "$SKILL_PATH" >/dev/null || fail "skill missing enforcement rule: $required"
done

for required in \
  "## Runtime enforcement skill" \
  "skills/discord-approval-gate/SKILL.md" \
  "Before approval, the safe default is response-only" \
  "Reply with exactly one option:"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "approval doc missing enforcement marker: $required"
done

if grep -E '\b[0-9]{17,20}\b' "$FIXTURE_PATH" "$SKILL_PATH" >/dev/null; then
  fail "approval gate artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "$FIXTURE_PATH" "$SKILL_PATH" >/dev/null; then
  fail "approval gate artifacts must not contain credential variable names"
fi

echo "Validated fake Discord approval gate contract."
echo "Fixture: $FIXTURE_PATH"
echo "Skill: $SKILL_PATH"
echo "Contract doc: $DOC_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
