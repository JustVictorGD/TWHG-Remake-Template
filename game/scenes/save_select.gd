extends Node2D


func _ready() -> void:
	for i: int in [1, 2, 3]:
		if FileAccess.file_exists(str("user://save_", i, ".json")):
			SaveData.current_save = i
			SaveData.load_game()
			
			var save: Node = get_node("SaveBlock" + str(i))
			if save is SaveBlock:
				save.update(true, false)
				
				save.stage.text = "Stage: " + Utilities.fallback(
					SaveData.try_get_data(["global", "current_level"]),
					"???")
				save.deaths.text = "Deaths: " + str(Utilities.fallback(
					int(SaveData.try_get_data(["global", "deaths"])),
					0))
				save.time.text = "Time: " + Interface.format_time(Utilities.fallback(
					SaveData.try_get_data(["global", "time"]),
					0
				))


func load_game(save_id: int) -> void:
	SaveData.current_save = save_id
	SaveData.load_game()
	GameManager.paused = false
	get_tree().change_scene_to_packed(preload("res://game/scenes/level_select.tscn"))


func _on_save_1_pressed() -> void:
	load_game(1)

func _on_save_2_pressed() -> void:
	load_game(2)

func _on_save_3_pressed() -> void:
	load_game(3)


func _on_reset_1_pressed() -> void:
	$SaveBlock1.update(false, true)
	SaveData.wipe_save(1)

func _on_reset_2_pressed() -> void:
	$SaveBlock2.update(false, true)
	SaveData.wipe_save(2)

func _on_reset_3_pressed() -> void:
	$SaveBlock3.update(false, true)
	SaveData.wipe_save(3)


func _on_exit_pressed() -> void:
	get_tree().quit()
