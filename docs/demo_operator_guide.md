# Demo Operator Guide

Last updated: 2026-05-13

This guide is for designers opening the Godot demo to playtest or edit levels.

## Open And Run

1. Open Godot 4.
2. Import or open this project folder, the folder that contains `project.godot`.
3. Open the main scene:
   - `scenes/Main.tscn`
4. Press `F6` to run the current scene.

If Godot asks which scene to run, choose `scenes/Main.tscn`.

## What To Look At First

Main files:

- `scenes/Main.tscn`: playable demo scene.
- `scripts/Main.gd`: current gameplay and editor logic.
- `levels/levels.json`: level order.
- `levels/level_001.json`, `levels/level_002.json`, etc.: authored level data.
- `docs/project_status.md`: current project status.
- `docs/handoff.md`: cross-device handoff notes.

In the running demo:

- Left side: board.
- Right side: road pieces, control buttons, debug/editor panels.
- Top HUD: level, fuel, cash score, status.
- During play, the cash HUD also shows `Win +$N`, the cash that would be earned if the level ended now.

## Playtest Controls

- Left click a road piece: select it.
- `R`: rotate selected road piece.
- Left click board: place selected road piece.
- `Restart Level`: restart the current level from its loaded data.
- `Reload Level`: reload the current level file or generated fallback.
- `Jump To Level` selector + `Load Level`: directly load a configured level.
- `Next Level`: appears after winning.
- `D`: show or hide debug info.
- `E`: enter or exit editor mode.

## Gameplay Rules

- The taxi starts from the start tile.
- The goal is the destination tile.
- Place road pieces to connect the taxi road network to the goal.
- Each road placement costs `1` fuel.
- If fuel reaches `0` before connecting the goal, the level is lost.
- On victory, every road cell on the board adds `$10` cash.
- Start and placed road cells count for victory cash; the goal tile does not.
- The top HUD updates `Win +$N` after each successful road placement.
- A victory panel appears after connecting to the goal.
- The victory panel shows road cells, level cash, total cash, and `Next Level` / `Restart` / `Close` buttons.
- Cash cells are collected when road is placed onto them or when they touch the powered road network.
- Collected cash cells become road and can extend the connected road network.
- Blocks are obstacles and cannot be covered by road.
- Portal A is the current linked portal pair.
- A level can contain either no portals or exactly two Portal A cells.
- When the powered road network reaches one Portal A cell, the paired Portal A cell also becomes powered.
- Roller cells trigger when paved over.
- A triggered roller turns the surrounding 3x3 editable area into road.
- Roller paving does not overwrite start, goal, blocks, or portals.
- Mole cells block road placement.
- After each successful road placement, moles move to random empty cells.
- A road piece must connect to the powered road network to be placed.

Hover preview:

- Yellow preview: valid placement.
- Red preview: invalid placement.

## Debug Mode

Press `D` while running.

The debug panel shows:

- level source,
- level entry/path,
- board size,
- start and goal coordinates,
- fuel,
- selected road piece,
- cash count,
- block count,
- portal count,
- roller count,
- mole count,
- powered cell count,
- generated route cell count.

Board overlays:

- Blue border: powered/connected cell.
- Purple border: generated hidden route cell.

## Enter The Level Editor

1. Run the scene with `F6`.
2. Press `E`.
3. The editor panel appears on the right.

Press `E` again to return to play mode and test the edited board.

## Switch Levels

In editor mode, use the `Level Files` dropdown.

The dropdown is populated from:

```text
levels/levels.json
```

Selecting an entry loads that level.

If a listed JSON file does not exist yet, the game falls back to generated content until the level is created or saved.

## Create A New Level

1. Press `E` to enter editor mode.
2. Click `New Level`.
3. The editor creates the next missing file, for example:

```text
levels/level_003.json
```

4. The editor also updates:

```text
levels/levels.json
```

New levels start as a simple blank board with:

- start at top-left,
- goal at bottom-right,
- current width/height settings,
- current initial fuel.

## Edit Board Settings

In editor mode, use:

- `Width`: board width, currently `4` to `14`.
- `Height`: board height, currently `4` to `12`.
- `Initial fuel`: starting fuel, currently `1` to `20`.
- `Cash value`: value used when painting new cash cells, currently `1` to `9`.

Changing width or height keeps in-bounds cash and blocks, clamps start/goal back into the board, and clears temporary playtest road state.

## Paint The Board

Brushes:

- `Ground`: clears a normal editable cell.
- `Cash`: paints a cash cell using the current `Cash value`.
- `Block`: paints an obstacle.
- `Start`: moves the unique taxi start.
- `Goal`: moves the unique destination.
- `Portal A`: paints a linked portal cell.
- `Roller`: paints a roller cell.
- `Mole`: paints a moving blocker cell.

Click board cells to paint.

Notes:

- Start and goal are unique.
- Painting a new start removes the old start.
- Painting a new goal removes the old goal.
- Cash and blocks cannot overlap start or goal.
- Portals cannot overlap start or goal.
- Rollers cannot overlap start or goal.
- Moles cannot overlap start or goal.
- Portal A must have exactly two cells to be valid.

## Validation

The editor panel shows validation status.

Before saving, make sure it says:

```text
Validation: OK
```

Common validation problems:

- missing start,
- missing goal,
- start and goal overlap,
- start or goal is outside the board,
- start/goal overlaps cash, blocks, portals, rollers, or moles,
- Portal A has only one cell or more than two cells.

## Save A Level

1. Enter editor mode with `E`.
2. Select or create the level.
3. Edit the board.
4. Confirm validation says `OK`.
5. Click `Save Level`.
6. Stop the running scene.
7. Open the JSON file under `levels/` and confirm it changed.

`Save Level` writes the edited board directly to the current JSON level file.

This workflow is for development in the Godot editor. Exported builds should not rely on writing to `res://levels/`.

## Backup Export Buttons

`Copy JSON`:

- Copies the current board JSON to the clipboard.
- Use this if direct save fails or if you want to paste the level manually.

`Copy levels.json Entry`:

- Copies a quoted level path such as:

```json
"res://levels/level_003.json"
```

- Use this when manually editing `levels/levels.json`.

## Level Order

Level order is controlled by:

```text
levels/levels.json
```

Example:

```json
{
	"levels": [
		"res://levels/level_001.json",
		"res://levels/level_002.json",
		"res://levels/level_003.json",
		"generated",
		"generated"
	]
}
```

`generated` means the game creates a fallback generated level at runtime.

For team work, let one person maintain final level order.

## Recommended Level Authoring Flow

1. Create or choose a level.
2. Set width, height, and initial fuel.
3. Place start and goal.
4. Add blocks to shape the route.
5. Add cash to reward detours.
6. Add two Portal A cells only when the level needs a teleport connection.
7. Add rollers when the level needs a 3x3 road expansion trigger.
8. Add moles when the level needs a moving blocker.
9. Save the level.
10. Exit editor mode with `E`.
11. Playtest the level.
12. Adjust fuel, blocks, cash, portals, rollers, and moles.
13. Save again.

Playtest goals:

- The level can be completed.
- The player has a reason to detour for cash.
- The route is understandable.
- The first few levels stay simple.

## GitHub Desktop Workflow

Before editing:

1. Open GitHub Desktop.
2. Select repository `longcrush-car-demo`.
3. Click `Fetch origin`.
4. Click `Pull origin` if available.
5. Create a new branch for the work.

Branch name examples:

```text
level/level-004
level/tune-level-002
feature/solver-check
```

After editing:

1. Check changed files in GitHub Desktop.
2. Write a short summary:

```text
Add level 004
Tune level 002
```

3. Commit to the current branch.
4. Push origin.
5. Create a Pull Request.

## Team Rules

- Do not edit directly on `main` for team work.
- Each designer should edit their own level file when possible.
- Avoid two people editing the same `level_00x.json` at the same time.
- Let one person maintain final `levels/levels.json` order.
- Run `F6` before submitting a level.
- In the Pull Request, mention:
  - changed level,
  - whether it was F6 tested,
  - whether it can be completed,
  - any known balance issue.
