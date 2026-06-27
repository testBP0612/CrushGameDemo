class_name AudioService
extends Node


func play_sfx(event_id: String) -> void:
	if event_id.is_empty():
		push_warning("AudioService.play_sfx skipped: empty event_id.")
		return
	# D-008: MVP reserves the interface only. No files are loaded and no sound is played.


func stop_all() -> void:
	# D-008: no-op placeholder for future H5 audio unlock / mixer integration.
	pass

