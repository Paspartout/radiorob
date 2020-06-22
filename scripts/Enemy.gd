extends KinematicBody2D

signal die

export var health: int = 3
export var speed: float = 64.0

enum State { WANDER_LEFT, WANDER_RIGHT, STAY }
var state = State.WANDER_LEFT
var velocity: Vector2 = Vector2.ZERO

onready var anim = $AnimationPlayer

func _ready():
	$Timer.start()

func ai_wander(delta):
	match state:
		State.WANDER_LEFT:
			velocity.x = -speed
		State.WANDER_RIGHT:
			velocity.x = speed
		State.STAY:
			velocity.x = 0	
	move_and_slide(velocity)

func _on_Timer_timeout():
	match state:
		State.WANDER_LEFT:
			state = State.WANDER_RIGHT
		State.WANDER_RIGHT:
			state = State.WANDER_LEFT
		State.STAY:
			pass

func _physics_process(delta):
	ai_wander(delta)

func hurt():
	health -= 1 # TODO: Could add bullet dependent damage here?
	if health <= 0:
		state = State.STAY
		anim.play("Die")
		emit_signal("die")
	else:
		anim.play("Hurt")

func attack(body: Area2D):
	print("Attacking", body)
	body.get_parent().hurt()
	
