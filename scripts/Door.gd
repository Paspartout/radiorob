extends Node2D

class_name Door

func _ready():
	$AnimationPlayer.play("Closed")
	
func open():
	$AnimationPlayer.play("Open")
