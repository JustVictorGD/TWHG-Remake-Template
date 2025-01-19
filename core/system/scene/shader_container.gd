extends Control

@onready var win_shader: ColorRect = $Win
@onready var invincibility_shader: ColorRect = $Invincibility
@onready var vignette_shader: ColorRect = $Vignette
@onready var timer: TickBasedTimer = $Win/TickBasedTimer

func _ready() -> void:
	Signals.finish.connect(on_finish)

func _process(delta: float) -> void:
	
	invincibility_shader.visible = true if GameManager.invincible else false
	
	win_shader.visible = true if GameManager.finished else false
	if timer.active:
		win_shader.material.set_shader_parameter("mainAlpha", 0.5 * timer.get_progress_left())
		#print(win_shader.material.get_shader_parameter("mainAlpha"))

func on_finish() -> void:
	timer.reset_and_play()
