class_name LeaderboardPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

var dim: ColorRect
var panel: PanelContainer
var title_label: Label
var close_button: Button
var rows_box: VBoxContainer

var _leaderboard_service


func _ready() -> void:
	_build_nodes()
	visible = false
	UiSkin.apply_panel(panel, "large")
	UiSkin.apply_button(close_button, "small")
	title_label.text = Data.text("lb_title")
	close_button.text = Data.text("lb_close")
	UiSkin.apply_modal_title(title_label)
	_install_button_feedback(close_button)
	close_button.pressed.connect(close)
	dim.gui_input.connect(_on_dim_gui_input)


func _build_nodes() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	dim = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.02, 0.03, 0.08, 0.48)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -430.0
	panel.offset_top = -520.0
	panel.offset_right = 430.0
	panel.offset_bottom = 520.0
	add_child(panel)

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.name = "Layout"
	layout.add_theme_constant_override("separation", 20)
	margin.add_child(layout)

	var header := HBoxContainer.new()
	header.name = "Header"
	header.add_theme_constant_override("separation", 16)
	layout.add_child(header)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 44)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title_label)

	close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.custom_minimum_size = Vector2(150.0, 68.0)
	close_button.add_theme_font_size_override("font_size", 28)
	header.add_child(close_button)

	rows_box = VBoxContainer.new()
	rows_box.name = "RowsBox"
	rows_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows_box.add_theme_constant_override("separation", 8)
	layout.add_child(rows_box)


func open(leaderboard_service) -> void:
	_leaderboard_service = leaderboard_service
	visible = true
	_clear_rows(Data.text("lb_loading"))
	if _leaderboard_service == null:
		_clear_rows(Data.text("lb_empty"))
		return
	if not _leaderboard_service.top_loaded.is_connected(_on_top_loaded):
		_leaderboard_service.top_loaded.connect(_on_top_loaded)
	_leaderboard_service.request_top(10)


func close() -> void:
	visible = false


func _on_top_loaded(rows: Array) -> void:
	for child in rows_box.get_children():
		child.queue_free()
	if rows.is_empty():
		_add_status_row(Data.text("lb_empty"))
		return
	for row: Dictionary in rows:
		_add_score_row(row)


func _add_score_row(row: Dictionary) -> void:
	var row_panel := PanelContainer.new()
	row_panel.custom_minimum_size = Vector2(0.0, 58.0)
	UiSkin.apply_panel(row_panel, "leaderboard_me" if bool(row.get("is_me", false)) else "leaderboard_row")

	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	row_panel.add_child(layout)

	var rank_label := _make_row_label("#%d" % int(row.get("rank", 0)), 72.0, HORIZONTAL_ALIGNMENT_CENTER)
	var name_label := _make_row_label(str(row.get("display_name", "")), 0.0, HORIZONTAL_ALIGNMENT_LEFT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var score_label := _make_row_label(str(int(row.get("best_payout", 0))), 150.0, HORIZONTAL_ALIGNMENT_RIGHT)
	layout.add_child(rank_label)
	layout.add_child(name_label)
	layout.add_child(score_label)
	rows_box.add_child(row_panel)


func _make_row_label(text: String, min_width: float, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(min_width, 0.0)
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_font_size_override("font_size", 28)
	UiSkin.apply_light_panel_label(label)
	return label


func _clear_rows(message: String) -> void:
	for child in rows_box.get_children():
		child.queue_free()
	_add_status_row(message)


func _add_status_row(message: String) -> void:
	var label := Label.new()
	label.custom_minimum_size = Vector2(0.0, 180.0)
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 34)
	UiSkin.apply_light_panel_label(label)
	rows_box.add_child(label)


func _on_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func _install_button_feedback(button: Button) -> void:
	var duration := float(Data.animation_timing_config().get("ui", {}).get("button_feedback", 0.0))
	ButtonFeedback.install(button, duration)
