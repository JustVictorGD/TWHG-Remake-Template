@tool
extends Control
class_name Teleporter

@export var teleportation_type: Types = Types.POSITION
@export var target_position: Vector2
@export var target_level: String

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


enum Types { POSITION, LEVEL }


func _ready() -> void:
	sync_collision()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		sync_collision()


func sync_collision() -> void:
	collision_shape_2d.shape.size = size
	collision_shape_2d.position = size / 2
