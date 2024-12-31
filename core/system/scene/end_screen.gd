extends Node2D

@onready var flash: ColorRect = $Flash
@onready var flash_timer: TickBasedTimer = $TickBasedTimer


func _ready() -> void:
	GameManager.current_level = "end_screen"
	$Button.pressed.connect(on_button_pressed)


func _process(delta: float) -> void:
	print($Button.is_connected("pressed", on_button_pressed))
	
	flash.color.a = flash_timer.get_progress_left()


func on_button_pressed() -> void:
	print("pressing the button")
	get_tree().change_scene_to_packed(preload("res://game/scenes/menu.tscn"))
