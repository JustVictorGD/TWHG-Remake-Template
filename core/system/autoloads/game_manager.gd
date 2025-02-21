extends Node

# Game loop signals
signal animation_update
signal wall_update
signal movement_update
signal collision_update
signal update_timers

var collectables_processed: bool = false

# Game properties
var allow_cheats: bool = true
var paused: bool = false
var snappy_movement: bool = false
var sliding_sensitivity: float = 0.5

# Player stats
var deaths: int = 0
var finished: bool = false
var current_level: String

# Special player states
var invincible: bool = false # Death can't trigger
var ghost: bool = false # Ignore walls
var flying: bool = false # Ignore terrains
var speed_hacking: bool = false # Doubles speed

# Measured in ticks where 1 second equals 60 ticks.
var time: int = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = not paused
	
	if allow_cheats:
		if event.is_action_pressed("speed_hack"):
			speed_hacking = not speed_hacking
		
		if event.is_action_pressed("invincibility"):
			invincible = not invincible
		
		if event.is_action_pressed("ghost"):
			ghost = not ghost


func _physics_process(delta: float) -> void:
	if GameManager.current_level != "" and not GameManager.paused:
		if not GameManager.finished:
			time += 1
		push_internal_frame()


func push_internal_frame() -> void:
	animation_update.emit() # Reserved for AnimationPlayer
	wall_update.emit() # Needs to be separate to avoid order of operation conflicts.
	movement_update.emit() # Player's and other objects' movement.
	collision_update.emit() # All the player/object checks are done now.
	update_timers.emit()


func reset_stats() -> void:
	invincible = false
	ghost = false
	flying = false
	speed_hacking = false
	
	paused = false
	finished = false
	
	deaths = 0
	time = 0
