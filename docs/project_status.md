# Project Status

Last updated: 2026-04-25

## Current Phase

The Godot 4 prototype is playable and has the core MVP loop, JSON level loading, generated fallback levels, placeholder art, debug tools, and a basic in-game editor.

Current focus is paused for cross-device handoff. No new gameplay feature is being developed in this documentation phase.

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
- Unpaved reward cells are not collected by adjacent roads.
- Paved reward cells are collected only after joining the powered network.
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
3. `generated`

### Auto Generation

Current generated levels include:

- Level configs with increasing grid size, cash count, and wall count.
- A hidden generated route from start to goal.
- Blocks prevented from spawning on the hidden route.
- Cash preferentially placed along the hidden route.
- Road-piece offers that always include:
  - one horizontal 2-cell piece,
  - one vertical 2-cell piece,
  - one random piece.

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
- Supported brushes:
  - Ground
  - Cash
  - Block
  - Start
  - Goal
- Click board cells to paint.
- Start and goal are unique; placing one clears the previous one.
- Cash default value is currently `2`.
- Painting resets temporary play state such as roads, powered flags, and collected rewards.
- `Copy JSON` copies the current board JSON to the clipboard.
- Press `E` again to return to play mode and test the edited board.

## Known Limitations

- Editor cannot directly save files into `res://levels/`.
- Editor does not yet support board size changes.
- Editor does not yet support initial fuel editing.
- Editor does not yet support custom cash values.
- Editor has no undo/redo.
- No direct UI for editing `levels/levels.json`.
- Only 2 hand-authored JSON levels are currently present; the third entry is generated.
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
- Cash/reward must be paved over to collect.
- Unpaved cash is not collected by adjacent road.
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

The most practical next phase is **Level Editor V2**.

Suggested scope:

- Add editor controls for board size.
- Add editor control for initial fuel.
- Add editor control for cash value.
- Add simple validation:
  - exactly one start,
  - exactly one goal,
  - start and goal inside board,
  - blocks/cash do not overlap start or goal.
- Add export assistance:
  - continue supporting `Copy JSON`,
  - optionally save exported JSON to `user://exported_levels/`,
  - add a `Copy levels.json entry` or similar helper.
- Document how to configure 5 levels from the current 3-level setup.

Alternative next phases:

- Add more JSON levels manually.
- Add a lightweight solvability check.
- Improve placeholder UI polish.

## How To Test Current Build

Manual Godot editor test:

1. Open the project folder containing `project.godot`.
2. Run the main scene with `F6`.
3. Verify level 1 loads from JSON.
4. Place road pieces until the goal is connected.
5. Confirm the next level button advances to level 2.
6. Confirm level 3 is generated.
7. Press `D` and verify debug info scrolls.
8. Press `E`, paint a small edit, use `Copy JSON`, then return to play mode.

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
