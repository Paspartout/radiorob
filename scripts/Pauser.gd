extends Node

func _process(delta):
	# TODO: Disable in release
	if Input.is_action_just_pressed("debug_pause"):
		get_tree().paused = !get_tree().paused
	if Input.is_action_just_pressed("debug_restart"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
