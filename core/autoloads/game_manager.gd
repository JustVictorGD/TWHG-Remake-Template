extends Node

# Game properties
var paused: bool = false # Toggled in game_manager and pause.gd
var music_enabled: bool = true
var sfx_enabled: bool = true

# Level properties
var max_money: int = 0

# Area properties
const AREA_SIZE: Vector2 = Vector2(32, 20)
var area_bounds: Dictionary = {}

# Player stats
var deaths: int = 0
var money: int = 0
var finished: bool = false

# Special player states
var invincible: bool = false # Death can't trigger
var ghost: bool = false # Ignore walls
var flying: bool = false # Ignore terrains
var speed_hacking: bool = false # Doubles speed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("speed_hack"):
		speed_hacking = not speed_hacking
		print("Speed hack")
		print()
	
	if event.is_action_pressed("invincibility"):
		invincible = not invincible
		print("Invincible")
		print(invincible)
	
	if event.is_action_pressed("ghost"):
		ghost = not ghost
		print("Ghost")
	
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	paused = not paused
	print("Pause")
