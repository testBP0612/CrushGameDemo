class_name MonsterActor
extends Node2D

const BOSS_ASSET_DIR := "res://Assets/final/boss/"
const MONSTER_IDLE_ANIMATION := &"idle"
const MONSTER_IDLE_SCALE := Vector2(0.62, 0.62)

@onready var body: ColorRect = $Body

var _home_position := Vector2.ZERO
var _idle_tween: Tween
var _base_color := Color.WHITE
var _idle_sprite: AnimatedSprite2D
var _using_idle_animation := false


func _ready() -> void:
	_home_position = position
	_ensure_idle_sprite()
	play_idle()


func apply_monster(monster: Dictionary) -> void:
	_kill_idle()
	_ensure_idle_sprite()
	_base_color = Color.html(str(monster.get("placeholder_color", "#ffffff")))
	body.color = _base_color
	body.visible = true
	_using_idle_animation = false
	if _idle_sprite != null:
		_idle_sprite.visible = false
		_idle_sprite.sprite_frames = null
		_idle_sprite.modulate = Color.WHITE
	modulate = Color.WHITE
	scale = Vector2.ONE
	rotation = 0.0
	position = _home_position
	visible = true
	_configure_idle_animation(str(monster.get("art_asset_id", "")))
	play_idle()


func play_idle() -> void:
	_kill_idle()
	if _using_idle_animation and _idle_sprite != null:
		_idle_sprite.play(MONSTER_IDLE_ANIMATION)
	var duration := _monster_duration("idle_loop")
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(self, "scale", Vector2(1.04, 0.96), duration * 0.5)
	_idle_tween.tween_property(self, "scale", Vector2.ONE, duration * 0.5)


func play_hurt() -> Signal:
	_kill_idle()
	var duration := _monster_duration("hurt")
	var tween := create_tween()
	var flash_target := hit_flash_target()
	var original_modulate := flash_target.modulate
	if _using_idle_animation:
		tween.tween_property(flash_target, "modulate", Color(1.6, 1.6, 1.6, 1.0), duration * 0.25)
	else:
		tween.tween_property(body, "color", Color.WHITE, duration * 0.25)
	tween.parallel().tween_property(self, "position:x", _home_position.x + 24.0, duration * 0.5)
	if _using_idle_animation:
		tween.tween_property(flash_target, "modulate", original_modulate, duration * 0.25)
	else:
		tween.tween_property(body, "color", _base_color, duration * 0.25)
	tween.parallel().tween_property(self, "position", _home_position, duration * 0.5)
	tween.tween_callback(play_idle)
	return tween.finished


func play_death() -> Signal:
	_kill_idle()
	var duration := _monster_duration("death")
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.2, 0.2), duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(func() -> void: visible = false)
	return tween.finished


func play_counter(target_position: Vector2) -> Signal:
	_kill_idle()
	var duration := _lose_branch_duration("monster_counter_duration")
	var tween := create_tween()
	var strike_position := _home_position.lerp(target_position, 0.35)
	tween.tween_property(self, "position", strike_position, duration * 0.45)
	tween.tween_property(self, "position", _home_position, duration * 0.55)
	tween.tween_callback(play_idle)
	return tween.finished


## D-022：只放慢怪物自身 tween，不改 Engine.time_scale。停在主角前等虎爺落下。
func play_huye_counter_slow(target_position: Vector2, config: Dictionary) -> Signal:
	_kill_idle()
	var normal_duration := _lose_branch_duration("monster_counter_duration")
	var brake_fraction := clampf(float(config.get("counter_brake_fraction", 0.0)), 0.0, 1.0)
	var slow_rate := maxf(float(config.get("slow_motion_rate", 0.0)), 0.01)
	var strike_position := _home_position.lerp(target_position, 0.35)
	var brake_position := _home_position.lerp(strike_position, brake_fraction)
	var tween := create_tween()
	# 虎爺在接近碰撞的位置直接介入，不再等怪物走完整段慢動作路徑。
	tween.tween_property(self, "position", brake_position, normal_duration / slow_rate)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(float(config.get("slow_hold", 0.0)))
	return tween.finished


func play_huye_fly_out(config: Dictionary) -> Signal:
	_kill_idle()
	var duration := float(config.get("monster_fly_duration", 0.0))
	var target := Vector2(
		float(config.get("monster_fly_target_x", position.x)),
		float(config.get("monster_fly_target_y", position.y))
	)
	var turns := float(config.get("monster_fly_rotation_turns", 0.0))
	var end_scale := maxf(float(config.get("monster_fly_end_scale", 0.0)), 0.0)
	var tween := create_tween()
	tween.tween_property(self, "position", target, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation", TAU * turns, duration)
	tween.parallel().tween_property(self, "scale", Vector2.ONE * end_scale, duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(func() -> void: visible = false)
	return tween.finished


func reset_after_huye() -> void:
	_kill_idle()
	position = _home_position
	rotation = 0.0
	scale = Vector2.ONE
	modulate = Color.WHITE
	visible = true
	if _idle_sprite != null:
		_idle_sprite.modulate = Color.WHITE
	play_idle()


func play_enter() -> Signal:
	_kill_idle()
	var duration := _advance_duration("next_monster_enter_duration")
	position = _home_position
	scale = Vector2.ONE
	modulate = Color.WHITE
	visible = true
	play_idle()
	return get_tree().create_timer(duration).timeout


func _kill_idle() -> void:
	if _idle_tween != null:
		_idle_tween.kill()
		_idle_tween = null


func hit_flash_target() -> CanvasItem:
	if _using_idle_animation and _idle_sprite != null:
		return _idle_sprite
	return body


func _ensure_idle_sprite() -> void:
	if _idle_sprite != null:
		return
	if has_node("IdleSprite"):
		_idle_sprite = $IdleSprite
	else:
		_idle_sprite = AnimatedSprite2D.new()
		_idle_sprite.name = "IdleSprite"
		add_child(_idle_sprite)
	_idle_sprite.visible = false
	_idle_sprite.centered = false
	_idle_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func _configure_idle_animation(asset_id: String) -> void:
	if asset_id.is_empty():
		return

	var texture_path := "%s%s.png" % [BOSS_ASSET_DIR, asset_id]
	var metadata_path := "%s%s.json" % [BOSS_ASSET_DIR, asset_id]
	var texture := _load_idle_texture(texture_path)
	if texture == null:
		return

	var metadata := _load_texture_packer_metadata(metadata_path)
	if metadata.is_empty():
		return

	var frame_names := _animation_frame_names(metadata, asset_id)
	if frame_names.is_empty():
		return

	var duration := _monster_duration("idle_loop")
	if duration <= 0.0:
		return

	var frames := SpriteFrames.new()
	frames.add_animation(MONSTER_IDLE_ANIMATION)
	frames.set_animation_loop(MONSTER_IDLE_ANIMATION, true)
	frames.set_animation_speed(MONSTER_IDLE_ANIMATION, float(frame_names.size()) / duration)

	var frame_size := _add_texture_packer_frames(frames, metadata, texture, frame_names)
	if frame_size == Vector2.ZERO:
		return

	_idle_sprite.sprite_frames = frames
	_idle_sprite.animation = MONSTER_IDLE_ANIMATION
	_idle_sprite.scale = MONSTER_IDLE_SCALE
	_idle_sprite.offset = Vector2(-frame_size.x * 0.5, -frame_size.y)
	_idle_sprite.modulate = Color.WHITE
	_idle_sprite.visible = true
	_idle_sprite.play(MONSTER_IDLE_ANIMATION)
	body.visible = false
	_using_idle_animation = true


func _load_idle_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path, "Texture2D"):
		push_warning("MonsterActor missing idle texture, using placeholder: %s" % path)
		return null

	var texture := load(path) as Texture2D
	if texture == null:
		push_warning("MonsterActor failed to load idle texture, using placeholder: %s" % path)
	return texture


func _load_texture_packer_metadata(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("MonsterActor missing idle metadata, using placeholder: %s" % path)
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("MonsterActor failed to parse idle metadata as JSON object, using placeholder: %s" % path)
		return {}

	return parsed


func _animation_frame_names(metadata: Dictionary, asset_id: String) -> Array:
	var meta: Dictionary = metadata.get("meta", {})
	var animations: Dictionary = meta.get("animations", {})
	var frame_names: Array = animations.get(asset_id, [])
	if frame_names.is_empty():
		push_warning("MonsterActor missing TexturePacker animation %s, using placeholder." % asset_id)
	return frame_names


func _add_texture_packer_frames(
	frames: SpriteFrames,
	metadata: Dictionary,
	texture: Texture2D,
	frame_names: Array
) -> Vector2:
	var frame_root: Dictionary = metadata.get("frames", {})
	var frame_size := Vector2.ZERO
	for frame_name: Variant in frame_names:
		var frame_entry: Dictionary = frame_root.get(str(frame_name), {})
		var frame_rect: Dictionary = frame_entry.get("frame", {})
		if frame_entry.get("rotated", false):
			push_warning("MonsterActor does not support rotated TexturePacker frames, using placeholder.")
			return Vector2.ZERO

		var x := int(frame_rect.get("x", -1))
		var y := int(frame_rect.get("y", -1))
		var width := int(frame_rect.get("w", 0))
		var height := int(frame_rect.get("h", 0))
		if x < 0 or y < 0 or width <= 0 or height <= 0:
			push_warning("MonsterActor invalid TexturePacker frame %s, using placeholder." % str(frame_name))
			return Vector2.ZERO
		if x + width > texture.get_width() or y + height > texture.get_height():
			push_warning("MonsterActor TexturePacker frame %s exceeds texture bounds, using placeholder." % str(frame_name))
			return Vector2.ZERO

		if frame_size == Vector2.ZERO:
			frame_size = Vector2(width, height)

		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region = Rect2(x, y, width, height)
		frames.add_frame(MONSTER_IDLE_ANIMATION, atlas_texture)

	if frames.get_frame_count(MONSTER_IDLE_ANIMATION) == 0:
		return Vector2.ZERO
	return frame_size


func _monster_duration(key: String) -> float:
	var duration := float(Data.animation_timing_config().get("monster", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("MonsterActor missing animation duration: monster.%s" % key)
	return duration


func _lose_branch_duration(key: String) -> float:
	var duration := float(Data.battle_sequence_config().get("result_resolution", {}).get("lose_branch", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("MonsterActor missing lose branch duration: %s" % key)
	return duration


func _advance_duration(key: String) -> float:
	var duration := float(Data.battle_sequence_config().get("advance_sequence", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("MonsterActor missing advance duration: %s" % key)
	return duration
