# Project Status

Last updated: 2026-05-27

## Current Phase

The Godot 4 prototype is playable and has the core MVP loop, JSON level loading, generated fallback levels, placeholder art, debug tools, and an improved in-game editor.

Current focus is gameplay tuning on top of the playable prototype. The code is still intentionally kept mostly in `scripts/Main.gd`, but project knowledge is now split into module docs and local rules so future work can read less context.

## Latest Completed Phase

Road Piece Preview Clarity.

Files changed in this phase:

- `docs/modules/gameplay.md`
- `docs/development/manual_test_checklist.md`
- `docs/demo_operator_guide.md`
- `docs/demo_operator_guide_zh.md`
- `docs/project_status.md`
- `docs/handoff.md`
- `scripts/Main.gd`

Current completed functionality:

- Replaced side-panel road-piece text previews with real grid previews.
- Each offered shape is drawn from small UI cells instead of `[]` text.
- Selected pieces keep their highlighted panel state and use brighter preview cells.
- Rotation still updates the selected shape preview.
- Road-piece generation, selection, rotation, and placement rules are unchanged.
- Updated gameplay docs, handoff docs, and manual test checklist.

Current run/test method:

- Run `git diff --check`.
- In Godot 4, open `scenes/Main.tscn`, press `F6`, and confirm the three road-piece offers are clear grid previews.
- Select a road piece and confirm the selected preview remains clear and highlighted.
- Press `R` and confirm the selected preview updates after rotation.
- Place a road piece and confirm gameplay behavior is unchanged.

Current known issues:

- Godot CLI is still unavailable in the Codex environment, so gameplay/runtime validation still relies on Godot editor `F6`.

If opening a new Codex session, read:

1. `AGENTS.md`
2. `docs/project_status.md`
3. `docs/design_summary.md`
4. `docs/handoff.md`
5. `docs/modules/README.md`

Then read the relevant module document for the task.

## Repository

- GitHub: `https://github.com/xingjiacheng175-maker/longcrush-car-demo.git`
- Branch used so far: `main`
- Godot project root: repository root, where `project.godot` lives.

## Key Files

- `AGENTS.md`: collaboration rules and new-session instructions.
- `docs/project_status.md`: current progress and next steps.
- `docs/design_summary.md`: gameplay and old demo summary.
- `docs/handoff.md`: cross-device / new-session handoff guide.
- `docs/modules/`: task-specific module docs.
- `docs/development/manual_test_checklist.md`: manual regression checklist.
- `docs/development/refactor_plan.md`: staged code split plan.
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
- Jump-to-level selector and `Load Level` button for direct level loading during playtests.

### Reward / Cash Rule

- Reward cells can be paved over.
- Reward cells are collected when they are paved over and join the powered network, or when they are adjacent to the powered road network.
- A collected reward cell becomes a road cell and can extend the powered network.
- Current prototype still treats reward gain in the fuel/cash loop; exact money-vs-fuel separation is not finalized.

### Obstacles

- Blocks/walls are hard obstacles.
- Road pieces cannot cover blocks.
- Generated levels avoid putting blocks on the hidden generated route.

### Special Tiles

- Portal V1 is implemented.
- The editor supports a `Portal A` brush.
- A valid Portal A setup contains exactly two portal cells.
- When the powered road network reaches one Portal A cell, the paired Portal A cell is treated as connected.
- Roads can then continue from the paired portal side.
- Portal cells are saved to and loaded from JSON through the optional `portals` array.
- Portal cells render with custom placeholder art.
- Roller V1 is implemented.
- The editor supports a `Roller` brush.
- When a road piece covers a roller, the roller turns the surrounding 3x3 area into road.
- Roller paving affects empty cells, cash cells, roads, and other roller cells.
- Roller paving does not overwrite start, goal, blocks, or portals.
- Roller cells are saved to and loaded from JSON through the optional `rollers` array.
- Roller cells render with custom placeholder art.
- Mole V1 is implemented.
- The editor supports a `Mole` brush.
- Road pieces cannot cover mole cells.
- After each successful road placement, moles move to random empty cells.
- Mole movement avoids start, goal, roads, cash, blocks, portals, rollers, and other mole cells.
- Mole cells are saved to and loaded from JSON through the optional `moles` array.
- Mole cells render with custom placeholder art.

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
4. `res://levels/level_004.json`
5. `generated`
6. `generated`

If a listed level JSON has not been created yet, selecting or playing that entry falls back to a generated level until the editor's `New Level` or `Save Level` workflow writes the file.

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
- `portal.png`
- `roller.png`
- `mole.png`

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
  - portal count,
  - roller count,
  - mole count,
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
  - Portal A
  - Roller
  - Mole
- Click board cells to paint.
- Start and goal are unique; placing one clears the previous one.
- Cash default value is currently `2`, and newly painted cash uses the current cash brush value.
- Painting resets temporary play state such as roads, powered flags, and collected rewards.
- Resizing the board preserves in-bounds cash and block cells, clamps start/goal back into the board, and clears temporary play state.
- JSON level loading and export support independent `width` and `height` values.
- JSON level loading and export support optional `portals` data.
- JSON level loading and export support optional `rollers` data.
- JSON level loading and export support optional `moles` data.
- Selecting a level in the editor loads that level entry.
- `New Level` creates the next missing `res://levels/level_%03d.json` file and adds it to `levels/levels.json` before generated entries.
- `Save Level` writes the current edited board back to the current JSON level file and updates `levels/levels.json`.
- Editor validation checks:
  - exactly one start,
  - exactly one goal,
  - start and goal inside the board,
  - start/goal not overlapping cash, blocks, portals, rollers, or moles,
  - Portal A must have exactly two cells, or none.
- `Copy JSON` copies the current board JSON to the clipboard.
- `Copy levels.json Entry` copies the suggested quoted `res://levels/level_%03d.json` entry for the current level.
- Press `E` again to return to play mode and test the edited board.

## Known Limitations

- Editor has no undo/redo.
- Editor saves are intended for development in the Godot editor; exported builds should not depend on writing to `res://`.
- Editor can update `levels/levels.json` when saving/new-leveling, but does not yet provide a full list editor for reordering or deleting entries.
- Hand-authored JSON files currently exist through `level_004.json`.
- No formal solver that simulates every possible road-piece sequence.
- No saved random seed or replay.
- Special tiles currently only include one portal pair (`Portal A`).
- Portal V1 does not yet support multiple named portal pairs.
- Roller V1 does not chain-activate other rollers that are only affected by the 3x3 paving area.
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
- Portal A links two board cells; connecting one portal to the powered road network also powers the paired portal.
- Roller turns nearby editable cells into road when paved over.
- Mole blocks road placement and moves to a random empty cell after each successful road placement.
- Generated levels may remain until the core gameplay and editor flow are stable.
- Collaboration docs should be kept in GitHub for switching between home Windows and company Mac.

## Open Questions

- Should money and fuel become separate resources?
- Should the player earn cash only for score while fuel remains a separate constraint?
- Should generated levels eventually use a real solver?
- Should editor exports save directly to project files, or stay clipboard-based for safety?
- Should level order be edited in-game, or manually through `levels/levels.json`?
- Should portals eventually support multiple pairs such as Portal A/B/C?
- Should rollers chain-activate other rollers inside their 3x3 effect, or remain single-trigger only?
- Should final art continue using the current placeholder set, or move toward a unified production style?
- When should `scripts/Main.gd` be split into smaller files?

## Recommended Next Development Phase

The most practical next phase is **level authoring with the three special tiles**.

Suggested scope:

- Use Portal A, Roller, and Mole to create a few authored test levels.
- Tune fuel values and cash placement around these special tiles.
- Decide whether roller chain activation or multiple portal pairs are needed after playtesting.

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
10. Paint two `Portal A` cells, confirm validation says `OK`, and test that the powered route can continue from the paired portal.
11. Paint a `Roller`, cover it with a road piece, and confirm the surrounding 3x3 editable cells become road.
12. Confirm roller paving does not overwrite start, goal, blocks, or portals.
13. Paint one or more `Mole` cells, confirm road pieces cannot cover them, then place a valid road piece and confirm moles move to empty cells.
14. Paint a small edit, confirm validation says `OK`, and click `Save Level`.
15. Stop running and inspect the corresponding JSON file to confirm it changed.
16. Use `New Level` and confirm the new JSON file appears under `levels/` and `levels/levels.json` includes it.

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
