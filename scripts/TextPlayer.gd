extends Node

var hud = null

func _ready():
	hud = get_parent().get_node("HUD")

func _on_Battery2_area_entered(area):
	hud.show_text("This is a battery.\n It restores 1 HP of yours.")
