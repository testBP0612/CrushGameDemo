class_name HeroActor
extends Node2D

const HERO_IDLE_SHEET_PATH := "res://Assets/final/hero_idle_sheet.png"
const HERO_IDLE_SHEET_META_PATH := "res://Assets/final/hero_idle_sheet.json"
const HERO_IDLE_ANIMATION := &"idle"
const HERO_IDLE_SCALE := Vector2(0.52, 0.52)

const HERO_WALK_SHEET_PATH := "res://Assets/final/hero_walk_sheet.png"
const HERO_WALK_SHEET_META_PATH := "res://Assets/final/hero_walk_sheet.json"
const HERO_WALK_ANIMATION := &"walk"

@onready var body: ColorRect = $Body
@onready var idle_sprite: AnimatedSprite2D = $IdleSprite

var _home_position := Vector2.ZERO
var _idle_tween: Tween
var _walk_tween: Tween
var _using_idle_sheet := false
var _has_walk_animation := false


func _ready() -> void:
	_home_position = position
	_configure_idle_visual()
	play_idle()


func play_idle() -> void:
	_kill_idle()
	if _using_idle_sheet and idle_sprite.animation != HERO_IDLE_ANIMATION:
		idle_sprite.play(HERO_IDLE_ANIMATION)
	var duration := _hero_duration("idle_loop")
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(self, "position:y", _home_position.y - 12.0, duration * 0.5)
	_idle_tween.tween_property(self, "position:y", _home_position.y, duration * 0.5)


func play_attack(target_position: Vector2) -> Signal:
	_kill_idle()
	var duration := _hero_duration("attack")
	var tween := create_tween()
	var strike_position := _home_position.lerp(target_position, 0.42)
	tween.tween_property(self, "position", strike_position, duration * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", _home_position, duration * 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(play_idle)
	return tween.finished


func play_hurt() -> Signal:
	_kill_idle()
	var duration := _hero_duration("hurt")
	var tween := create_tween()
	if _using_idle_sheet:
		var original_modulate := idle_sprite.modulate
		tween.tween_property(idle_sprite, "modulate", Color(1.0, 0.35, 0.35, 1.0), duration * 0.25)
		tween.parallel().tween_property(self, "position:x", _home_position.x - 40.0, duration * 0.5)
		tween.tween_property(idle_sprite, "modulate", original_modulate, duration * 0.25)
	else:
		var original_color := body.color
		tween.tween_property(body, "color", Color(1.0, 0.35, 0.35, 1.0), duration * 0.25)
		tween.parallel().tween_property(self, "position:x", _home_position.x - 40.0, duration * 0.5)
		tween.tween_property(body, "color", original_color, duration * 0.25)
	tween.parallel().tween_property(self, "position", _home_position, duration * 0.5)
	tween.tween_callback(play_idle)
	return tween.finished


func play_defeat() -> Signal:
	_kill_idle()
	var duration := _hero_duration("defeat")
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", -18.0, duration)
	tween.parallel().tween_property(self, "modulate", Color(0.55, 0.55, 0.55, 1.0), duration)
	return tween.finished


func play_walk() -> Signal:
	_kill_idle()
	_kill_walk_tween()
	if _using_idle_sheet and _has_walk_animation:
		idle_sprite.play(HERO_WALK_ANIMATION)
	var duration := _advance_duration("hero_walk_duration")
	var distance := _advance_distance("hero_walk_distance")
	var transition_overlap := _advance_duration("transition_duration") * 0.5
	_walk_tween = create_tween()
	_walk_tween.tween_property(self, "position:x", _home_position.x + distance, duration + transition_overlap) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return get_tree().create_timer(duration).timeout


func snap_home() -> void:
	_kill_walk_tween()
	position = _home_position
	play_idle()


func _kill_walk_tween() -> void:
	if _walk_tween != null:
		_walk_tween.kill()
		_walk_tween = null


func reset_pose() -> void:
	_kill_idle()
	position = _home_position
	rotation = 0.0
	modulate = Color.WHITE
	if _using_idle_sheet:
		idle_sprite.modulate = Color.WHITE
	play_idle()


func _kill_idle() -> void:
	if _idle_tween != null:
		_idle_tween.kill()
		_idle_tween = null


func _configure_idle_visual() -> void:
	idle_sprite.visible = false
	body.visible = true
	_using_idle_sheet = false
	_has_walk_animation = false

	var metadata := _load_sheet_metadata(HERO_IDLE_SHEET_META_PATH)
	if metadata.is_empty():
		return

	var texture := _load_sheet_texture(HERO_IDLE_SHEET_PATH)
	if texture == null:
		return

	if not _is_valid_sheet_metadata(metadata, texture, "hero_idle"):
		return

	var frame_width := int(metadata.get("frame_width", 0))
	var frame_height := int(metadata.get("frame_height", 0))

	var frames := SpriteFrames.new()
	_add_sheet_animation(frames, HERO_IDLE_ANIMATION, metadata, texture)

	idle_sprite.sprite_frames = frames
	idle_sprite.animation = HERO_IDLE_ANIMATION
	idle_sprite.centered = false
	idle_sprite.offset = Vector2(-float(frame_width) * 0.5, -float(frame_height))
	idle_sprite.scale = HERO_IDLE_SCALE
	idle_sprite.visible = true
	idle_sprite.play(HERO_IDLE_ANIMATION)

	body.visible = false
	_using_idle_sheet = true

	_configure_walk_visual(frames)


func _configure_walk_visual(frames: SpriteFrames) -> void:
	_has_walk_animation = false

	var metadata := _load_sheet_metadata(HERO_WALK_SHEET_META_PATH)
	if metadata.is_empty():
		return

	var texture := _load_sheet_texture(HERO_WALK_SHEET_PATH)
	if texture == null:
		return

	if not _is_valid_sheet_metadata(metadata, texture, "hero_walk"):
		return

	_add_sheet_animation(frames, HERO_WALK_ANIMATION, metadata, texture)
	_has_walk_animation = true


func _add_sheet_animation(frames: SpriteFrames, animation_name: StringName, metadata: Dictionary, texture: Texture2D) -> void:
	var frame_width := int(metadata.get("frame_width", 0))
	var frame_height := int(metadata.get("frame_height", 0))
	var columns := int(metadata.get("columns", 0))
	var frame_count := int(metadata.get("frame_count", 0))
	var fps := float(metadata.get("fps", 0.0))

	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, true)

	for frame_index in range(frame_count):
		var column := frame_index % columns
		var row := frame_index / columns
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region = Rect2(column * frame_width, row * frame_height, frame_width, frame_height)
		frames.add_frame(animation_name, atlas_texture)


func _load_sheet_metadata(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("HeroActor missing sheet metadata: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("HeroActor failed to open sheet metadata %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("HeroActor failed to parse sheet metadata as JSON object: %s" % path)
		return {}

	return parsed


func _load_sheet_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path) or not ResourceLoader.exists(path, "Texture2D"):
		push_error("HeroActor missing sheet texture: %s" % path)
		return null

	var texture := load(path) as Texture2D
	if texture == null:
		push_error("HeroActor failed to load sheet texture: %s" % path)
	return texture


func _is_valid_sheet_metadata(metadata: Dictionary, texture: Texture2D, sheet_id: String) -> bool:
	var frame_width := int(metadata.get("frame_width", 0))
	var frame_height := int(metadata.get("frame_height", 0))
	var columns := int(metadata.get("columns", 0))
	var rows := int(metadata.get("rows", 0))
	var frame_count := int(metadata.get("frame_count", 0))
	var fps := float(metadata.get("fps", 0.0))

	if frame_width <= 0 or frame_height <= 0 or columns <= 0 or rows <= 0 or frame_count <= 0 or fps <= 0.0:
		push_error("HeroActor invalid %s sheet metadata values." % sheet_id)
		return false

	if columns * rows < frame_count:
		push_error("HeroActor invalid %s sheet grid: columns * rows is smaller than frame_count." % sheet_id)
		return false

	if texture.get_width() < columns * frame_width or texture.get_height() < rows * frame_height:
		push_error("HeroActor invalid %s sheet size: texture is smaller than metadata grid." % sheet_id)
		return false

	return true


func _hero_duration(key: String) -> float:
	var duration := float(Data.animation_timing_config().get("hero", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("HeroActor missing animation duration: hero.%s" % key)
	return duration


func _advance_duration(key: String) -> float:
	var duration := float(Data.battle_sequence_config().get("advance_sequence", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("HeroActor missing advance duration: %s" % key)
	return duration


func _advance_distance(key: String) -> float:
	var distance := float(Data.battle_sequence_config().get("advance_sequence", {}).get(key, 0.0))
	if distance <= 0.0:
		push_error("HeroActor missing advance distance: %s" % key)
	return distance
