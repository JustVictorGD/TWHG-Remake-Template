extends Node

# Store whatever persistent data you want inside this dictionary.
# This singleton's primary purpose is to deal with the .json file
var data: Dictionary = {
	"global": {}
}

func _ready() -> void:
	load_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("0"):
		print(data)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print(GameManager.touched_checkpoint_ids.size())
		
		if GameManager.touched_checkpoint_ids.size() != 0:
			print("Saving safely")
			save_game()
		else:
			print("Saving unsafely")
			save_game(0, false)


func save_game(id: int = 0, safe: bool = true) -> void:
	if safe:
		Signals.save_game.emit()
	else:
		Signals.save_unsafely.emit()
	
	var file: FileAccess = FileAccess.open(get_save_path(id), FileAccess.WRITE)
	
	if not is_instance_valid(file):
		print_debug("An error happened while saving data: ", FileAccess.get_open_error())
		return
	
	file.store_string(str(JSON.stringify(data)))


func load_game(id: int = 0) -> void:
	var file: String = FileAccess.get_file_as_string(get_save_path(id))
	
	if JSON.parse_string(file):
		data = JSON.parse_string(file)
	
	Signals.load_game.emit()


func wipe_save(id: int = 0) -> void:
	Signals.wipe_save.emit()
	
	data = {"global": {}}
	
	var file: FileAccess = FileAccess.open(get_save_path(id), FileAccess.WRITE)
	
	if not is_instance_valid(file):
		print("An error happened while wiping data: ", FileAccess.get_open_error())
		return
	
	file.store_string("{\"global\": {}}")


func get_save_path(id: int) -> String:
	return str("user://save_", id, ".json")


func try_get_data(path: Array) -> Variant:
	if path.is_empty():
		return null
	
	var target: Variant = data
	
	for i: int in path.size():
		var key: Variant = path[i]
		if not is_key_valid(key):
			return null
		
		if target is Dictionary:
			if key not in target:
				return null
			target = target[key]
		
		elif target is Array:
			if key is int and -target.size() <= key < target.size():
				target = target[key]
			else:
				return null
		
		else:
			return null
	
	return target


func is_key_valid(key: Variant) -> bool:
	return key is int or key is String
