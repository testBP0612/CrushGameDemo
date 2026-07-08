class_name WinBanner
extends CanvasLayer

const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

signal dismissed

const DIGIT_DIR := "res://Assets/final/ui/windigits"
const DIGIT_CHARS := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ","]

var _root: Control
var _digit_center: CenterContainer
var _digit_row: HBoxContainer
var _fallback_label: Label
var _hint_label: Label
var _textures := {}
var _source_digit_height := 1.0
var _using_digit_textures := false
var _target_payout := 0
var _config := {}
var _main_tween: Tween
var _breath_tween: Tween
var _can_dismiss := false
var _closing := false


func play(payout: int) -> bool:
	_target_payout = maxi(payout, 0)
	_config = _animation_timing_config().get("effects", {}).get("win_banner", {})
	if _config.is_empty():
		push_warning("WinBanner skipped: missing animation_timing.effects.win_banner config.")
		queue_free()
		return false

	var coin_layer := int(_animation_timing_config().get("effects", {}).get("coin_burst", {}).get("canvas_layer", 2))
	layer = coin_layer + 1
	_load_digit_textures()
	_build_tree()
	_play_intro()
	_arm_dismiss_timers()
	return true


func _build_tree() -> void:
	_root = Control.new()
	_root.name = "WinBannerRoot"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.gui_input.connect(_on_root_gui_input)
	add_child(_root)

	var dimmer := ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.color = Color(0.035, 0.06, 0.13, 0.84)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dimmer)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)

	var layout := VBoxContainer.new()
	layout.name = "Layout"
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.custom_minimum_size = Vector2(980.0, 720.0)
	layout.add_theme_constant_override("separation", 34)
	center.add_child(layout)

	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = _text("win_banner_title")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	title_label.add_theme_font_size_override("font_size", 72)
	UiSkin.apply_ribbon_label(title_label)
	layout.add_child(title_label)

	_digit_center = CenterContainer.new()
	_digit_center.name = "DigitStrip"
	_digit_center.custom_minimum_size = Vector2(980.0, 220.0)
	layout.add_child(_digit_center)

	if _using_digit_textures:
		_digit_row = HBoxContainer.new()
		_digit_row.alignment = BoxContainer.ALIGNMENT_CENTER
		_digit_row.add_theme_constant_override("separation", -8)
		_digit_center.add_child(_digit_row)
	else:
		_fallback_label = Label.new()
		_fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_fallback_label.add_theme_font_size_override("font_size", 138)
		_fallback_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.15, 1.0))
		_fallback_label.add_theme_color_override("font_outline_color", UiSkin.DEEP_NAVY)
		_fallback_label.add_theme_constant_override("outline_size", 16)
		_digit_center.add_child(_fallback_label)

	_hint_label = Label.new()
	_hint_label.name = "ContinueLabel"
	_hint_label.text = _text("win_banner_continue")
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 34)
	_hint_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.84, 0.92))
	_hint_label.add_theme_color_override("font_outline_color", UiSkin.DEEP_NAVY)
	_hint_label.add_theme_constant_override("outline_size", 6)
	layout.add_child(_hint_label)

	_set_display_value(0.0)


func _load_digit_textures() -> void:
	_textures.clear()
	_using_digit_textures = true
	_source_digit_height = 1.0
	for digit_char in DIGIT_CHARS:
		var path := _digit_path(digit_char)
		if not ResourceLoader.exists(path, "Texture2D"):
			push_warning("WinBanner digit fallback: missing %s." % path)
			_textures.clear()
			_using_digit_textures = false
			return
		var texture := load(path) as Texture2D
		if texture == null:
			push_warning("WinBanner digit fallback: failed to load %s." % path)
			_textures.clear()
			_using_digit_textures = false
			return
		_textures[digit_char] = texture
		if digit_char != ",":
			_source_digit_height = maxf(_source_digit_height, float(texture.get_height()))


func _digit_path(digit_char: String) -> String:
	if digit_char == ",":
		return "%s/digit_comma.png" % DIGIT_DIR
	return "%s/digit_%s.png" % [DIGIT_DIR, digit_char]


func _play_intro() -> void:
	_root.modulate.a = 0.0
	_digit_center.scale = Vector2(0.86, 0.86)
	_digit_center.pivot_offset = Vector2(490.0, 110.0)
	_hint_label.modulate.a = 0.0

	var appear := float(_config.get("appear", 0.0))
	var count_up := float(_config.get("count_up", 0.0))
	_main_tween = create_tween()
	_main_tween.tween_property(_root, "modulate:a", 1.0, appear).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_main_tween.parallel().tween_property(_digit_center, "scale", Vector2.ONE, appear).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_main_tween.tween_method(_set_display_value, 0.0, float(_target_payout), count_up).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_main_tween.parallel().tween_property(_hint_label, "modulate:a", 1.0, count_up * 0.6).set_delay(count_up * 0.4)
	_main_tween.tween_callback(_start_breath)


func _arm_dismiss_timers() -> void:
	var min_show := float(_config.get("min_show", 0.0))
	var auto_dismiss := float(_config.get("auto_dismiss", 0.0))
	get_tree().create_timer(min_show).timeout.connect(func() -> void:
		_can_dismiss = true
	)
	if auto_dismiss > 0.0:
		get_tree().create_timer(auto_dismiss).timeout.connect(_dismiss)


func _start_breath() -> void:
	if _closing or _digit_center == null or not is_instance_valid(_digit_center):
		return
	_breath_tween = create_tween().set_loops()
	_breath_tween.tween_property(_digit_center, "scale", Vector2(1.035, 1.035), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_breath_tween.tween_property(_digit_center, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if _hint_label != null and is_instance_valid(_hint_label):
		var hint_tween := create_tween().set_loops()
		hint_tween.tween_property(_hint_label, "modulate:a", 0.48, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		hint_tween.tween_property(_hint_label, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _set_display_value(value: float) -> void:
	var text := _format_amount(int(round(value)))
	if _using_digit_textures:
		for child in _digit_row.get_children():
			child.queue_free()
		var digit_height := float(_config.get("digit_height", 0.0))
		for index in range(text.length()):
			var digit_char := text.substr(index, 1)
			var texture: Texture2D = _textures.get(digit_char, null)
			if texture == null:
				continue
			var height := digit_height * float(texture.get_height()) / _source_digit_height
			var width := height * float(texture.get_width()) / float(texture.get_height())
			var rect := TextureRect.new()
			rect.texture = texture
			rect.custom_minimum_size = Vector2(width, height)
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_digit_row.add_child(rect)
	else:
		_fallback_label.text = text


func _format_amount(value: int) -> String:
	var raw := str(maxi(value, 0))
	var output := ""
	var group_count := 0
	for index in range(raw.length() - 1, -1, -1):
		if group_count > 0 and group_count % 3 == 0:
			output = "," + output
		output = raw.substr(index, 1) + output
		group_count += 1
	return output


func _animation_timing_config() -> Dictionary:
	var data := _data_node()
	if data == null:
		return {}
	return data.animation_timing_config()


func _text(key: String) -> String:
	var data := _data_node()
	if data == null:
		return "[%s]" % key
	return data.text(key)


func _data_node() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.root.get_node_or_null("Data")


func _on_root_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_root.accept_event()
		_request_dismiss()
	elif event is InputEventScreenTouch and event.pressed:
		_root.accept_event()
		_request_dismiss()


func _request_dismiss() -> void:
	if not _can_dismiss:
		return
	_dismiss()


func _dismiss() -> void:
	if _closing:
		return
	_closing = true
	if _main_tween != null and _main_tween.is_valid():
		_main_tween.kill()
	if _breath_tween != null and _breath_tween.is_valid():
		_breath_tween.kill()
	var fade_out := float(_config.get("fade_out", 0.0))
	var tween := create_tween()
	tween.tween_property(_root, "modulate:a", 0.0, fade_out).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		dismissed.emit()
		queue_free()
	)
