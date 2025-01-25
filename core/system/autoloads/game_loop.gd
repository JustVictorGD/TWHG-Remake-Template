extends Node

signal animation_update
signal wall_update
signal movement_update
signal collision_update
signal update_timers

const TICK_LENGTH: float = 1/60.0
var time: float = 0
var ticks: int = 0

# Stops ticking upon victory.
var game_ticks: int = 0


func _physics_process(delta: float) -> void:
	if GameManager.current_level != "" and not GameManager.paused:
		ticks += 1
		
		if not GameManager.finished:
			game_ticks += 1
		
		push_internal_frame()


func push_internal_frame() -> void:
	animation_update.emit() # Reserved for AnimationPlayer
	wall_update.emit() # Needs to be separate to avoid order of operation conflicts.
	movement_update.emit() # Player's and other objects' movement.
	collision_update.emit() # All the player/object checks are done now.
	update_timers.emit()
