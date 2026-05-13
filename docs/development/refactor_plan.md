# Refactor Plan

This project should stay runnable while it grows. Refactoring should happen in small, reversible phases.

## Current Constraint

Most code intentionally lives in `scripts/Main.gd`. This has been useful for fast prototype work, but the file now contains gameplay, UI, editor, JSON, debug, and asset loading logic.

## Refactor Principles

- Do not combine refactoring with new gameplay unless the user explicitly asks.
- Prefer pure-data or pure-helper extraction before node/UI extraction.
- After every refactor step, run the manual checklist relevant to the touched area.
- Keep `scenes/Main.tscn` runnable at all times.
- Do not move level JSON or assets during code refactors.

## Suggested Phases

### Phase 1: Documentation And Rules

Status: current phase.

- Add module docs.
- Add local `AGENTS.md` files.
- Add manual test checklist.
- Add this refactor plan.

Risk: low.
Benefit: future work needs less context.

### Phase 2: Data Extraction

Potential files:

- `scripts/core/ShapeLibrary.gd`
- `scripts/core/LevelConstants.gd`

Move:

- shape definitions,
- stable constants,
- simple utility helpers if they do not depend on UI nodes.

Risk: low to medium.
Benefit: smaller `Main.gd`, easier shape tuning.

### Phase 3: Level Data Helpers

Potential file:

- `scripts/core/LevelData.gd`

Move:

- JSON parsing helpers,
- JSON validation helpers,
- level path helpers.

Risk: medium.
Benefit: level workflow becomes easier to reason about.

### Phase 4: Special Tile Logic

Potential file:

- `scripts/systems/SpecialTileLogic.gd`

Move:

- Portal linking,
- Roller activation,
- Mole movement,
- special-tile validation helpers.

Risk: medium.
Benefit: future obstacles become faster and safer to add.

### Phase 5: UI Split

Potential files:

- `scripts/ui/EditorPanel.gd`
- `scripts/ui/DebugPanel.gd`

Move:

- editor UI construction,
- debug label construction,
- editor panel refresh logic.

Risk: medium to high because Godot node references and signals can break easily.
Benefit: `Main.gd` becomes much smaller.

## Do Later

- Automated solver or level validation.
- Formal unit tests.
- Scene/node restructure.
- Export-build save workflow.

