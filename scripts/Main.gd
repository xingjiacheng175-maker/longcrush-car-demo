extends Control

const CELL_EMPTY := "empty"
const CELL_START := "start"
const CELL_END := "end"
const CELL_PATH := "path"
const CELL_FUEL := "fuel"
const CELL_ROCK := "rock"
const CELL_PORTAL := "portal"
const CELL_ROLLER := "roller"
const CELL_MOLE := "mole"
const PORTAL_PAIR_A := "A"

const INITIAL_FUEL := 3
const FUEL_TO_SCORE_RATIO := 10
const LEVEL_LIST_PATH := "res://levels/levels.json"
const LEVEL_PATH_TEMPLATE := "res://levels/level_%03d.json"
const EDITOR_MIN_GRID_WIDTH := 4
const EDITOR_MAX_GRID_WIDTH := 14
const EDITOR_MIN_GRID_HEIGHT := 4
const EDITOR_MAX_GRID_HEIGHT := 12
const EDITOR_MIN_INITIAL_FUEL := 1
const EDITOR_MAX_INITIAL_FUEL := 20
const EDITOR_MIN_CASH_VALUE := 1
const EDITOR_MAX_CASH_VALUE := 9
const UI_SCALE := 1.5

const LEVEL_CONFIGS := [
	{"level": 1, "size": 6, "fuel_count": 4, "rocks": 2},
	{"level": 2, "size": 8, "fuel_count": 6, "rocks": 7},
	{"level": 3, "size": 10, "fuel_count": 8, "rocks": 14},
	{"level": 4, "size": 10, "fuel_count": 10, "rocks": 20},
	{"level": 5, "size": 10, "fuel_count": 12, "rocks": 26},
]

const SHAPE_LIBRARY := [
	{"id": "domino", "cells": [{"x": 0, "y": 0}, {"x": 1, "y": 0}]},
	{"id": "triomino-i", "cells": [{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}]},
	{"id": "triomino-l", "cells": [{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 1, "y": 1}]},
	{"id": "tetromino-i", "cells": [{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}, {"x": 3, "y": 0}]},
	{"id": "tetromino-o", "cells": [{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 0, "y": 1}, {"x": 1, "y": 1}]},
	{"id": "tetromino-t", "cells": [{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}, {"x": 1, "y": 1}]},
	{"id": "tetromino-s", "cells": [{"x": 1, "y": 0}, {"x": 2, "y": 0}, {"x": 0, "y": 1}, {"x": 1, "y": 1}]},
	{"id": "tetromino-z", "cells": [{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 1, "y": 1}, {"x": 2, "y": 1}]},
	{"id": "tetromino-j", "cells": [{"x": 0, "y": 0}, {"x": 0, "y": 1}, {"x": 1, "y": 1}, {"x": 2, "y": 1}]},
	{"id": "tetromino-l", "cells": [{"x": 2, "y": 0}, {"x": 0, "y": 1}, {"x": 1, "y": 1}, {"x": 2, "y": 1}]},
]

var rng := RandomNumberGenerator.new()
var grid: Array = []
var grid_width := 6
var grid_height := 6
var current_level := 1
var fuel := INITIAL_FUEL
var initial_fuel := INITIAL_FUEL
var score := 0
var status := "playing"
var current_shapes: Array = []
var selected_shape_index := -1
var message := ""
var hover_origin := Vector2i(-1, -1)
var generated_route_cells: Dictionary = {}
var tile_textures: Dictionary = {}
var start_pos: Vector2i = Vector2i(0, 0)
var goal_pos: Vector2i = Vector2i(5, 5)
var level_source: String = "generated"
var level_path: String = ""
var level_sequence: Array = []
var current_level_entry: String = ""
var debug_visible: bool = false
var editor_mode: bool = false
var editor_brush: String = CELL_ROCK
var editor_cash_value: int = 2
var editor_refreshing_level_selector: bool = false

var board_grid: GridContainer
var pieces_container: VBoxContainer
var level_label: Label
var fuel_label: Label
var score_label: Label
var status_label: Label
var message_label: Label
var next_button: Button
var level_jump_selector: OptionButton
var debug_panel: PanelContainer
var debug_label: Label
var editor_panel: PanelContainer
var editor_level_selector: OptionButton
var editor_level_path_label: Label
var editor_grid_width_spin: SpinBox
var editor_grid_height_spin: SpinBox
var editor_initial_fuel_spin: SpinBox
var editor_cash_value_spin: SpinBox
var editor_validation_label: Label
var editor_json_text: TextEdit


func _ready() -> void:
	rng.randomize()
	_load_tile_textures()
	_load_level_sequence()
	_build_ui()
	init_level()


func _load_tile_textures() -> void:
	tile_textures = {
		"ground": load("res://assets/placeholders/ground.png"),
		"road": load("res://assets/placeholders/road.png"),
		"road_powered": load("res://assets/placeholders/road_powered.png"),
		"taxi_start": load("res://assets/placeholders/taxi_start.png"),
		"goal": load("res://assets/placeholders/goal.png"),
		"cash": load("res://assets/placeholders/cash.png"),
		"cash_road": load("res://assets/placeholders/cash_road.png"),
		"cash_collected": load("res://assets/placeholders/cash_collected.png"),
		"block": load("res://assets/placeholders/block.png"),
		"portal": load("res://assets/placeholders/portal.png"),
		"roller": load("res://assets/placeholders/roller.png"),
		"mole": load("res://assets/placeholders/mole.png"),
	}


func _load_level_sequence() -> void:
	level_sequence = []
	if not FileAccess.file_exists(LEVEL_LIST_PATH):
		return

	var file: FileAccess = FileAccess.open(LEVEL_LIST_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open level list: %s" % LEVEL_LIST_PATH)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid level list JSON: %s" % LEVEL_LIST_PATH)
		return

	var data: Dictionary = parsed
	var entries = data.get("levels", [])
	if not entries is Array:
		push_warning("Level list missing array 'levels': %s" % LEVEL_LIST_PATH)
		return

	for entry in entries:
		if entry is String:
			level_sequence.append(entry)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			rotate_selected_shape()
		elif event.keycode == KEY_D:
			_toggle_debug_panel()
		elif event.keycode == KEY_E:
			_toggle_editor_mode()


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", _ui_size(12))
	root.offset_left = _ui_size(18)
	root.offset_top = _ui_size(18)
	root.offset_right = -_ui_size(18)
	root.offset_bottom = -_ui_size(18)
	add_child(root)

	var title := Label.new()
	title.text = "Money Road: Taxi Detour Prototype"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", _ui_size(24))
	root.add_child(title)

	var hud := HBoxContainer.new()
	hud.add_theme_constant_override("separation", _ui_size(16))
	root.add_child(hud)

	level_label = _make_hud_label()
	fuel_label = _make_hud_label()
	score_label = _make_hud_label()
	status_label = _make_hud_label()
	hud.add_child(level_label)
	hud.add_child(fuel_label)
	hud.add_child(score_label)
	hud.add_child(status_label)

	var main_row := HBoxContainer.new()
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", _ui_size(18))
	root.add_child(main_row)

	board_grid = GridContainer.new()
	board_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_grid.add_theme_constant_override("h_separation", _ui_size(4))
	board_grid.add_theme_constant_override("v_separation", _ui_size(4))
	board_grid.mouse_exited.connect(_on_board_mouse_exited)
	main_row.add_child(board_grid)

	var side_scroll := ScrollContainer.new()
	side_scroll.custom_minimum_size = Vector2(_ui_size(375), 0)
	side_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_row.add_child(side_scroll)

	var side_panel := VBoxContainer.new()
	side_panel.custom_minimum_size = Vector2(_ui_size(345), 0)
	side_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_panel.add_theme_constant_override("separation", _ui_size(10))
	side_scroll.add_child(side_panel)

	var pieces_title := Label.new()
	pieces_title.text = "Road Pieces"
	pieces_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side_panel.add_child(pieces_title)

	pieces_container = VBoxContainer.new()
	pieces_container.add_theme_constant_override("separation", _ui_size(8))
	side_panel.add_child(pieces_container)

	var rotate_button := Button.new()
	rotate_button.text = "Rotate [R]"
	rotate_button.pressed.connect(rotate_selected_shape)
	side_panel.add_child(rotate_button)

	var restart_button := Button.new()
	restart_button.text = "Restart Level"
	restart_button.pressed.connect(init_level)
	side_panel.add_child(restart_button)

	var reload_button := Button.new()
	reload_button.text = "Reload Level"
	reload_button.pressed.connect(init_level)
	side_panel.add_child(reload_button)

	var jump_title := Label.new()
	jump_title.text = "Jump To Level"
	jump_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side_panel.add_child(jump_title)

	level_jump_selector = OptionButton.new()
	level_jump_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_panel.add_child(level_jump_selector)

	var load_level_button := Button.new()
	load_level_button.text = "Load Level"
	load_level_button.pressed.connect(_on_load_selected_level_pressed)
	side_panel.add_child(load_level_button)

	next_button = Button.new()
	next_button.text = "Next Generated Level"
	next_button.pressed.connect(_on_next_level_pressed)
	side_panel.add_child(next_button)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(_ui_size(330), 0)
	message_label.text = ""
	side_panel.add_child(message_label)

	debug_panel = PanelContainer.new()
	debug_panel.visible = false
	side_panel.add_child(debug_panel)

	var debug_box := VBoxContainer.new()
	debug_box.add_theme_constant_override("separation", _ui_size(6))
	debug_panel.add_child(debug_box)

	var debug_title := Label.new()
	debug_title.text = "Debug [D]"
	debug_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	debug_box.add_child(debug_title)

	debug_label = Label.new()
	debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_label.custom_minimum_size = Vector2(_ui_size(330), 0)
	debug_label.text = ""
	debug_box.add_child(debug_label)

	editor_panel = PanelContainer.new()
	editor_panel.visible = false
	side_panel.add_child(editor_panel)

	var editor_box := VBoxContainer.new()
	editor_box.add_theme_constant_override("separation", _ui_size(6))
	editor_panel.add_child(editor_box)

	var editor_title := Label.new()
	editor_title.text = "Editor [E]"
	editor_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	editor_box.add_child(editor_title)

	var editor_help := Label.new()
	editor_help.text = "Paint the current board, then save it to a level file."
	editor_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	editor_box.add_child(editor_help)

	var editor_files_title := Label.new()
	editor_files_title.text = "Level Files"
	editor_files_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	editor_box.add_child(editor_files_title)

	editor_level_selector = OptionButton.new()
	editor_level_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor_level_selector.item_selected.connect(_on_editor_level_selected)
	editor_box.add_child(editor_level_selector)

	editor_level_path_label = Label.new()
	editor_level_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	editor_level_path_label.custom_minimum_size = Vector2(_ui_size(330), 0)
	editor_box.add_child(editor_level_path_label)

	var level_file_buttons := HBoxContainer.new()
	level_file_buttons.add_theme_constant_override("separation", _ui_size(4))
	editor_box.add_child(level_file_buttons)

	var new_level_button := Button.new()
	new_level_button.text = "New Level"
	new_level_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_level_button.pressed.connect(_create_new_editor_level)
	level_file_buttons.add_child(new_level_button)

	var save_level_button := Button.new()
	save_level_button.text = "Save Level"
	save_level_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_level_button.pressed.connect(_save_editor_level)
	level_file_buttons.add_child(save_level_button)

	var editor_settings_title := Label.new()
	editor_settings_title.text = "Settings"
	editor_settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	editor_box.add_child(editor_settings_title)

	editor_grid_width_spin = _make_editor_spinbox(EDITOR_MIN_GRID_WIDTH, EDITOR_MAX_GRID_WIDTH, 1, grid_width)
	editor_grid_width_spin.value_changed.connect(_on_editor_grid_width_changed)
	editor_box.add_child(_make_editor_spinbox_row("Width", editor_grid_width_spin))

	editor_grid_height_spin = _make_editor_spinbox(EDITOR_MIN_GRID_HEIGHT, EDITOR_MAX_GRID_HEIGHT, 1, grid_height)
	editor_grid_height_spin.value_changed.connect(_on_editor_grid_height_changed)
	editor_box.add_child(_make_editor_spinbox_row("Height", editor_grid_height_spin))

	editor_initial_fuel_spin = _make_editor_spinbox(EDITOR_MIN_INITIAL_FUEL, EDITOR_MAX_INITIAL_FUEL, 1, initial_fuel)
	editor_initial_fuel_spin.value_changed.connect(_on_editor_initial_fuel_changed)
	editor_box.add_child(_make_editor_spinbox_row("Initial fuel", editor_initial_fuel_spin))

	editor_cash_value_spin = _make_editor_spinbox(EDITOR_MIN_CASH_VALUE, EDITOR_MAX_CASH_VALUE, 1, editor_cash_value)
	editor_cash_value_spin.value_changed.connect(_on_editor_cash_value_changed)
	editor_box.add_child(_make_editor_spinbox_row("Cash value", editor_cash_value_spin))

	var brushes_title := Label.new()
	brushes_title.text = "Brushes"
	brushes_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	editor_box.add_child(brushes_title)

	var brush_row_1 := HBoxContainer.new()
	brush_row_1.add_theme_constant_override("separation", _ui_size(4))
	editor_box.add_child(brush_row_1)
	brush_row_1.add_child(_make_editor_brush_button("Ground", CELL_EMPTY))
	brush_row_1.add_child(_make_editor_brush_button("Cash", CELL_FUEL))
	brush_row_1.add_child(_make_editor_brush_button("Block", CELL_ROCK))

	var brush_row_2 := HBoxContainer.new()
	brush_row_2.add_theme_constant_override("separation", _ui_size(4))
	editor_box.add_child(brush_row_2)
	brush_row_2.add_child(_make_editor_brush_button("Start", CELL_START))
	brush_row_2.add_child(_make_editor_brush_button("Goal", CELL_END))
	brush_row_2.add_child(_make_editor_brush_button("Portal A", CELL_PORTAL))
	brush_row_2.add_child(_make_editor_brush_button("Roller", CELL_ROLLER))

	var brush_row_3 := HBoxContainer.new()
	brush_row_3.add_theme_constant_override("separation", _ui_size(4))
	editor_box.add_child(brush_row_3)
	brush_row_3.add_child(_make_editor_brush_button("Mole", CELL_MOLE))

	var copy_json_button := Button.new()
	copy_json_button.text = "Copy JSON"
	copy_json_button.pressed.connect(_copy_editor_json_to_clipboard)
	editor_box.add_child(copy_json_button)

	var copy_entry_button := Button.new()
	copy_entry_button.text = "Copy levels.json Entry"
	copy_entry_button.pressed.connect(_copy_editor_level_entry_to_clipboard)
	editor_box.add_child(copy_entry_button)

	editor_validation_label = Label.new()
	editor_validation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	editor_validation_label.custom_minimum_size = Vector2(_ui_size(330), 0)
	editor_box.add_child(editor_validation_label)

	editor_json_text = TextEdit.new()
	editor_json_text.custom_minimum_size = Vector2(_ui_size(330), _ui_size(330))
	editor_json_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	editor_json_text.editable = false
	editor_box.add_child(editor_json_text)


func _ui_size(value: int) -> int:
	return int(round(float(value) * UI_SCALE))


func _make_hud_label() -> Label:
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", _ui_size(18))
	return label


func _make_editor_spinbox(min_value: float, max_value: float, step_value: float, current_value: float) -> SpinBox:
	var spinbox := SpinBox.new()
	spinbox.min_value = min_value
	spinbox.max_value = max_value
	spinbox.step = step_value
	spinbox.value = current_value
	spinbox.allow_greater = false
	spinbox.allow_lesser = false
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return spinbox


func _make_editor_spinbox_row(label_text: String, spinbox: SpinBox) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(_ui_size(147), 0)
	row.add_child(label)
	row.add_child(spinbox)
	return row


func _make_editor_brush_button(label_text: String, brush: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_set_editor_brush.bind(brush))
	return button


func init_level() -> void:
	status = "playing"
	selected_shape_index = -1
	hover_origin = Vector2i(-1, -1)
	current_shapes = _get_random_shapes(3)
	var loaded_from_json: bool = _load_current_level_entry()
	if not loaded_from_json:
		_init_generated_level()
	_update_powered_status()
	_refresh_all()


func _get_level_config(level: int) -> Dictionary:
	if level <= LEVEL_CONFIGS.size():
		return LEVEL_CONFIGS[level - 1]

	var extra_level: int = level - LEVEL_CONFIGS.size()
	return {
		"level": level,
		"size": 10,
		"fuel_count": 12 + min(extra_level, 6),
		"rocks": 26 + min(extra_level * 2, 10),
	}


func _load_current_level_entry() -> bool:
	current_level_entry = _get_level_entry(current_level)
	if current_level_entry == "" or current_level_entry == "generated":
		return false
	return _load_level_from_path(current_level_entry)


func _get_level_entry(level: int) -> String:
	var index: int = level - 1
	if index >= 0 and index < level_sequence.size():
		return String(level_sequence[index])
	if level_sequence.is_empty():
		return LEVEL_PATH_TEMPLATE % level
	return "generated"


func _load_level_from_json(level: int) -> bool:
	var path: String = LEVEL_PATH_TEMPLATE % level
	return _load_level_from_path(path)


func _load_level_from_path(path: String) -> bool:
	level_path = path
	if not FileAccess.file_exists(path):
		return false

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Could not open level JSON: %s" % path)
		return false

	var json_text := file.get_as_text()
	var parsed = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid level JSON: %s" % path)
		return false

	var level_data: Dictionary = parsed
	if not _validate_level_data(level_data, path):
		return false

	level_source = "json"
	grid_width = int(level_data["width"])
	grid_height = int(level_data["height"])
	initial_fuel = int(level_data.get("initial_fuel", INITIAL_FUEL))
	fuel = initial_fuel
	start_pos = _point_from_dict(level_data["start"])
	goal_pos = _point_from_dict(level_data["goal"])
	generated_route_cells = {}
	grid = _create_empty_grid(grid_width, grid_height)
	grid[start_pos.y][start_pos.x]["type"] = CELL_START
	grid[goal_pos.y][goal_pos.x]["type"] = CELL_END

	for cash_entry in level_data.get("cash", []):
		if not cash_entry is Dictionary:
			continue
		var cash_data: Dictionary = cash_entry
		var cash_point := _point_from_dict(cash_data)
		if _is_in_bounds(cash_point.x, cash_point.y) and grid[cash_point.y][cash_point.x]["type"] == CELL_EMPTY:
			_set_fuel(cash_point.x, cash_point.y, int(cash_data.get("value", 1)))

	for block_entry in level_data.get("blocks", []):
		if not block_entry is Dictionary:
			continue
		var block_data: Dictionary = block_entry
		var block_point := _point_from_dict(block_data)
		if _is_in_bounds(block_point.x, block_point.y) and grid[block_point.y][block_point.x]["type"] == CELL_EMPTY:
			grid[block_point.y][block_point.x]["type"] = CELL_ROCK

	for roller_entry in level_data.get("rollers", []):
		if not roller_entry is Dictionary:
			continue
		var roller_data: Dictionary = roller_entry
		var roller_point := _point_from_dict(roller_data)
		if _is_in_bounds(roller_point.x, roller_point.y) and grid[roller_point.y][roller_point.x]["type"] == CELL_EMPTY:
			_set_roller(roller_point.x, roller_point.y)

	for portal_entry in level_data.get("portals", []):
		if not portal_entry is Dictionary:
			continue
		var portal_data: Dictionary = portal_entry
		var portal_point := _point_from_dict(portal_data)
		if _is_in_bounds(portal_point.x, portal_point.y) and grid[portal_point.y][portal_point.x]["type"] == CELL_EMPTY:
			_set_portal(portal_point.x, portal_point.y, String(portal_data.get("pair", PORTAL_PAIR_A)))

	for mole_entry in level_data.get("moles", []):
		if not mole_entry is Dictionary:
			continue
		var mole_data: Dictionary = mole_entry
		var mole_point := _point_from_dict(mole_data)
		if _is_in_bounds(mole_point.x, mole_point.y) and grid[mole_point.y][mole_point.x]["type"] == CELL_EMPTY:
			_set_mole(mole_point.x, mole_point.y)

	message = "Loaded %s from JSON: %dx%d, fuel %d." % [
		String(level_data.get("name", path)),
		grid_width,
		grid_height,
		initial_fuel,
	]
	return true


func _validate_level_data(level_data: Dictionary, path: String) -> bool:
	var required_keys: Array[String] = ["width", "height", "start", "goal"]
	for key in required_keys:
		if not level_data.has(key):
			push_warning("Level JSON missing '%s': %s" % [key, path])
			return false

	var width: int = int(level_data["width"])
	var height: int = int(level_data["height"])
	if width <= 1 or height <= 1:
		push_warning("Level JSON has invalid size: %s" % path)
		return false

	var json_start := _point_from_dict(level_data["start"])
	var json_goal := _point_from_dict(level_data["goal"])
	if not _is_point_in_bounds(json_start, width, height) or not _is_point_in_bounds(json_goal, width, height):
		push_warning("Level JSON start or goal is out of bounds: %s" % path)
		return false
	if json_start == json_goal:
		push_warning("Level JSON start and goal overlap: %s" % path)
		return false
	if not _validate_level_rollers(level_data, width, height, json_start, json_goal, path):
		return false
	if not _validate_level_portals(level_data, width, height, json_start, json_goal, path):
		return false
	if not _validate_level_moles(level_data, width, height, json_start, json_goal, path):
		return false
	return true


func _validate_level_rollers(level_data: Dictionary, width: int, height: int, json_start: Vector2i, json_goal: Vector2i, path: String) -> bool:
	var rollers = level_data.get("rollers", [])
	if not rollers is Array:
		push_warning("Level JSON rollers must be an array: %s" % path)
		return false

	var blocked_points: Dictionary = {}
	for cash_entry in level_data.get("cash", []):
		if cash_entry is Dictionary:
			blocked_points[_point_from_dict(cash_entry)] = "cash"
	for block_entry in level_data.get("blocks", []):
		if block_entry is Dictionary:
			blocked_points[_point_from_dict(block_entry)] = "block"
	for portal_entry in level_data.get("portals", []):
		if portal_entry is Dictionary:
			blocked_points[_point_from_dict(portal_entry)] = "portal"

	var seen: Dictionary = {}
	for roller_entry in rollers:
		if not roller_entry is Dictionary:
			push_warning("Level JSON roller entry is invalid: %s" % path)
			return false
		var roller_data: Dictionary = roller_entry
		var roller_point := _point_from_dict(roller_data)
		if not _is_point_in_bounds(roller_point, width, height):
			push_warning("Level JSON roller is out of bounds: %s" % path)
			return false
		if roller_point == json_start or roller_point == json_goal:
			push_warning("Level JSON roller overlaps start or goal: %s" % path)
			return false
		if blocked_points.has(roller_point):
			push_warning("Level JSON roller overlaps cash, block, or portal: %s" % path)
			return false
		if seen.has(roller_point):
			push_warning("Level JSON has duplicate roller cells: %s" % path)
			return false
		seen[roller_point] = true
	return true


func _validate_level_moles(level_data: Dictionary, width: int, height: int, json_start: Vector2i, json_goal: Vector2i, path: String) -> bool:
	var moles = level_data.get("moles", [])
	if not moles is Array:
		push_warning("Level JSON moles must be an array: %s" % path)
		return false

	var blocked_points: Dictionary = {}
	for cash_entry in level_data.get("cash", []):
		if cash_entry is Dictionary:
			blocked_points[_point_from_dict(cash_entry)] = "cash"
	for block_entry in level_data.get("blocks", []):
		if block_entry is Dictionary:
			blocked_points[_point_from_dict(block_entry)] = "block"
	for roller_entry in level_data.get("rollers", []):
		if roller_entry is Dictionary:
			blocked_points[_point_from_dict(roller_entry)] = "roller"
	for portal_entry in level_data.get("portals", []):
		if portal_entry is Dictionary:
			blocked_points[_point_from_dict(portal_entry)] = "portal"

	var seen: Dictionary = {}
	for mole_entry in moles:
		if not mole_entry is Dictionary:
			push_warning("Level JSON mole entry is invalid: %s" % path)
			return false
		var mole_data: Dictionary = mole_entry
		var mole_point := _point_from_dict(mole_data)
		if not _is_point_in_bounds(mole_point, width, height):
			push_warning("Level JSON mole is out of bounds: %s" % path)
			return false
		if mole_point == json_start or mole_point == json_goal:
			push_warning("Level JSON mole overlaps start or goal: %s" % path)
			return false
		if blocked_points.has(mole_point):
			push_warning("Level JSON mole overlaps cash, block, portal, or roller: %s" % path)
			return false
		if seen.has(mole_point):
			push_warning("Level JSON has duplicate mole cells: %s" % path)
			return false
		seen[mole_point] = true
	return true


func _validate_level_portals(level_data: Dictionary, width: int, height: int, json_start: Vector2i, json_goal: Vector2i, path: String) -> bool:
	var portals = level_data.get("portals", [])
	if not portals is Array:
		push_warning("Level JSON portals must be an array: %s" % path)
		return false
	if portals.is_empty():
		return true
	if portals.size() != 2:
		push_warning("Level JSON must contain exactly 0 or 2 portals for now: %s" % path)
		return false

	var seen: Dictionary = {}
	var blocked_points: Dictionary = {}
	for cash_entry in level_data.get("cash", []):
		if cash_entry is Dictionary:
			blocked_points[_point_from_dict(cash_entry)] = "cash"
	for block_entry in level_data.get("blocks", []):
		if block_entry is Dictionary:
			blocked_points[_point_from_dict(block_entry)] = "block"
	for roller_entry in level_data.get("rollers", []):
		if roller_entry is Dictionary:
			blocked_points[_point_from_dict(roller_entry)] = "roller"
	for portal_entry in portals:
		if not portal_entry is Dictionary:
			push_warning("Level JSON portal entry is invalid: %s" % path)
			return false
		var portal_data: Dictionary = portal_entry
		var portal_point := _point_from_dict(portal_data)
		var portal_pair := String(portal_data.get("pair", PORTAL_PAIR_A))
		if portal_pair != PORTAL_PAIR_A:
			push_warning("Level JSON only supports Portal A for now: %s" % path)
			return false
		if not _is_point_in_bounds(portal_point, width, height):
			push_warning("Level JSON portal is out of bounds: %s" % path)
			return false
		if portal_point == json_start or portal_point == json_goal:
			push_warning("Level JSON portal overlaps start or goal: %s" % path)
			return false
		if blocked_points.has(portal_point):
			push_warning("Level JSON portal overlaps cash or block: %s" % path)
			return false
		if seen.has(portal_point):
			push_warning("Level JSON has duplicate portal cells: %s" % path)
			return false
		seen[portal_point] = true
	return true


func _point_from_dict(data: Dictionary) -> Vector2i:
	return Vector2i(int(data.get("x", 0)), int(data.get("y", 0)))


func _is_point_in_bounds(point: Vector2i, width: int, height: int) -> bool:
	return point.x >= 0 and point.x < width and point.y >= 0 and point.y < height


func _init_generated_level() -> void:
	var config: Dictionary = _get_level_config(current_level)
	level_source = "generated"
	if current_level_entry == "":
		current_level_entry = "generated"
	level_path = current_level_entry
	grid_width = int(config["size"])
	grid_height = int(config["size"])
	initial_fuel = INITIAL_FUEL
	fuel = initial_fuel
	start_pos = Vector2i(0, 0)
	goal_pos = Vector2i(grid_width - 1, grid_height - 1)
	grid = _create_empty_grid(grid_width, grid_height)
	generated_route_cells = _generate_solution_route()
	grid[start_pos.y][start_pos.x]["type"] = CELL_START
	grid[goal_pos.y][goal_pos.x]["type"] = CELL_END
	_place_rocks(int(config["rocks"]))
	_place_fuels(int(config["fuel_count"]))
	message = "Level %d generated: %dx%d, %d cash stops, %d blocks." % [
		current_level,
		grid_width,
		grid_height,
		int(config["fuel_count"]),
		int(config["rocks"]),
	]


func _create_empty_grid(width: int, height: int) -> Array:
	var rows := []
	for y in range(height):
		var row := []
		for x in range(width):
			row.append({
				"x": x,
				"y": y,
				"type": CELL_EMPTY,
				"powered": false,
				"consumed": false,
				"has_road": false,
				"fuel_value": 0,
				"collected_fuel": false,
				"portal_pair": "",
			})
		rows.append(row)
	return rows


func _place_rocks(count: int) -> void:
	var placed := 0
	var attempts := 0
	while placed < count and attempts < count * 40 + 100:
		attempts += 1
		var x := rng.randi_range(0, grid_width - 1)
		var y := rng.randi_range(0, grid_height - 1)
		if grid[y][x]["type"] != CELL_EMPTY or _is_protected_generation_cell(x, y) or _is_route_cell(x, y):
			continue
		grid[y][x]["type"] = CELL_ROCK
		if _has_non_rock_path():
			placed += 1
		else:
			grid[y][x]["type"] = CELL_EMPTY


func _place_fuels(count: int) -> void:
	var placed := 0
	for point in _get_route_fuel_points(count):
		if placed < count and _is_in_bounds(point.x, point.y) and grid[point.y][point.x]["type"] == CELL_EMPTY:
			_set_fuel(point.x, point.y, 2)
			placed += 1

	var attempts := 0
	while placed < count and attempts < count * 30 + 50:
		attempts += 1
		var x := rng.randi_range(0, grid_width - 1)
		var y := rng.randi_range(0, grid_height - 1)
		if grid[y][x]["type"] == CELL_EMPTY and not _is_protected_generation_cell(x, y):
			_set_fuel(x, y, rng.randi_range(1, 2))
			placed += 1


func _set_fuel(x: int, y: int, value: int) -> void:
	grid[y][x]["type"] = CELL_FUEL
	grid[y][x]["fuel_value"] = value
	grid[y][x]["consumed"] = false
	grid[y][x]["has_road"] = false
	grid[y][x]["collected_fuel"] = false
	grid[y][x]["portal_pair"] = ""


func _set_portal(x: int, y: int, pair: String = PORTAL_PAIR_A) -> void:
	grid[y][x]["type"] = CELL_PORTAL
	grid[y][x]["portal_pair"] = pair
	grid[y][x]["fuel_value"] = 0
	grid[y][x]["consumed"] = false
	grid[y][x]["has_road"] = false
	grid[y][x]["collected_fuel"] = false


func _set_roller(x: int, y: int) -> void:
	grid[y][x]["type"] = CELL_ROLLER
	grid[y][x]["portal_pair"] = ""
	grid[y][x]["fuel_value"] = 0
	grid[y][x]["consumed"] = false
	grid[y][x]["has_road"] = false
	grid[y][x]["collected_fuel"] = false


func _set_mole(x: int, y: int) -> void:
	grid[y][x]["type"] = CELL_MOLE
	grid[y][x]["portal_pair"] = ""
	grid[y][x]["fuel_value"] = 0
	grid[y][x]["consumed"] = false
	grid[y][x]["has_road"] = false
	grid[y][x]["collected_fuel"] = false


func _is_protected_generation_cell(x: int, y: int) -> bool:
	var distance_to_start: int = abs(x - start_pos.x) + abs(y - start_pos.y)
	var distance_to_end: int = abs(x - goal_pos.x) + abs(y - goal_pos.y)
	return distance_to_start <= 1 or distance_to_end <= 1


func _generate_solution_route() -> Dictionary:
	var route: Dictionary = {}
	var position: Vector2i = start_pos
	route[position] = true

	while position != goal_pos:
		var step_x: int = int(sign(goal_pos.x - position.x))
		var step_y: int = int(sign(goal_pos.y - position.y))
		if step_x != 0 and step_y != 0:
			position += Vector2i(step_x, 0) if rng.randf() < 0.5 else Vector2i(0, step_y)
		elif step_x != 0:
			position += Vector2i(step_x, 0)
		else:
			position += Vector2i(0, step_y)
		route[position] = true
	return route


func _is_route_cell(x: int, y: int) -> bool:
	return generated_route_cells.has(Vector2i(x, y))


func _get_route_fuel_points(count: int) -> Array[Vector2i]:
	var route_points: Array[Vector2i] = []
	for key in generated_route_cells.keys():
		var route_point: Vector2i = key
		route_points.append(route_point)
	route_points.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.x + a.y < b.x + b.y
	)

	var points: Array[Vector2i] = []
	var min_gap: int = 2
	var next_distance: int = 2
	for point in route_points:
		var distance: int = point.x + point.y
		if distance <= 1 or distance >= (grid_width - 1) + (grid_height - 1):
			continue
		if distance >= next_distance:
			points.append(point)
			next_distance = distance + min_gap
			if points.size() >= count:
				break
	return points


func _has_non_rock_path() -> bool:
	var start: Vector2i = start_pos
	var target: Vector2i = goal_pos
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {}
	visited[start] = true
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]

	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		if current == target:
			return true
		for direction in directions:
			var next_pos: Vector2i = current + direction
			if not _is_in_bounds(next_pos.x, next_pos.y):
				continue
			if visited.has(next_pos):
				continue
			if String(grid[next_pos.y][next_pos.x]["type"]) == CELL_ROCK:
				continue
			visited[next_pos] = true
			queue.append(next_pos)
	return false


func _get_random_shapes(count: int) -> Array:
	var shapes := []
	var selected_signatures: Dictionary = {}
	var unique_library: Array = _get_unique_shape_library()
	var easy_shapes: Array = _filter_shapes_by_id(unique_library, ["domino", "triomino-i", "triomino-l"])

	if count > 0 and not easy_shapes.is_empty():
		var easy_source: Dictionary = easy_shapes[rng.randi_range(0, easy_shapes.size() - 1)]
		shapes.append(_make_shape_offer(easy_source, shapes.size()))
		selected_signatures[_shape_rotation_signature(easy_source["cells"])] = true

	var attempts := 0
	while shapes.size() < count and selected_signatures.size() < unique_library.size() and attempts < 200:
		attempts += 1
		var source: Dictionary = unique_library[rng.randi_range(0, unique_library.size() - 1)]
		var signature: String = _shape_rotation_signature(source["cells"])
		if selected_signatures.has(signature):
			continue
		shapes.append(_make_shape_offer(source, shapes.size()))
		selected_signatures[signature] = true
	return shapes


func _get_unique_shape_library() -> Array:
	var unique_shapes := []
	var seen_signatures: Dictionary = {}
	for source in SHAPE_LIBRARY:
		var source_shape: Dictionary = source
		var signature: String = _shape_rotation_signature(source_shape["cells"])
		if seen_signatures.has(signature):
			continue
		seen_signatures[signature] = true
		unique_shapes.append(source_shape)
	return unique_shapes


func _filter_shapes_by_id(shapes: Array, ids: Array) -> Array:
	var filtered := []
	for source in shapes:
		var source_shape: Dictionary = source
		if ids.has(String(source_shape["id"])):
			filtered.append(source_shape)
	return filtered


func _make_shape_offer(source: Dictionary, index: int) -> Dictionary:
	return {
		"id": "%s-%d" % [source["id"], index],
		"cells": _copy_points(source["cells"]),
	}


func _copy_points(points: Array) -> Array:
	var copied := []
	for point in points:
		copied.append({"x": int(point["x"]), "y": int(point["y"])})
	return copied


func _shape_rotation_signature(points: Array) -> String:
	var signatures: Array[String] = []
	var rotated: Array = _copy_points(points)
	for i in range(4):
		signatures.append(_shape_cells_signature(rotated))
		rotated = _rotate_cells(rotated)
	signatures.sort()
	return signatures[0]


func _shape_cells_signature(points: Array) -> String:
	var parts: Array[String] = []
	for point in points:
		parts.append("%d,%d" % [int(point["x"]), int(point["y"])])
	parts.sort()
	return ";".join(parts)


func _rotate_cells(points: Array) -> Array:
	var rotated := []
	for point in points:
		rotated.append({"x": -int(point["y"]), "y": int(point["x"])})
	return _normalize_points(rotated)


func rotate_selected_shape() -> void:
	if editor_mode:
		return
	if status != "playing" or selected_shape_index < 0:
		return
	current_shapes[selected_shape_index] = _rotate_shape(current_shapes[selected_shape_index])
	message = "Rotated selected road piece."
	_refresh_pieces()
	_refresh_hud()


func _rotate_shape(shape: Dictionary) -> Dictionary:
	var rotated := []
	for point in shape["cells"]:
		rotated.append({"x": -int(point["y"]), "y": int(point["x"])})
	return {"id": shape["id"], "cells": _normalize_points(rotated)}


func _normalize_points(points: Array) -> Array:
	var min_x := 999
	var min_y := 999
	for point in points:
		min_x = min(min_x, int(point["x"]))
		min_y = min(min_y, int(point["y"]))

	var normalized := []
	for point in points:
		normalized.append({"x": int(point["x"]) - min_x, "y": int(point["y"]) - min_y})
	return normalized


func _on_cell_pressed(x: int, y: int) -> void:
	if editor_mode:
		_paint_editor_cell(x, y)
		return

	if status != "playing":
		return
	if selected_shape_index < 0:
		message = "Select a road piece first."
		_refresh_hud()
		return

	var shape: Dictionary = current_shapes[selected_shape_index]
	if not _is_placement_valid(shape, Vector2i(x, y)):
		message = "Invalid placement. Extend from powered road and avoid blocks, moles, and the destination."
		_refresh_hud()
		return

	var rollers_to_activate: Array[Vector2i] = []
	for offset in shape["cells"]:
		var cell_x := x + int(offset["x"])
		var cell_y := y + int(offset["y"])
		if grid[cell_y][cell_x]["type"] == CELL_EMPTY:
			grid[cell_y][cell_x]["type"] = CELL_PATH
			grid[cell_y][cell_x]["has_road"] = true
		elif grid[cell_y][cell_x]["type"] == CELL_FUEL:
			grid[cell_y][cell_x]["has_road"] = true
		elif grid[cell_y][cell_x]["type"] == CELL_PORTAL:
			grid[cell_y][cell_x]["has_road"] = true
		elif grid[cell_y][cell_x]["type"] == CELL_ROLLER:
			rollers_to_activate.append(Vector2i(cell_x, cell_y))
			grid[cell_y][cell_x]["type"] = CELL_PATH
			grid[cell_y][cell_x]["has_road"] = true

	fuel -= 1
	var roller_gain := 0
	for roller_pos in rollers_to_activate:
		roller_gain += _activate_roller(roller_pos)

	_update_powered_status()
	var gained := _harvest_connected_fuel()
	gained += roller_gain
	if gained > 0:
		fuel += gained
		if rollers_to_activate.is_empty():
			message = "Collected %d fuel by reaching cash stops." % gained
		else:
			message = "Roller paved nearby streets and collected %d fuel." % gained
	elif not rollers_to_activate.is_empty():
		message = "Roller paved nearby streets."
	else:
		message = "Road extended. Keep the taxi moving."

	_update_powered_status()
	var moved_moles := _move_moles_after_placement()
	if moved_moles > 0:
		message += " Moles shifted."
	_update_powered_status()
	if bool(grid[goal_pos.y][goal_pos.x]["powered"]):
		status = "won"
		selected_shape_index = -1
		hover_origin = Vector2i(-1, -1)
		score += fuel * FUEL_TO_SCORE_RATIO + 100
		message = "Route complete. Passenger delivered. Press Next Level to generate a harder route."
	elif fuel <= 0:
		fuel = 0
		status = "lost"
		selected_shape_index = -1
		hover_origin = Vector2i(-1, -1)
		message = "Out of fuel before reaching the destination."
	else:
		current_shapes = _get_random_shapes(3)
		selected_shape_index = -1
		hover_origin = Vector2i(-1, -1)

	_refresh_all()


func _is_placement_valid(shape: Dictionary, origin: Vector2i) -> bool:
	var touches_powered_road := false
	var adds_new_road := false
	for offset in shape["cells"]:
		var x := origin.x + int(offset["x"])
		var y := origin.y + int(offset["y"])
		if not _is_in_bounds(x, y):
			return false

		var cell: Dictionary = grid[y][x]
		var cell_type := String(cell["type"])
		if cell_type == CELL_ROCK or cell_type == CELL_END or cell_type == CELL_MOLE:
			return false
		if cell_type == CELL_EMPTY or (cell_type == CELL_FUEL and not bool(cell["has_road"])) or (cell_type == CELL_PORTAL and not bool(cell["has_road"])) or cell_type == CELL_ROLLER:
			adds_new_road = true
		if bool(cell["powered"]) and _is_cell_power_connectable(cell):
			touches_powered_road = true

	return touches_powered_road and adds_new_road


func _update_powered_status() -> void:
	for row in grid:
		for cell in row:
			cell["powered"] = false

	var queue: Array[Vector2i] = [start_pos]
	grid[start_pos.y][start_pos.x]["powered"] = true
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]

	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		var current_cell: Dictionary = grid[current.y][current.x]
		if String(current_cell["type"]) == CELL_PORTAL:
			for linked_portal in _get_linked_portals(current):
				if bool(grid[linked_portal.y][linked_portal.x]["powered"]):
					continue
				grid[linked_portal.y][linked_portal.x]["powered"] = true
				queue.append(linked_portal)
		for direction in directions:
			var next_pos: Vector2i = current + direction
			if not _is_in_bounds(next_pos.x, next_pos.y):
				continue
			var cell: Dictionary = grid[next_pos.y][next_pos.x]
			if bool(cell["powered"]):
				continue
			if _is_cell_power_connectable(cell):
				cell["powered"] = true
				queue.append(next_pos)


func _is_power_connectable(cell_type: String) -> bool:
	return cell_type == CELL_START or cell_type == CELL_PATH or cell_type == CELL_END or cell_type == CELL_PORTAL


func _is_cell_power_connectable(cell: Dictionary) -> bool:
	var cell_type: String = String(cell["type"])
	if cell_type == CELL_FUEL:
		return bool(cell["has_road"])
	return _is_power_connectable(cell_type)


func _get_linked_portals(portal_pos: Vector2i) -> Array[Vector2i]:
	var linked: Array[Vector2i] = []
	if not _is_in_bounds(portal_pos.x, portal_pos.y):
		return linked
	var source_cell: Dictionary = grid[portal_pos.y][portal_pos.x]
	var pair: String = String(source_cell.get("portal_pair", ""))
	if String(source_cell["type"]) != CELL_PORTAL or pair == "":
		return linked

	for y in range(grid_height):
		for x in range(grid_width):
			var cell: Dictionary = grid[y][x]
			if String(cell["type"]) != CELL_PORTAL:
				continue
			if String(cell.get("portal_pair", "")) != pair:
				continue
			var other_pos := Vector2i(x, y)
			if other_pos != portal_pos:
				linked.append(other_pos)
	return linked


func _get_portal_cells(pair: String = PORTAL_PAIR_A) -> Array[Vector2i]:
	var portals: Array[Vector2i] = []
	for y in range(grid_height):
		for x in range(grid_width):
			var cell: Dictionary = grid[y][x]
			if String(cell["type"]) == CELL_PORTAL and String(cell.get("portal_pair", "")) == pair:
				portals.append(Vector2i(x, y))
	return portals


func _activate_roller(origin: Vector2i) -> int:
	var gained := 0
	for y in range(origin.y - 1, origin.y + 2):
		for x in range(origin.x - 1, origin.x + 2):
			if not _is_in_bounds(x, y):
				continue
			var cell: Dictionary = grid[y][x]
			var cell_type := String(cell["type"])
			if not _can_roller_pave(cell_type):
				continue
			if cell_type == CELL_FUEL and not bool(cell["consumed"]):
				gained += int(cell["fuel_value"])
				_convert_fuel_to_road(x, y)
			else:
				var was_collected_fuel := bool(cell.get("collected_fuel", false))
				grid[y][x]["type"] = CELL_PATH
				grid[y][x]["has_road"] = true
				grid[y][x]["consumed"] = was_collected_fuel
				grid[y][x]["fuel_value"] = 0
				grid[y][x]["collected_fuel"] = was_collected_fuel
				grid[y][x]["portal_pair"] = ""
	return gained


func _can_roller_pave(cell_type: String) -> bool:
	return cell_type == CELL_EMPTY or cell_type == CELL_PATH or cell_type == CELL_FUEL or cell_type == CELL_ROLLER


func _move_moles_after_placement() -> int:
	var mole_positions := _get_mole_cells()
	if mole_positions.is_empty():
		return 0

	var reserved_originals: Dictionary = {}
	for mole_pos in mole_positions:
		reserved_originals[mole_pos] = true
	for mole_pos in mole_positions:
		_clear_cell(mole_pos.x, mole_pos.y)

	var moved := 0
	var occupied_targets: Dictionary = {}
	for mole_pos in mole_positions:
		var targets := _get_mole_move_targets(reserved_originals, occupied_targets)
		var target := mole_pos
		if not targets.is_empty():
			target = targets[rng.randi_range(0, targets.size() - 1)]
			if target != mole_pos:
				moved += 1
		_set_mole(target.x, target.y)
		occupied_targets[target] = true
	return moved


func _get_mole_cells() -> Array[Vector2i]:
	var moles: Array[Vector2i] = []
	for y in range(grid_height):
		for x in range(grid_width):
			if String(grid[y][x]["type"]) == CELL_MOLE:
				moles.append(Vector2i(x, y))
	return moles


func _get_mole_move_targets(reserved_originals: Dictionary, occupied_targets: Dictionary) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	for y in range(grid_height):
		for x in range(grid_width):
			var target := Vector2i(x, y)
			if reserved_originals.has(target) or occupied_targets.has(target):
				continue
			if String(grid[y][x]["type"]) == CELL_EMPTY:
				targets.append(target)
	return targets


func _harvest_connected_fuel() -> int:
	var gained := 0
	var changed := true
	while changed:
		changed = false
		_update_powered_status()
		var fuel_points: Array[Vector2i] = []
		for y in range(grid_height):
			for x in range(grid_width):
				if _is_fuel_collectable(x, y):
					fuel_points.append(Vector2i(x, y))

		for point in fuel_points:
			var cell: Dictionary = grid[point.y][point.x]
			if String(cell["type"]) != CELL_FUEL or bool(cell["consumed"]):
				continue
			gained += int(cell["fuel_value"])
			_convert_fuel_to_road(point.x, point.y)
			changed = true
	return gained


func _is_fuel_collectable(x: int, y: int) -> bool:
	var cell: Dictionary = grid[y][x]
	if String(cell["type"]) != CELL_FUEL or bool(cell["consumed"]):
		return false
	if bool(cell["powered"]):
		return true

	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	for direction in directions:
		var neighbor_pos := Vector2i(x, y) + direction
		if not _is_in_bounds(neighbor_pos.x, neighbor_pos.y):
			continue
		var neighbor: Dictionary = grid[neighbor_pos.y][neighbor_pos.x]
		if bool(neighbor["powered"]) and _is_cell_power_connectable(neighbor):
			return true
	return false


func _convert_fuel_to_road(x: int, y: int) -> void:
	grid[y][x]["type"] = CELL_PATH
	grid[y][x]["powered"] = true
	grid[y][x]["consumed"] = true
	grid[y][x]["has_road"] = true
	grid[y][x]["fuel_value"] = 0
	grid[y][x]["collected_fuel"] = true
	grid[y][x]["portal_pair"] = ""


func _is_in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < grid_width and y >= 0 and y < grid_height


func _refresh_all() -> void:
	_refresh_hud()
	_refresh_board()
	_refresh_pieces()
	_refresh_debug_panel()
	_refresh_editor_panel()


func _refresh_hud() -> void:
	level_label.text = "Level %d (%s)" % [current_level, level_source]
	fuel_label.text = "Fuel %d" % fuel
	score_label.text = "Cash $%d" % score
	status_label.text = "Mode Editor" if editor_mode else "Status %s" % status.capitalize()
	message_label.text = message
	_refresh_level_jump_selector()
	if next_button:
		next_button.disabled = editor_mode or status != "won"
		next_button.text = "Next Level" if status == "won" else "Next Level Locked"
	_refresh_debug_panel()
	_refresh_editor_panel()


func _refresh_level_jump_selector() -> void:
	if not level_jump_selector:
		return
	level_jump_selector.clear()
	var entries := _get_level_selector_entries()
	for i in range(entries.size()):
		var entry: String = String(entries[i])
		level_jump_selector.add_item(_format_level_selector_text(i, entry), i)

	if entries.size() > 0:
		var selected_index: int = clampi(current_level - 1, 0, entries.size() - 1)
		level_jump_selector.select(selected_index)


func _toggle_debug_panel() -> void:
	debug_visible = not debug_visible
	if debug_panel:
		debug_panel.visible = debug_visible
	_refresh_board_visuals()
	_refresh_debug_panel()


func _toggle_editor_mode() -> void:
	editor_mode = not editor_mode
	selected_shape_index = -1
	hover_origin = Vector2i(-1, -1)
	if editor_mode:
		status = "playing"
		message = "Editor mode: brush %s. Click board cells to paint." % editor_brush
	else:
		_reset_play_state_after_edit()
		message = "Play mode: testing edited board."
	if editor_panel:
		editor_panel.visible = editor_mode
	_refresh_all()


func _set_editor_brush(brush: String) -> void:
	editor_brush = brush
	message = "Editor brush: %s" % editor_brush
	_refresh_hud()


func _on_editor_grid_width_changed(value: float) -> void:
	if not editor_mode:
		return
	var new_width: int = clampi(int(value), EDITOR_MIN_GRID_WIDTH, EDITOR_MAX_GRID_WIDTH)
	if new_width == grid_width:
		return
	_resize_editor_grid(new_width, grid_height)


func _on_editor_grid_height_changed(value: float) -> void:
	if not editor_mode:
		return
	var new_height: int = clampi(int(value), EDITOR_MIN_GRID_HEIGHT, EDITOR_MAX_GRID_HEIGHT)
	if new_height == grid_height:
		return
	_resize_editor_grid(grid_width, new_height)


func _on_editor_initial_fuel_changed(value: float) -> void:
	if not editor_mode:
		return
	initial_fuel = clampi(int(value), EDITOR_MIN_INITIAL_FUEL, EDITOR_MAX_INITIAL_FUEL)
	_reset_play_state_after_edit()
	message = "Initial fuel set to %d." % initial_fuel
	_refresh_all()


func _on_editor_cash_value_changed(value: float) -> void:
	if not editor_mode:
		return
	editor_cash_value = clampi(int(value), EDITOR_MIN_CASH_VALUE, EDITOR_MAX_CASH_VALUE)
	message = "Cash brush value set to %d." % editor_cash_value
	_refresh_hud()


func _resize_editor_grid(new_width: int, new_height: int) -> void:
	var old_grid: Array = grid
	var old_width: int = grid_width
	var old_height: int = grid_height
	var old_start: Vector2i = start_pos
	var old_goal: Vector2i = goal_pos

	grid_width = new_width
	grid_height = new_height
	grid = _create_empty_grid(grid_width, grid_height)
	for y in range(min(old_height, grid_height)):
		for x in range(min(old_width, grid_width)):
			var old_cell: Dictionary = old_grid[y][x]
			var old_type: String = String(old_cell["type"])
			if old_type == CELL_FUEL:
				_set_fuel(x, y, int(old_cell.get("fuel_value", editor_cash_value)))
			elif old_type == CELL_ROCK:
				grid[y][x]["type"] = CELL_ROCK
			elif old_type == CELL_PORTAL:
				_set_portal(x, y, String(old_cell.get("portal_pair", PORTAL_PAIR_A)))
			elif old_type == CELL_ROLLER:
				_set_roller(x, y)
			elif old_type == CELL_MOLE:
				_set_mole(x, y)

	start_pos = _clamp_point_to_grid(old_start)
	goal_pos = _clamp_point_to_grid(old_goal)
	if start_pos == goal_pos:
		start_pos = Vector2i(0, 0)
		goal_pos = Vector2i(grid_width - 1, grid_height - 1)
	_clear_cell(start_pos.x, start_pos.y)
	_clear_cell(goal_pos.x, goal_pos.y)
	grid[start_pos.y][start_pos.x]["type"] = CELL_START
	grid[goal_pos.y][goal_pos.x]["type"] = CELL_END

	_reset_play_state_after_edit()
	message = "Board resized to %dx%d." % [grid_width, grid_height]
	_refresh_all()


func _clamp_point_to_grid(point: Vector2i) -> Vector2i:
	return Vector2i(clampi(point.x, 0, grid_width - 1), clampi(point.y, 0, grid_height - 1))


func _refresh_editor_panel() -> void:
	if not editor_panel:
		return
	editor_panel.visible = editor_mode
	_refresh_editor_level_selector()
	if editor_grid_width_spin:
		editor_grid_width_spin.set_value_no_signal(grid_width)
	if editor_grid_height_spin:
		editor_grid_height_spin.set_value_no_signal(grid_height)
	if editor_initial_fuel_spin:
		editor_initial_fuel_spin.set_value_no_signal(initial_fuel)
	if editor_cash_value_spin:
		editor_cash_value_spin.set_value_no_signal(editor_cash_value)
	if editor_validation_label:
		var validation := _validate_current_editor_level()
		if bool(validation["ok"]):
			editor_validation_label.text = "Validation: OK"
		else:
			editor_validation_label.text = "Validation:\n%s" % "\n".join(validation["errors"])
	if editor_json_text:
		editor_json_text.text = _build_current_level_json_text()


func _refresh_editor_level_selector() -> void:
	if not editor_level_selector:
		return

	editor_refreshing_level_selector = true
	editor_level_selector.clear()
	var entries := _get_level_selector_entries()

	for i in range(entries.size()):
		var entry: String = String(entries[i])
		editor_level_selector.add_item(_format_level_selector_text(i, entry), i)

	var selected_index: int = clampi(current_level - 1, 0, max(entries.size() - 1, 0))
	if entries.size() > 0:
		editor_level_selector.select(selected_index)
	editor_refreshing_level_selector = false

	if editor_level_path_label:
		editor_level_path_label.text = "Current: %s" % _current_editor_level_path_text()


func _get_level_selector_entries() -> Array:
	var entries := level_sequence.duplicate()
	if entries.is_empty():
		entries.append(_get_level_entry(current_level))
	return entries


func _format_level_selector_text(index: int, entry: String) -> String:
	var prefix: String = "%02d" % (index + 1)
	if entry == "" or entry == "generated":
		return "%s: generated" % prefix
	return "%s: %s" % [prefix, entry.get_file()]


func _current_editor_level_path_text() -> String:
	if current_level_entry != "":
		return current_level_entry
	if level_path != "":
		return level_path
	return _suggest_editor_level_entry()


func _on_editor_level_selected(index: int) -> void:
	if editor_refreshing_level_selector:
		return
	if index < 0:
		return
	current_level = index + 1
	init_level()
	if editor_mode:
		message = "Editing level %d." % current_level
		_refresh_all()


func _on_load_selected_level_pressed() -> void:
	if not level_jump_selector:
		return
	var selected_index: int = level_jump_selector.get_selected_id()
	if selected_index < 0:
		return
	current_level = selected_index + 1
	selected_shape_index = -1
	hover_origin = Vector2i(-1, -1)
	init_level()
	message = "Jumped to level %d." % current_level
	_refresh_all()


func _copy_editor_json_to_clipboard() -> void:
	var validation := _validate_current_editor_level()
	if not bool(validation["ok"]):
		message = "Fix validation errors before copying JSON."
		_refresh_hud()
		return
	var json_text: String = _build_current_level_json_text()
	DisplayServer.clipboard_set(json_text)
	message = "Current level JSON copied to clipboard."
	_refresh_hud()


func _copy_editor_level_entry_to_clipboard() -> void:
	var entry: String = _suggest_editor_level_entry()
	DisplayServer.clipboard_set("\"%s\"" % entry)
	message = "levels.json entry copied: %s" % entry
	_refresh_hud()


func _suggest_editor_level_entry() -> String:
	if level_source == "json" and level_path.begins_with("res://levels/"):
		return level_path
	return LEVEL_PATH_TEMPLATE % current_level


func _save_editor_level() -> void:
	var validation := _validate_current_editor_level()
	if not bool(validation["ok"]):
		message = "Fix validation errors before saving level."
		_refresh_hud()
		return

	var save_path: String = _current_editor_save_path()
	if save_path == "":
		message = "No valid level file path is available for saving."
		_refresh_hud()
		return

	if not _write_text_file(save_path, _build_current_level_json_text()):
		message = "Could not save level file: %s" % save_path
		_refresh_hud()
		return

	_assign_current_level_entry(save_path)
	if not _write_level_sequence_file():
		message = "Saved level, but could not update levels.json."
		_refresh_hud()
		return
	level_source = "json"
	level_path = save_path
	current_level_entry = save_path
	message = "Saved level %d to %s." % [current_level, save_path]
	_refresh_all()


func _current_editor_save_path() -> String:
	if current_level_entry.begins_with("res://levels/") and current_level_entry.ends_with(".json"):
		return current_level_entry
	if level_path.begins_with("res://levels/") and level_path.ends_with(".json"):
		return level_path
	return LEVEL_PATH_TEMPLATE % current_level


func _assign_current_level_entry(path: String) -> void:
	var index: int = current_level - 1
	while level_sequence.size() <= index:
		level_sequence.append("generated")
	level_sequence[index] = path


func _create_new_editor_level() -> void:
	var new_path: String = _next_new_level_path()
	var entry_index: int = _find_level_entry_index(new_path)
	if entry_index < 0:
		entry_index = _insert_level_entry_before_generated(new_path)

	current_level = entry_index + 1
	current_level_entry = new_path
	level_path = new_path
	level_source = "json"
	_reset_to_blank_editor_level()

	if not _write_text_file(new_path, _build_current_level_json_text()):
		message = "Could not create level file: %s" % new_path
		_refresh_all()
		return

	if not _write_level_sequence_file():
		message = "Created level file, but could not update levels.json."
		_refresh_all()
		return
	message = "Created new level: %s." % new_path
	_refresh_all()


func _reset_to_blank_editor_level() -> void:
	grid_width = clampi(grid_width, EDITOR_MIN_GRID_WIDTH, EDITOR_MAX_GRID_WIDTH)
	grid_height = clampi(grid_height, EDITOR_MIN_GRID_HEIGHT, EDITOR_MAX_GRID_HEIGHT)
	initial_fuel = clampi(initial_fuel, EDITOR_MIN_INITIAL_FUEL, EDITOR_MAX_INITIAL_FUEL)
	fuel = initial_fuel
	status = "playing"
	selected_shape_index = -1
	hover_origin = Vector2i(-1, -1)
	current_shapes = _get_random_shapes(3)
	generated_route_cells = {}
	start_pos = Vector2i(0, 0)
	goal_pos = Vector2i(grid_width - 1, grid_height - 1)
	grid = _create_empty_grid(grid_width, grid_height)
	grid[start_pos.y][start_pos.x]["type"] = CELL_START
	grid[goal_pos.y][goal_pos.x]["type"] = CELL_END
	_update_powered_status()


func _next_new_level_path() -> String:
	for i in range(1, 1000):
		var path: String = LEVEL_PATH_TEMPLATE % i
		if not FileAccess.file_exists(path):
			return path
	return LEVEL_PATH_TEMPLATE % (level_sequence.size() + 1)


func _find_level_entry_index(entry: String) -> int:
	for i in range(level_sequence.size()):
		if String(level_sequence[i]) == entry:
			return i
	return -1


func _insert_level_entry_before_generated(entry: String) -> int:
	for i in range(level_sequence.size()):
		if String(level_sequence[i]) == "generated":
			level_sequence.insert(i, entry)
			return i
	level_sequence.append(entry)
	return level_sequence.size() - 1


func _write_level_sequence_file() -> bool:
	var data: Dictionary = {"levels": level_sequence}
	return _write_text_file(LEVEL_LIST_PATH, JSON.stringify(data, "\t"))


func _write_text_file(path: String, text: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not write file: %s" % path)
		return false
	file.store_string(text)
	return true


func _validate_current_editor_level() -> Dictionary:
	var errors: Array[String] = []
	if grid_width < EDITOR_MIN_GRID_WIDTH or grid_width > EDITOR_MAX_GRID_WIDTH:
		errors.append("Width must be between %d and %d." % [EDITOR_MIN_GRID_WIDTH, EDITOR_MAX_GRID_WIDTH])
	if grid_height < EDITOR_MIN_GRID_HEIGHT or grid_height > EDITOR_MAX_GRID_HEIGHT:
		errors.append("Height must be between %d and %d." % [EDITOR_MIN_GRID_HEIGHT, EDITOR_MAX_GRID_HEIGHT])
	if not _is_in_bounds(start_pos.x, start_pos.y):
		errors.append("Start is out of bounds.")
	if not _is_in_bounds(goal_pos.x, goal_pos.y):
		errors.append("Goal is out of bounds.")
	if start_pos == goal_pos:
		errors.append("Start and goal cannot overlap.")

	var start_count := 0
	var goal_count := 0
	for y in range(grid_height):
		for x in range(grid_width):
			var point := Vector2i(x, y)
			var cell_type: String = String(grid[y][x]["type"])
			if cell_type == CELL_START:
				start_count += 1
			elif cell_type == CELL_END:
				goal_count += 1
			if (cell_type == CELL_FUEL or cell_type == CELL_ROCK or cell_type == CELL_PORTAL or cell_type == CELL_ROLLER or cell_type == CELL_MOLE) and (point == start_pos or point == goal_pos):
				errors.append("Start/goal cannot overlap cash, blocks, portals, rollers, or moles.")

	if start_count != 1:
		errors.append("Level must contain exactly one start.")
	if goal_count != 1:
		errors.append("Level must contain exactly one goal.")
	var portal_count := _get_portal_cells(PORTAL_PAIR_A).size()
	if portal_count != 0 and portal_count != 2:
		errors.append("Portal A must contain exactly two cells, or none.")
	if _is_in_bounds(start_pos.x, start_pos.y) and String(grid[start_pos.y][start_pos.x]["type"]) != CELL_START:
		errors.append("Start marker does not match the start cell.")
	if _is_in_bounds(goal_pos.x, goal_pos.y) and String(grid[goal_pos.y][goal_pos.x]["type"]) != CELL_END:
		errors.append("Goal marker does not match the goal cell.")

	return {
		"ok": errors.is_empty(),
		"errors": errors,
	}


func _refresh_debug_panel() -> void:
	if not debug_panel or not debug_label:
		return
	debug_panel.visible = debug_visible
	if not debug_visible:
		return

	var stats := _collect_level_stats()
	var selected_text: String = "none"
	if selected_shape_index >= 0 and selected_shape_index < current_shapes.size():
		selected_text = String(current_shapes[selected_shape_index].get("id", "piece"))

	debug_label.text = "\n".join([
		"Source: %s" % level_source,
		"Entry: %s" % current_level_entry,
		"Path: %s" % level_path,
		"Grid: %dx%d" % [grid_width, grid_height],
		"Start: (%d,%d)" % [start_pos.x, start_pos.y],
		"Goal: (%d,%d)" % [goal_pos.x, goal_pos.y],
		"Fuel: %d / initial %d" % [fuel, initial_fuel],
		"Status: %s" % status,
		"Selected: %s" % selected_text,
		"Cash: %d / %d" % [int(stats["cash_collected"]), int(stats["cash_total"])],
		"Blocks: %d" % int(stats["blocks"]),
		"Portals: %d" % int(stats["portals"]),
		"Rollers: %d" % int(stats["rollers"]),
		"Moles: %d" % int(stats["moles"]),
		"Powered: %d" % int(stats["powered"]),
		"Route cells: %d" % generated_route_cells.size(),
	])


func _collect_level_stats() -> Dictionary:
	var stats: Dictionary = {
		"cash_total": 0,
		"cash_collected": 0,
		"blocks": 0,
		"portals": 0,
		"rollers": 0,
		"moles": 0,
		"powered": 0,
	}
	for row in grid:
		for cell in row:
			var cell_type: String = String(cell["type"])
			if cell_type == CELL_FUEL:
				stats["cash_total"] += 1
				if bool(cell["consumed"]):
					stats["cash_collected"] += 1
			elif bool(cell.get("collected_fuel", false)):
				stats["cash_total"] += 1
				stats["cash_collected"] += 1
			elif cell_type == CELL_ROCK:
				stats["blocks"] += 1
			elif cell_type == CELL_PORTAL:
				stats["portals"] += 1
			elif cell_type == CELL_ROLLER:
				stats["rollers"] += 1
			elif cell_type == CELL_MOLE:
				stats["moles"] += 1
			if bool(cell["powered"]):
				stats["powered"] += 1
	return stats


func _paint_editor_cell(x: int, y: int) -> void:
	if not _is_in_bounds(x, y):
		return
	if editor_brush == CELL_START:
		if Vector2i(x, y) == goal_pos:
			message = "Start cannot overlap goal."
			_refresh_hud()
			return
		_clear_cell(start_pos.x, start_pos.y)
		start_pos = Vector2i(x, y)
		_clear_cell(x, y)
		grid[y][x]["type"] = CELL_START
	elif editor_brush == CELL_END:
		if Vector2i(x, y) == start_pos:
			message = "Goal cannot overlap start."
			_refresh_hud()
			return
		_clear_cell(goal_pos.x, goal_pos.y)
		goal_pos = Vector2i(x, y)
		_clear_cell(x, y)
		grid[y][x]["type"] = CELL_END
	else:
		if Vector2i(x, y) == start_pos or Vector2i(x, y) == goal_pos:
			message = "Move start/goal before painting this cell."
			_refresh_hud()
			return
		if editor_brush == CELL_PORTAL and String(grid[y][x]["type"]) != CELL_PORTAL and _get_portal_cells(PORTAL_PAIR_A).size() >= 2:
			message = "Portal A already has two cells. Paint Ground first."
			_refresh_hud()
			return
		_clear_cell(x, y)
		if editor_brush == CELL_FUEL:
			_set_fuel(x, y, editor_cash_value)
		elif editor_brush == CELL_ROCK:
			grid[y][x]["type"] = CELL_ROCK
		elif editor_brush == CELL_PORTAL:
			_set_portal(x, y, PORTAL_PAIR_A)
		elif editor_brush == CELL_ROLLER:
			_set_roller(x, y)
		elif editor_brush == CELL_MOLE:
			_set_mole(x, y)
		else:
			grid[y][x]["type"] = CELL_EMPTY

	_reset_play_state_after_edit()
	message = "Painted (%d,%d) with %s." % [x, y, editor_brush]
	_refresh_all()


func _clear_cell(x: int, y: int) -> void:
	if not _is_in_bounds(x, y):
		return
	grid[y][x]["type"] = CELL_EMPTY
	grid[y][x]["powered"] = false
	grid[y][x]["consumed"] = false
	grid[y][x]["has_road"] = false
	grid[y][x]["fuel_value"] = 0
	grid[y][x]["collected_fuel"] = false
	grid[y][x]["portal_pair"] = ""


func _reset_play_state_after_edit() -> void:
	status = "playing"
	fuel = initial_fuel
	selected_shape_index = -1
	hover_origin = Vector2i(-1, -1)
	current_shapes = _get_random_shapes(3)
	generated_route_cells = {}
	for y in range(grid_height):
		for x in range(grid_width):
			var cell: Dictionary = grid[y][x]
			if String(cell["type"]) == CELL_PATH:
				_clear_cell(x, y)
			elif String(cell["type"]) == CELL_FUEL:
				cell["powered"] = false
				cell["consumed"] = false
				cell["has_road"] = false
				cell["collected_fuel"] = false
			elif String(cell["type"]) == CELL_PORTAL:
				cell["powered"] = false
				cell["consumed"] = false
				cell["has_road"] = false
				cell["collected_fuel"] = false
			elif String(cell["type"]) == CELL_ROLLER:
				cell["powered"] = false
				cell["consumed"] = false
				cell["has_road"] = false
				cell["collected_fuel"] = false
			elif String(cell["type"]) == CELL_MOLE:
				cell["powered"] = false
				cell["consumed"] = false
				cell["has_road"] = false
				cell["collected_fuel"] = false
			else:
				cell["powered"] = false
	grid[start_pos.y][start_pos.x]["type"] = CELL_START
	grid[goal_pos.y][goal_pos.x]["type"] = CELL_END
	_update_powered_status()


func _build_current_level_json_text() -> String:
	var level_data: Dictionary = {
		"id": "level_%03d" % current_level,
		"name": "Edited Level %d" % current_level,
		"width": grid_width,
		"height": grid_height,
		"initial_fuel": initial_fuel,
		"start": {"x": start_pos.x, "y": start_pos.y},
		"goal": {"x": goal_pos.x, "y": goal_pos.y},
		"cash": [],
		"blocks": [],
		"portals": [],
		"rollers": [],
		"moles": [],
	}

	for y in range(grid_height):
		for x in range(grid_width):
			var cell: Dictionary = grid[y][x]
			var cell_type: String = String(cell["type"])
			if cell_type == CELL_FUEL:
				level_data["cash"].append({
					"x": x,
					"y": y,
					"value": int(cell["fuel_value"]),
				})
			elif cell_type == CELL_ROCK:
				level_data["blocks"].append({
					"x": x,
					"y": y,
				})
			elif cell_type == CELL_PORTAL:
				level_data["portals"].append({
					"x": x,
					"y": y,
					"pair": String(cell.get("portal_pair", PORTAL_PAIR_A)),
				})
			elif cell_type == CELL_ROLLER:
				level_data["rollers"].append({
					"x": x,
					"y": y,
				})
			elif cell_type == CELL_MOLE:
				level_data["moles"].append({
					"x": x,
					"y": y,
				})
	return JSON.stringify(level_data, "\t")


func _refresh_board() -> void:
	board_grid.columns = grid_width
	for child in board_grid.get_children():
		child.queue_free()

	for y in range(grid_height):
		for x in range(grid_width):
			var button := Button.new()
			var cell_size: int = _get_cell_pixel_size()
			button.custom_minimum_size = Vector2(cell_size, cell_size)
			button.expand_icon = true
			button.clip_text = true
			button.add_theme_color_override("font_color", Color.WHITE)
			button.mouse_entered.connect(_on_cell_hovered.bind(x, y))
			button.pressed.connect(_on_cell_pressed.bind(x, y))
			board_grid.add_child(button)
			_apply_cell_button_visual(button, x, y)


func _refresh_board_visuals() -> void:
	for y in range(grid_height):
		for x in range(grid_width):
			var index: int = y * grid_width + x
			if index >= board_grid.get_child_count():
				return
			var button: Button = board_grid.get_child(index) as Button
			if button:
				_apply_cell_button_visual(button, x, y)


func _get_cell_pixel_size() -> int:
	var longest_side: int = max(grid_width, grid_height)
	if longest_side <= 6:
		return _ui_size(52)
	if longest_side <= 8:
		return _ui_size(44)
	return _ui_size(36)


func _apply_cell_button_visual(button: Button, x: int, y: int) -> void:
	var preview_state: String = _get_preview_state(x, y)
	var cell: Dictionary = grid[y][x]
	button.text = ""
	button.icon = null if preview_state != "" else _cell_texture(cell)
	button.add_theme_font_size_override("font_size", _ui_size(18))
	button.tooltip_text = "(%d, %d) %s" % [x, y, _cell_tooltip(cell)]
	button.add_theme_stylebox_override("normal", _cell_style(cell, false, preview_state))
	button.add_theme_stylebox_override("hover", _cell_style(cell, true, preview_state))
	button.add_theme_stylebox_override("pressed", _cell_style(cell, true, preview_state))


func _cell_texture(cell: Dictionary) -> Texture2D:
	var cell_type := String(cell["type"])
	if cell_type == CELL_START:
		return _get_tile_texture("taxi_start")
	if cell_type == CELL_END:
		return _get_tile_texture("goal")
	if cell_type == CELL_PATH:
		return _get_tile_texture("road_powered") if bool(cell["powered"]) else _get_tile_texture("road")
	if cell_type == CELL_FUEL:
		if bool(cell["has_road"]):
			if bool(cell["consumed"]):
				return _get_tile_texture("cash_collected")
			return _get_tile_texture("cash_road")
		return _get_tile_texture("cash")
	if cell_type == CELL_ROCK:
		return _get_tile_texture("block")
	if cell_type == CELL_PORTAL:
		return _get_tile_texture("portal")
	if cell_type == CELL_ROLLER:
		return _get_tile_texture("roller")
	if cell_type == CELL_MOLE:
		return _get_tile_texture("mole")
	return _get_tile_texture("ground")


func _get_tile_texture(texture_name: String) -> Texture2D:
	return tile_textures[texture_name] as Texture2D


func _cell_tooltip(cell: Dictionary) -> String:
	var cell_type := String(cell["type"])
	if cell_type == CELL_START:
		return "Taxi start"
	if cell_type == CELL_END:
		return "Goal"
	if cell_type == CELL_PATH:
		if bool(cell.get("collected_fuel", false)):
			return "Collected cash road"
		return "Powered road" if bool(cell["powered"]) else "Road"
	if cell_type == CELL_FUEL:
		if bool(cell["has_road"]):
			if bool(cell["consumed"]):
				return "Collected cash road"
			return "Cash road +%d" % int(cell["fuel_value"])
		return "Cash +%d" % int(cell["fuel_value"])
	if cell_type == CELL_ROCK:
		return "Block"
	if cell_type == CELL_PORTAL:
		var powered_text := "powered " if bool(cell["powered"]) else ""
		var road_text := "road-connected " if bool(cell["has_road"]) else ""
		return "%s%sPortal %s" % [powered_text.capitalize(), road_text, String(cell.get("portal_pair", PORTAL_PAIR_A))]
	if cell_type == CELL_ROLLER:
		return "Roller"
	if cell_type == CELL_MOLE:
		return "Mole"
	return "Ground"


func _cell_style(cell: Dictionary, hover: bool = false, preview_state: String = "") -> StyleBoxFlat:
	var cell_type := String(cell["type"])
	var background := Color("#4a3528")
	var border := Color("#2a201a")

	if cell_type == CELL_START:
		background = Color("#d97706")
		border = Color("#fde68a")
	elif cell_type == CELL_END:
		background = Color("#1d4ed8") if bool(cell["powered"]) else Color("#172554")
		border = Color("#93c5fd")
	elif cell_type == CELL_PATH:
		background = Color("#242424") if bool(cell["powered"]) else Color("#3f3f46")
		border = Color("#facc15") if bool(cell["powered"]) else Color("#71717a")
	elif cell_type == CELL_FUEL:
		if bool(cell["has_road"]):
			background = Color("#242424") if bool(cell["powered"]) else Color("#3f3f46")
			border = Color("#86efac") if not bool(cell["consumed"]) else Color("#facc15")
		else:
			background = Color("#166534") if not bool(cell["consumed"]) else Color("#14532d")
			border = Color("#86efac") if not bool(cell["consumed"]) else Color("#4ade80")
	elif cell_type == CELL_ROCK:
		background = Color("#57534e")
		border = Color("#292524")
	elif cell_type == CELL_PORTAL:
		background = Color("#4c1d95") if bool(cell["powered"]) else Color("#312e81")
		border = Color("#f0abfc") if bool(cell["has_road"]) else Color("#c4b5fd")
	elif cell_type == CELL_ROLLER:
		background = Color("#92400e")
		border = Color("#fdba74")
	elif cell_type == CELL_MOLE:
		background = Color("#713f12")
		border = Color("#fbbf24")

	if preview_state == "valid":
		background = Color("#facc15")
		border = Color("#fff7ad")
	elif preview_state == "invalid":
		background = Color("#ef4444")
		border = Color("#fecaca")
	elif editor_mode and int(cell["x"]) == hover_origin.x and int(cell["y"]) == hover_origin.y:
		border = Color("#f97316")
	elif debug_visible and bool(cell["powered"]):
		border = Color("#38bdf8")
	elif debug_visible and _is_route_cell(int(cell["x"]), int(cell["y"])):
		border = Color("#a78bfa")

	if hover:
		background = background.lightened(0.12)

	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	var thick_border: bool = (debug_visible and (bool(cell["powered"]) or _is_route_cell(int(cell["x"]), int(cell["y"])))) or (editor_mode and int(cell["x"]) == hover_origin.x and int(cell["y"]) == hover_origin.y)
	style.set_border_width_all(4 if thick_border else 2)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style


func _refresh_pieces() -> void:
	for child in pieces_container.get_children():
		child.queue_free()

	for i in range(current_shapes.size()):
		var button := Button.new()
		button.custom_minimum_size = Vector2(_ui_size(285), _ui_size(123))
		button.text = _shape_preview_text(current_shapes[i])
		button.tooltip_text = "Select this road piece."
		if i == selected_shape_index:
			button.add_theme_stylebox_override("normal", _piece_style(Color("#854d0e"), Color("#facc15")))
		else:
			button.add_theme_stylebox_override("normal", _piece_style(Color("#27272a"), Color("#71717a")))
		button.add_theme_stylebox_override("hover", _piece_style(Color("#3f3f46"), Color("#facc15")))
		button.pressed.connect(_select_shape.bind(i))
		pieces_container.add_child(button)


func _piece_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style


func _shape_preview_text(shape: Dictionary) -> String:
	var max_x := 0
	var max_y := 0
	for point in shape["cells"]:
		max_x = max(max_x, int(point["x"]))
		max_y = max(max_y, int(point["y"]))

	var lines := []
	for y in range(max_y + 1):
		var line := ""
		for x in range(max_x + 1):
			line += "[]" if _shape_has_cell(shape, x, y) else "  "
		lines.append(line)
	return "\n".join(lines)


func _shape_has_cell(shape: Dictionary, x: int, y: int) -> bool:
	for point in shape["cells"]:
		if int(point["x"]) == x and int(point["y"]) == y:
			return true
	return false


func _select_shape(index: int) -> void:
	if editor_mode:
		return
	if status != "playing":
		return
	selected_shape_index = index
	hover_origin = Vector2i(-1, -1)
	message = "Selected piece %d. Click the board to place it." % (index + 1)
	_refresh_pieces()
	_refresh_hud()


func _on_cell_hovered(x: int, y: int) -> void:
	if editor_mode:
		hover_origin = Vector2i(x, y)
		_refresh_board_visuals()
		return
	if status != "playing" or selected_shape_index < 0:
		return
	hover_origin = Vector2i(x, y)
	_refresh_board_visuals()


func _on_board_mouse_exited() -> void:
	if hover_origin.x < 0:
		return
	hover_origin = Vector2i(-1, -1)
	_refresh_board_visuals()


func _get_preview_state(x: int, y: int) -> String:
	if editor_mode:
		return ""
	if status != "playing" or selected_shape_index < 0 or hover_origin.x < 0:
		return ""
	var shape: Dictionary = current_shapes[selected_shape_index]
	var is_preview_cell := false
	for offset in shape["cells"]:
		if x == hover_origin.x + int(offset["x"]) and y == hover_origin.y + int(offset["y"]):
			is_preview_cell = true
			break
	if not is_preview_cell:
		return ""
	return "valid" if _is_placement_valid(shape, hover_origin) else "invalid"


func _on_next_level_pressed() -> void:
	if status != "won":
		return
	current_level += 1
	init_level()
