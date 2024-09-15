extends Node

const AREA_SIZE: Vector2 = Vector2(32, 20)

<<<<<<< HEAD:core/autoloads/area_manager.gd
var paused: bool = false

=======
var area_bounds: Array[Rect2] = []
>>>>>>> multi-area:core/autoloads/game_manager.gd
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
		AreaManager.speed_hacking = not AreaManager.speed_hacking
		
	
	if Input.is_action_just_pressed("invincibility"):
		AreaManager.invincible = not AreaManager.invincible
	
	if Input.is_action_just_pressed("ghost"):
		AreaManager.ghost = not AreaManager.ghost
	
	if Input.is_action_just_pressed("pause"):
		AreaManager.paused = not AreaManager.paused
