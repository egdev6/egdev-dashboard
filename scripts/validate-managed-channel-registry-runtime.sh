#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="${MANAGED_CHANNEL_REGISTRY_SCRIPT:-docker/openclaw/managed-channel-registry.sh}"
DOCKERFILE_PATH="docker/openclaw/Dockerfile"
CONFIG_README_PATH="openclaw/config/README.md"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

require_cmd grep
require_cmd mktemp
require_cmd chmod

[[ -f "$SCRIPT_PATH" ]] || fail "registry script not found: $SCRIPT_PATH"
[[ -f "$DOCKERFILE_PATH" ]] || fail "Dockerfile not found: $DOCKERFILE_PATH"
[[ -f "$CONFIG_README_PATH" ]] || fail "config README not found: $CONFIG_README_PATH"

bash -n "$SCRIPT_PATH" || fail "registry script has invalid shell syntax"

grep -F "discord-project-manager-managed-registry" "$DOCKERFILE_PATH" >/dev/null || fail "Dockerfile does not install registry CLI"
grep -F "private-runtime-managed-channel-registry" "$SCRIPT_PATH" >/dev/null || fail "script missing backend name"
grep -F "approve write" "$SCRIPT_PATH" >/dev/null || fail "script missing approval phrase marker"
grep -F "private-runtime-managed-channel-registry" "$CONFIG_README_PATH" >/dev/null || fail "config README missing registry backend reference"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
chmod 700 "$workdir"
export DISCORD_PROJECT_MANAGER_MANAGED_REGISTRY_DIR="$workdir/private-runtime-managed-channel-registry"
fake_private_id="$(printf '%018d' 1)"

backend_output="$(sh "$SCRIPT_PATH" backend-status)"
[[ "$backend_output" == *'"status":"OK"'* ]] || fail "backend status did not report OK: $backend_output"
[[ "$backend_output" == *'private-runtime-managed-channel-registry'* ]] || fail "backend status missing backend name"

missing_output="$(sh "$SCRIPT_PATH" status guild-demo channel-missing global context none)"
[[ "$missing_output" == *'"status":"MISSING_METADATA"'* ]] || fail "missing binding did not report MISSING_METADATA: $missing_output"

preview_output="$(sh "$SCRIPT_PATH" preview-repair guild-demo category-global channel-global-context global context none "project-manager-global:$fake_private_id" /project-manager-init)"
[[ "$preview_output" == *'"status":"MISSING_METADATA"'* ]] || fail "preview did not report missing metadata: $preview_output"
[[ "$preview_output" == *'"approval_state":"approval-requested"'* ]] || fail "preview did not request approval: $preview_output"
[[ "$preview_output" == *'"write_executed":false'* ]] || fail "preview attempted a write: $preview_output"
[[ "$preview_output" == *'"guildId":"private-runtime-id"'* ]] || fail "preview leaked or omitted sanitized guild id: $preview_output"
[[ "$preview_output" == *'"idempotencyKey":"project-manager-global:<private-id>"'* ]] || fail "preview did not sanitize idempotency key: $preview_output"
if printf '%s' "$preview_output" | grep -E '[0-9]{17,20}' >/dev/null; then
  fail "preview output leaked a snowflake-like value: $preview_output"
fi

put_output="$(sh "$SCRIPT_PATH" put guild-demo category-global channel-global-context global context none "project-manager-global:$fake_private_id" /project-manager-init)"
[[ "$put_output" == *'"status":"OK"'* ]] || fail "put did not report OK: $put_output"
[[ "$put_output" == *'"write_executed":true'* ]] || fail "put did not report write execution: $put_output"

ok_output="$(sh "$SCRIPT_PATH" verify guild-demo channel-global-context global context none)"
[[ "$ok_output" == *'"status":"OK"'* ]] || fail "verify did not report OK: $ok_output"
[[ "$ok_output" == *'"source":"persisted-semantic-metadata"'* ]] || fail "verify did not report persisted metadata source: $ok_output"

refresh_preview_output="$(sh "$SCRIPT_PATH" preview-repair guild-demo category-global channel-global-context global context none "project-manager-global:$fake_private_id" /project-manager-init)"
[[ "$refresh_preview_output" == *'"status":"NEEDS_REPAIR_PREVIEW"'* ]] || fail "existing-binding preview did not report NEEDS_REPAIR_PREVIEW: $refresh_preview_output"
[[ "$refresh_preview_output" == *'"proposed_action":"refresh-metadata"'* ]] || fail "existing-binding preview did not propose refresh-metadata: $refresh_preview_output"
[[ "$refresh_preview_output" == *'"write_executed":false'* ]] || fail "existing-binding preview attempted a write: $refresh_preview_output"
[[ "$refresh_preview_output" == *'"idempotencyKey":"project-manager-global:<private-id>"'* ]] || fail "existing-binding preview did not sanitize idempotency key: $refresh_preview_output"

wrong_scope_output="$(sh "$SCRIPT_PATH" verify guild-demo channel-global-context project context linkedin)"
[[ "$wrong_scope_output" == *'"status":"WRONG_SCOPE"'* ]] || fail "wrong scope was not detected: $wrong_scope_output"

wrong_field_output="$(sh "$SCRIPT_PATH" verify guild-demo channel-global-context global skills none)"
[[ "$wrong_field_output" == *'"status":"WRONG_FIELD"'* ]] || fail "wrong field was not detected: $wrong_field_output"

wrong_project_seed="$(sh "$SCRIPT_PATH" put guild-demo category-project channel-project-context project context linkedin "project:$fake_private_id:linkedin" /project-create)"
[[ "$wrong_project_seed" == *'"status":"OK"'* ]] || fail "project binding seed failed: $wrong_project_seed"
wrong_project_output="$(sh "$SCRIPT_PATH" verify guild-demo channel-project-context project context other-project)"
[[ "$wrong_project_output" == *'"status":"WRONG_PROJECT"'* ]] || fail "wrong project was not detected: $wrong_project_output"

deleted_output="$(sh "$SCRIPT_PATH" simulate-edge-case deleted-managed-channel project tasks linkedin)"
[[ "$deleted_output" == *'"scenario":"deleted-managed-channel"'* ]] || fail "deleted channel simulation missing scenario marker: $deleted_output"
[[ "$deleted_output" == *'"status":"needs-repair"'* ]] || fail "deleted channel simulation did not report needs-repair: $deleted_output"
[[ "$deleted_output" == *'"proposed_action":"recreate-channel"'* ]] || fail "deleted channel simulation did not propose recreate-channel: $deleted_output"
[[ "$deleted_output" == *'"metadata_refresh_required":true'* ]] || fail "deleted channel simulation did not require metadata refresh: $deleted_output"
[[ "$deleted_output" == *'"approval_phrase":"approve write"'* ]] || fail "deleted channel simulation did not require approval phrase: $deleted_output"
[[ "$deleted_output" == *'"write_executed":false'* ]] || fail "deleted channel simulation attempted a write: $deleted_output"

missing_id_output="$(sh "$SCRIPT_PATH" simulate-edge-case missing-persisted-id project tasks linkedin)"
[[ "$missing_id_output" == *'"scenario":"missing-persisted-id"'* ]] || fail "missing ID simulation missing scenario marker: $missing_id_output"
[[ "$missing_id_output" == *'"status":"unsafe-missing-id"'* ]] || fail "missing ID simulation did not report unsafe-missing-id: $missing_id_output"
[[ "$missing_id_output" == *'"auto_linked_by_name":false'* ]] || fail "missing ID simulation allowed name auto-link: $missing_id_output"
[[ "$missing_id_output" == *'"relink_by_name_attempted":false'* ]] || fail "missing ID simulation attempted relink by name: $missing_id_output"
[[ "$missing_id_output" == *'"write_executed":false'* ]] || fail "missing ID simulation attempted a write: $missing_id_output"

permission_output="$(sh "$SCRIPT_PATH" simulate-edge-case permission-failure project tasks linkedin manage_messages_for_pin)"
[[ "$permission_output" == *'"scenario":"permission-failure"'* ]] || fail "permission simulation missing scenario marker: $permission_output"
[[ "$permission_output" == *'"status":"blocked-permissions"'* ]] || fail "permission simulation did not report blocked-permissions: $permission_output"
[[ "$permission_output" == *'"permission_preflight_status":"blocked-permissions"'* ]] || fail "permission simulation did not block during preflight: $permission_output"
[[ "$permission_output" == *'"manage_messages_for_pin"'* ]] || fail "permission simulation did not report missing capability: $permission_output"
[[ "$permission_output" == *'"partial_repair_attempted":false'* ]] || fail "permission simulation attempted partial repair: $permission_output"
[[ "$permission_output" == *'"write_executed":false'* ]] || fail "permission simulation attempted a write: $permission_output"

for simulated_output in "$deleted_output" "$missing_id_output" "$permission_output"; do
  if printf '%s' "$simulated_output" | grep -E '[0-9]{17,20}' >/dev/null; then
    fail "edge-case simulation leaked a snowflake-like value: $simulated_output"
  fi
done

list_output="$(sh "$SCRIPT_PATH" list)"
[[ "$list_output" == *'"guildId":"private-runtime-id"'* ]] || fail "list output did not sanitize guild id"
[[ "$list_output" == *'project-manager-global:<private-id>'* ]] || fail "list output did not sanitize global idempotency key"
[[ "$list_output" == *'project:<private-id>:linkedin'* ]] || fail "list output did not sanitize project idempotency key"
if printf '%s' "$list_output" | grep -E '[0-9]{17,20}' >/dev/null; then
  fail "list output leaked a snowflake-like value: $list_output"
fi
if grep -E 'gho_|DISCORD_BOT_TOKEN=|[0-9]{17,20}' "$SCRIPT_PATH" "$DOCKERFILE_PATH" "$CONFIG_README_PATH" >/dev/null; then
  fail "registry implementation contains obvious token or snowflake-like private id"
fi

echo "Validated private runtime managed channel registry CLI."
echo "Script: $SCRIPT_PATH"
echo "Backend: private-runtime-managed-channel-registry"
echo "Storage dir: disposable temp dir"
