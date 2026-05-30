#!/usr/bin/env sh
set -eu

workspace="${OPENCLAW_WORKSPACE:-/home/node/.openclaw/workspace}"
source_dir="${EGDEV_SKILLS_SOURCE:-/opt/egdev-dashboard/skills}"
target_dir="$workspace/skills"

mkdir -p "$target_dir"

if [ -d "$source_dir" ]; then
  cp -R "$source_dir"/. "$target_dir"/
fi
