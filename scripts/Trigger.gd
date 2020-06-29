extends Area2D

signal triggered

func _ready():
	connect("area_entered", self, "_trigger")
	
func _trigger(body):
	emit_signal("triggered")
	queue_free()
	
