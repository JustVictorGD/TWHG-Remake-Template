extends Node2D


func _on_back_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://game/scenes/save_select.tscn"))
