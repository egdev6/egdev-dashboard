#!/usr/bin/env sh
set -eu

registry_root="${DISCORD_PROJECT_MANAGER_MANAGED_REGISTRY_DIR:-${OPENCLAW_WORKSPACE:-/home/node/.openclaw/workspace}/private-runtime-managed-channel-registry}"
registry_file="${DISCORD_PROJECT_MANAGER_MANAGED_REGISTRY_FILE:-$registry_root/managed-channel-bindings.jsonl}"
allowed_fields_global="context skills strategy decisions config"
allowed_fields_project="context skills strategy tasks decisions qa"

usage() {
  cat <<'USAGE'
discord-project-manager-managed-registry <command> [args]

Private runtime backend for Project Manager managed Discord channel metadata.
Stores JSONL under the OpenClaw workspace by default:
  /home/node/.openclaw/workspace/private-runtime-managed-channel-registry/managed-channel-bindings.jsonl

Commands:
  backend-status
  put <guildId> <categoryId> <channelId> <scope> <field> <projectSlug|none> <idempotencyKey> <source>
  status <guildId> <channelId> <scope> <field> <projectSlug|none>
  verify <guildId> <channelId> <scope> <field> <projectSlug|none>
  preview-repair <guildId> <categoryId> <channelId> <scope> <field> <projectSlug|none> <idempotencyKey> <source>
  list

Safety:
  - This tool is for private runtime state only.
  - Do not commit the generated registry file.
  - Repair preview does not write. Use put only after explicit approval.
USAGE
}

json_escape() {
  # JSON-string escape for simple runtime refs. Handles backslash and double quote.
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

sanitize_evidence_value() {
  # Redact Discord snowflake-like values from operator-facing output.
  printf '%s' "$1" | sed -E 's/[0-9]{17,20}/<private-id>/g'
}

ensure_backend() {
  mkdir -p "$registry_root"
  touch "$registry_file"
  chmod 700 "$registry_root" 2>/dev/null || true
  chmod 600 "$registry_file" 2>/dev/null || true
}

backend_status() {
  ensure_backend
  printf '{"backend":"private-runtime-managed-channel-registry","status":"OK","storage":"%s","repo_safe":false}\n' "$(json_escape "$registry_file")"
}

validate_scope_field() {
  scope="$1"
  field="$2"
  project_slug="$3"

  case "$scope" in
    global)
      [ "$project_slug" = "none" ] || {
        printf '{"status":"WRONG_PROJECT","reason":"global bindings must use project none"}\n'
        return 1
      }
      for allowed in $allowed_fields_global; do
        [ "$field" = "$allowed" ] && return 0
      done
      printf '{"status":"WRONG_FIELD","reason":"unsupported global field"}\n'
      return 1
      ;;
    project)
      [ "$project_slug" != "none" ] || {
        printf '{"status":"WRONG_PROJECT","reason":"project bindings require projectSlug"}\n'
        return 1
      }
      for allowed in $allowed_fields_project; do
        [ "$field" = "$allowed" ] && return 0
      done
      printf '{"status":"WRONG_FIELD","reason":"unsupported project field"}\n'
      return 1
      ;;
    *)
      printf '{"status":"WRONG_SCOPE","reason":"scope must be global or project"}\n'
      return 1
      ;;
  esac
}

latest_binding() {
  guild_id="$1"
  channel_id="$2"
  [ -f "$registry_file" ] || return 1
  awk -v guild="\"guildId\":\"$guild_id\"" -v channel="\"channelId\":\"$channel_id\"" '
    index($0, guild) && index($0, channel) { found = $0 }
    END { if (found != "") print found; else exit 1 }
  ' "$registry_file"
}

put_binding() {
  [ "$#" -eq 8 ] || { usage >&2; exit 2; }
  guild_id="$1"
  category_id="$2"
  channel_id="$3"
  scope="$4"
  field="$5"
  project_slug="$6"
  idempotency_key="$7"
  source="$8"

  validate_scope_field "$scope" "$field" "$project_slug" >/dev/null
  ensure_backend

  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  cat >>"$registry_file" <<EOF
{"backend":"private-runtime-managed-channel-registry","guildId":"$(json_escape "$guild_id")","categoryId":"$(json_escape "$category_id")","channelId":"$(json_escape "$channel_id")","scope":"$(json_escape "$scope")","field":"$(json_escape "$field")","projectSlug":"$(json_escape "$project_slug")","idempotencyKey":"$(json_escape "$idempotency_key")","createdOrUpdatedBy":"$(json_escape "$source")","updatedAt":"$now"}
EOF
  printf '{"status":"OK","backend":"private-runtime-managed-channel-registry","write_executed":true,"approval_required":"approve write"}\n'
}

status_binding() {
  [ "$#" -eq 5 ] || { usage >&2; exit 2; }
  guild_id="$1"
  channel_id="$2"
  expected_scope="$3"
  expected_field="$4"
  expected_project="$5"

  ensure_backend
  binding="$(latest_binding "$guild_id" "$channel_id" 2>/dev/null || true)"
  if [ -z "$binding" ]; then
    printf '{"status":"MISSING_METADATA","backend":"private-runtime-managed-channel-registry","channelId":"private-runtime-id"}\n'
    return 0
  fi

  actual_scope="$(printf '%s' "$binding" | sed -n 's/.*"scope":"\([^"]*\)".*/\1/p')"
  actual_field="$(printf '%s' "$binding" | sed -n 's/.*"field":"\([^"]*\)".*/\1/p')"
  actual_project="$(printf '%s' "$binding" | sed -n 's/.*"projectSlug":"\([^"]*\)".*/\1/p')"

  if [ "$actual_scope" != "$expected_scope" ]; then
    printf '{"status":"WRONG_SCOPE","scope":"%s","field":"%s","project":"%s"}\n' "$(json_escape "$actual_scope")" "$(json_escape "$actual_field")" "$(json_escape "$actual_project")"
    return 0
  fi
  if [ "$actual_field" != "$expected_field" ]; then
    printf '{"status":"WRONG_FIELD","scope":"%s","field":"%s","project":"%s"}\n' "$(json_escape "$actual_scope")" "$(json_escape "$actual_field")" "$(json_escape "$actual_project")"
    return 0
  fi
  if [ "$actual_project" != "$expected_project" ]; then
    printf '{"status":"WRONG_PROJECT","scope":"%s","field":"%s","project":"%s"}\n' "$(json_escape "$actual_scope")" "$(json_escape "$actual_field")" "$(json_escape "$actual_project")"
    return 0
  fi

  printf '{"status":"OK","backend":"private-runtime-managed-channel-registry","scope":"%s","field":"%s","project":"%s","source":"persisted-semantic-metadata"}\n' "$(json_escape "$actual_scope")" "$(json_escape "$actual_field")" "$(json_escape "$actual_project")"
}

preview_repair() {
  [ "$#" -eq 8 ] || { usage >&2; exit 2; }
  guild_id="$1"
  category_id="$2"
  channel_id="$3"
  scope="$4"
  field="$5"
  project_slug="$6"
  idempotency_key="$7"
  source="$8"

  validate_scope_field "$scope" "$field" "$project_slug" >/dev/null
  ensure_backend
  existing="$(latest_binding "$guild_id" "$channel_id" 2>/dev/null || true)"
  if [ -n "$existing" ]; then
    status="NEEDS_REPAIR_PREVIEW"
    action="refresh-metadata"
  else
    status="MISSING_METADATA"
    action="create-metadata"
  fi
  safe_idempotency_key="$(sanitize_evidence_value "$idempotency_key")"
  printf '{"status":"%s","backend":"private-runtime-managed-channel-registry","approval_state":"approval-requested","approval_phrase":"approve write","write_executed":false,"proposed_action":"%s","binding":{"guildId":"private-runtime-id","categoryId":"private-runtime-id","channelId":"private-runtime-id","scope":"%s","field":"%s","projectSlug":"%s","idempotencyKey":"%s","source":"%s"}}\n' \
    "$status" "$action" "$(json_escape "$scope")" "$(json_escape "$field")" "$(json_escape "$project_slug")" "$(json_escape "$safe_idempotency_key")" "$(json_escape "$source")"
}

list_bindings() {
  ensure_backend
  if [ ! -s "$registry_file" ]; then
    printf '{"backend":"private-runtime-managed-channel-registry","bindings":[]}\n'
    return 0
  fi
  sed -E 's/"guildId":"[^"]*"/"guildId":"private-runtime-id"/g; s/"categoryId":"[^"]*"/"categoryId":"private-runtime-id"/g; s/"channelId":"[^"]*"/"channelId":"private-runtime-id"/g; s/[0-9]{17,20}/<private-id>/g' "$registry_file"
}

cmd="${1:-}"
[ -n "$cmd" ] || { usage >&2; exit 2; }
shift || true

case "$cmd" in
  backend-status) backend_status "$@" ;;
  put) put_binding "$@" ;;
  status|verify) status_binding "$@" ;;
  preview-repair) preview_repair "$@" ;;
  list) list_bindings "$@" ;;
  -h|--help|help) usage ;;
  *) usage >&2; exit 2 ;;
esac
