---
name: strategy-planner
description: "Produce small planning outputs for network-specific content workflows using approved brand context."
license: MIT
---

# Strategy Planner

Use this skill to transform stored context into a planning slice such as a weekly LinkedIn outline or an X queue draft.

## Inputs

- project slug
- network
- brand context summary
- campaign or timeframe
- constraints and goals

## Behavior

1. Start from approved brand context when available.
2. Generate concise planning structures instead of long prose.
3. Separate confirmed facts from assumptions.
4. Leave publishing and analytics execution to later skills or runtime integrations.

## Output shape

- project
- network
- timeframe
- goals
- planned items
- required assets
- review checkpoints

## Safety rules

- Do not pretend Discord routing, Buffer access, or memory writes are already configured.
- Do not publish or schedule content from this skeleton alone.
- Keep repository examples generic and reviewable.

## TODO

Split this skill into LinkedIn, X, and on-demand brief variants after the first memory-backed roundtrip is validated.
