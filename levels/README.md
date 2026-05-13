# Levels

This folder contains authored JSON levels and level order configuration.

## Key Files

- `levels.json`: ordered level list.
- `level_001.json`, `level_002.json`, etc.: authored levels.

## Entry Types

`levels.json` can contain:

- resource paths such as `res://levels/level_001.json`,
- `"generated"` fallback entries.

## JSON Format

See `docs/modules/level_authoring.md` for the current JSON schema and authoring rules.

## Team Notes

- Prefer one owner for final level order.
- Avoid simultaneous edits to the same `level_00x.json`.
- Use the Godot runtime editor for normal level edits.

