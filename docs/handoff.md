# Handoff

Last updated: 2026-05-13

## Purpose

This file is for switching between devices or starting a new Codex session without losing project context.

The user works across a home Windows machine and a company Mac. Keep this file and `docs/project_status.md` updated after every completed phase.

## Latest Completed Phase

Victory Panel V1.

Files changed in this phase:

- `docs/modules/gameplay.md`
- `docs/development/manual_test_checklist.md`
- `docs/demo_operator_guide.md`
- `docs/demo_operator_guide_zh.md`
- `docs/project_status.md`
- `docs/handoff.md`
- `scripts/Main.gd`

What works now:

- A victory panel appears when the player connects to the goal.
- The panel shows road cell count, level cash, and total cash.
- The panel has `Next Level`, `Restart`, and `Close` buttons.
- The side-panel `Next Level` button remains as a fallback control.
- Restarting or loading the next level hides the victory panel.
- Gameplay docs, operator guides, and manual test checklist now describe the victory panel.

How to test:

- Run `git diff --check`.
- In Godot 4, open `scenes/Main.tscn`, press `F6`, complete a level, and confirm the victory panel appears.
- Confirm the panel values match road count, level cash, and total cash.
- Confirm `Close`, `Restart`, and `Next Level` work from the panel.

Known issues:

- Godot CLI is not assumed to be available; use editor `F6` for final runtime testing.

Recommended next step:

- Playtest the victory panel and then decide whether to add a matching failure panel.

## New Device / New Session Checklist

1. Clone or open the GitHub repository:
   - `https://github.com/xingjiacheng175-maker/longcrush-car-demo.git`
2. Open the folder that contains `project.godot`.
3. Before making changes, read:
   - `AGENTS.md`
   - `docs/project_status.md`
   - `docs/design_summary.md`
   - `docs/handoff.md`
   - `docs/modules/README.md`
4. Read the module doc relevant to the task.
5. In Godot 4, run the main scene with `F6` when the task affects runtime behavior.

## Current Controls

- The default run window is 1440x960, and the main UI is scaled up for playtesting readability.
- Left click a road piece: select it.
- `R`: rotate selected road piece.
- Left click board: place selected road piece if valid.
- `D`: toggle debug panel.
- `E`: toggle editor mode.
- In editor mode, adjust board width, board height, initial fuel, and current cash value from the editor panel.
- In editor mode, use the level selector to load configured level entries.
- In editor mode, use `New Level` to create the next missing JSON level file.
- In editor mode, use `Save Level` to write the current edit back to the current JSON level file.
- In editor mode, use `Portal A` to paint exactly two linked portal cells.
- In editor mode, use `Roller` to paint any number of roller cells.
- In editor mode, use `Mole` to paint any number of moving blocker cells.
- `Restart Level`: restart current level.
- `Reload Level`: reload current level data.
- `Jump To Level` selector + `Load Level`: directly load a configured level entry.
- `Next Level`: available after victory.

## Current Gameplay Notes

- Cash/fuel rewards are collected when paved over or when adjacent to the powered road network.
- Collected reward cells become road cells and can extend the powered network.
- On victory, each score-counted road cell gives `10` cash.
- The start tile, normal road tiles, paved cash tiles, and paved portal tiles count for victory cash.
- The goal tile does not count for victory cash.
- During play, the top HUD previews the current completion cash as `Win +$N`.
- Connecting to the goal opens a victory panel with road count, level cash, total cash, and action buttons.
- Portal A cells are linked. When the powered road network reaches one Portal A cell, the paired Portal A cell also becomes powered.
- Roller cells trigger when paved over, turning the surrounding 3x3 editable area into road.
- Roller paving does not overwrite start, goal, blocks, or portals.
- Mole cells block road placement and move to random empty cells after successful road placement.
- Road-piece offers draw from small connector pieces plus the seven tetromino families.
- A single offer avoids duplicate shapes that are equivalent by rotation.

## Current Level Setup

Level order is controlled by:

- `levels/levels.json`

Current entries:

1. `res://levels/level_001.json`
2. `res://levels/level_002.json`
3. `res://levels/level_003.json`
4. `res://levels/level_004.json`
5. `generated`
6. `generated`

Hand-authored JSON files currently exist through `level_004.json`. Missing JSON entries fall back to generated content until saved.

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
  ],
  "portals": [
    { "x": 1, "y": 4, "pair": "A" },
    { "x": 4, "y": 1, "pair": "A" }
  ],
  "rollers": [
    { "x": 3, "y": 3 }
  ],
  "moles": [
    { "x": 2, "y": 4 }
  ]
}
```

## Current Editor Notes

- Level selector is populated from `levels/levels.json`.
- `New Level` creates the next missing `res://levels/level_%03d.json` and updates `levels/levels.json`.
- `Save Level` writes the current board JSON to the current level path and updates `levels/levels.json`.
- Board width can be changed from 4 to 14.
- Board height can be changed from 4 to 12.
- Initial fuel can be changed from 1 to 20.
- Current cash brush value can be changed from 1 to 9.
- The `Portal A` brush paints linked portal cells. Use exactly two Portal A cells, or no portals.
- The `Roller` brush paints any number of roller cells.
- The `Mole` brush paints any number of moving blocker cells.
- Resizing preserves in-bounds cash and blocks, clamps start/goal inside the board, and resets temporary play state.
- JSON level loading and export support independent `width` and `height` values.
- JSON level loading and export support optional `portals` data.
- JSON level loading and export support optional `rollers` data.
- JSON level loading and export support optional `moles` data.
- Validation is shown in the editor panel before export.
- `Copy JSON` copies the current board JSON if validation passes.
- `Copy levels.json Entry` copies the suggested quoted level path for `levels/levels.json`.
- Saves are intended for development inside the Godot editor. Exported builds should not rely on writing to `res://levels/`.
- The editor does not yet support deleting or reordering level entries.

## Recommended Next Phase

Recommended next phase: **level authoring with the three special tiles**.

Before coding, tell the user:

- Plan:
  - create authored test levels using Portal A, Roller, and Mole,
  - tune fuel and cash placement,
  - identify whether roller chaining or multiple portal pairs are needed.
- File modification scope:
  - likely `levels/*.json`,
  - possibly `docs/project_status.md`,
  - possibly `docs/handoff.md`.
- Testing method:
  - run F6 in Godot,
  - enter editor with `E`,
  - create or edit a test level,
  - save and reload it,
  - verify the special-tile interactions during play.

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
