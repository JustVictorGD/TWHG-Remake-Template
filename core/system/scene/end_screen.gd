extends Node2D

@onready var flash: ColorRect = $Flash
@onready var flash_timer: TickBasedTimer = $TickBasedTimer


func _process(delta: float) -> void:
	flash.color.a = flash_timer.get_progress_left()


func _on_button_pressed() -> void:
	print("pressing the button")
	get_tree().change_scene_to_packed(preload("res://game/scenes/menu.tscn"))
