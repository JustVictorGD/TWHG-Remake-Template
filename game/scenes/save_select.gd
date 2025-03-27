extends Node2D

func load_game(save_id: int) -> void:
	SaveData.current_save = save_id
	GameManager.paused = false
	get_tree().change_scene_to_packed(preload("res://game/scenes/world.tscn"))


func _on_save_1_pressed() -> void:
	load_game(1)

func _on_save_2_pressed() -> void:
	load_game(2)

func _on_save_3_pressed() -> void:
	load_game(3)


func _on_reset_1_pressed() -> void:
	SaveData.wipe_save(1)

func _on_reset_2_pressed() -> void:
	SaveData.wipe_save(2)

func _on_reset_3_pressed() -> void:
	SaveData.wipe_save(3)


func _on_exit_pressed() -> void:
	get_tree().quit()
