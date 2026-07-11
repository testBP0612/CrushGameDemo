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

const UiSkin := preload("res://Scripts/ui/ui_skin.gd")
const HitFlash := preload("res://Scripts/effects/hit_flash.gd")
const ScreenShake := preload("res://Scripts/effects/screen_shake.gd")
const BACKGROUND_ASSET_DIR := "res://Assets/final/"
const BACKGROUND_ASSET_EXTENSIONS := [".jpg", ".jpeg", ".png"]
const BATTLE_CANVAS_SIZE := Vector2(1080.0, 1920.0)

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
var _danger_panel: PanelContainer
var _danger_row: HBoxContainer
var _danger_caption: Label
var _danger_icons: HBoxContainer
# 受擊 punch：多段連擊時先殺前一個 tween 並歸位，避免縮放疊加
var _punch_tween: Tween
var _monster_base_scale := Vector2.ONE


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


func play_advance_walk() -> void:
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


func play_player_hurt() -> void:
	await hero.play_hurt()
	await hero.play_defeat()
	var delay := float(Data.battle_sequence_config().get("result_resolution", {}).get("lose_branch", {}).get("defeat_settle_delay", 0.0))
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	player_hurt_finished.emit()


func reset_for_betting() -> void:
	hero.reset_pose()
	_show_default_background()
	show_monster_for_stage(1, false)


## 任務 23 結算稿只有街景＋結果卡；只切顯示，不碰角色/狀態機資料。
func set_settlement_presentation(enabled: bool) -> void:
	hero.visible = not enabled
	monster.visible = not enabled
	monster_name_label.visible = not enabled
	if _danger_panel != null and is_instance_valid(_danger_panel):
		_danger_panel.visible = not enabled and Data.danger_max_level() > 0


## D-019：血條位置改放危險度列（危險度＋爪印等級）。全程式生成，不動 .tscn。
## 外層加半透明深色藥丸底板（夜間 UI 輪）——原本裸放在花背景上對比不足。
func _build_danger_display() -> void:
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


func _show_default_background() -> void:
	var background_config := Data.background_zones_config()
	var default_background_id := str(background_config.get("default_background_id", ""))
	if default_background_id.is_empty():
		default_background_id = Data.background_id_for_stage(1)
	_apply_background_id(default_background_id)


func _apply_background_id(background_id: String) -> void:
	var resolved_path := _resolve_background_path(background_id)
	if resolved_path.is_empty():
		_current_background_path = ""
		background_image.texture = null
		background_image.visible = false
		background_fallback.visible = true
		return

	if resolved_path == _current_background_path:
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
