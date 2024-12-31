extends Node

signal save_loaded

var path: String = "user://save.json"

var default_save: Dictionary = {
	"global": {
		"ticks": 0,
		"game_ticks": 0,
		"deaths": 0 ,
		"level": "",
		"color": -1,
	},
	"levels": {
		"1": {
			"checkpoint_id": -1,
			"coins": [],
			"extra_coins": 0,
			"keys": [],
			"paints": [],
		}
	}
}

var save_dictionary: Dictionary = default_save.duplicate(true)

func _ready() -> void:
	GlobalSignal.progress_saved.connect(save)
	GlobalSignal.checkpoint_touched.connect(update_cp_and_collectables)


func _notification(what: int) -> void:
	if GameManager.current_level != "" and what == NOTIFICATION_WM_CLOSE_REQUEST:
		save()


func update_cp_and_collectables(cp_id: int) -> void:
	var current_level: String = save_dictionary["global"]["level"]
	save_dictionary["levels"][current_level]["checkpoint_id"] = cp_id
	print(save_dictionary)


func add_level_to_dict(level: String) -> void:
	if level not in save_dictionary["levels"]:
		save_dictionary["levels"][level] = {
			"checkpoint_id": -1,
			"coins": [],
			"extra_coins": 0,
			"keys": [],
			"paints": [],
		}
		pass


func store_save() -> void:
	var json: String = JSON.stringify(save_dictionary)
	
	var file_access: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return
	file_access.store_string(json)


func save() -> void:
	save_dictionary["global"]["ticks"] = GameLoop.ticks
	save_dictionary["global"]["game_ticks"] = GameLoop.game_ticks
	save_dictionary["global"]["deaths"] = GameManager.deaths
	save_dictionary["global"]["level"] = GameManager.current_level
	
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player != null:
		save_dictionary["global"]["color"] = player.paint_id
	
	store_save()


func clear_save() -> void:
	save_dictionary = default_save
	store_save()

func view_save() -> void:
	if not FileAccess.file_exists(path):
		return
	
	var json: String = FileAccess.get_file_as_string(path)
	save_dictionary = JSON.parse_string(json)

func load_save() -> void:
	GameLoop.ticks = save_dictionary["global"]["ticks"]
	GameLoop.game_ticks = save_dictionary["global"]["game_ticks"]
	GameManager.deaths = save_dictionary["global"]["deaths"]
	GameManager.current_level = save_dictionary["global"]["level"]
	save_loaded.emit()
