extends Node

var collectables_processed: bool = false

# Game properties
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

func _ready() -> void:
	GlobalSignal.checkpoint_touched.connect(on_checkpoint_touch)

func on_checkpoint_touch(id: int) -> void:
	GlobalSignal.progress_saved.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("speed_hack"):
		speed_hacking = not speed_hacking
	
	if event.is_action_pressed("invincibility"):
		invincible = not invincible
	
	if event.is_action_pressed("ghost"):
		ghost = not ghost
	
	if event.is_action_pressed("pause"):
		paused = not paused
