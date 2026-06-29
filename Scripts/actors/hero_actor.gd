class_name HeroActor
extends Node2D

const HERO_IDLE_SHEET_PATH := "res://Assets/final/hero_idle_sheet.png"
const HERO_IDLE_SHEET_META_PATH := "res://Assets/final/hero_idle_sheet.json"
const HERO_IDLE_ANIMATION := &"idle"
const HERO_IDLE_SCALE := Vector2(0.52, 0.52)

@onready var body: ColorRect = $Body
@onready var idle_sprite: AnimatedSprite2D = $IdleSprite

var _home_position := Vector2.ZERO
var _idle_tween: Tween
var _using_idle_sheet := false


func _ready() -> void:
	_home_position = position
	_configure_idle_visual()
	play_idle()


func play_idle() -> void:
	_kill_idle()
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
	var duration := _advance_duration("hero_walk_duration")
	var tween := create_tween()
	tween.tween_property(self, "position:x", _home_position.x + 90.0, duration * 0.5)
	tween.tween_property(self, "position:x", _home_position.x, duration * 0.5)
	tween.tween_callback(play_idle)
	return tween.finished


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

	var metadata := _load_sheet_metadata()
	if metadata.is_empty():
		return

	var texture := _load_idle_sheet_texture()
	if texture == null:
		return

	var frame_width := int(metadata.get("frame_width", 0))
	var frame_height := int(metadata.get("frame_height", 0))
	var columns := int(metadata.get("columns", 0))
	var rows := int(metadata.get("rows", 0))
	var frame_count := int(metadata.get("frame_count", 0))
	var fps := float(metadata.get("fps", 0.0))
	if not _is_valid_sheet_metadata(frame_width, frame_height, columns, rows, frame_count, fps, texture):
		return

	var frames := SpriteFrames.new()
	frames.add_animation(HERO_IDLE_ANIMATION)
	frames.set_animation_speed(HERO_IDLE_ANIMATION, fps)
	frames.set_animation_loop(HERO_IDLE_ANIMATION, true)

	for frame_index in range(frame_count):
		var column := frame_index % columns
		var row := frame_index / columns
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region = Rect2(column * frame_width, row * frame_height, frame_width, frame_height)
		frames.add_frame(HERO_IDLE_ANIMATION, atlas_texture)

	idle_sprite.sprite_frames = frames
	idle_sprite.animation = HERO_IDLE_ANIMATION
	idle_sprite.centered = false
	idle_sprite.offset = Vector2(-float(frame_width) * 0.5, -float(frame_height))
	idle_sprite.scale = HERO_IDLE_SCALE
	idle_sprite.visible = true
	idle_sprite.play(HERO_IDLE_ANIMATION)

	body.visible = false
	_using_idle_sheet = true


func _load_sheet_metadata() -> Dictionary:
	if not FileAccess.file_exists(HERO_IDLE_SHEET_META_PATH):
		push_error("HeroActor missing idle sheet metadata: %s" % HERO_IDLE_SHEET_META_PATH)
		return {}

	var file := FileAccess.open(HERO_IDLE_SHEET_META_PATH, FileAccess.READ)
	if file == null:
		push_error("HeroActor failed to open idle sheet metadata %s: %s" % [HERO_IDLE_SHEET_META_PATH, error_string(FileAccess.get_open_error())])
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("HeroActor failed to parse idle sheet metadata as JSON object: %s" % HERO_IDLE_SHEET_META_PATH)
		return {}

	return parsed


func _load_idle_sheet_texture() -> Texture2D:
	if not FileAccess.file_exists(HERO_IDLE_SHEET_PATH) or not ResourceLoader.exists(HERO_IDLE_SHEET_PATH, "Texture2D"):
		push_error("HeroActor missing idle sheet texture: %s" % HERO_IDLE_SHEET_PATH)
		return null

	var texture := load(HERO_IDLE_SHEET_PATH) as Texture2D
	if texture == null:
		push_error("HeroActor failed to load idle sheet texture: %s" % HERO_IDLE_SHEET_PATH)
	return texture


func _is_valid_sheet_metadata(frame_width: int, frame_height: int, columns: int, rows: int, frame_count: int, fps: float, texture: Texture2D) -> bool:
	if frame_width <= 0 or frame_height <= 0 or columns <= 0 or rows <= 0 or frame_count <= 0 or fps <= 0.0:
		push_error("HeroActor invalid hero_idle sheet metadata values.")
		return false

	if columns * rows < frame_count:
		push_error("HeroActor invalid hero_idle sheet grid: columns * rows is smaller than frame_count.")
		return false

	if texture.get_width() < columns * frame_width or texture.get_height() < rows * frame_height:
		push_error("HeroActor invalid hero_idle sheet size: texture is smaller than metadata grid.")
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
