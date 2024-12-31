extends Node2D

@onready var flash: ColorRect = $Flash
@onready var flash_timer: TickBasedTimer = $TickBasedTimer


func _ready() -> void:
	GameManager.current_level = "end_screen"
	$Button.pressed.connect(on_button_pressed)
	
	$FinalDeaths.text = str("Final deaths: ", GameManager.deaths)
	$FinalTime.text = "Final time: " + Saves.format_time(GameLoop.game_ticks)
	
	SaveFile.clear_save()


func _process(delta: float) -> void:
	flash.color.a = flash_timer.get_progress_left()


func on_button_pressed() -> void:
	get_tree().change_scene_to_packed(preload("res://game/scenes/menu.tscn"))
