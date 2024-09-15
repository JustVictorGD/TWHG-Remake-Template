extends Node

const AREA_SIZE: Vector2 = Vector2(32, 20)

var paused: bool = false

var area_bounds: Array[Rect2] = []

var deaths: int = 0
var max_money: int = 0
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
		paused = not paused
		print("Pause")
