extends Control
@onready var saves_scene: PackedScene = preload("res://game/scenes/saves.tscn")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		SaveFile.view_save()
		get_tree().change_scene_to_packed(saves_scene)
