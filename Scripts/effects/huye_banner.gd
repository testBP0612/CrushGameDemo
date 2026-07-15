class_name HuyeBanner
extends CanvasLayer

const BANNER_PATH := "res://Assets/final/huye_event_banner.png"
const CANVAS_WIDTH := 1080.0
const HuyeJackpotFxScript := preload("res://Scripts/effects/huye_jackpot_fx.gd")

signal dismissed

var _root: Control
var _modal: Control
var _config: Dictionary
var _can_dismiss := false
var _closing := false
var _jackpot_fx: Node2D


func play() -> bool:
	_config = Data.animation_timing_config().get("effects", {}).get("huye_event", {})
	if _config.is_empty():
		push_warning("HuyeBanner skipped: missing animation_timing.effects.huye_event config.")
		return false
	layer = int(Data.animation_timing_config().get("effects", {}).get("coin_burst", {}).get("canvas_layer", 2)) + 1
	_build_tree()
	_play_jackpot_fx()
	_play_intro()
	_arm_dismiss()
	return true


func _build_tree() -> void:
	_root = Control.new()
	_root.name = "HuyeBannerRoot"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.gui_input.connect(_on_gui_input)
	add_child(_root)

	var dimmer := ColorRect.new()
	dimmer.color = Color(0.025, 0.035, 0.10, 0.82)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# 輸入統一交給全畫面的 _root；遮罩若 STOP 會吃掉滑鼠事件，導致點擊無法關閉。
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dimmer)

	_modal = Control.new()
	_modal.name = "EventModal"
	_modal.set_anchors_preset(Control.PRESET_CENTER)
	_modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_modal)

	var banner_height := 0.0
	if ResourceLoader.exists(BANNER_PATH, "Texture2D"):
		var texture := load(BANNER_PATH) as Texture2D
		if texture != null:
			banner_height = CANVAS_WIDTH * float(texture.get_height()) / maxf(float(texture.get_width()), 1.0)
			var banner := TextureRect.new()
			banner.name = "HuyeEventBanner"
			banner.texture = texture
			banner.position = Vector2(-CANVAS_WIDTH * 0.5, -banner_height * 0.5)
			banner.size = Vector2(CANVAS_WIDTH, banner_height)
			banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_modal.add_child(banner)
	else:
		push_warning("HuyeBanner missing %s; showing continue hint fallback." % BANNER_PATH)

	var hint := Label.new()
	hint.name = "ContinueHint"
	hint.text = Data.text("huye_banner_continue")
	hint.position = Vector2(-CANVAS_WIDTH * 0.5, banner_height * 0.5 + float(_config.get("banner_hint_gap", 0.0)))
	hint.size = Vector2(CANVAS_WIDTH, float(_config.get("banner_hint_height", 0.0)))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", int(_config.get("banner_hint_font_size", 0)))
	hint.add_theme_color_override("font_color", Color(1.0, 0.96, 0.84, 0.94))
	hint.add_theme_color_override("font_outline_color", Color(0.08, 0.12, 0.24, 1.0))
	hint.add_theme_constant_override("outline_size", int(_config.get("banner_hint_outline_size", 0)))
	_modal.add_child(hint)


func _play_intro() -> void:
	_root.modulate.a = 0.0
	var fx_config: Dictionary = _config.get("jackpot_fx", {})
	var fx_enabled := bool(fx_config.get("enabled", false))
	# FX 關閉／整組缺失時維持卡 24 的 0.94→1.0 淡入，不套用本卡 overshoot。
	var scale_start := float(fx_config.get("banner_scale_start", 0.94)) if fx_enabled else 0.94
	var scale_peak := float(fx_config.get("banner_scale_overshoot", 1.0)) if fx_enabled else 1.0
	_modal.scale = Vector2.ONE * scale_start
	var appear := float(_config.get("banner_appear", 0.0))
	var tween := create_tween()
	tween.tween_property(_root, "modulate:a", 1.0, appear)
	tween.parallel().tween_property(
		_modal,
		"scale",
		Vector2.ONE * scale_peak,
		appear
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var settle_duration := float(fx_config.get("banner_scale_settle_duration", 0.0)) if fx_enabled else 0.0
	if settle_duration > 0.0:
		tween.tween_property(_modal, "scale", Vector2.ONE, settle_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _play_jackpot_fx() -> void:
	var fx := HuyeJackpotFxScript.new()
	if not fx.setup(_config):
		fx.queue_free()
		return
	_jackpot_fx = fx
	_root.add_child(fx)
	fx.play_banner_confetti(get_viewport().get_visible_rect().size)


func _arm_dismiss() -> void:
	get_tree().create_timer(float(_config.get("banner_min_show", 0.0))).timeout.connect(func() -> void: _can_dismiss = true)
	var auto_dismiss := float(_config.get("banner_auto_dismiss", 0.0))
	if auto_dismiss > 0.0:
		get_tree().create_timer(auto_dismiss).timeout.connect(_dismiss)


func _on_gui_input(event: InputEvent) -> void:
	# 任意鍵包含滑鼠所有按鍵與觸控；不限定左鍵。
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		_root.accept_event()
		if _can_dismiss:
			_dismiss()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and _can_dismiss:
		get_viewport().set_input_as_handled()
		_dismiss()


func _dismiss() -> void:
	if _closing:
		return
	_closing = true
	var tween := create_tween()
	tween.tween_property(_root, "modulate:a", 0.0, float(_config.get("banner_fade_out", 0.0)))
	await tween.finished
	dismissed.emit()
	queue_free()
