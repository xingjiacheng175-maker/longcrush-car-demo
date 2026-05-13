# Assets Module

## Scope

This module covers prototype art assets and replacement workflow.

## Current Asset Directory

Prototype tile assets live in:

```text
assets/placeholders/
```

Current board tile PNGs are 256x256.

## Current Key Assets

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

## Asset Rules

- Use PNG for board tiles.
- Default board tile size is `256x256`.
- Keep visual style readable at small in-game board sizes.
- Keep source art inside the project only if it is meant to be versioned.
- Avoid committing `.DS_Store`, `.godot/`, temporary files, or random source downloads.

## Replacement Workflow

1. Put the final PNG under `assets/placeholders/`.
2. Keep the filename stable if replacing an existing tile.
3. If adding a new tile, add it to `_load_tile_textures` in `scripts/Main.gd`.
4. Map the cell type to the texture in `_cell_texture`.
5. Run Godot `F6` and confirm the tile appears in the board.
6. Update `docs/modules/assets.md`, `docs/project_status.md`, and `docs/handoff.md`.

## Godot Import Notes

Godot may create `.import` files for new assets after opening the editor. These can be committed when they correspond to real project assets. Do not commit `.godot/` imported cache files.

