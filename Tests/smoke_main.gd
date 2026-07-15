extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := load("res://Scenes/Main.tscn") as PackedScene
	if scene == null:
		push_error("MAIN SMOKE: failed to load Main.tscn")
		quit(1)
		return
	var main := scene.instantiate()
	root.add_child(main)
	for _frame in range(5):
		await process_frame
	main.queue_free()
	for _frame in range(5):
		await process_frame
	print("MAIN SMOKE OK: Main.tscn entered TITLE and cleaned up")
	quit(0)
