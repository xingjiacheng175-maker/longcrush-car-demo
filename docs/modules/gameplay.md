# Gameplay Module

## Scope

This module covers the player-facing road-building rules:

- road-piece selection and rotation,
- valid placement,
- powered/connected road network,
- fuel cost,
- reward/cash collection,
- win and loss conditions.

## Current Rules

- The player starts from the taxi/start tile.
- The goal is to connect the powered road network to the goal tile.
- Each successful road-piece placement costs `1` fuel.
- Initial fuel is currently level-defined, usually `3`.
- A placement must overlap or connect through an already powered/connectable cell.
- Road pieces cannot cover blocks, moles, or the goal tile.
- Road pieces can cover empty cells, cash cells, portal cells, and roller cells.
- `R` rotates the selected road piece.
- Yellow preview means valid placement; red preview means invalid placement.
- The player wins when the goal becomes powered.
- The player loses if fuel reaches `0` before the goal is powered.

## Cash / Reward Rule

- Cash can be collected by paving over it.
- Cash can also be collected when it touches the powered road network.
- Collected cash becomes road and can extend the powered network.
- The prototype currently uses the cash value as fuel gain. Money and fuel are not separate resources yet.

## Completion Cash Rule

- When the player wins, completion cash is based on road coverage.
- Each score-counted road cell gives `$10`.
- Score-counted road cells are:
  - start tile,
  - normal road/path tiles,
  - cash tiles that already have road,
  - portal tiles that already have road.
- The goal tile does not count as a road cell.
- Remaining fuel no longer adds completion cash.
- The old fixed `$100` victory bonus has been removed.
- During play, the HUD previews the current completion cash as `Win +$N`.
- After victory, the previewed completion cash is added to total `Cash`.
- After victory, a victory panel shows road cells, level cash, and total cash.
- The victory panel offers `Next Level`, `Restart`, and `Close`.

## Code Touch Points

Most gameplay logic is currently in `scripts/Main.gd`:

- shape library and rotation,
- `_is_placement_valid`,
- `_on_cell_pressed`,
- `_count_score_road_cells`,
- `_get_completion_cash_bonus`,
- `_refresh_hud`,
- `_show_victory_panel`,
- `_update_powered_status`,
- `_harvest_connected_fuel`,
- `_convert_fuel_to_road`.

## Change Checklist

When changing gameplay rules:

- Update `docs/modules/gameplay.md`.
- Update `docs/project_status.md` and `docs/handoff.md`.
- Check whether `docs/demo_operator_guide.md` and `docs/demo_operator_guide_zh.md` need user-facing updates.
- Run the manual checks in `docs/development/manual_test_checklist.md`.
