extends Node


const DEFAULT_DATA: String = "{\"global\": {}}"

# Store whatever persistent data you want inside this dictionary.
# This singleton's primary purpose is to deal with the .json file
var data: Dictionary = {
	"global": {}
}

var current_save: int = -1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("0"):
		print(data)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		exit()


func exit() -> void:
	if GameManager.touched_checkpoint_ids.size() != 0:
		print("Saving safely :D")
		save_game()
	else:
		print("Saving unsafely >:(")
		Signals.player_respawn.emit() # Making all collectables drop.
		save_game(false)


func save_game(safe: bool = true) -> void:
	if safe:
		Signals.save_game.emit()
	else:
		Signals.save_unsafely.emit()
	
	var file: FileAccess = FileAccess.open(get_save_path(), FileAccess.WRITE)
	
	if not is_instance_valid(file):
		print_debug("An error happened while saving data: ", FileAccess.get_open_error())
		return
	
	file.store_string(str(JSON.stringify(data)))


func load_game() -> void:
	var file: String = FileAccess.get_file_as_string(get_save_path())
	
	if file.is_empty():
		data = JSON.parse_string(DEFAULT_DATA)
	elif JSON.parse_string(file):
		data = JSON.parse_string(file)
	
	Signals.load_game.emit()


func wipe_save(id: int = -1) -> void:
	if id == -1: id = current_save
	
	Signals.wipe_save.emit()
	
	data = {"global": {}}
	
	DirAccess.remove_absolute(get_save_path(id))


func get_save_path(id: int = -1) -> String:
	return str("user://save_", current_save if id == -1 else id, ".json")


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
