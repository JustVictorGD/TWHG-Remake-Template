extends AnimationPlayer
class_name TickBasedAnimator

@export var start_time: int = 0
## Determines how many seconds the animation advances per minute.
## Change this value and use 1 second as 1 beat for music sync.
@export var bpm: float = 60
# For some reason advance() doesn't work inside the _ready()
# function so I'm doing a one-time event myself.
var started: bool = false

func _ready() -> void:
	GameManager.animation_update.connect(animation_update)
	callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL

func animation_update() -> void:
	if not started:
		advance(1.0 / Engine.physics_ticks_per_second * start_time)
		started = true
	
	advance(1.0 / Engine.physics_ticks_per_second * (bpm / 60))
	pass
