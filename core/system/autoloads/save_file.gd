extends Node

var path: String = "user://save.json"

var save_dictionary: Dictionary = {
	"global": {
		"ticks": 0,
		"deaths": 0 ,
		"current_level": "",
	},
	"levels": {
		
	}
}

func _ready() -> void:
	GlobalSignal.progress_saved.connect(save)


func _notification(what: int) -> void:
	if GameManager.current_level != "" and what == NOTIFICATION_WM_CLOSE_REQUEST:
		save()


func save() -> void:
	save_dictionary["global"]["ticks"] = GameLoop.ticks
	save_dictionary["global"]["deaths"] = GameManager.deaths
	save_dictionary["global"]["current_level"] = GameManager.current_level
	
	var json: String = JSON.stringify(save_dictionary)
	
	var file_access: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return
	file_access.store_string(json)


func view_save() -> void:
	if not FileAccess.file_exists(path):
		return
	
	var json: String = FileAccess.get_file_as_string(path)
	save_dictionary = JSON.parse_string(json)

func load_save() -> void:
	GameLoop.ticks = save_dictionary["global"]["ticks"]
	GameManager.deaths = save_dictionary["global"]["deaths"]
	GameManager.current_level = save_dictionary["global"]["current_level"]
