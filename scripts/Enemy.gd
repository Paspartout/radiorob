tool
extends KinematicBody2D

signal die

export var health: int = 3
export var speed: float = 64.0 setget set_speed
export var wander_length: float = 100 setget set_wander_length
export var wander: bool = false

enum State { WANDER_LEFT, WANDER_RIGHT, STAY }
var state = State.WANDER_LEFT
var velocity: Vector2 = Vector2.ZERO
export var wander_position: float

onready var anim = $AnimationPlayer

func _ready():
	wander_position = wander_length / 2

func ai_wander(delta):
	match state:
		State.WANDER_LEFT:
			velocity.x = -speed
			if wander_position <= 0:
				state = State.WANDER_RIGHT
		State.WANDER_RIGHT:
			velocity.x = speed
			if wander_position >= wander_length:
				state = State.WANDER_LEFT
		State.STAY:
			velocity.x = 0
	wander_position += velocity.x * delta
	move_and_slide(velocity)

func _physics_process(delta):
	if not Engine.editor_hint or wander:
		ai_wander(delta)

func set_wander_length(new_length):
	wander_length = new_length
	update()

func set_speed(new_speed):
	speed = new_speed
	update()

func _draw():
	if not Engine.editor_hint:
		return
	var thickness := min(8, max(1.0, speed / 32.0))
	draw_line(Vector2(-wander_length/2,0), Vector2(wander_length/2,0), Color.red, thickness)

func hurt():
	health -= 1 # TODO: Could add bullet dependent damage here?
	if health <= 0:
		state = State.STAY
		anim.play("Die")
		emit_signal("die")
	else:
		anim.play("Hurt")

func attack(body: Area2D):
	body.get_parent().hurt()
	
