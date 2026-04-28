# Project Status

Last updated: 2026-04-28

## Current Phase

The Godot 4 prototype is playable and has the core MVP loop, JSON level loading, generated fallback levels, placeholder art, debug tools, and an improved in-game editor.

Current focus is Level Editor V3 validation and handoff. The editor now supports rectangular board dimensions, level selection, new level creation, and saving edited JSON level files from the editor while running in Godot.

## Repository

- GitHub: `https://github.com/xingjiacheng175-maker/longcrush-car-demo.git`
- Branch used so far: `main`
- Godot project root: repository root, where `project.godot` lives.

## Key Files

- `AGENTS.md`: collaboration rules and new-session instructions.
- `docs/project_status.md`: current progress and next steps.
- `docs/design_summary.md`: gameplay and old demo summary.
- `docs/handoff.md`: cross-device / new-session handoff guide.
- `project.godot`: Godot project config.
- `scenes/Main.tscn`: main scene.
- `scripts/Main.gd`: current prototype implementation.
- `levels/levels.json`: ordered level list.
- `levels/level_001.json`: first hand-authored JSON level.
- `levels/level_002.json`: second hand-authored JSON level.
- `assets/placeholders/`: generated placeholder art assets.

## Implemented Features

### Core Gameplay

- Main Godot scene.
- Programmatic UI.
- Default run window is configured to 1440x960.
- Main gameplay UI uses a 1.5x scale for board cells, side panel, piece buttons, spacing, and HUD text.
- Grid board.
- Taxi/start tile.
- Goal tile.
- Road-piece selection.
- Shape rotation with `R`.
- Hover preview:
  - Yellow = valid placement.
  - Red = invalid placement.
- Road placement from the powered/connected road network.
- Fuel cost: `1` fuel per placement.
- Initial fuel: currently `3`.
- Win condition: connect to goal.
- Loss condition: fuel reaches `0` before connecting to goal.
- Restart level.
- Next level after winning.

### Reward / Cash Rule

- Reward cells can be paved over.
- Reward cells are collected when they are paved over and join the powered network, or when they are adjacent to the powered road network.
- A collected reward cell becomes a road cell and can extend the powered network.
- Current prototype still treats reward gain in the fuel/cash loop; exact money-vs-fuel separation is not finalized.

### Obstacles

- Blocks/walls are hard obstacles.
- Road pieces cannot cover blocks.
- Generated levels avoid putting blocks on the hidden generated route.

### Level Loading

- JSON level loading is implemented.
- Ordered level sequence is controlled by `levels/levels.json`.
- `levels.json` entries can be:
  - A JSON path, for example `res://levels/level_001.json`.
  - The string `"generated"`.
- If `levels.json` is missing, the game falls back to numeric lookup with `res://levels/level_%03d.json`.
- If a JSON level is missing or invalid, the game falls back to a generated level.

Current configured level order:

1. `res://levels/level_001.json`
2. `res://levels/level_002.json`
3. `res://levels/level_003.json`
4. `generated`
5. `generated`

If `level_003.json` has not been created yet, selecting or playing that entry falls back to a generated level until the editor's `New Level` or `Save Level` workflow writes the file.

### Auto Generation

Current generated levels include:

- Level configs with increasing grid size, cash count, and wall count.
- A hidden generated route from start to goal.
- Blocks prevented from spawning on the hidden route.
- Cash preferentially placed along the hidden route.
- Road-piece offers choose from a larger non-duplicate shape pool:
  - small 2-cell and 3-cell pieces,
  - the seven tetromino families,
  - no same-offer duplicates that are equivalent by rotation.

This gives generated levels a structural solution path, although it is not a full formal solver.

### Placeholder Art Assets

Stylized top-down placeholder assets were generated and added under `assets/placeholders/`:

- `traffic_tiles_sheet.png`
- `ground.png`
- `road.png`
- `road_powered.png`
- `taxi_start.png`
- `goal.png`
- `cash.png`
- `cash_road.png`
- `cash_collected.png`
- `block.png`

Road-related placeholder art was simplified into direction-neutral asphalt blocks so the prototype does not need separate straight/corner road art yet.

### Debug Tools

- Press `D` to show or hide debug information.
- Right panel uses scrolling so debug text remains reachable.
- `Reload Level` button reloads the current level.
- Debug panel shows:
  - level source,
  - level path or generated marker,
  - grid size,
  - start and goal coordinates,
  - current fuel and initial fuel,
  - status,
  - selected road piece id,
  - cash collected / total cash,
  - block count,
  - powered cell count,
  - generated hidden route cell count.
- Debug board overlays:
  - Blue border = powered/connected cell.
  - Purple border = generated hidden route cell.

### Basic Level Editor

- Press `E` to enter or exit editor mode.
- Editor panel is shown in the right-side scroll area.
- Editor has a `Level Files` section with:
  - a level selector populated from `levels/levels.json`,
  - current level path display,
  - `New Level`,
  - `Save Level`.
- Editor supports board width changes from 4 to 14.
- Editor supports board height changes from 4 to 12.
- Editor supports initial fuel changes from 1 to 20.
- Editor supports a current cash brush value from 1 to 9.
- Supported brushes:
  - Ground
  - Cash
  - Block
  - Start
  - Goal
- Click board cells to paint.
- Start and goal are unique; placing one clears the previous one.
- Cash default value is currently `2`, and newly painted cash uses the current cash brush value.
- Painting resets temporary play state such as roads, powered flags, and collected rewards.
- Resizing the board preserves in-bounds cash and block cells, clamps start/goal back into the board, and clears temporary play state.
- JSON level loading and export support independent `width` and `height` values.
- Selecting a level in the editor loads that level entry.
- `New Level` creates the next missing `res://levels/level_%03d.json` file and adds it to `levels/levels.json` before generated entries.
- `Save Level` writes the current edited board back to the current JSON level file and updates `levels/levels.json`.
- Editor validation checks:
  - exactly one start,
  - exactly one goal,
  - start and goal inside the board,
  - start/goal not overlapping cash or blocks.
- `Copy JSON` copies the current board JSON to the clipboard.
- `Copy levels.json Entry` copies the suggested quoted `res://levels/level_%03d.json` entry for the current level.
- Press `E` again to return to play mode and test the edited board.

## Known Limitations

- Editor has no undo/redo.
- Editor saves are intended for development in the Godot editor; exported builds should not depend on writing to `res://`.
- Editor can update `levels/levels.json` when saving/new-leveling, but does not yet provide a full list editor for reordering or deleting entries.
- Only 2 hand-authored JSON level files are currently present unless `New Level` has been used to create `level_003.json`.
- No formal solver that simulates every possible road-piece sequence.
- No saved random seed or replay.
- Placeholder art is good enough for a demo but not final art.
- Cash value is mostly conveyed through tooltip/logic rather than polished UI.
- Godot CLI was not available in the Codex environment, so runtime validation has relied on user F6 testing in the Godot editor.
- Implementation is mostly concentrated in `scripts/Main.gd`; acceptable for MVP, but may need splitting later.

## Current User-Confirmed Rules

- Use Godot 4 and GDScript.
- Prefer JSON for levels.
- Use placeholder visuals for now.
- Initial fuel: `3`.
- Road-piece placement cost: `1` fuel.
- Victory: connect to goal.
- Cash/reward can be collected by paving over it or by touching it with the powered road network.
- Collected cash/reward becomes road.
- Walls/blocks are the primary path restriction.
- Generated levels may remain until the core gameplay and editor flow are stable.
- Collaboration docs should be kept in GitHub for switching between home Windows and company Mac.

## Open Questions

- Should money and fuel become separate resources?
- Should the player earn cash only for score while fuel remains a separate constraint?
- Should generated levels eventually use a real solver?
- Should editor exports save directly to project files, or stay clipboard-based for safety?
- Should level order be edited in-game, or manually through `levels/levels.json`?
- When should `scripts/Main.gd` be split into smaller files?

## Recommended Next Development Phase

The most practical next phase is **level authoring and editor workflow hardening**.

Suggested scope:

- Use the editor to create and tune `level_003.json`, `level_004.json`, and `level_005.json`.
- Add `Save As` if overwriting current levels feels risky.
- Add level delete/reorder controls if needed.
- Add a lightweight solvability check.

Alternative next phases:

- Improve placeholder UI polish.
- Split `scripts/Main.gd` after the level workflow is stable.

## How To Test Current Build

Manual Godot editor test:

1. Open the project folder containing `project.godot`.
2. Run the main scene with `F6`.
3. Verify level 1 loads from JSON.
4. Place road pieces until the goal is connected.
5. Confirm the next level button advances to level 2.
6. Confirm missing JSON level entries fall back to generated content.
7. Press `D` and verify debug info scrolls.
8. Press `E`, use the level selector to switch between configured levels.
9. Change width, height, initial fuel, and cash value.
10. Paint a small edit, confirm validation says `OK`, and click `Save Level`.
11. Stop running and inspect the corresponding JSON file to confirm it changed.
12. Use `New Level` and confirm the new JSON file appears under `levels/` and `levels/levels.json` includes it.

## Phase Completion Rule

After every future completed phase, update:

- `docs/project_status.md`
- `docs/handoff.md`

Each update should include:

- Files changed.
- Current working features.
- Known issues.
- Test method.
- Recommended next step.
