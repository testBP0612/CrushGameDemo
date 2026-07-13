class_name AudioService
extends Node

const AUDIO_BASE_PATH := "res://Assets/final/audio/"
const SFX_POOL_SIZE := 6
const SILENT_VOLUME_DB := -80.0

var _bgm_player: AudioStreamPlayer
var _event_bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_streams: Dictionary = {}
var _event_bgm_configs: Dictionary = {}
var _event_bgm_streams: Dictionary = {}
var _sfx_volume_db := 0.0
var _bgm_target_volume_db := 0.0
var _bgm_loop := false
var _bgm_should_play := false
var _next_sfx_player := 0
var _audio_unlocked := false
var _active_event_bgm_id := ""
var _main_bgm_resume_position := 0.0
var _bgm_transition_tween: Tween


func _ready() -> void:
	_setup_players()
	_load_audio_config()

	if _requires_user_unlock():
		set_process_input(true)
	else:
		_audio_unlocked = true
		set_process_input(false)
		play_bgm()


func _input(event: InputEvent) -> void:
	if _audio_unlocked:
		return
	if event is InputEventMouseButton and event.pressed:
		unlock_audio()
	elif event is InputEventScreenTouch and event.pressed:
		unlock_audio()


func unlock_audio() -> void:
	if _audio_unlocked:
		return

	_audio_unlocked = true
	set_process_input(false)
	play_bgm()


func play_sfx(event_id: String) -> void:
	if event_id.is_empty():
		push_warning("AudioService.play_sfx skipped: empty event_id.")
		return

	if not _audio_unlocked:
		return
	if not _sfx_streams.has(event_id):
		return

	var player := _next_available_sfx_player()
	if player == null:
		return

	player.stop()
	player.stream = _sfx_streams[event_id]
	player.volume_db = _sfx_volume_db
	player.play()


func play_bgm() -> void:
	_bgm_should_play = true
	if not _audio_unlocked:
		return
	if not _active_event_bgm_id.is_empty():
		return
	if _bgm_player == null or _bgm_player.stream == null or _bgm_player.playing:
		return

	_bgm_player.volume_db = _bgm_target_volume_db
	_bgm_player.play()


func play_event_bgm(event_id: String) -> void:
	if not _audio_unlocked or event_id.is_empty():
		return
	if not _active_event_bgm_id.is_empty():
		return
	if not _event_bgm_configs.has(event_id) or not _event_bgm_streams.has(event_id):
		return

	_active_event_bgm_id = event_id
	_kill_bgm_transition()
	var config: Dictionary = _event_bgm_configs[event_id]
	var fade_out := maxf(float(config.get("fade_out", 0.0)), 0.0)
	if _bgm_player == null or not _bgm_player.playing or fade_out <= 0.0:
		_start_event_bgm(event_id)
		return

	_bgm_transition_tween = create_tween()
	_bgm_transition_tween.tween_property(_bgm_player, "volume_db", SILENT_VOLUME_DB, fade_out)
	_bgm_transition_tween.tween_callback(_start_event_bgm.bind(event_id))


func stop_event_bgm() -> void:
	if _active_event_bgm_id.is_empty():
		return

	var event_id := _active_event_bgm_id
	var config: Dictionary = _event_bgm_configs.get(event_id, {})
	var event_fade_out := maxf(float(config.get("fade_out", 0.0)), 0.0)
	var main_fade_in := maxf(float(config.get("fade_in", 0.0)), 0.0)
	_active_event_bgm_id = ""
	_kill_bgm_transition()

	var main_can_resume := _audio_unlocked and _bgm_should_play and _bgm_player != null and _bgm_player.stream != null
	if main_can_resume and not _bgm_player.playing:
		_bgm_player.volume_db = SILENT_VOLUME_DB if main_fade_in > 0.0 else _bgm_target_volume_db
		_bgm_player.play(_main_bgm_resume_position)

	var event_is_playing := _event_bgm_player != null and _event_bgm_player.playing
	var has_tweener := false
	_bgm_transition_tween = create_tween()
	if event_is_playing and event_fade_out > 0.0:
		_bgm_transition_tween.tween_property(_event_bgm_player, "volume_db", SILENT_VOLUME_DB, event_fade_out)
		has_tweener = true
	elif event_is_playing:
		_event_bgm_player.stop()

	if main_can_resume and main_fade_in > 0.0:
		if has_tweener:
			_bgm_transition_tween.parallel().tween_property(_bgm_player, "volume_db", _bgm_target_volume_db, main_fade_in)
		else:
			_bgm_transition_tween.tween_property(_bgm_player, "volume_db", _bgm_target_volume_db, main_fade_in)
		has_tweener = true
	elif main_can_resume:
		_bgm_player.volume_db = _bgm_target_volume_db

	if has_tweener:
		_bgm_transition_tween.tween_callback(_finish_event_bgm_stop)
	else:
		_bgm_transition_tween.kill()
		_bgm_transition_tween = null
		_finish_event_bgm_stop()


func stop_all() -> void:
	_bgm_should_play = false
	_kill_bgm_transition()
	_active_event_bgm_id = ""
	_main_bgm_resume_position = 0.0
	if _bgm_player != null:
		_bgm_player.stop()
		_bgm_player.volume_db = _bgm_target_volume_db
	if _event_bgm_player != null:
		_event_bgm_player.stop()
		_event_bgm_player.stream = null

	for player: AudioStreamPlayer in _sfx_players:
		player.stop()


func _setup_players() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BgmPlayer"
	_bgm_player.finished.connect(_on_bgm_finished)
	add_child(_bgm_player)
	_event_bgm_player = AudioStreamPlayer.new()
	_event_bgm_player.name = "EventBgmPlayer"
	_event_bgm_player.finished.connect(_on_event_bgm_finished)
	add_child(_event_bgm_player)

	for index in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % (index + 1)
		add_child(player)
		_sfx_players.append(player)


func _load_audio_config() -> void:
	var config := Data.audio_config()
	if config.is_empty():
		push_warning("AudioService found no Data/audio.json config. Audio will stay silent.")
		return

	var bgm_config: Dictionary = config.get("bgm", {})
	_bgm_loop = bool(bgm_config.get("loop", false))
	_bgm_target_volume_db = float(bgm_config.get("volume_db", 0.0))
	_bgm_player.volume_db = _bgm_target_volume_db
	_bgm_player.stream = _load_stream(str(bgm_config.get("file", "")), "BGM")

	_sfx_volume_db = float(config.get("sfx_volume_db", 0.0))
	var sfx_events: Dictionary = config.get("sfx_events", {})
	for event_id: String in sfx_events:
		var stream := _load_stream(str(sfx_events[event_id]), "SFX %s" % event_id)
		if stream != null:
			_sfx_streams[event_id] = stream

	var event_bgm: Dictionary = config.get("event_bgm", {})
	for event_id: String in event_bgm:
		if not event_bgm[event_id] is Dictionary:
			push_warning("AudioService skipped event BGM %s: config must be an object." % event_id)
			continue
		var event_config: Dictionary = event_bgm[event_id]
		_event_bgm_configs[event_id] = event_config
		var stream := _load_stream(str(event_config.get("file", "")), "event BGM %s" % event_id)
		if stream != null:
			_event_bgm_streams[event_id] = stream


func _load_stream(file_name: String, label: String) -> AudioStream:
	if file_name.is_empty():
		push_warning("AudioService skipped %s: empty file name." % label)
		return null

	var path := AUDIO_BASE_PATH.path_join(file_name)
	# FileAccess.file_exists 在匯出版對 imported 音檔恆為 false，改用 ResourceLoader。
	if not ResourceLoader.exists(path):
		push_warning("AudioService skipped %s: missing file %s." % [label, path])
		return null

	var stream := load(path)
	if stream == null or not (stream is AudioStream):
		push_warning("AudioService skipped %s: failed to load %s as AudioStream." % [label, path])
		return null

	return stream


func _next_available_sfx_player() -> AudioStreamPlayer:
	for player: AudioStreamPlayer in _sfx_players:
		if not player.playing:
			return player

	if _sfx_players.is_empty():
		return null

	var player := _sfx_players[_next_sfx_player]
	_next_sfx_player = (_next_sfx_player + 1) % _sfx_players.size()
	return player


func _on_bgm_finished() -> void:
	if _bgm_loop and _bgm_should_play and _audio_unlocked and _active_event_bgm_id.is_empty():
		_bgm_player.play()


func _on_event_bgm_finished() -> void:
	if _active_event_bgm_id.is_empty() or not _audio_unlocked:
		return
	var config: Dictionary = _event_bgm_configs.get(_active_event_bgm_id, {})
	if bool(config.get("loop", false)):
		_event_bgm_player.play()


func _start_event_bgm(event_id: String) -> void:
	if event_id != _active_event_bgm_id or not _audio_unlocked:
		return
	if not _event_bgm_configs.has(event_id) or not _event_bgm_streams.has(event_id):
		return

	if _bgm_player != null and _bgm_player.playing:
		_main_bgm_resume_position = _bgm_player.get_playback_position()
		_bgm_player.stop()
	var config: Dictionary = _event_bgm_configs[event_id]
	_event_bgm_player.stream = _event_bgm_streams[event_id]
	_event_bgm_player.volume_db = float(config.get("volume_db", 0.0))
	_event_bgm_player.play()
	_bgm_transition_tween = null


func _finish_event_bgm_stop() -> void:
	if _event_bgm_player != null:
		_event_bgm_player.stop()
		_event_bgm_player.stream = null
	if _bgm_player != null and _bgm_player.playing:
		_bgm_player.volume_db = _bgm_target_volume_db
	_main_bgm_resume_position = 0.0
	_bgm_transition_tween = null


func _kill_bgm_transition() -> void:
	if _bgm_transition_tween != null and _bgm_transition_tween.is_valid():
		_bgm_transition_tween.kill()
	_bgm_transition_tween = null


func _requires_user_unlock() -> bool:
	return OS.has_feature("web") or OS.get_name() == "Web"
