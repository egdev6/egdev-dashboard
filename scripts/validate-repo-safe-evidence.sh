#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found on PATH: $1"
}

require_cmd grep
require_cmd find

# Keep CI fake-first and repo-safe. This guard intentionally scans repository-facing
# files where accidental private Discord evidence, tokens, raw logs, or transcripts
# are most likely to be pasted.
scan_roots=(
  .github
  docs
  examples
  scripts
  docker
  openclaw
  README.md
)

existing_roots=()
for root in "${scan_roots[@]}"; do
  [[ -e "$root" ]] && existing_roots+=("$root")
done

((${#existing_roots[@]} > 0)) || fail "no scan roots found"

mapfile -d '' scan_files < <(
  find "${existing_roots[@]}" \
    -type f \
    \( \
    -name '*.md' -o \
    -name '*.yml' -o \
    -name '*.yaml' -o \
    -name '*.json' -o \
    -name '*.json5' -o \
    -name '*.sh' -o \
    -name '*.js' -o \
    -name '*.ts' -o \
    -name '*.html' -o \
    -name '.env.example' \
    \) \
    -print0 | sort -z
)

((${#scan_files[@]} > 0)) || fail "no files selected for repo-safe evidence scan"

# Discord snowflakes are 17-20 digit IDs. Repo-facing artifacts should use
# placeholders such as <guild-id>, <channel-id>, <private-id>, or fake-* values.
# Existing fake fixtures sometimes use repeated demo IDs like 111111111111111111;
# those are allowed because they are visibly non-real.
if ! python3 - "${scan_files[@]}" <<'PY'; then
import re
import sys
from pathlib import Path

bad = []
pattern = re.compile(r'(?<![0-9])([0-9]{17,20})(?![0-9])')
for raw in sys.argv[1:]:
    path = Path(raw)
    try:
        text = path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        continue
    for lineno, line in enumerate(text.splitlines(), 1):
        for match in pattern.finditer(line):
            value = match.group(1)
            if len(set(value)) == 1:
                continue
            bad.append(f'{path}:{lineno}:{line}')

if bad:
    print('\n'.join(bad))
    raise SystemExit(1)
PY
  fail "repo-facing files contain non-trivial snowflake-like 17-20 digit values; replace with placeholders"
fi

# Common token/secret prefixes or pasted assignment patterns. Keep this as a
# lightweight guard; Gitleaks remains the deeper secret scanner. Validator regex
# definitions are allowed; actual pasted values are not.
if ! python3 - "${scan_files[@]}" <<'PY'; then
import re
import sys
from pathlib import Path

patterns = [
    re.compile(r'ghp_[A-Za-z0-9_]{20,}'),
    re.compile(r'gho_[A-Za-z0-9_]{20,}'),
    re.compile(r'github_pat_[A-Za-z0-9_]{20,}'),
    re.compile(r'xox[baprs]-[A-Za-z0-9-]{20,}'),
    re.compile(r'mfa\.[A-Za-z0-9_-]{20,}'),
    re.compile(r'\b(DISCORD_BOT_TOKEN|OPENAI_API_KEY|ANTHROPIC_API_KEY)=[^<\s][^\s#]+'),
]
allowed_validator_markers = (
    'grep -E',
    'grep -nE',
    're.compile',
    'patterns =',
)

bad = []
for raw in sys.argv[1:]:
    path = Path(raw)
    try:
        text = path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        continue
    for lineno, line in enumerate(text.splitlines(), 1):
        if any(marker in line for marker in allowed_validator_markers):
            continue
        if any(pattern.search(line) for pattern in patterns):
            bad.append(f'{path}:{lineno}:{line}')

if bad:
    print('\n'.join(bad))
    raise SystemExit(1)
PY
  fail "repo-facing files contain obvious token/secret-like values or assignments"
fi

# Discourage committing raw evidence dumps. Sanitized summaries are allowed;
# raw logs/transcripts should stay private and be summarized in issues/PRs.
if find docs examples .github -type f \
  \( -iname '*raw*log*' -o -iname '*transcript*' -o -iname '*.log' \) \
  -print | grep -q .; then
  find docs examples .github -type f \
    \( -iname '*raw*log*' -o -iname '*transcript*' -o -iname '*.log' \) \
    -print
  fail "repo-facing raw log/transcript-like files are not allowed; use sanitized summaries"
fi

echo "Validated repo-safe evidence hygiene."
echo "Files scanned: ${#scan_files[@]}"
echo "Private Discord IDs/secrets/raw evidence: not found"
