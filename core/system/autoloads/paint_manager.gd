@tool
extends Node

@export var error_coating: ColorTuple
@export var coatings: Array[ColorTuple] = []
@export var instant_unlocks: PackedInt32Array = [0]

var coating_progress: PackedInt32Array = []
var current_coating: int = 0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	reset_unlocks()
	
	Signals.save_game.connect(save_game)
	Signals.load_game.connect(load_game)


func save_game() -> void:
	SaveData.data["global"]["coatings"] = coating_progress
	SaveData.data["global"]["current_coating"] = current_coating


func load_game() -> void:
	if SaveData.try_get_data(["global", "coatings"]) is Array:
		coating_progress = SaveData.data["global"]["coatings"]
	else:
		reset_unlocks()
	
	current_coating = Utilities.fallback(
		SaveData.try_get_data(["global", "current_coating"]),
		0)


func reset_unlocks() -> void:
	coating_progress.resize(coatings.size())
	coating_progress.fill(0)
	
	for index: int in instant_unlocks:
		if get_progress(index) != -1:
			coating_progress[index] = 2


func get_coating(index: int) -> ColorTuple:
	if Utilities.index_in_range(index, coatings.size()):
		return coatings[index]
	else:
		return error_coating


func get_progress(index: int) -> int:
	if Utilities.index_in_range(index, coatings.size()):
		return coating_progress[index]
	else:
		return -1
