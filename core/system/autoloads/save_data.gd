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
		save_game()


func save_game(id: int = 0) -> void:
	Signals.save_game.emit()
	
	var file: FileAccess = FileAccess.open(get_save_path(id), FileAccess.WRITE)
	
	if not is_instance_valid(file):
		print_debug("An error happened while saving data: ", FileAccess.get_open_error())
		return
	
	file.store_string(str(JSON.stringify(data)))


func load_game(id: int = 0) -> void:
	var file: String = FileAccess.get_file_as_string(get_save_path(id))
	
	if not is_instance_valid(file):
		wipe_save(id)
		save_game(id)
	
	if JSON.parse_string(file):
		data = JSON.parse_string(file)
	
	Signals.load_game.emit()


func wipe_save(id: int = 0) -> void:
	Signals.wipe_save.emit()
	
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
	var tries: int = 0
	
	for key: Variant in path:
		if not is_key_valid(key): return null
		if target is not Array and target is not Dictionary: return null
		
		tries += 1
		var last_element: bool = (tries == path.size())
		
		if target is Dictionary:
			if key not in target.keys(): return null
			
			if not last_element:
				target = target[key]
			else:
				return target[key]
		
		else: # 'target' is an array
			if key is not int: return null
			
			if key >= 0 and key + 1 > target.size(): return null
			if key < 0 and abs(key) > target.size(): return null
			
			if not last_element:
				target = target[key]
			else:
				return target[key]
	
	return null


func is_key_valid(key: Variant) -> bool:
	return key is int or key is String
