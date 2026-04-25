# Project Status

Last updated: 2026-04-25

## Current Phase

Godot 4 minimal runnable demo is in progress and playable enough for rule testing.

Current focus: JSON level loading has been added and needs F6 runtime verification.

## Key Files

- `AGENTS.md`: project collaboration rules and session-start instructions.
- `docs/design_summary.md`: gameplay and old demo summary.
- `docs/project_status.md`: current progress and next steps.
- `gamedesign.pdf`: original design document.
- `old_demo_code/`: previous React/Vite demo.
- `new-game-project/project.godot`: Godot project config.
- `new-game-project/scenes/Main.tscn`: main scene.
- `new-game-project/scripts/Main.gd`: current prototype implementation.
- `new-game-project/assets/placeholders/`: generated placeholder art assets.

## Completed So Far

### Analysis

- Read `gamedesign.pdf`.
- Read and analyzed `old_demo_code`.
- Confirmed the core game is a grid-based taxi/path-building puzzle.
- Confirmed Godot 4 + GDScript as the target implementation.
- Confirmed JSON should be preferred for level data in later phases.

### Godot MVP

Implemented in `new-game-project`.

Current features:

- Main Godot scene.
- Programmatic UI.
- Grid board.
- Taxi/start tile.
- Goal tile.
- Road-piece selection.
- Shape rotation with `R`.
- Road placement from powered/connected road.
- Fuel cost: 1 fuel per placement.
- Initial fuel: 3.
- Cash/fuel cells.
- Cash must be paved over to be collected.
- Cash collection when paved cash joins the powered network.
- Win condition: connect to goal.
- Loss condition: fuel reaches 0 before connecting to goal.
- Restart level.
- Next level after winning.
- Automatic level generation.
- JSON level loading for fixed levels.
- Ordered level list loading through `levels/levels.json`.
- Auto-generation fallback when a JSON level file is missing or invalid.
- Basic debug panel toggled with `D`.
- Reload current level button.
- Basic in-game level editor toggled with `E`.
- Blocks/walls as hard obstacles.
- Blocks cannot be paved over.
- Hover preview:
  - Yellow = valid placement.
  - Red = invalid placement.
- Short grid labels to avoid layout jitter:
  - `T` = taxi/start.
  - `G` = goal.
  - `$N` = unpaved cash/fuel.
  - `R` = road.
  - `R $N` = paved cash not yet collected.
  - `R OK` = paved cash collected.
  - `X` = block/wall.

### Auto Generation

Current automatic generation includes:

- Level configs with increasing grid size, cash count, and wall count.
- A hidden generated route from start to goal.
- Blocks are prevented from spawning on the hidden route.
- Cash is preferentially placed along the hidden route.
- Each road-piece offer includes:
  - a horizontal 2-cell piece,
  - a vertical 2-cell piece,
  - one random piece.

This is intended to make each generated level structurally solvable with basic straight pieces, although it is not yet a full formal solver.

### JSON Level Loading

Added the first hand-authored level file:

- `new-game-project/levels/level_001.json`
- `new-game-project/levels/level_002.json`
- `new-game-project/levels/levels.json`

Current JSON fields:

- `id`
- `name`
- `width`
- `height`
- `initial_fuel`
- `start`: `{ "x": number, "y": number }`
- `goal`: `{ "x": number, "y": number }`
- `cash`: array of `{ "x": number, "y": number, "value": number }`
- `blocks`: array of `{ "x": number, "y": number }`

`Main.gd` now attempts to load `res://levels/level_%03d.json` for the current level. If the file does not exist or is invalid, it falls back to the existing automatic generator.

`levels.json` now defines the level order. Entries can be JSON paths or the string `"generated"`.

Current list:

1. `res://levels/level_001.json`
2. `res://levels/level_002.json`
3. `generated`

If `levels.json` is missing, the game falls back to numeric lookup with `res://levels/level_%03d.json`.

Only square levels are supported for now because the current board code uses one `grid_size`.

### Debug Tools

Added a lightweight debug panel in `Main.gd`.

The right-side control panel is wrapped in a vertical `ScrollContainer`, so debug information remains reachable on smaller windows.

Controls:

- Press `D` to show or hide the debug panel.
- Click `Reload Level` to reload the current level.

Debug panel currently shows:

- Level source: `json` or `generated`.
- Level path or `auto-generated`.
- Grid size.
- Start and goal coordinates.
- Current fuel and initial fuel.
- Current status.
- Selected road piece id.
- Cash collected / total cash.
- Block count.
- Powered cell count.
- Generated hidden route cell count.

Debug board overlays:

- Blue border: powered/connected cell.
- Purple border: generated hidden route cell.

For JSON levels, hidden route cells are empty because the hidden route is only generated for auto-generated levels.

### Basic Level Editor

Added a lightweight in-game editor in `Main.gd`.

Controls:

- Press `E` to enter or exit editor mode.
- Pick a brush in the right-side editor panel.
- Click cells on the board to paint.
- Press `E` again to return to play mode and test the edited board.

Supported brushes:

- Ground
- Cash
- Block
- Start
- Goal

Editor behavior:

- Start and goal are unique. Placing a new one clears the previous one.
- Start and goal cannot overlap.
- Cash uses default value `2`.
- Painting resets temporary play state such as paved roads, powered flags, and collected cash.
- The editor panel displays the current board as JSON.
- `Copy JSON` copies the current board JSON to the system clipboard.

Limitations:

- The editor does not save directly to `res://levels/*.json`.
- Board size and initial fuel are not editable in UI yet.
- Cash value is fixed at `2` in the editor UI.
- No undo/redo.

### Placeholder Art Assets

Generated and added a stylized top-down asset set inspired by bright European casual traffic puzzle games.

Files added under `new-game-project/assets/placeholders/`:

- `traffic_tiles_sheet.png`: original generated 3x3 sprite sheet.
- `ground.png`: grass/ground tile.
- `road.png`: asphalt road tile.
- `road_powered.png`: powered/glowing road tile.
- `taxi_start.png`: yellow taxi start tile.
- `goal.png`: destination marker tile.
- `cash.png`: unpaved cash/fuel reward tile.
- `cash_road.png`: paved cash road tile.
- `cash_collected.png`: collected cash road tile.
- `block.png`: construction barrier/block tile.

`Main.gd` now loads these PNGs and uses them as button icons for board cells. Grid text labels are no longer the main visual; cell details remain available through tooltips.

Road-related placeholder art was simplified after testing:

- `road.png` is now a direction-neutral asphalt square.
- `road_powered.png` is now a direction-neutral glowing asphalt square.
- `cash_road.png` is now a direction-neutral asphalt square with a coin.
- `cash_collected.png` is now a direction-neutral glowing asphalt square with a coin and check mark.
- Hover preview hides cell icons temporarily and shows yellow/red color blocks so the placement area remains readable.

## Known Limitations

- Level editor exists, but it is MVP-only and does not write files directly.
- Debug tools are basic and may need more controls later.
- No saved random seed or replay.
- No formal solver that simulates every road-piece sequence.
- UI is still placeholder-only.
- Placeholder images are AI-generated and may need later cleanup, resizing, or replacement with final art.
- Cash value is currently shown in tooltip rather than directly over the tile art.
- Godot CLI was not available in the current Codex environment, so runtime validation depends on user F6 testing in the Godot editor.
- Current implementation is mostly concentrated in `Main.gd`; this is acceptable for the MVP but should be split once JSON and editor work begins.

## Current User-Confirmed Rules

- Use Godot 4 and GDScript.
- Use placeholder visuals for now.
- Initial fuel: 3.
- Road-piece placement cost: 1 fuel.
- Victory: connect to goal.
- Cash must be paved over to collect.
- Unpaved cash is not collected by adjacent road.
- Walls/blocks are the primary path restriction.
- Level editor is a later feature.
- Automatic generation can remain until the core gameplay loop is stable.

## Pending Confirmation / Open Questions

- Whether score should represent money only, fuel only, or both.
- Whether fuel and money should become separate resources.
- Whether the hidden generated route should be visible in debug mode later.
- Whether level progression should use a hand-authored level list or continue numeric JSON lookup.
- Whether route solvability should eventually be verified by a real solver.
- Whether the visual theme should remain symbolic for a while or move toward taxi/city placeholder art next.

## Recommended Next Steps

Before continuing development in a new session:

1. Read `AGENTS.md`.
2. Read `docs/design_summary.md`.
3. Read this file.
4. Ask the user what to do next.

Possible next development phases:

1. Verify the latest F6 runtime behavior and fix any Godot errors.
2. Add more JSON levels and configure them in `levels/levels.json`.
3. Improve the editor with board size, initial fuel, cash value controls, and direct save/export workflow.
4. Add a fuller debug/validation tool for solvability checks.

## Phase Completion Rule

After every future phase, update this file with:

- Files changed.
- Current working features.
- Known issues.
- Test method.
- Recommended next step.
