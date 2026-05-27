# Runtime Editor Module

## Scope

This module covers the in-game/runtime level editor that appears after pressing `E`.

## Current Editor Capabilities

- Toggle editor mode with `E`.
- Select configured levels from `levels/levels.json`.
- Create a new level with `New Level`.
- Save the current level with `Save Level`.
- Copy the current level JSON with `Copy JSON`.
- Copy a suggested `levels.json` entry with `Copy levels.json Entry`.
- Change board width from `4` to `14`.
- Change board height from `4` to `12`.
- Change initial fuel from `1` to `20`.
- Change cash brush value from `1` to `9`.
- New cash cells default to value `1`.

## Brushes

- `Ground`
- `Cash`
- `Block`
- `Start`
- `Goal`
- `Portal A`
- `Roller`
- `Mole`

## Editor Behavior

- Painting start or goal moves the unique marker.
- Painting normal cells over start/goal is blocked; move start/goal first.
- Resizing preserves in-bounds editable cells when possible.
- Resizing clamps start/goal back into the board.
- Painting or resizing resets temporary play state.
- Saves are meant for development inside Godot editor; exported builds should not depend on writing to `res://levels/`.

## Code Touch Points

Editor logic is currently in `scripts/Main.gd`:

- `_build_ui`
- `_toggle_editor_mode`
- `_refresh_editor_panel`
- `_refresh_editor_level_selector`
- `_paint_editor_cell`
- `_resize_editor_grid`
- `_validate_current_editor_level`
- `_build_current_level_json_text`
- `_save_editor_level`
- `_create_new_editor_level`

## Change Checklist

When changing the editor:

- Update `docs/modules/editor_workflow.md`.
- Update `docs/demo_operator_guide.md` and `docs/demo_operator_guide_zh.md` if designers need to know.
- Run editor checks in `docs/development/manual_test_checklist.md`.
