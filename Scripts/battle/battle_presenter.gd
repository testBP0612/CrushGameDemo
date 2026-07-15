class_name BattlePresenter
extends Node2D

signal attack_sequence_finished(hit_count: int)
signal monster_hurt_finished
signal monster_death_finished
signal advance_walk_finished
signal transition_finished
signal monster_counter_finished
signal player_hurt_finished
signal hit_landed
signal huye_impact
signal huye_rescue_visual_finished

const UiSkin := preload("res://Scripts/ui/ui_skin.gd")
const HitFlash := preload("res://Scripts/effects/hit_flash.gd")
const ScreenShake := preload("res://Scripts/effects/screen_shake.gd")
const HuyeJackpotFxScript := preload("res://Scripts/effects/huye_jackpot_fx.gd")
const BACKGROUND_ASSET_DIR := "res://Assets/final/"
const BACKGROUND_ASSET_EXTENSIONS := [".jpg", ".jpeg", ".png"]
const BATTLE_CANVAS_SIZE := Vector2(1080.0, 1920.0)
const HUYE_ASSET_PATH := "res://Assets/final/huye.png"
const INTERMISSION_BACKGROUND_PATH := "res://Assets/final/intermission.jpg"

@onready var background_fallback: ColorRect = $Background
@onready var background_image: TextureRect = $BackgroundImage
@onready var hero = $Hero
@onready var monster = $Monster
@onready var monster_name_label: Label = $MonsterNameLabel
@onready var monster_hp_bar: ProgressBar = $MonsterHpBar
@onready var transition_overlay: ColorRect = $TransitionOverlay

var _current_monster: Dictionary = {}
var _current_background_path := ""
# D-019：血條改危險度顯示（程式生成，原血條僅隱藏——傷害節奏演出仍依賴其內部數值）
var _danger_panel: Control
var _danger_row: HBoxContainer
var _danger_caption: Label
var _danger_icons: HBoxContainer
var _risk_art_in_use := false
var _risk_star_texture: Texture2D
# 受擊 punch：多段連擊時先殺前一個 tween 並歸位，避免縮放疊加
var _punch_tween: Tween
var _monster_base_scale := Vector2.ONE
var _monster_hidden_after_huye := false
var _huye_coin_origin := Vector2.ZERO
var _active_huye_visual: Node2D
var _active_huye_jackpot_fx: Node2D
var _huye_exit_tween: Tween
var _intermission_background_active := false


func _ready() -> void:
	UiSkin.style_monster_status(monster_name_label, monster_hp_bar)
	_build_danger_display()
	_configure_background_image()
	transition_overlay.modulate.a = 0.0
	show_monster_for_stage(1)


func show_monster_for_stage(stage_to_challenge: int, update_background := true) -> void:
	if update_background:
		_show_background_for_stage(stage_to_challenge)

	_current_monster = Data.monster_for_stage(stage_to_challenge)
	if _current_monster.is_empty():
		return

	var name_key := str(_current_monster.get("name_key", ""))
	monster_name_label.text = Data.text(name_key)
	_monster_hidden_after_huye = false
	# 虎爺局結束時 monster.visible=false；BETTING 的 _update_view 跑在本函式之前
	# （當時旗標未清），這裡必須自行恢復，否則虎爺局撤退後的下注畫面怪物隱形。
	monster.visible = true
	monster.apply_monster(_current_monster)
	_monster_base_scale = monster.scale
	monster_hp_bar.max_value = float(_current_monster.get("display_hp", 0))
	monster_hp_bar.value = monster_hp_bar.max_value
	_update_danger_display(stage_to_challenge)


func play_attack_sequence(stage_to_challenge: int) -> void:
	show_monster_for_stage(stage_to_challenge)
	if _current_monster.is_empty():
		attack_sequence_finished.emit(0)
		return

	var hit_range: Array = _current_monster.get("attack_hits_range", [])
	if hit_range.size() != 2:
		push_error("BattlePresenter missing attack_hits_range for stage %d." % stage_to_challenge)
		attack_sequence_finished.emit(0)
		return

	var hit_count := randi_range(int(hit_range[0]), int(hit_range[1]))
	var attack_config: Dictionary = Data.battle_sequence_config().get("attack_sequence", {})
	var first_hit_delay := float(attack_config.get("first_hit_delay", 0.0))
	var hit_interval := float(attack_config.get("hit_interval", 0.0))
	var damage_ratio := float(attack_config.get("damage_per_hit_ratio", 0.0))
	var display_hp := int(_current_monster.get("display_hp", 0))
	var damage_per_hit: int = maxi(1, int(ceil(float(display_hp) * damage_ratio)))

	print("BATTLE_ATTACK hits stage=%d count=%d range=%s hit_interval=%s" % [stage_to_challenge, hit_count, hit_range, hit_interval])
	for hit_index in range(hit_count):
		var delay: float = first_hit_delay if hit_index == 0 else hit_interval
		await get_tree().create_timer(delay).timeout
		await hero.play_attack(monster.global_position)
		_apply_hit_damage(damage_per_hit)
		hit_landed.emit()
		_play_hit_feel()

	attack_sequence_finished.emit(hit_count)


func play_monster_hurt() -> void:
	monster_hp_bar.value = 0.0
	await monster.play_hurt()
	monster_hurt_finished.emit()


func play_monster_death() -> void:
	monster_hp_bar.value = 0.0
	await monster.play_death()
	monster_death_finished.emit()


func monster_canvas_position() -> Vector2:
	if monster == null or not is_instance_valid(monster):
		return Vector2.ZERO

	var target: CanvasItem = monster.hit_flash_target()
	if target != null and is_instance_valid(target):
		var local_center := Vector2.ZERO
		if target is Control:
			local_center = (target as Control).size * 0.5
		elif target.has_method("get_rect"):
			local_center = (target.call("get_rect") as Rect2).get_center()
		return target.get_global_transform_with_canvas() * local_center

	return monster.get_global_transform_with_canvas().origin


func huye_coin_origin() -> Vector2:
	return _huye_coin_origin


func play_advance_walk() -> void:
	await _fade_out_active_huye()
	await hero.play_walk()
	advance_walk_finished.emit()


func play_transition(stage_to_challenge: int) -> void:
	var sequence_config: Dictionary = Data.battle_sequence_config().get("advance_sequence", {})
	var transition_duration := float(sequence_config.get("transition_duration", 0.0))
	var half_duration := transition_duration * 0.5
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, half_duration)
	tween.tween_callback(_snap_hero_and_show_monster.bind(stage_to_challenge))
	tween.tween_property(transition_overlay, "modulate:a", 0.0, half_duration)
	await tween.finished
	await monster.play_enter()
	transition_finished.emit()


func _snap_hero_and_show_monster(stage_to_challenge: int) -> void:
	hero.snap_home()
	show_monster_for_stage(stage_to_challenge)


func play_monster_counter() -> void:
	await monster.play_counter(hero.global_position)
	monster_counter_finished.emit()


func play_huye_rescue() -> void:
	var config: Dictionary = Data.animation_timing_config().get("effects", {}).get("huye_event", {})
	if config.is_empty():
		push_warning("Huye rescue skipped visual: missing animation_timing.effects.huye_event.")
		huye_impact.emit()
		huye_rescue_visual_finished.emit()
		return

	var dimmer := ColorRect.new()
	dimmer.name = "HuyeDramaticDimmer"
	dimmer.position = Vector2.ZERO
	dimmer.size = BATTLE_CANVAS_SIZE
	dimmer.color = Color(0.02, 0.025, 0.08, 0.0)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)
	move_child(dimmer, monster.get_index())
	var dim_tween := create_tween()
	dim_tween.tween_property(dimmer, "color:a", float(config.get("dimmer_alpha", 0.0)), float(config.get("dimmer_fade", 0.0)))

	# 先清掉上一輪殘留，再建立本次事件的 FX；若反過來會把剛建立的
	# 落下尾跡與撞擊粒子一起清除，只剩預告粒子來得及顯示。
	_clear_active_huye()
	_setup_huye_jackpot_fx(config)
	if _active_huye_jackpot_fx != null:
		_active_huye_jackpot_fx.play_anticipation(monster_canvas_position())
	await monster.play_huye_counter_slow(hero.global_position, config)
	# 金幣應從螢幕內的命中位置噴出；不可沿用怪物飛出畫面的終點座標。
	_huye_coin_origin = monster_canvas_position()
	var huye := _create_huye_visual(config)
	_active_huye_visual = huye
	add_child(huye)
	var impact_position := monster_canvas_position() + Vector2(0.0, float(config.get("huye_impact_offset_y", 0.0)))
	huye.position = Vector2(impact_position.x, float(config.get("huye_start_y", 0.0)))
	if _active_huye_jackpot_fx != null:
		_active_huye_jackpot_fx.play_descent_trail(huye.position, impact_position)
	var huye_target_scale := huye.scale
	var fx_config: Dictionary = config.get("jackpot_fx", {})
	if bool(fx_config.get("enabled", false)):
		huye.scale = huye_target_scale * float(fx_config.get("drop_scale_start", 1.0))
	var drop := create_tween()
	drop.tween_property(huye, "position", impact_position, float(config.get("huye_drop_duration", 0.0)))\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if bool(fx_config.get("enabled", false)):
		drop.parallel().tween_property(
			huye,
			"scale",
			huye_target_scale * float(fx_config.get("drop_scale_end", 1.0)),
			float(config.get("huye_drop_duration", 0.0))
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await drop.finished
	if _active_huye_jackpot_fx != null:
		var impact_fx_position := impact_position + Vector2(0.0, float(fx_config.get("impact_fx_offset_y", 0.0)))
		_active_huye_jackpot_fx.play_impact(impact_fx_position)
	_play_huye_impact_feel(config)
	huye_impact.emit()
	var scale_settle_duration := float(fx_config.get("drop_scale_settle_duration", 0.0))
	if bool(fx_config.get("enabled", false)) and scale_settle_duration > 0.0:
		var scale_settle := create_tween()
		scale_settle.tween_property(huye, "scale", huye_target_scale, scale_settle_duration)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await _play_huye_landing_bounce(huye, config)
	await get_tree().create_timer(float(config.get("impact_hold", 0.0))).timeout
	await monster.play_huye_fly_out(config)
	monster.reset_after_huye()
	_monster_hidden_after_huye = true
	monster.visible = false
	var fade := create_tween()
	fade.tween_property(dimmer, "color:a", 0.0, float(config.get("dimmer_fade", 0.0)))
	await fade.finished
	dimmer.queue_free()
	# 彈跳、怪物飛出與淡出全部演完後，畫面明確停住一整段再開 modal。
	var pre_banner_delay := float(config.get("pre_banner_delay", 0.0))
	if pre_banner_delay > 0.0:
		await get_tree().create_timer(pre_banner_delay).timeout
	_clear_active_huye_jackpot_fx()
	huye_rescue_visual_finished.emit()


func _play_huye_landing_bounce(huye: Node2D, config: Dictionary) -> void:
	var duration := float(config.get("huye_bounce_duration", 0.0))
	var height := float(config.get("huye_bounce_height", 0.0))
	if duration <= 0.0 or height <= 0.0 or huye == null or not is_instance_valid(huye):
		return
	var landing_position := huye.position
	var tween := create_tween()
	tween.tween_property(huye, "position:y", landing_position.y - height, duration * 0.45)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(huye, "position:y", landing_position.y, duration * 0.55)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tween.finished


func _play_huye_impact_feel(config: Dictionary) -> void:
	var duration := float(config.get("impact_shake_duration", 0.0))
	var strength := float(config.get("impact_shake_strength", 0.0))
	if duration <= 0.0:
		return
	HitFlash.play(monster.hit_flash_target(), duration)
	ScreenShake.play(self, duration, strength)
	_play_hit_punch(duration)


func _create_huye_visual(config: Dictionary) -> Node2D:
	if ResourceLoader.exists(HUYE_ASSET_PATH, "Texture2D"):
		var texture := load(HUYE_ASSET_PATH) as Texture2D
		if texture != null:
			var sprite := Sprite2D.new()
			sprite.texture = texture
			var width := float(config.get("huye_display_width", 0.0))
			var scale_factor := width / maxf(float(texture.get_width()), 1.0)
			sprite.scale = Vector2.ONE * scale_factor
			return sprite

	# 缺圖 fallback：金色圓＋資料驅動文字，不阻塞事件。
	var fallback := Node2D.new()
	var circle := Polygon2D.new()
	var points := PackedVector2Array()
	var radius := float(config.get("huye_display_width", 0.0)) * 0.36
	var segments := 24
	for index in range(segments):
		points.append(Vector2.RIGHT.rotated(TAU * float(index) / float(segments)) * radius)
	circle.polygon = points
	circle.color = Color(1.0, 0.68, 0.08, 1.0)
	fallback.add_child(circle)
	var label := Label.new()
	label.text = Data.text("huye_fallback_label")
	label.position = Vector2(-radius, -40.0)
	label.size = Vector2(radius * 2.0, 80.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(0.10, 0.16, 0.30))
	fallback.add_child(label)
	return fallback


func play_player_hurt() -> void:
	await hero.play_hurt()
	await hero.play_defeat()
	var delay := float(Data.battle_sequence_config().get("result_resolution", {}).get("lose_branch", {}).get("defeat_settle_delay", 0.0))
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	player_hurt_finished.emit()


func reset_for_betting() -> void:
	_clear_active_huye()
	hero.reset_pose()
	# 插頁只替換 Texture，關卡背景快取仍可能指向原路徑；下一局必須強制重載。
	_intermission_background_active = false
	_show_default_background(true)
	show_monster_for_stage(1, false)


## 任務 23 結算稿只有街景＋結果卡；只切顯示，不碰角色/狀態機資料。
func set_settlement_presentation(enabled: bool, use_intermission_background := false) -> void:
	if enabled:
		_fade_out_active_huye()
	if enabled and use_intermission_background:
		_show_intermission_background()
	elif _intermission_background_active:
		_intermission_background_active = false
		_show_default_background(true)
	hero.visible = not enabled
	monster.visible = not enabled and not _monster_hidden_after_huye
	monster_name_label.visible = not enabled
	if _danger_panel != null and is_instance_valid(_danger_panel):
		_danger_panel.visible = not enabled and Data.danger_max_level() > 0


func _show_intermission_background() -> void:
	if _intermission_background_active:
		return
	if not ResourceLoader.exists(INTERMISSION_BACKGROUND_PATH, "Texture2D"):
		push_warning("BattlePresenter intermission background missing; keeping stage background.")
		return
	var texture := load(INTERMISSION_BACKGROUND_PATH) as Texture2D
	if texture == null:
		push_warning("BattlePresenter intermission background failed to load; keeping stage background.")
		return
	background_image.texture = texture
	background_image.visible = true
	_intermission_background_active = true


func _fade_out_active_huye() -> void:
	if _active_huye_visual == null or not is_instance_valid(_active_huye_visual):
		_active_huye_visual = null
		return
	if _huye_exit_tween != null and _huye_exit_tween.is_valid():
		await _huye_exit_tween.finished
		return
	var target := _active_huye_visual
	var config: Dictionary = Data.animation_timing_config().get("effects", {}).get("huye_event", {})
	_huye_exit_tween = create_tween()
	_huye_exit_tween.tween_property(target, "modulate:a", 0.0, float(config.get("huye_exit_fade", 0.0)))
	await _huye_exit_tween.finished
	if target != null and is_instance_valid(target):
		target.queue_free()
	if _active_huye_visual == target:
		_active_huye_visual = null
	_huye_exit_tween = null


func _clear_active_huye() -> void:
	if _huye_exit_tween != null and _huye_exit_tween.is_valid():
		_huye_exit_tween.kill()
	_huye_exit_tween = null
	if _active_huye_visual != null and is_instance_valid(_active_huye_visual):
		_active_huye_visual.queue_free()
	_active_huye_visual = null
	_clear_active_huye_jackpot_fx()


func _setup_huye_jackpot_fx(config: Dictionary) -> void:
	_clear_active_huye_jackpot_fx()
	var fx := HuyeJackpotFxScript.new()
	if not fx.setup(config):
		fx.queue_free()
		return
	_active_huye_jackpot_fx = fx
	add_child(fx)


func _clear_active_huye_jackpot_fx() -> void:
	if _active_huye_jackpot_fx != null and is_instance_valid(_active_huye_jackpot_fx):
		_active_huye_jackpot_fx.queue_free()
	_active_huye_jackpot_fx = null


## D-019：血條位置改放危險度列（危險度＋爪印等級）。全程式生成，不動 .tscn。
## 外層加半透明深色藥丸底板（夜間 UI 輪）——原本裸放在花背景上對比不足。
func _build_danger_display() -> void:
	# 2026-07-12 設計師危險度美術：risk_state（骷髏+深色橫條）+ risk_star（金星）。
	# 兩張都在才走美術路線；缺任一張退回原程式藥丸+爪印（D-004）。
	var state_texture: Texture2D = UiSkin.art_texture("risk_state")
	_risk_star_texture = UiSkin.art_texture("risk_star")
	_risk_art_in_use = state_texture != null and _risk_star_texture != null
	if _risk_art_in_use:
		_build_risk_art_display(state_texture)
		return
	_build_danger_pill_display()


## 美術版：骷髏橫條 1:1 原尺寸（447x112），金星由 _update_danger_display 疊上；
## 怪物名改白字置於橫條上方（骷髏右側），對齊設計稿。
func _build_risk_art_display(state_texture: Texture2D) -> void:
	# 血條僅供錨定/內部演出，美術路線也必須藏（舊路線在 _build_danger_pill_display 藏）
	monster_hp_bar.visible = false
	var root := Control.new()
	root.name = "DangerPanel"
	root.position = Vector2(560.0, 748.0)
	root.size = Vector2(447.0, 112.0)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_danger_panel = root

	var bar := TextureRect.new()
	bar.name = "RiskStateBar"
	bar.texture = state_texture
	bar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bar)

	_danger_icons = HBoxContainer.new()
	_danger_icons.name = "DangerIcons"
	_danger_icons.alignment = BoxContainer.ALIGNMENT_BEGIN
	_danger_icons.add_theme_constant_override("separation", 10)
	# 橫條實帶（像素掃描）y47..93、x~140..415 → 星列垂直置中於 y70
	_danger_icons.position = Vector2(150.0, 49.0)
	_danger_icons.size = Vector2(250.0, 42.0)
	_danger_icons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_danger_icons)

	monster_name_label.add_theme_color_override("font_color", Color.WHITE)
	monster_name_label.add_theme_color_override("font_outline_color", UiSkin.DEEP_NAVY)
	monster_name_label.add_theme_constant_override("outline_size", 10)
	monster_name_label.offset_left = 690.0
	monster_name_label.offset_right = 1007.0
	monster_name_label.offset_top = 694.0
	monster_name_label.offset_bottom = 746.0


func _build_danger_pill_display() -> void:
	monster_hp_bar.visible = false
	_danger_panel = PanelContainer.new()
	_danger_panel.name = "DangerPanel"
	_danger_panel.position = Vector2(monster_hp_bar.offset_left, monster_hp_bar.offset_top - 12.0)
	_danger_panel.custom_minimum_size = Vector2(monster_hp_bar.offset_right - monster_hp_bar.offset_left, 64.0)
	UiSkin.apply_overlay_pill(_danger_panel)
	add_child(_danger_panel)

	_danger_row = HBoxContainer.new()
	_danger_row.name = "DangerRow"
	_danger_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_danger_row.add_theme_constant_override("separation", 14)
	_danger_panel.add_child(_danger_row)

	_danger_caption = Label.new()
	_danger_caption.name = "DangerCaption"
	_danger_caption.add_theme_font_size_override("font_size", 32)
	_danger_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiSkin.apply_hud_card_text(_danger_caption, "value")
	_danger_row.add_child(_danger_caption)

	_danger_icons = HBoxContainer.new()
	_danger_icons.name = "DangerIcons"
	_danger_icons.alignment = BoxContainer.ALIGNMENT_CENTER
	_danger_icons.add_theme_constant_override("separation", 6)
	_danger_row.add_child(_danger_icons)


func _update_danger_display(stage_to_challenge: int) -> void:
	if _danger_panel == null or not is_instance_valid(_danger_panel):
		return
	var max_level := Data.danger_max_level()
	if max_level <= 0:
		_danger_panel.visible = false
		return

	var level := Data.danger_level_at(stage_to_challenge)
	if _risk_art_in_use:
		# 設計稿樣式：只排亮星（level 顆），不畫暗星佔位
		for child in _danger_icons.get_children():
			child.queue_free()
		for index in range(level):
			var star := TextureRect.new()
			star.texture = _risk_star_texture
			star.custom_minimum_size = Vector2(42.0, 42.0)
			star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_danger_icons.add_child(star)
		_danger_panel.visible = true
		return
	var icons_ok := UiSkin.fill_danger_icons(_danger_icons, level, max_level, 53.0)
	_danger_icons.visible = icons_ok
	if icons_ok:
		_danger_caption.text = Data.text("monster_danger_caption")
	else:
		# 缺爪印貼紙 → 星號文字保底（缺檔不崩，D-004）
		_danger_caption.text = Data.text("monster_danger_fallback", {
			"stars": "★".repeat(level) + "☆".repeat(maxi(0, max_level - level))
		})
	_danger_panel.visible = true


func _apply_hit_damage(damage: int) -> void:
	monster_hp_bar.value = max(1.0, monster_hp_bar.value - float(damage))


# D-019 微調（2026-07-08 人類指示）：傷害數字移除——血條已拿掉，假傷害數值不再顯示；
# hit flash / 震動等打擊感保留。DamageNumberLayer 節點與 damage_number.gd 模組保留備用。
func _play_hit_feel() -> void:
	var duration := float(Data.animation_timing_config().get("monster", {}).get("hurt", 0.0))
	HitFlash.play(monster.hit_flash_target(), duration)
	ScreenShake.play(self, duration, 14.0)
	_play_hit_punch(duration)


## 受擊縮放 punch：快速漲 8% 再彈回，補足拿掉傷害數字後的打擊回饋。
func _play_hit_punch(duration: float) -> void:
	if duration <= 0.0 or monster == null or not is_instance_valid(monster):
		return
	if _punch_tween != null and _punch_tween.is_valid():
		_punch_tween.kill()
	monster.scale = _monster_base_scale
	_punch_tween = create_tween()
	_punch_tween.tween_property(monster, "scale", _monster_base_scale * 1.08, duration * 0.3)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_punch_tween.tween_property(monster, "scale", _monster_base_scale, duration * 0.7)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _configure_background_image() -> void:
	background_image.position = Vector2.ZERO
	background_image.size = BATTLE_CANVAS_SIZE
	background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_image.visible = false


func _show_background_for_stage(stage_to_challenge: int) -> void:
	_apply_background_id(Data.background_id_for_stage(stage_to_challenge))


func _show_default_background(force_reload := false) -> void:
	var background_config := Data.background_zones_config()
	var default_background_id := str(background_config.get("default_background_id", ""))
	if default_background_id.is_empty():
		default_background_id = Data.background_id_for_stage(1)
	_apply_background_id(default_background_id, force_reload)


func _apply_background_id(background_id: String, force_reload := false) -> void:
	var resolved_path := _resolve_background_path(background_id)
	if resolved_path.is_empty():
		_current_background_path = ""
		background_image.texture = null
		background_image.visible = false
		background_fallback.visible = true
		return

	if not force_reload and resolved_path == _current_background_path:
		return

	var texture := load(resolved_path) as Texture2D
	if texture == null:
		push_error("BattlePresenter failed to load background texture: %s" % resolved_path)
		_current_background_path = ""
		background_image.texture = null
		background_image.visible = false
		background_fallback.visible = true
		return

	_current_background_path = resolved_path
	background_image.texture = texture
	background_image.visible = true
	background_fallback.visible = false


func _resolve_background_path(background_id: String) -> String:
	var resolved_path := _background_path(background_id)
	if not resolved_path.is_empty():
		return resolved_path

	var background_config := Data.background_zones_config()
	var fallback_background_id := str(background_config.get("fallback_background_id", ""))
	if fallback_background_id != background_id:
		return _background_path(fallback_background_id)

	return ""


func _background_path(background_id: String) -> String:
	if background_id.is_empty():
		return ""

	for extension: String in BACKGROUND_ASSET_EXTENSIONS:
		var path := "%s%s%s" % [BACKGROUND_ASSET_DIR, background_id, extension]
		# FileAccess.file_exists 在匯出版對 imported 資源恆為 false，只能用 ResourceLoader。
		if ResourceLoader.exists(path, "Texture2D"):
			return path

	return ""
