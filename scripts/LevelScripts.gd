extends Node

var hud: HUD
var doors: Node2D
var elevator_anim: AnimationPlayer
var reactor_anim: AnimationPlayer
var player: Player

onready var success_sound: AudioStreamPlayer = $Success
onready var timer: Timer = $Timer
var ticker: GeigerTicker
	
func _ready():
	hud = get_parent().get_parent().get_node("HUD")
	doors = get_parent().get_node("Doors")
	elevator_anim = get_parent().get_node("Elevator").get_node("AnimationPlayer")
	timer.one_shot = true
	player = get_tree().get_nodes_in_group("player")[0]
	reactor_anim = get_tree().get_nodes_in_group("ranim")[0]
	ticker = get_tree().get_nodes_in_group("ticker")[0]
	
	init_room2()
	init_room3()
	init_reactor()

func open_door(door :String):
	timer.connect("timeout", self, "_open_door", [door])
	timer.start()

func _open_door(door: String):
	doors.get_node(door).open()
	success_sound.play()
	timer.disconnect("timeout", self, "_open_door")


func jump_help():
	hud.show_text("We equipped you with springs.\nPress C to jump.")

# =============================================================================
# Room1
# Kill one robot
# =============================================================================

func combat_help():
	hud.connect("text_displayed", self, "combat_open")
	hud.show_text("The security bots went hostile.\nPress X to shoot.")

func combat_open():
	doors.get_node("CombatDoor1").open()
	hud.disconnect("text_displayed", self, "combat_open")

func first_robot_died():
	open_door("CombatDoor2")

# =============================================================================
# Room2
# Kill 3 robots and collect battery
# =============================================================================

var n_room2_bots : int
var has_battery = false

func init_room2():
	var room2_bots = get_tree().get_nodes_in_group("room2")
	for bot in room2_bots:
		bot.connect("die", self, "room2_robot_dead")
	n_room2_bots = room2_bots.size()

func room2_robot_dead():
	n_room2_bots -= 1
	check_room2()

func battery_collected():
	has_battery = true
	check_room2()
	
func check_room2():
	if has_battery and n_room2_bots <= 0:
		hud.show_text("Good Job!\nBatteries will heal you.")
		hud.connect("text_displayed", self, "room2_text2")

func room2_text2():
	hud.disconnect("text_displayed", self, "room2_text2")
	hud.connect("text_displayed", self, "room2_exit")
	hud.show_text("The next room contains some\nexperimental combat drones.")

func room2_exit():
	hud.disconnect("text_displayed", self, "room2_exit")
	open_door("ItemDoor")

# =============================================================================
# Room3
# Kill 5 flying bots
# =============================================================================

var n_room3_bots : int

func init_room3():
	var room3_bots = get_tree().get_nodes_in_group("room3")
	for bot in room3_bots:
		bot.connect("die", self, "room3_robot_dead")
	n_room3_bots = room3_bots.size()

func room3_robot_dead():
	n_room3_bots -= 1
	check_room3()
	
func check_room3():
	if n_room3_bots <= 0:
		open_door("FlybotDoor")
	
# =============================================================================
# Elevator Room 4
# Survive Elevator
# =============================================================================

func elevator_trigger():
	hud.show_text("Hey glad you're alive.\nI'll call the elevator.")
	hud.connect("text_displayed", self, "battery_hint")
	elevator_anim.play("GoUp")

func battery_hint():
	hud.disconnect("text_displayed", self, "battery_hint")
	hud.show_text("Oh, there should be a battery\nin the office upstairs.")

func elevator_arrived():
	open_door("ElevatorDoorUp")

func elevator_arrived_down():
	hud.show_text("Ok we are almost there.")

func elevator_start():
	elevator_anim.play("GoDown")

# =============================================================================
# Control Room
# =============================================================================

var n_reactor_bots

func init_reactor():
	var reactor_bots = get_tree().get_nodes_in_group("fr")
	for bot in reactor_bots:
		bot.connect("die", self, "fr_robot_dead")
	n_reactor_bots = reactor_bots.size()

func fr_robot_dead():
	n_reactor_bots -= 1
	print(n_reactor_bots, " left")
	check_fr()

func check_fr():
	if n_reactor_bots <= 0:
		open_door("ControlRoomDoor")

func reactor_room_trigger():
	hud.show_text("Ok, this is the reactor room.\nFight all the bots.")
	hud.connect("text_displayed", self, "open_reactor_door")

func open_reactor_door():
	hud.disconnect("text_displayed", self, "open_reactor_door")
	open_door("ReactorDoor")

func reactor_shutdown():
	hud.show_text("Good job!\nLet's shutdown the reactor!")
	hud.connect("text_displayed", self, "play_reactot_anim")

func play_reactot_anim():
	hud.disconnect("text_displayed", self, "play_reactot_anim")
	reactor_anim.play("GoDown")

func thanks():
	ticker.disable()
	hud.show_text("Thanks for playing!\nYou can quit the game now.")

func _on_Player_died():
	hud.show_text("Ouch. Please try again\nNo time for checkpoints :/")
	hud.connect("text_displayed", self, "restart")

func restart():
	get_tree().reload_current_scene()
