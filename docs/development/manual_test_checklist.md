# Manual Test Checklist

Use this checklist after gameplay, editor, level, or asset changes.

## Basic Run

1. Open the project folder containing `project.godot` in Godot 4.
2. Open `scenes/Main.tscn`.
3. Press `F6`.
4. Confirm the game starts without script errors.
5. Confirm level 1 loads from JSON.

## Gameplay Smoke Test

1. Select a road piece.
2. Confirm each road-piece offer is shown as a clear grid preview.
3. Rotate it with `R` and confirm the selected piece preview updates.
4. Hover over the board, press `R` without moving the mouse, and confirm the board preview updates immediately.
5. Hover over valid and invalid cells.
6. Confirm yellow preview means valid and red preview means invalid.
7. Place a valid road piece and confirm fuel decreases by `1`.
8. Confirm the HUD `Win +$N` preview updates after the road is placed.
9. Connect to the goal and confirm victory.
10. Confirm the victory panel appears.
11. Confirm the victory panel shows road cell count, level cash, and total cash.
12. Confirm cash increases by `road cell count * 10`.
13. Press `Close` and confirm the panel closes without changing level.
14. Restart the level.
15. Win again, press `Next Level`, and confirm the next configured level loads.
16. Run out of fuel before reaching the goal and confirm loss.

## Cash Test

1. Place road over a cash cell and confirm it is collected.
2. Connect road adjacent to a cash cell and confirm it is collected.
3. Confirm collected cash becomes road and can extend the powered network.

## Special Tile Test

Portal A:

1. In editor mode, paint exactly two Portal A cells.
2. Return to play mode.
3. Connect road to one portal.
4. Confirm the paired portal becomes part of the powered network.
5. Confirm road can continue from the paired portal side.

Roller:

1. In editor mode, paint a Roller.
2. Return to play mode.
3. Cover the Roller with a road piece.
4. Confirm the surrounding `3x3` editable cells become road.
5. Confirm start, goal, blocks, portals, and moles are not overwritten.

Mole:

1. In editor mode, paint one or more Moles.
2. Return to play mode.
3. Confirm road pieces cannot cover Mole cells.
4. Place a valid road piece elsewhere.
5. Confirm Moles move to empty cells.
6. Confirm Moles do not move onto start, goal, roads, cash, blocks, portals, rollers, or other moles.

## Editor Test

1. Press `E` to enter editor mode.
2. Switch between level entries.
3. Change width and height.
4. Change initial fuel and cash value.
5. Paint each brush type.
6. Confirm validation reports `OK` for valid levels.
7. Use `Copy JSON` and confirm the clipboard JSON contains current edits.
8. Use `Save Level`.
9. Stop running and inspect the corresponding JSON file.
10. Reload the level and confirm edits persist.

## Asset Test

1. Confirm all board tile assets render in play/editor mode.
2. Confirm new assets are 256x256 PNG unless intentionally different.
3. Confirm text markers are not accidentally visible for tiles that should use art.

## Documentation-Only Changes

For documentation-only changes:

1. Run `git diff --check`.
2. Confirm paths and filenames in docs match the repository.
3. No Godot `F6` test is required unless the documentation claims behavior that has not been recently verified.
