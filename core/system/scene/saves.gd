extends Control
@onready var square: ColorRect = $Square
@onready var load_save_1: Button = $Save1/Button
@onready var world_scene: PackedScene = preload("res://game/scenes/world.tscn")

func _ready() -> void:
	load_save_1.button_up.connect(load_save_and_world)

func _process(delta: float) -> void:
	$Square.rotation_degrees += 180 * delta

func load_save_and_world() -> void:
	get_tree().change_scene_to_packed(world_scene)
