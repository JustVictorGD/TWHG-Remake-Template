extends Node

var data: Dictionary = {}


func get_group(key: String) -> int:
	if key not in data.keys():
		data[key] = -1
	
	data[key] += 1
	return data[key]
