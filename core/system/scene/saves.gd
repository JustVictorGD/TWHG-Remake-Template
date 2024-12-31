extends Control
class_name Saves

@onready var square: ColorRect = $Square
@onready var load_save_1: Button = $Save1/LoadSave
@onready var clear_save_1: Button = $Save1/ClearSave
@onready var world_scene: PackedScene = preload("res://game/scenes/world.tscn")

func _ready() -> void:
	load_save_1.button_up.connect(load_save_and_world)
	clear_save_1.button_up.connect(override_save)
	
	var ticks: int = SaveFile.save_dictionary["global"]["ticks"]
	var deaths: int = SaveFile.save_dictionary["global"]["deaths"]
	var level: String = SaveFile.save_dictionary["global"]["level"]
	
	$Save1/Deaths.text = "Deaths: " + str(deaths)
	$Save1/Time.text = "Time: " + format_time(ticks)
	$Save1/Level.text = "Level: " + level




@warning_ignore("integer_division")
static func format_time(total_ticks: int) -> String:
	var hours: int = total_ticks / 216_000
	var minutes: int = total_ticks / 3_600 % 60
	var seconds: int = total_ticks / 60 % 60
	var ticks: int = total_ticks % 60
	return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, ticks]


func _process(delta: float) -> void:
	$Square.rotation_degrees += 180 * delta

func override_save() -> void:
	SaveFile.clear_save()
	load_save_and_world()

func load_save_and_world() -> void:
	SaveFile.load_save()
	get_tree().change_scene_to_packed(world_scene)
