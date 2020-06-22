extends Control

signal scrolling_stopped

onready var text_label: Label = $Label
onready var timer: Timer = $Timer
onready var tick_player: AudioStreamPlayer = $TickPlayer
export(int) var speed: int = 15
var is_playing: bool = false

func _ready():
	text_label.percent_visible = 0.0
	timer.wait_time = 1.0/speed

func set_text(text: String):
	text_label.percent_visible = 0.0
	text_label.text = text

func start():
	is_playing = true
	timer.start()

func _on_Timer_timeout():
	text_label.visible_characters += 1
	if text_label.percent_visible >= 1.0:
		timer.stop()
		is_playing = false
		emit_signal("scrolling_stopped")
	tick_player.play()
