#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TEMP_CONTEXT_MD=""
RESTORE_CONTEXT_MD=0

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

run_cmd() {
  local label="$1"
  shift

  echo
  echo "==> ${label}"
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
  "$@"
}

skip_step() {
  echo
  echo "==> SKIP: $*"
}

restore_context_md() {
  if [[ "$RESTORE_CONTEXT_MD" == "1" && -n "$TEMP_CONTEXT_MD" && -f "$TEMP_CONTEXT_MD" ]]; then
    mv "$TEMP_CONTEXT_MD" context.md
  fi
}
trap restore_context_md EXIT

hide_untracked_context_md() {
  if [[ -f context.md && "$RESTORE_CONTEXT_MD" == "0" ]]; then
    if git ls-files --error-unmatch context.md >/dev/null 2>&1; then
      return
    fi

    TEMP_CONTEXT_MD="$(mktemp)"
    mv context.md "$TEMP_CONTEXT_MD"
    RESTORE_CONTEXT_MD=1
    echo "Temporarily moved untracked context.md aside for markdown lint."
  fi
}

run_optional_markdown_lint() {
  if command -v markdownlint-cli2 >/dev/null 2>&1; then
    hide_untracked_context_md
    run_cmd "Stage 0: markdown lint" markdownlint-cli2 "**/*.md"
    return
  fi

  if [[ "${SAFE_VALIDATION_USE_NPX_MARKDOWNLINT:-0}" == "1" ]]; then
    require_cmd npx
    hide_untracked_context_md
    run_cmd "Stage 0: markdown lint via npx" npx --yes markdownlint-cli2@0.18.1 "**/*.md"
    return
  fi

  skip_step "markdown lint (install markdownlint-cli2 or set SAFE_VALIDATION_USE_NPX_MARKDOWNLINT=1)"
}

run_optional_tool() {
  local tool="$1"
  shift

  if command -v "$tool" >/dev/null 2>&1; then
    run_cmd "Stage 0: $tool" "$@"
  else
    skip_step "$tool not found on PATH"
  fi
}

run_stage_0() {
  run_cmd "Stage 0: git diff --check" git diff --check

  echo
  printf 'Discovered %d shell scripts for syntax checks.\n' "${#shell_scripts[@]}"
  for script in "${shell_scripts[@]}"; do
    run_cmd "Stage 0: bash -n ${script}" bash -n "$script"
  done

  run_optional_tool actionlint actionlint
  run_optional_tool shellcheck shellcheck "${shell_scripts[@]}"
  run_optional_tool shfmt shfmt -d -i 2 -ci scripts docker/openclaw/sync-skills.sh
  run_optional_tool yamllint yamllint .
  run_optional_markdown_lint
}

require_cmd bash
require_cmd find
require_cmd git
require_cmd sort

shell_scripts=()
while IFS= read -r script; do
  shell_scripts+=("$script")
done < <(find scripts docker -type f -name '*.sh' -print | LC_ALL=C sort)

validator_scripts=()
while IFS= read -r script; do
  validator_scripts+=("$script")
done < <(find scripts -maxdepth 1 -type f -name 'validate-*.sh' -print | LC_ALL=C sort)

[[ ${#shell_scripts[@]} -gt 0 ]] || fail "no shell scripts found under scripts/ or docker/"
[[ ${#validator_scripts[@]} -gt 0 ]] || fail "no validator scripts found under scripts/"

if [[ "${SAFE_VALIDATION_SKIP_STAGE0:-0}" == "1" ]]; then
  echo
  echo "==> SKIP: Stage 0 static hygiene (SAFE_VALIDATION_SKIP_STAGE0=1)"
else
  run_stage_0
fi

echo
printf 'Discovered %d safe validators:\n' "${#validator_scripts[@]}"
printf ' - %s\n' "${validator_scripts[@]}"

for script in "${validator_scripts[@]}"; do
  run_cmd "Stage 1: ${script}" bash "$script"
done

echo
printf 'Safe validation suite completed successfully.\n'
printf 'Shell scripts checked: %d\n' "${#shell_scripts[@]}"
printf 'Validators run: %d\n' "${#validator_scripts[@]}"
printf 'Mode: local fake-first Stage 0-1 only (no Docker runtime or private Discord steps).\n'
