# levels/AGENTS.md

## Scope

Rules for authored level data under `levels/`.

## Change Rules

- Do not overwrite authored levels without clear user intent.
- Do not reorder `levels/levels.json` casually.
- If changing `levels/levels.json`, explain the intended play order.
- Avoid two people editing the same `level_00x.json` at the same time.
- Keep level files valid JSON.

## Current JSON References

- Level authoring guide: `docs/modules/level_authoring.md`
- Editor workflow: `docs/modules/editor_workflow.md`
- Manual checks: `docs/development/manual_test_checklist.md`

## Testing

After level edits:

- run the level with Godot `F6`,
- use `Jump To Level` or the editor level selector,
- confirm the level loads from JSON instead of falling back to generated content,
- confirm `Save Level` / reload behavior if the editor was used.

