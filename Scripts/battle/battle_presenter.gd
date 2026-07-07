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

const DamageNumberScript := preload("res://Scripts/effects/damage_number.gd")
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
@onready var damage_number_layer: Node2D = $DamageNumberLayer
@onready var transition_overlay: ColorRect = $TransitionOverlay

var _current_monster: Dictionary = {}
var _current_background_path := ""


func _ready() -> void:
	UiSkin.style_monster_status(monster_name_label, monster_hp_bar)
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
	monster_hp_bar.max_value = float(_current_monster.get("display_hp", 0))
	monster_hp_bar.value = monster_hp_bar.max_value


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
		_spawn_damage_number(damage_per_hit, hit_index)
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
	player_hurt_finished.emit()


func reset_for_betting() -> void:
	hero.reset_pose()
	_show_default_background()
	show_monster_for_stage(1, false)


func _apply_hit_damage(damage: int) -> void:
	monster_hp_bar.value = max(1.0, monster_hp_bar.value - float(damage))


func _spawn_damage_number(damage: int, hit_index: int) -> void:
	var config: Dictionary = Data.battle_sequence_config().get("damage_number", {})
	var stagger := float(config.get("stagger_between_hits", 0.0))
	var number := DamageNumberScript.new()
	number.theme_type_variation = &""
	number.add_theme_font_size_override("font_size", 42)
	damage_number_layer.add_child(number)
	number.play(damage, float(hit_index) * stagger, monster.position + Vector2(0.0, -180.0))


func _play_hit_feel() -> void:
	var duration := float(Data.animation_timing_config().get("monster", {}).get("hurt", 0.0))
	HitFlash.play(monster.hit_flash_target(), duration)
	ScreenShake.play(self, duration, 14.0)


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
