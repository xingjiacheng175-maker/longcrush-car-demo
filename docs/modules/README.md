# Module Reading Guide

Use this directory to avoid rereading the whole project for every task.

## When Starting Work

Always read the root session files first:

1. `AGENTS.md`
2. `docs/project_status.md`
3. `docs/design_summary.md`
4. `docs/handoff.md`

Then read only the module file that matches the task:

- Gameplay rule or player feedback changes: `docs/modules/gameplay.md`
- Portal, Roller, Mole, or future obstacle work: `docs/modules/special_tiles.md`
- Level JSON, level order, or level collaboration: `docs/modules/level_authoring.md`
- Runtime editor UI and save/load workflow: `docs/modules/editor_workflow.md`
- Placeholder art or tile replacement: `docs/modules/assets.md`
- Manual validation and regression checks: `docs/modules/testing.md`

## Current Code Shape

Most implementation still lives in `scripts/Main.gd`. This is intentional for the current prototype. Prefer documentation-first and checklist-driven changes until the gameplay and level workflow are stable enough for code refactoring.

