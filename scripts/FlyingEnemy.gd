extends KinematicBody2D

export(int) var health: int = 3
export(float) var speed: float = 64.0
export(bool) var vertical = false
export(float) var shoot_delay: float = 1
export(float) var wander_time: float = 1
export(bool) var shoot_through_walls = false

signal die

enum State { IDLE, WANDER_LEFT_UP, WANDER_RIGHT_DOWN, STAY }
var state = State.WANDER_LEFT_UP
var velocity: Vector2 = Vector2.ZERO

onready var shoot_sound: AudioStreamPlayer = $ShootSound
onready var hurt_sound: AudioStreamPlayer = $HurtSound
onready var anim = $AnimationPlayer
var i: float = 0.0

export (PackedScene) var Bullet: PackedScene

var player: Node2D

func _ready():
	var rand_offset = rand_range(-0.2, 0.7)
	$ShootTimer.wait_time = shoot_delay + rand_offset
	$WanderTimer.wait_time = wander_time
	$WanderTimer.start()
	player = get_tree().get_nodes_in_group("player")[0]

func shoot_at_player():
	var direction = (player.position - position).normalized()
	var angle = direction.angle()
	var rand_offset = rand_range(-0.2, 0.2)
	direction = Vector2(cos(angle+rand_offset), sin(angle+rand_offset))
	var bullet: Area2D = Bullet.instance()
	bullet.set_collision_mask_bit(4, true)
	bullet.set_collision_mask_bit(2, false)
	bullet.set_collision_mask_bit(0, !shoot_through_walls)
	bullet.direction = direction
	bullet.position = position + Vector2(10, 10) * direction
	var bullet_sprite: Sprite = bullet.get_child(0)
	get_parent().add_child(bullet)
	shoot_sound.play()

func _on_Timer_timeout():
	match state:
		State.IDLE:
			state = State.WANDER_RIGHT
		State.WANDER_LEFT_UP:
			state = State.WANDER_RIGHT_DOWN
		State.WANDER_RIGHT_DOWN:
			state = State.WANDER_LEFT_UP

func ai_wander(delta):
	match state:
		State.WANDER_LEFT_UP:
			if vertical: 
				velocity.y = -speed
			else:
				velocity.x = -speed
		State.WANDER_RIGHT_DOWN:
			if vertical: 
				velocity.y = speed
			else:
				velocity.x = speed
		State.STAY:
			velocity.y = 0
	i+= 0.1
	if vertical: 	
		velocity.x = sin(i) * 8
	else:
		velocity.y = sin(i) * 8
	move_and_slide(velocity)

func _physics_process(delta):
	ai_wander(delta)

func hurt():
	if health <= 0:
		return
	health -= 1
	if health <= 0:
		state = State.STAY
		anim.play("Die")
		emit_signal("die")
		$ShootTimer.stop()
	else:
		hurt_sound.play()
		anim.play("Hurt")

func player_detected(_body):
	$ShootTimer.start()

func player_lost(_body):
	$ShootTimer.stop()

func _on_ShootTimer_timeout():
	shoot_at_player()


