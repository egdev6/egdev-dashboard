# OpenClaw workspace placeholder

This directory is documentation-only. It stays in git so the repository can explain how the OpenClaw workspace is expected to behave.

Live OpenClaw workspace state should not be written here. The Docker skeleton mounts a named volume at `/workspace` so runtime-local files stay outside the tracked repository.

Use this directory only for small tracked notes or examples that are safe to publish. Keep private runtime state, generated prompts, and local experiments in Docker volumes or ignored paths.
