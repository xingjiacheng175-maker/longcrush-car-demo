# Design Summary

## Source Materials

- `gamedesign.pdf`: original design document for "钱路漫漫".
- `old_demo_code/`: previous React/Vite demo from Google AI Studio.
- `new-game-project/`: Godot 4 reimplementation.

## Core Fantasy

The player is a taxi driver who wants to earn more money by taking profitable detours while still delivering the passenger before fuel runs out.

The theme is "growth":

- Road growth: the road network expands from the starting point.
- Money growth: the player earns by routing through cash/fuel points.
- Moral growth: mentioned in the design document but not implemented yet.

## Core Gameplay

The game is a grid-based path-building puzzle.

The player:

1. Starts from a taxi/start tile.
2. Chooses one of several road-piece shapes.
3. Rotates the selected piece.
4. Places it on the grid so it connects to the existing powered road network.
5. Spends 1 fuel per placement.
6. Routes through cash/fuel cells to gain more fuel/cash.
7. Wins by connecting the start network to the goal before fuel runs out.

## Current Confirmed Rules

- Initial fuel is `3`.
- Each road-piece placement costs `1` fuel.
- Victory condition for the current MVP: connect to the goal.
- Loss condition: fuel reaches `0` before the goal is connected.
- Start and goal may be fixed in the first version.
- Level JSON and level editor are later phases.
- Current demo may use automatic level generation first.

## Fuel / Cash Rule

The rule has been adjusted from the original adjacency version.

Current confirmed rule:

- `CASH` cells can be paved over.
- Unpaved `CASH` is not collected by adjacent road.
- The player must place road onto `CASH`.
- A paved `CASH` cell becomes part of the road network.
- Once the paved `CASH` cell is connected to the taxi/start network, it is collected.

Current visual shorthand:

- `T`: taxi/start.
- `G`: goal.
- `$2`: unpaved cash/fuel worth 2.
- `R`: road.
- `R $2`: paved cash/fuel not yet collected.
- `R OK`: paved and collected cash/fuel.
- `X`: wall/block.

## Walls / Blocks

- `BLOCK` / `X` cells are hard obstacles.
- Road pieces cannot cover blocks.
- Hover preview should show invalid placement in red when covering a block.
- Current automatic generation avoids placing blocks on a hidden guaranteed route.

## Old Demo Logic Worth Preserving

From `old_demo_code/gameLogic.ts` and `old_demo_code/App.tsx`:

- Grid data model with cell types.
- Road shape library.
- Randomly offering 3 road shapes.
- Shape rotation with coordinate normalization.
- Placement validation from the existing powered network.
- BFS/flood-fill powered connection check from the start.
- Fuel/cash collection once a special cell joins the powered network.
- Level configs with size, target, and obstacle counts.
- Hover preview concept.

## Old Demo Logic Not Worth Directly Migrating

- React component structure and browser DOM rendering.
- Tailwind / Font Awesome / CSS visuals.
- Monolithic `App.tsx` state layout.
- Random generation without JSON or seed control.
- Google GenAI import, which is not part of the core gameplay.
- Web-specific input handling.

## Godot Reimplementation Direction

Current Godot MVP is intentionally simple:

- One main scene.
- One main script.
- Programmatic UI.
- Placeholder visuals using colored grid buttons and short text labels.

The next architectural step should be JSON level loading, not a large refactor.
