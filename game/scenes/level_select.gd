extends Node2D

@export var starting_level: String = "showcase_1"


func _ready() -> void:
	SaveData.load_game()
	
	if "visited_levels" not in SaveData.data["global"]:
		SaveData.data["global"]["visited_levels"] = [starting_level]
	
	for button: Node in $LevelButtons.get_children():
		if button is LevelButton:
			if button.level_code not in SaveData.data["global"]["visited_levels"]:
				button.toggle(false)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://game/scenes/save_select.tscn"))
