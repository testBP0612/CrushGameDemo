extends SceneTree

const JSON_PATHS := [
	"res://Data/animation_timing.json",
	"res://Data/audio.json",
	"res://Data/battle_sequences.json",
	"res://Data/game_balance.json",
	"res://Data/leaderboard_mock.json",
	"res://Data/monsters.json",
	"res://Data/ui_text.json",
]

var _failures: Array[String] = []


func _initialize() -> void:
	var parsed := {}
	for path in JSON_PATHS:
		var value = _read_json(path)
		if value is Dictionary:
			parsed[path] = value

	_validate_balance(parsed.get("res://Data/game_balance.json", {}))
	_validate_monsters(parsed.get("res://Data/monsters.json", {}))
	_validate_audio(parsed.get("res://Data/audio.json", {}))
	_validate_task_25_routing()

	if _failures.is_empty():
		print("PROJECT SMOKE OK: JSON, stage assets, audio assets, and task 25 routing")
		quit(0)
		return

	for failure in _failures:
		push_error("PROJECT SMOKE: %s" % failure)
	quit(1)


func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_failures.append("cannot open %s" % path)
		return null
	var value = JSON.parse_string(file.get_as_text())
	if not value is Dictionary:
		_failures.append("expected JSON object in %s" % path)
	return value


func _validate_balance(config: Dictionary) -> void:
	var progression: Dictionary = config.get("stage_progression", {})
	var max_stage := int(progression.get("max_stage", 0))
	if max_stage != 10:
		_failures.append("expected max_stage 10, got %d" % max_stage)
	var huye: Dictionary = config.get("random_events", {}).get("huye", {})
	if bool(huye.get("force_trigger", true)):
		_failures.append("release config must keep random_events.huye.force_trigger=false")
	if str(huye.get("reward_mode", "")) != "run_payout_x2":
		_failures.append("unexpected Huye reward_mode")


func _validate_monsters(config: Dictionary) -> void:
	var monsters: Array = config.get("monsters", [])
	if monsters.size() != 10:
		_failures.append("expected 10 monsters, got %d" % monsters.size())
	for stage in range(1, 11):
		var png := "res://Assets/final/boss/boss%d_idle.png" % stage
		var metadata := "res://Assets/final/boss/boss%d_idle.json" % stage
		if not ResourceLoader.exists(png, "Texture2D"):
			_failures.append("missing boss texture %s" % png)
		if not FileAccess.file_exists(metadata):
			_failures.append("missing boss metadata %s" % metadata)


func _validate_audio(config: Dictionary) -> void:
	var bgm: Dictionary = config.get("bgm", {})
	_validate_audio_file(str(bgm.get("file", "")), "main BGM")
	var event_bgm: Dictionary = config.get("event_bgm", {})
	for event_id in event_bgm:
		_validate_audio_file(str(event_bgm[event_id].get("file", "")), "event BGM %s" % event_id)
	var events: Dictionary = config.get("sfx_events", {})
	for required_id in ["coin_burst", "huye_coin_burst", "huye_appear", "huye_divine_reveal"]:
		if not events.has(required_id):
			_failures.append("missing audio mapping %s" % required_id)
	for event_id in events:
		_validate_audio_file(str(events[event_id]), "SFX %s" % event_id)


func _validate_audio_file(file_name: String, label: String) -> void:
	var path := "res://Assets/final/audio/" + file_name
	if file_name.is_empty() or not ResourceLoader.exists(path, "AudioStream"):
		_failures.append("missing %s at %s" % [label, path])


func _validate_task_25_routing() -> void:
	var path := "res://Scripts/core/game_controller.gd"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_failures.append("cannot inspect task 25 routing")
		return
	var source := file.get_as_text()
	var huye_start := source.find("func _start_huye_coin_burst()")
	var normal_start := source.find("func _play_monster_death_with_coin_burst()")
	if huye_start < 0 or normal_start < 0:
		_failures.append("coin burst entry points missing")
		return
	var huye_section := source.substr(huye_start, normal_start - huye_start)
	var normal_section := source.substr(normal_start)
	if huye_section.find('audio_service.play_sfx("huye_coin_burst")') < 0:
		_failures.append("Huye burst is not routed to huye_coin_burst")
	if huye_section.find('audio_service.play_sfx("coin_burst")') >= 0:
		_failures.append("Huye burst still routes to generic coin_burst")
	if normal_section.find('audio_service.play_sfx("coin_burst")') < 0:
		_failures.append("monster burst is not routed to coin_burst")
