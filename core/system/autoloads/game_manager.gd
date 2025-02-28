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

var last_checkpoint_id: int = -1:
	set(value):
		last_checkpoint_id = value
		SaveData.data["global"]["last_checkpoint_id"] = value

var last_checkpoint_area: int # Unused... for now.

# Measured in ticks where 1 second equals 60 ticks.
var time: int = 0:
	set(value):
		time = value
		SaveData.data["global"]["time"] = value

# Player stats
var deaths: int = 0:
	set(value):
		deaths = value
		SaveData.data["global"]["deaths"] = value

var current_level: String:
	set(value):
		current_level = value
		SaveData.data["global"]["current_level"] = value

var finished: bool = false

# Special player states
var invincible: bool = false # Death can't trigger
var ghost: bool = false # Ignore walls
var flying: bool = false # Ignore terrains
var speed_hacking: bool = false # Doubles speed


func _ready() -> void:
	Signals.load_game.connect(load_game)


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


func load_game() -> void:
	deaths = Utilities.fallback(
		SaveData.try_get_data(["global", "deaths"]),
		0)
	time = Utilities.fallback(
		SaveData.try_get_data(["global", "time"]),
		0)
	last_checkpoint_id = Utilities.fallback(
		SaveData.try_get_data(["global", "last_checkpoint_id"]),
		-1)
	current_level = Utilities.fallback(
		SaveData.try_get_data(["global", "current_level"]),
		"NULL_LEVEL")
