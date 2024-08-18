extends Node

signal animation_update
signal wall_update
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
	animation_update.emit() # Reserved for AnimationPlayer
	wall_update.emit() # Needs to be separate to avoid order of operation conflicts.
	movement_update.emit() # Player's and other objects' movement.
	collision_update.emit() # All the player/object checks are done now.
	update_timers.emit()
