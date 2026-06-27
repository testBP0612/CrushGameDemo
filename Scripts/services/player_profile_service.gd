class_name PlayerProfileService
extends RefCounted


func get_profile() -> Dictionary:
	return {
		"player_id": "local_mock",
		"display_name": Data.text("profile_mock_display_name"),
		"avatar": "placeholder"
	}
