#!/usr/bin/env bash
set -euo pipefail

FIXTURE_PATH="${X_QUEUE_SOURCE_INGESTION_FIXTURE:-examples/x-queue-source-ingestion.fake.yaml}"
SKILL_PATH="skills/x-queue-planner/SKILL.md"
DOC_PATH="docs/research/x-queue-planning-skill.md"
RUNBOOK_PATH="docs/operations/x-queue-discord-approval-flow.md"
RUNTIME_NAMESPACE_CONTRACT="discord-project-manager/runtime/discord/<guild-id>/<channel-id>"
BRAND_NAMESPACE="discord-project-manager/project/egdev/brand"
STRATEGY_NAMESPACE="discord-project-manager/project/egdev/strategy"
LEDGER_NAMESPACE="discord-project-manager/project/egdev/content-ledger"
X_NAMESPACE="discord-project-manager/project/egdev/network/x"

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
[[ -f "$SKILL_PATH" ]] || fail "skill not found: $SKILL_PATH"
[[ -f "$DOC_PATH" ]] || fail "research doc not found: $DOC_PATH"
[[ -f "$RUNBOOK_PATH" ]] || fail "runbook not found: $RUNBOOK_PATH"

for required in \
  "schema_version: 1" \
  "fixture_type: fake-demo" \
  "safe_for_repo: true" \
  "privacy_reviewed: true" \
  "contract: x-queue-source-ingestion" \
  "project: egdev" \
  "network: x" \
  "live_discord_connection: false" \
  "uses_real_discord_ids: false" \
  "publishing_enabled: false" \
  "scheduling_enabled: false" \
  "buffer_activity_enabled: false" \
  "durable_memory_writes_allowed: false" \
  "workspace_file_writes_allowed: false" \
  "writes_before_approval: false" \
  "runtime_audit_namespace_contract: $RUNTIME_NAMESPACE_CONTRACT" \
  "source_type: fake-manual-input" \
  "brand_namespace_key: $BRAND_NAMESPACE" \
  "strategy_namespace_key: $STRATEGY_NAMESPACE" \
  "ledger_namespace_key: $LEDGER_NAMESPACE" \
  "network_namespace_key: $X_NAMESPACE" \
  "target_namespace_key: $X_NAMESPACE" \
  "target_namespace: $X_NAMESPACE" \
  "runtime_audit_namespace: $RUNTIME_NAMESPACE_CONTRACT"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required marker: $required"
done

for required in \
  "approve write" \
  "revise: <instruction>" \
  "reject"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing approval option: $required"
done

for required in \
  "queue_candidates:" \
  "proposed_queue_update:" \
  "approval_request:" \
  "runtime_audit_preview:"; do
  grep -F "$required" "$FIXTURE_PATH" >/dev/null || fail "fixture missing required section: $required"
done

candidate_count="$(grep -c '^  - candidate_id:' "$FIXTURE_PATH")"
[[ "$candidate_count" -ge 2 ]] || fail "fixture must include at least two queue candidates"

for required in \
  "source ingestion" \
  "proposal-only queue candidates" \
  "skills/discord-approval-gate/SKILL.md"; do
  grep -F "$required" "$SKILL_PATH" >/dev/null || fail "skill missing issue #58 contract marker: $required"
done

for required in \
  "examples/x-queue-source-ingestion.fake.yaml" \
  "ingestion-to-proposal" \
  "approve write"; do
  grep -F "$required" "$DOC_PATH" >/dev/null || fail "research doc missing issue #58 marker: $required"
done

for required in \
  "source ingestion" \
  "approve write" \
  "$RUNTIME_NAMESPACE_CONTRACT"; do
  grep -F "$required" "$RUNBOOK_PATH" >/dev/null || fail "runbook missing required marker: $required"
done

review_paths=("$FIXTURE_PATH" "$RUNBOOK_PATH" "$SKILL_PATH" "$DOC_PATH")

if grep -E '\b[0-9]{17,20}\b' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not expose raw Discord snowflake-like IDs"
fi

if grep -E 'BUFFER_[A-Z0-9_]+|DISCORD_[A-Z0-9_]+|OPENAI_[A-Z0-9_]+|ANTHROPIC_[A-Z0-9_]+|GITHUB_TOKEN|ENGRAM_[A-Z0-9_]+' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not contain credential variable names"
fi

if grep -E 'live_discord_connection: true|publishing_enabled: true|scheduling_enabled: true|buffer_activity_enabled: true|production-ready|public Discord validation passed|live Discord validation passed|uses production credentials|production credentials enabled' "${review_paths[@]}" >/dev/null; then
  fail "artifacts must not claim live, publishing, scheduling, production, or public Discord behavior"
fi

echo "Validated fake X queue source-ingestion contract."
echo "Fixture: $FIXTURE_PATH"
echo "Skill: $SKILL_PATH"
echo "Research doc: $DOC_PATH"
echo "Runbook: $RUNBOOK_PATH"
echo "Runtime namespace contract: $RUNTIME_NAMESPACE_CONTRACT"
