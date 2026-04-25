# Handoff

Last updated: 2026-04-25

## Purpose

This file is for switching between devices or starting a new Codex session without losing project context.

The user works across a home Windows machine and a company Mac. Keep this file and `docs/project_status.md` updated after every completed phase.

## New Device / New Session Checklist

1. Clone or open the GitHub repository:
   - `https://github.com/xingjiacheng175-maker/longcrush-car-demo.git`
2. Open the folder that contains `project.godot`.
3. Before making changes, read:
   - `AGENTS.md`
   - `docs/project_status.md`
   - `docs/design_summary.md`
   - `docs/handoff.md`
4. In Godot 4, run the main scene with `F6`.
5. Verify the current behavior before continuing development.

## Current Controls

- Left click a road piece: select it.
- `R`: rotate selected road piece.
- Left click board: place selected road piece if valid.
- `D`: toggle debug panel.
- `E`: toggle editor mode.
- `Restart Level`: restart current level.
- `Reload Level`: reload current level data.
- `Next Level`: available after victory.

## Current Level Setup

Level order is controlled by:

- `levels/levels.json`

Current entries:

1. `res://levels/level_001.json`
2. `res://levels/level_002.json`
3. `generated`

There are currently 2 hand-authored JSON levels plus 1 generated level entry.

## How To Configure 5 Levels Later

Recommended manual workflow until editor export is improved:

1. Create or copy more JSON files:
   - `levels/level_003.json`
   - `levels/level_004.json`
   - `levels/level_005.json`
2. Update `levels/levels.json`:

```json
{
  "levels": [
    "res://levels/level_001.json",
    "res://levels/level_002.json",
    "res://levels/level_003.json",
    "res://levels/level_004.json",
    "res://levels/level_005.json"
  ]
}
```

3. Run with `F6`.
4. Use `Next Level` after each win to verify the order.

Temporary mixed setup is also allowed:

```json
{
  "levels": [
    "res://levels/level_001.json",
    "res://levels/level_002.json",
    "generated",
    "generated",
    "generated"
  ]
}
```

## Current JSON Level Shape

Example:

```json
{
  "id": "level_001",
  "name": "First Detour",
  "width": 6,
  "height": 6,
  "initial_fuel": 3,
  "start": { "x": 0, "y": 0 },
  "goal": { "x": 5, "y": 5 },
  "cash": [
    { "x": 1, "y": 1, "value": 2 }
  ],
  "blocks": [
    { "x": 2, "y": 0 }
  ]
}
```

## Recommended Next Phase

Recommended next phase: **Level Editor V2**.

Before coding, tell the user:

- Plan:
  - add board size control,
  - add initial fuel control,
  - add cash value control,
  - add validation,
  - improve export workflow,
  - document how to configure 5 levels.
- File modification scope:
  - likely `scripts/Main.gd`,
  - possibly `docs/project_status.md`,
  - possibly `docs/handoff.md`,
  - optional new doc such as `docs/level_authoring.md`.
- Testing method:
  - run F6 in Godot,
  - enter editor with `E`,
  - create/export JSON,
  - paste or save it as a level file,
  - update `levels/levels.json`,
  - verify progression through levels.

Wait for user confirmation before modifying files.

## Important Constraints

- Do not add new functionality during documentation-only requests.
- Do not assume Godot CLI is available.
- Do not commit `.godot/`.
- Do not overwrite user changes without checking.
- Keep the MVP small and playable.
- Keep docs updated after each completed phase.

## Git Notes

Suggested cross-device rhythm:

1. Pull latest changes before starting work.
2. Make one focused phase of changes.
3. Test with Godot F6.
4. Update `docs/project_status.md` and `docs/handoff.md`.
5. Commit and push.

Do not push unless the user asks or confirms.
