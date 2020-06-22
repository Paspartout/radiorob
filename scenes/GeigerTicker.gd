extends Node

class_name GeigerTicker

onready var tick: AudioStreamPlayer = $AudioStreamPlayer
export(float) var rad: float = 0.1

var player: Player
var reactor: Reactor
var i: int = 0
var disabled: bool = false

signal rad_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	reactor = get_parent().get_node("Reactor")

func disable():
	rad = 0.05
	disabled = true
	emit_signal("rad_changed", rad)

func _process(delta):
	i += 1
	if i > 10 and not disabled:
		var dist = player.position.distance_to(reactor.position)
		rad = min((1 - (dist / 1300)) - 0.2, 1.0)
		emit_signal("rad_changed", rad)
		i = 0
	if rand_range(0, 1) > 1 - rad:
		tick.play()
