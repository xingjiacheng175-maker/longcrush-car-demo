# Testing Module

## Scope

This module points to the current manual validation process.

The authoritative checklist is:

- `docs/development/manual_test_checklist.md`

## Current Test Reality

Godot CLI is not assumed to be available in the Codex environment. The primary runtime validation method is opening the project in Godot 4 and running the main scene with `F6`.

## When To Test

Run the checklist after changes to:

- gameplay rules,
- special tiles,
- JSON loading or saving,
- runtime editor behavior,
- board visuals,
- level files.

Documentation-only changes usually do not require Godot `F6`, but should still be checked for links, paths, and consistency with current behavior.

