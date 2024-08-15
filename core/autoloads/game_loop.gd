extends Node

signal animation_update
signal movement_update
signal collision_update
signal update_timers

const TICK_LENGTH : float = 1/240.0
var time : float = 0
var ticks : int = 0

func _process(delta: float) -> void:
	time += delta
	
	while time > TICK_LENGTH:
		time -= TICK_LENGTH
		ticks += 1
		
		push_internal_frame()

func push_internal_frame() -> void:
	animation_update.emit() # Non-player object movement with AnimationPlayer
	movement_update.emit() # Player movement and enemy position update
	collision_update.emit()
	update_timers.emit()
