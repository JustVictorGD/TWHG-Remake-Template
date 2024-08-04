extends Node2D

@export var lock_scale : bool = true

var id: int

func _ready() -> void:
	GameLoop.movement_update.connect(movement_update)
	# This is how collision works here!
	id = Collider.register_enemy_id()

func movement_update() -> void:
	Collider.enemies[id] = round(NiceFunctions.global_to_normal_position(self.global_position))
	
	if lock_scale:
		global_scale.x = Collider.GAMEPLAY_SCALE
		global_scale.y = Collider.GAMEPLAY_SCALE
