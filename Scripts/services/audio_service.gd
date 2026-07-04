class_name AudioService
extends Node

const AUDIO_BASE_PATH := "res://Assets/final/audio/"
const SFX_POOL_SIZE := 6

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_streams: Dictionary = {}
var _sfx_volume_db := 0.0
var _bgm_loop := false
var _bgm_should_play := false
var _next_sfx_player := 0
var _audio_unlocked := false


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
	if _bgm_player == null or _bgm_player.stream == null or _bgm_player.playing:
		return

	_bgm_player.play()


func stop_all() -> void:
	_bgm_should_play = false
	if _bgm_player != null:
		_bgm_player.stop()

	for player: AudioStreamPlayer in _sfx_players:
		player.stop()


func _setup_players() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BgmPlayer"
	_bgm_player.finished.connect(_on_bgm_finished)
	add_child(_bgm_player)

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
	_bgm_player.volume_db = float(bgm_config.get("volume_db", 0.0))
	_bgm_player.stream = _load_stream(str(bgm_config.get("file", "")), "BGM")

	_sfx_volume_db = float(config.get("sfx_volume_db", 0.0))
	var sfx_events: Dictionary = config.get("sfx_events", {})
	for event_id: String in sfx_events:
		var stream := _load_stream(str(sfx_events[event_id]), "SFX %s" % event_id)
		if stream != null:
			_sfx_streams[event_id] = stream


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
	if _bgm_loop and _bgm_should_play and _audio_unlocked:
		_bgm_player.play()


func _requires_user_unlock() -> bool:
	return OS.has_feature("web") or OS.get_name() == "Web"
