# scripts/AGENTS.md

## Scope

Rules for files under `scripts/`.

## Current Shape

- `scripts/Main.gd` is still the main implementation file.
- Keep the prototype runnable and avoid broad code movement unless the user confirms a refactor phase.

## Change Rules

- For gameplay changes, check `docs/modules/gameplay.md`.
- For special tile changes, check `docs/modules/special_tiles.md`.
- For editor changes, check `docs/modules/editor_workflow.md`.
- For test expectations, check `docs/development/manual_test_checklist.md`.

## Special Tile Checklist

When adding or changing a special tile, update all relevant code paths:

- constants,
- JSON loading,
- JSON validation,
- runtime behavior,
- editor brush,
- editor painting,
- resize preservation,
- reset/play-state cleanup,
- JSON export,
- debug stats,
- visual texture or temporary marker,
- module docs and handoff docs.

## Refactor Rules

- Do not do a large `Main.gd` split during feature work unless explicitly requested.
- Prefer small helper extraction with a clear test path.
- Keep `scenes/Main.tscn` runnable with `F6`.

