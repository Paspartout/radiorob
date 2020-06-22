extends Area2D

class_name Blast

export var SPEED = 100

var direction: Vector2 = Vector2.RIGHT

func _enter_tree():
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * SPEED * delta

func hit_something(body: Node):
	var target
	if body is Area2D and body.name == "HitBox":
		target = body.get_parent()
	else:
		target = body
	if target.is_in_group("living"):
		target.hurt()
	queue_free()
