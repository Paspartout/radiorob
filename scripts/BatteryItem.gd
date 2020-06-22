extends Area2D

signal collected

onready var sound: AudioStreamPlayer

func _ready():
	pass

func collected(hitbox: Area2D):
	var player: Player = hitbox.get_parent()
	player.heal()
	queue_free()
	emit_signal("collected")
