extends CanvasLayer

class_name HUD

signal text_displayed

onready var health_bar = $TopBar/Stats/HealthBar
onready var rad_bar = $TopBar/Stats/RadBar
onready var scroller = $ScrollingText
onready var anim: AnimationPlayer = $AnimationPlayer
onready var text_timeout: Timer = $TextTimeout

var displaying_text := false

func _ready():
	var player: Player = get_tree().get_nodes_in_group("player")[0]
	player.connect("health_changed", self, "display_health")
	var ticker: GeigerTicker = get_tree().get_nodes_in_group("ticker")[0]
	ticker.connect("rad_changed", self, "display_rad")
	
func display_health(health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = health - (floor(0.1 * max_health) as int)

func display_rad(rad: float):
	rad_bar.value = rad * 100

func _input(event):
	if !displaying_text or anim.is_playing() or scroller.is_playing or !text_timeout.is_stopped():
		return
	print("Process Input")	
	anim.play("Collapse")
	displaying_text = false
	emit_signal("text_displayed")

func show_text(text: String, timeout: float = 1) -> void:
	scroller.set_text(text)
	anim.play("Expand")
	text_timeout.wait_time = timeout
	displaying_text = true

func _on_ScrollingText_scrolling_stopped():
	text_timeout.start()
