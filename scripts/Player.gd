extends KinematicBody2D

class_name Player

signal health_changed
signal died

# Config
export var ACCELERATION = 512
export var MAX_SPEED = 64
export var FRICTION = 0.4
export var GRAVITY = 200
export var JUMP_FORCE = 128

export var debug_node: NodePath
export (PackedScene) var Bullet: PackedScene

onready var sprite: AnimatedSprite = $Sprite

var debug: Label

var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT
var no_ground_check: bool = false

export var health: int = 5
export var max_health: int = 5

onready var shoot_sound: AudioStreamPlayer = $Shoot
onready var heal_sound: AudioStreamPlayer = $HealSound
	
func _ready():
	call_deferred("set_health", max_health)

func shoot(input_y: float):
	var bullet = Bullet.instance()
	var aim_direction = Vector2(0, input_y) if input_y != 0 else direction
	bullet.position = position + Vector2(10, 10) * aim_direction
	bullet.direction = aim_direction.normalized()
	# TODO: Set bullet rotation here
	get_parent().add_child(bullet)
	shoot_sound.play()

func handle_actions(input_y: float):
	if Input.is_action_just_pressed("shoot"):
		shoot(input_y)


func handle_movement(delta, input_x: float) -> void:
	# Horizontal Movement
	if input_x != 0:
		velocity.x += input_x * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		
		sprite.flip_h = input_x < 0
		direction = Vector2.LEFT if input_x < 0 else Vector2.RIGHT
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)

	# Jumping
	if is_on_floor() or no_ground_check:
		if Input.is_action_just_pressed("jump"):
			velocity.y = -JUMP_FORCE
	else: # in air
		if Input.is_action_just_released("jump") and velocity.y < -JUMP_FORCE/2:
			velocity.y = -JUMP_FORCE/2
		velocity.x = lerp(velocity.x, 0, 0.02)

func _physics_process(delta):	
	var input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var input_y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
	handle_movement(delta, input_x)
	handle_actions(input_y)

	# GRAVITY
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	sprite.playing = input_x != 0

func set_health(new_health: int):
	health = new_health
	print("%d/%d" % [health, max_health])
	emit_signal("health_changed", health, max_health)
	if health <= 0:
		$AnimationPlayer.play("Die")
		emit_signal("died")

func hurt(from_position: Vector2 = Vector2.ZERO):
	var hurt_direction: Vector2 = (position - from_position).normalized()
	velocity = velocity + hurt_direction * 300
	$AnimationPlayer.play("Hurt")
	set_health(health-1)

func heal():
	set_health(min(health + 1, max_health))
	heal_sound.play()
