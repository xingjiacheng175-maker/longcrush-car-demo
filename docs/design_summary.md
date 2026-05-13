# Design Summary

Last updated: 2026-05-13

## Source Materials

- `gamedesign.pdf`: original game design document for "钱路漫漫".
- `old_demo_code/`: previous React/Vite demo from Google AI Studio.
- Current target: Godot 4 + GDScript.

The source PDF and old demo may not be included in the GitHub repository. This document preserves the usable summary for future sessions.

## Core Fantasy

The player is a taxi driver who wants to earn more money by taking profitable detours while still reaching the destination before fuel runs out.

The theme is "growth":

- Road growth: the road network expands from the taxi/start point.
- Money growth: the player earns by routing through reward cells.
- Moral growth: mentioned in the design document but not implemented in the current prototype.

## Core Gameplay

The game is a grid-based path-building puzzle.

Player flow:

1. Start from a taxi/start tile.
2. Select one of several offered road pieces.
3. Rotate the selected piece with `R`.
4. Hover over the grid to preview placement.
5. Place the piece so it connects to the powered road network.
6. Spend `1` fuel for each road placement.
7. Reach reward cells by paving over them or touching them with the powered road network to gain more fuel/cash.
8. Win by connecting the road network to the goal.

## Current Confirmed Rules

- Initial fuel is currently `3`.
- Each road-piece placement costs `1` fuel.
- Current victory condition: connect to the goal.
- Current loss condition: fuel reaches `0` before the goal is connected.
- Start and goal are supported by JSON and editor data.
- Walls/blocks are hard obstacles.
- Road can be placed on reward cells.
- Road cannot be placed on wall/block cells.
- Portal A links two board cells; reaching one portal connects the paired portal into the powered road network.
- Roller turns the surrounding 3x3 editable area into road when paved over.
- Mole blocks road placement and moves to a random empty cell after each successful road placement.
- User confirmed that detouring for money is the core experience.

## Fuel / Cash Rule

The reward rule was changed during testing.

Current confirmed rule:

- `CASH` cells can be collected by placing road onto them.
- `CASH` cells can also be collected when they are adjacent to the taxi/start powered road network.
- Once collected, the `CASH` cell becomes a road cell and can extend the powered network.

Current prototype treats reward value as fuel/cash gain in the same flow. Whether money and fuel should become separate resources remains open.

## Walls / Blocks

- `BLOCK` cells are hard obstacles.
- Road pieces cannot cover blocks.
- Hover preview should show invalid placement in red when covering a block.
- Auto-generated levels avoid placing blocks on the hidden generated route.

## Special Tiles

Current implemented special tiles:

- `Portal A`: a pair of linked cells. When one Portal A cell is connected to the powered road network, the paired Portal A cell becomes connected too.
- `Roller`: when paved over, it turns the surrounding 3x3 area into road. It affects empty cells, cash cells, roads, and other roller cells, but does not overwrite start, goal, blocks, or portals.
- `Mole`: a moving blocker. Road pieces cannot cover it; after each successful road placement, every mole moves to a random empty cell if one is available.

## Old Demo Logic Worth Preserving

From `old_demo_code/gameLogic.ts` and `old_demo_code/App.tsx`:

- Grid data model with cell types.
- Road shape library.
- Randomly offering 3 road shapes.
- Shape rotation with coordinate normalization.
- Placement validation from the existing powered network.
- BFS/flood-fill powered connection check from the start.
- Reward collection once a special cell joins the powered network.
- Level configs with size, target, and obstacle counts.
- Hover preview concept.

## Old Demo Logic Not Worth Directly Migrating

- React component structure and browser DOM rendering.
- Tailwind / Font Awesome / CSS visuals.
- Monolithic browser state layout.
- Web-specific input handling.
- Google GenAI import, which is not part of the core gameplay.
- Random generation without JSON, export, or seed control.

## Godot Reimplementation Direction

The current Godot prototype intentionally stays simple:

- One main scene.
- One main script.
- Programmatic UI.
- JSON level files.
- Basic generated levels.
- Basic editor and debug tools.
- Placeholder top-down assets.

The next architecture step should be driven by concrete pain points, especially level editing and level validation, rather than a large early refactor.
