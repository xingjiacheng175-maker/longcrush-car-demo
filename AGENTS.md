# AGENTS.md

## Project Context

This is a Godot 4 prototype project for the game "钱路漫漫" / "Money Road".

Source materials:

- `gamedesign.pdf`: original game design document.
- `old_demo_code/`: previous Google AI Studio React/Vite demo.
- `new-game-project/`: current Godot 4 project.

Before starting work in a new Codex session, read these files first:

1. `AGENTS.md`
2. `docs/design_summary.md`
3. `docs/project_status.md`

## Planned Phases

1. Analyze the gameplay design.
2. Analyze the old demo code.
3. Reimplement a minimal runnable demo in Godot 4.
4. Add level JSON loading.
5. Add a basic level editor.
6. Generate or organize placeholder assets.
7. Add debugging tools.

## Collaboration Rules

1. Before executing each phase, first tell the user:
   - The proposed plan.
   - The expected file modification scope.
   - The testing method.
2. Wait for the user's confirmation before modifying files.
3. For any step that requires manual user action, clearly explain:
   - Why the user needs to do it.
   - Exactly what the user should do.
   - What the user should reply after finishing.
4. Prioritize the smallest runnable version. Do not start with complex architecture.
5. Use Godot 4 and GDScript.
6. Prefer JSON for level data.
7. Use placeholder assets in the first stage. If simple placeholder assets can be generated automatically, generate them. If not, provide an asset list and image-generation prompts.
8. After each phase, summarize:
   - Which files were modified.
   - What functionality currently works.
   - How to run or test it.
   - Recommended next steps.
9. After each phase is completed, update `docs/project_status.md`.
10. If a new Codex session is started, read `AGENTS.md`, `docs/design_summary.md`, and `docs/project_status.md` before continuing.

## Current Implementation Direction

- Keep the prototype small and playable.
- Current Godot implementation is UI-driven and concentrated mostly in `new-game-project/scripts/Main.gd`.
- Avoid premature architecture until JSON levels, editor needs, and debug tools are clearer.
- The level editor is a later feature. The current demo may keep automatic level generation until core gameplay stabilizes.
