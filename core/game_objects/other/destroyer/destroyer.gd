class_name Destroyer
extends Node2D

@export var groups_to_check: Array[String] = ["enemies"]
@onready var collider: RectangleCollider = $RectangleCollider

func _ready() -> void:
	collider.groups_to_check = groups_to_check
	collider.collision_entered.connect(on_collision_entered)
	

func _process(delta: float) -> void:
	collider.scale = 48 * scale

func on_collision_entered(node: Node) -> void:
	node.queue_free()
