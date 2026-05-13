# Special Tiles Module

## Scope

This module covers special grid cells and obstacles:

- `Block`
- `Portal A`
- `Roller`
- `Mole`
- future special tiles.

## Current Tile Rules

### Block

- Blocks are hard obstacles.
- Road pieces cannot cover blocks.
- Generated levels avoid placing blocks on the hidden generated route.

JSON field:

```json
"blocks": [
  { "x": 2, "y": 0 }
]
```

### Portal A

- A level can contain no portals, or exactly two Portal A cells.
- When one Portal A cell is powered, the paired Portal A cell becomes connected too.
- Road can continue from the paired portal side.
- Portal cells render with `assets/placeholders/portal.png`.

JSON field:

```json
"portals": [
  { "x": 1, "y": 4, "pair": "A" },
  { "x": 4, "y": 1, "pair": "A" }
]
```

### Roller

- A roller triggers when road is placed over it.
- The triggered roller turns the surrounding `3x3` editable area into road.
- Roller paving affects empty cells, cash cells, roads, and other roller cells.
- Roller paving does not overwrite start, goal, blocks, portals, or moles.
- Roller cells render with `assets/placeholders/roller.png`.

JSON field:

```json
"rollers": [
  { "x": 3, "y": 3 }
]
```

### Mole

- Moles are moving blockers.
- Road pieces cannot cover mole cells.
- After each successful road placement, every mole moves to a random empty cell if possible.
- Mole movement avoids start, goal, road, cash, block, portal, roller, and other mole cells.
- Mole cells render with `assets/placeholders/mole.png`.

JSON field:

```json
"moles": [
  { "x": 2, "y": 4 }
]
```

## Code Touch Points

Special tile changes usually touch these areas in `scripts/Main.gd`:

- cell constants,
- `_load_tile_textures`,
- JSON loading,
- JSON validation,
- cell setter helpers,
- placement validation,
- placement effects,
- powered-network behavior,
- editor brush UI,
- editor painting,
- editor JSON export,
- debug stats,
- cell texture / tooltip / style.

## New Special Tile Checklist

When adding a special tile, update:

- `CELL_*` constant.
- `_create_empty_grid` if extra per-cell fields are needed.
- JSON loader and validator.
- Runtime behavior.
- Editor brush and paint handling.
- Resize preservation.
- Reset/play-state cleanup.
- JSON export.
- Debug stats.
- Visual texture or temporary marker.
- `docs/modules/special_tiles.md`.
- `docs/project_status.md` and `docs/handoff.md`.
- Operator guides if the tile affects designers.

