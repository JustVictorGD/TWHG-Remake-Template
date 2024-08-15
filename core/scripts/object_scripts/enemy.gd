extends Node2D

@export var lock_scale : bool = true

var radius: float = 7
var id: int

func _ready() -> void:
	GameLoop.movement_update.connect(movement_update)
	# This is how collision works here!
	id = Collider.register_enemy_id(self)

func movement_update() -> void:
	if lock_scale:
		global_scale = Vector2(1, 1)
