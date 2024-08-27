extends AnimationPlayer
class_name TickBasedAnimator

func _ready() -> void:
	GameLoop.animation_update.connect(animation_update)
	callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL

func animation_update() -> void:
	advance(GameLoop.TICK_LENGTH)
	pass
