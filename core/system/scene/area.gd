@icon("res://core/misc_assets/images/node_icons/area.png")
extends Node2D
class_name Area

## Examples: "1-1", "5-X", "3-9", "2-S", "???". Will be displayed
## in the top left corner as "Level: {level_code}."
@export var level_code: String = "0-1"

## Used as the level's unique identificator. Example:
## "final_boss_phase_1". Check out res://game/connections.json,
## it uses code names as shortcuts to scene file paths.
@export var code_name: String = ""

## Just an extra comment in the bottom middle part of the screen.
@export var bottom_text: String = ""

## (Should) affect the colors of pretty much everything.
@export var theme: AreaTheme

## Used to make the camera focus properly.
@export var area_size: Vector2i = Vector2(32, 20)

## Change for small player or fat player gameplay.
@export var player_size: Vector2i = Vector2i(42, 42)

var last_checkpoint_id: int

## Used by 'persistent_data' to skip subsequent searches after a successful one.
var data_is_valid: bool = false

var persistent_data: Dictionary:
	get:
		if data_is_valid: return persistent_data
		
		if SaveData.try_get_data(["areas", code_name]) is Dictionary:
			data_is_valid = true
		elif SaveData.try_get_data(["areas"]) is Dictionary:
			SaveData.data["areas"][code_name] = {}
		else:
			SaveData.data["areas"] = {}
			SaveData.data["areas"][code_name] = {}
		
		data_is_valid = true
		persistent_data = SaveData.data["areas"][code_name]
		return persistent_data


func _ready() -> void:
	Signals.save_game.connect(save_game)
	
	last_checkpoint_id = get_last_checkpoint_id()


func save_game() -> void:
	persistent_data["last_checkpoint_id"] = last_checkpoint_id


func get_last_checkpoint_id() -> int:
	if "last_checkpoint_id" not in persistent_data:
		persistent_data["last_checkpoint_id"] = -1
	
	return persistent_data["last_checkpoint_id"]


func erase_data() -> void:
	SaveData.data["areas"].erase(code_name)
