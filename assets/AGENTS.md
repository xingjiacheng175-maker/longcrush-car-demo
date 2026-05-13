# assets/AGENTS.md

## Scope

Rules for art and asset files under `assets/`.

## Asset Rules

- Board tile PNGs should normally be `256x256`.
- Current prototype board art lives under `assets/placeholders/`.
- Keep filenames stable when replacing an existing tile.
- Do not commit `.DS_Store`, random temporary downloads, or `.godot/` cache files.

## Replacement Checklist

When adding or replacing a board tile:

- place the PNG under `assets/placeholders/`,
- confirm dimensions and alpha if needed,
- update `scripts/Main.gd` texture loading if it is a new tile,
- update `docs/modules/assets.md`,
- test in Godot with `F6`.

