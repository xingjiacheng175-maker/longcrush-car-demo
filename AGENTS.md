# AGENTS.md

## Project Context

This is a Godot 4 prototype project for the game "钱路漫漫" / "Money Road".

The current Git repository root is this Godot project folder:

- `project.godot`
- `scenes/`
- `scripts/`
- `levels/`
- `assets/`
- `docs/`

Original source materials were used during earlier analysis:

- `gamedesign.pdf`: original game design document.
- `old_demo_code/`: previous Google AI Studio React/Vite demo.

These source materials may exist outside the Git repository on the user's machine. Do not assume they are always present after cloning from GitHub.

## Required Session Start

Before continuing work in a new Codex session or on a new device, read these files first:

1. `AGENTS.md`
2. `docs/project_status.md`
3. `docs/design_summary.md`
4. `docs/handoff.md`

Then continue from the current status instead of restarting analysis from scratch.

## Planned Phases

1. Analyze the gameplay design.
2. Analyze the old demo code.
3. Reimplement a minimal runnable demo in Godot 4.
4. Add level JSON loading.
5. Add a basic level editor.
6. Generate or organize placeholder assets.
7. Add debugging tools.

Some phases are already implemented. Use `docs/project_status.md` as the current source of truth.

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
7. Use placeholder assets until the gameplay loop and level workflow are stable.
8. After each phase, summarize:
   - Which files were modified.
   - What functionality currently works.
   - How to run or test it.
   - Recommended next steps.
9. After each completed phase, update:
   - `docs/project_status.md`
   - `docs/handoff.md`
10. Do not develop unrelated features during documentation-only requests.

## Implementation Guidance

- Keep the prototype small and playable.
- Current implementation is intentionally concentrated mostly in `scripts/Main.gd`.
- Avoid large refactors until JSON levels, editor workflow, and debug tools are clearer.
- Use Godot editor F6 testing as the primary runtime check unless Godot CLI becomes available.
- Do not commit or push `.godot/`, temporary files, cache files, OS files, or secrets.
- Keep collaboration documents in Git so the user can switch between home Windows and company Mac.
