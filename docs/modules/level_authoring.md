# Level Authoring Module

## Scope

This module covers authored level files, level order, and team workflow for level design.

## Current Files

- `levels/levels.json`: ordered list of playable level entries.
- `levels/level_001.json` and later: authored level data.

`levels.json` entries can be:

- a JSON resource path such as `res://levels/level_001.json`,
- the string `"generated"` for runtime generated fallback content.

## Current JSON Shape

```json
{
  "id": "level_001",
  "name": "Example Level",
  "width": 6,
  "height": 6,
  "initial_fuel": 3,
  "start": { "x": 0, "y": 0 },
  "goal": { "x": 5, "y": 5 },
  "cash": [
    { "x": 1, "y": 1, "value": 1 }
  ],
  "blocks": [
    { "x": 2, "y": 0 }
  ],
  "portals": [
    { "x": 1, "y": 4, "pair": "A" },
    { "x": 4, "y": 1, "pair": "A" }
  ],
  "rollers": [
    { "x": 3, "y": 3 }
  ],
  "moles": [
    { "x": 2, "y": 4 }
  ]
}
```

## Authoring Rules

- Use the runtime editor for normal level creation and edits.
- Prefer one person owning `levels/levels.json` order.
- Avoid two people editing the same `level_00x.json` at the same time.
- Do not overwrite existing authored levels without confirming intent.
- Generated fallback entries are acceptable during prototyping.

## Validation Expectations

- Exactly one start.
- Exactly one goal.
- Start and goal are inside the board.
- Start and goal cannot overlap.
- Cash, block, portal, roller, and mole cells cannot overlap start or goal.
- Portal A must have exactly two cells or none.
- Other special tiles can appear any number of times unless a future rule says otherwise.

## Team Workflow

1. Pull latest changes.
2. Create or select a level branch.
3. Edit one or a small number of levels.
4. Test in Godot with `F6`.
5. Commit JSON changes and relevant docs.
6. Push and create a PR if collaborating through GitHub.
