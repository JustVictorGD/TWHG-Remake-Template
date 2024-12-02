extends Node2D

@export var event_id: int

@onready var collider: RectangleCollider = $RectangleCollider

func _ready() -> void:
	collider.collided.connect(collided)

func collided(node: Node) -> void:
	print($RectangleCollider.global_position, node.global_position)
