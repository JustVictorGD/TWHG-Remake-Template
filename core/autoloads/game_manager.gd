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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("speed_hack"):
		GameManager.speed_hacking = not GameManager.speed_hacking
		
	
	if Input.is_action_just_pressed("invincibility"):
		GameManager.invincible = not GameManager.invincible
	
	if Input.is_action_just_pressed("ghost"):
		GameManager.ghost = not GameManager.ghost
	
	if Input.is_action_just_pressed("pause"):
		GameManager.paused = not GameManager.paused
