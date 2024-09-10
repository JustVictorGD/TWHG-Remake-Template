extends Node

const AREA_SIZE: Vector2 = Vector2(32, 20)

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

var x: bool = true

func _process(delta: float) -> void:
	if x:
		print("Area bounds: ", area_bounds)
	
	x = false
